public without sharing class OSF_Compensation_TriggerHandler {
    private static String JOURNAL_TYPE_NAME = Test.isRunningTest() ? 'AccrualTest' : 'Accrual';

    public static void createTransactionJournals(List<Compensation__c> newList, Map<Id, Compensation__c> oldMap) {
        if (!OSF_Utility.isActive('OSF_Compensation_TriggerHandler', 'createTransactionJournals') && !Test.isRunningTest()) {
            return;
        }
        List<TransactionJournal> lstTransactionJournals = new List<TransactionJournal>();
        Map<String, Compensation__c> mapMembershipNumbersToCompensations = new Map<String, Compensation__c>();
        System.Debug('### in createTransactionJournals');
        try {
            for (Compensation__c c : newList) {
                system.debug('line:13');
            if (((!String.isBlank(c.Compensation_Type__c) && c.Compensation_Type__c.toLowerCase() == 'points') || (!String.isBlank(c.Claimed_Compensation_Type__c) && c.Claimed_Compensation_Type__c.toLowerCase() == 'points' && (!String.isBlank(c.Compensation_Type__c) && c.Compensation_Type__c.toLowerCase() == 'online'))) && c.Claim_Status__c == 'Claimed' && (oldMap==null || (oldMap!=null && oldMap.get(c.Id).Claim_Status__c != 'Claimed'))) {
                    mapMembershipNumbersToCompensations.put(c.Membership_Number__c, c);
                }
            }
            system.debug('line:18'+mapMembershipNumbersToCompensations);
            if (mapMembershipNumbersToCompensations.size() > 0) {
                	system.debug('line:20');
                	JournalType jt = [SELECT Id FROM JournalType WHERE Name =: JOURNAL_TYPE_NAME];
                    system.debug('line:22'+jt);
                    JournalSubType jst = [SELECT Id FROM JournalSubType WHERE Name = 'Compensation'];
                     system.debug('line:25'+jst);
                        System.Debug('### mapMembershipNumbersToCompensations: ' + mapMembershipNumbersToCompensations);
                    for (LoyaltyProgramMember lpm :[SELECT Id, MembershipNumber, ProgramId FROM LoyaltyProgramMember WHERE MembershipNumber IN :mapMembershipNumbersToCompensations.keySet()]) {
                        System.debug('### in for');
                        TransactionJournal tj = new TransactionJournal();
                        tj.MemberId = lpm.Id;
                        tj.LoyaltyProgramId = lpm.ProgramId;
                        tj.ActivityDate = System.today();
                        tj.Status = 'Pending';
                        tj.JournalTypeId = jt.Id;
                        tj.JournalSubTypeId = jst.Id;
                        tj.Case__c = mapMembershipNumbersToCompensations.get(lpm.MembershipNumber).Case__c;
                        tj.Points__c = mapMembershipNumbersToCompensations.get(lpm.MembershipNumber).Points_Amount__c;
                        lstTransactionJournals.add(tj);
                    }
                    System.Debug('### lstTransactionJournals: ' + lstTransactionJournals);
                    if (!lstTransactionJournals.isEmpty()) {
                        system.debug('Inserted');
                        insert lstTransactionJournals;
                    }
            }
            
        } catch(Exception e) {
            system.debug('ex'+e);
            OSF_ErrorLogHandler.logError(e, 'OSF_Compensation_TriggerHandler');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
    }
}