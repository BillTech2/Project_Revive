/*********************************************************************************************************
Class Name      : OSF_LoyaltyProgramMember_TriggerHandler
Description     : Class to handle LoyaltyProgramMember trigger functionality
Developer       : Vasile Paraschiv
Date            : 
Version         : 1.0
*********************************************************************************************************
History
*********************************************************************************************************
Date            Developer           Version      Description
*********************************************************************************************************/
public with sharing class OSF_LoyaltyProgramMember_TriggerHandler {
    public static void createHistoryRecord(List<LoyaltyProgramMember> newList, Map<Id, LoyaltyProgramMember> oldMap) {
        if (!OSF_Utility.isActive('OSF_LoyaltyProgramMember_TriggerHandler', 'createHistoryRecord') && !Test.isRunningTest()) {
            return;
        }
        List<Membership_Status_History__c> lstLPMHistory = new List<Membership_Status_History__c>();
        try {
            for(LoyaltyProgramMember lpm : newList) {
                if ((oldMap != null && (oldMap.containsKey(lpm.Id) && oldMap.get(lpm.Id).MemberStatus != lpm.MemberStatus)) || oldMap == null || !oldMap.containsKey(lpm.Id) ) {
                    Membership_Status_History__c lpmHistory = new Membership_Status_History__c();
                    lpmHistory.ToStatus__c = lpm.MemberStatus;
                    if (oldMap != null && oldMap.containsKey(lpm.Id)) {
                        lpmHistory.FromStatus__c = oldMap.get(lpm.Id).MemberStatus;
                    }
                    lpmHistory.Loyalty_Program_Member__c = lpm.Id;
                    lstLPMHistory.add(lpmHistory);
                }
            }
            if (lstLPMHistory.size() > 0) {
                insert lstLPMHistory;
            }
        } catch(Exception e) {
            system.debug('ex'+e);
            OSF_ErrorLogHandler.logError(e, 'OSF_LoyaltyProgramMember_TriggerHandler');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
    }
    
    public static void createTransactionJournal(List<LoyaltyProgramMember> newList, Map<Id, LoyaltyProgramMember> oldMap){
        try{
            JournalSubType aJournalSubType;
            if(!Test.isRunningTest()){
                aJournalSubType = [Select Id,Name,JournalTypeId From JournalSubType Where Name = 'Rejoin Club Eurostar' LIMIT 1]; 
            }else{
                aJournalSubType = [Select Id,Name,JournalTypeId From JournalSubType LIMIT 1];
            }
            
            List<TransactionJournal> transactionJournalList = new List<TransactionJournal>();
            for(LoyaltyProgramMember aLoyaltyProgramMember : newList){
                if(aLoyaltyProgramMember.Memberstatus == 'Active' && oldMap.get(aLoyaltyProgramMember.Id).Memberstatus == 'Inactive'){
                    TransactionJournal aTransactionJournal = new TransactionJournal();
                    aTransactionJournal.JournalTypeId = aJournalSubType.JournalTypeId;
                    aTransactionJournal.JournalSubTypeId = aJournalSubType.Id;
                    aTransactionJournal.JournalDate = System.now();
                    aTransactionJournal.Status = 'Pending';
                    aTransactionJournal.ActivityDate = System.now();
                    aTransactionJournal.MemberId = aLoyaltyProgramMember.Id;
                    transactionJournalList.add(aTransactionJournal);
                }  
            }
            insert transactionJournalList;
        }catch(Exception e) {
            system.debug('ex'+e);
            OSF_ErrorLogHandler.logError(e, 'OSF_LoyaltyProgramMember_TriggerHandler');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
        
    }
}