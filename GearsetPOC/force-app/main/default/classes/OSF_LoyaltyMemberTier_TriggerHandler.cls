//Devops testing

/*********************************************************************************************************
Class Name      : OSF_LoyaltyMemberTier_TriggerHandler
Description     : Class to handle LoyaltyMemberTier trigger functionality
Developer       : Vasile Paraschiv
Date            : 
Version         : 1.0
*********************************************************************************************************
History
*********************************************************************************************************
Date            Developer           Version      Description
*********************************************************************************************************/
public with sharing class OSF_LoyaltyMemberTier_TriggerHandler {
    //set previous and current tier change dates
    public static void setTierDates(List<LoyaltyMemberTier> newList, Map<Id, LoyaltyMemberTier> oldMap) {
        if (!OSF_Utility.isActive('OSF_LoyaltyMemberTier_TriggerHandler', 'setTierDates') && !Test.isRunningTest()) {
            return;
        }
        try {
            for(LoyaltyMemberTier lmt : newList) {
                if(oldMap != null && (oldMap.containsKey(lmt.Id) && oldMap.get(lmt.Id).LoyaltyTierId != lmt.LoyaltyTierId)) {
                    if (lmt.PreviousTierDateTime__c == null) {
                        lmt.PreviousTierDateTime__c = lmt.CreatedDate;
                        lmt.CurrentTierDateTime__c = Datetime.now();
                    } else {
                        lmt.PreviousTierDateTime__c = lmt.CurrentTierDateTime__c;
                        lmt.CurrentTierDateTime__c = Datetime.now();
                    }
                }
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }   
    }
    public static void createHistoryRecord(List<LoyaltyMemberTier> newList, Map<Id, LoyaltyMemberTier> oldMap) {
        if (!OSF_Utility.isActive('OSF_LoyaltyMemberTier_TriggerHandler', 'createHistoryRecord') && !Test.isRunningTest()) {
            return;
        }
        List<Loyalty_Tier_History__c> lstLMTHistory = new List<Loyalty_Tier_History__c>();
        try {
            for(LoyaltyMemberTier lmt : newList) {
             if ((oldMap != null && (oldMap.containsKey(lmt.Id) && oldMap.get(lmt.Id).LoyaltyTierId != lmt.LoyaltyTierId)) || oldMap == null || !oldMap.containsKey(lmt.Id) ) {
                Loyalty_Tier_History__c lmtHistory = new Loyalty_Tier_History__c();
                    lmtHistory.New_Tier__c = lmt.LoyaltyTierId;
                    if (oldMap != null && oldMap.containsKey(lmt.Id)) {
                        lmtHistory.Old_Tier__c = oldMap.get(lmt.Id).LoyaltyTierId;
                    }
                    lmtHistory.FromTierStartDate__c = lmt.PreviousTierDateTime__c == null ? Datetime.now() : lmt.PreviousTierDateTime__c;
                    lmtHistory.ToTierStartDate__c = lmt.CurrentTierDateTime__c == null ? Datetime.now() : lmt.CurrentTierDateTime__c;
                    lmtHistory.Loyalty_Program_Member__c = lmt.LoyaltyMemberId;
                    lmtHistory.TierChangeReason__c = lmt.ReasonForChange;
                    lmtHistory.ChangeReasonType__c = lmt.ChangeReasonType;
                    lstLMTHistory.add(lmtHistory);
               }
            }
            if (lstLMTHistory.size() > 0) {
                insert lstLMTHistory;
            }
        } catch(Exception e) {
            system.debug('ex'+e);
            OSF_ErrorLogHandler.logError(e, 'OSF_LoyaltyMemberTier_TriggerHandler');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
    }
}