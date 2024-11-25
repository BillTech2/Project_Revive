public with sharing class OSF_Account_TriggerHandler {
    
    public static Boolean isFirstTimeInTransaction = true;

    /**
     * @description Processes the loyalty changes for the accounts and create LPMs if needed
     * @param {List<Account>} newList - The list of new accounts
     * @param {Map<Id, Account>} oldMap - The map of old accounts
     */
    public static void processLoyaltyChanges(List<Account> newList, Map<Id, Account> oldMap) {
        if (!OSF_Utility.isActive('OSF_Account_TriggerHandler', 'processLoyaltyChanges') && !Test.isRunningTest()) {
            return;
        }
        System.Debug('### OSF_Account_TriggerHandler processLoyaltyChanges start');
        Map<Id, Id> mapAccIdsToContactIds = new Map<Id, Id>();
        Set<Id> setInvalidContactIds = new Set<Id>();
        System.debug('### newList.size(): ' + newList.size());
        if(oldMap != null) {
            System.debug('### oldMap.size(): ' + oldMap.size());
        } else {
            System.debug('### oldMap:' + oldMap);
        }
        try {
            //only process accounts for which the Loyalty_Opt_In__c has been set to true and the account is new or the old value was false
            for (Account acc :newList) {
                System.Debug('### acc: ' + acc);
                System.Debug('### acc.Loyalty_Opt_In__c: ' + acc.Loyalty_Opt_In__c);
                if(oldMap != null && oldMap.containsKey(acc.Id)) {
                     System.Debug('### oldMap.get(acc.Id).Loyalty_Opt_In__c: ' + oldMap.get(acc.Id).Loyalty_Opt_In__c);
                }
                if (acc.Loyalty_Opt_In__c == true && ((oldMap != null && oldMap.containsKey(acc.Id) && oldMap.get(acc.Id).Loyalty_Opt_In__c == false) || oldMap == null || !oldMap.containsKey(acc.Id) ))  {
                    mapAccIdsToContactIds.put(acc.Id, acc.PersonContactId);
                }
            }
            System.Debug('### mapAccIdsToContactIds.size(): ' + mapAccIdsToContactIds.size());
            //verify if there is already a LPM for the account and if not, create one
            if (mapAccIdsToContactIds.size() > 0 && isFirstTimeInTransaction) {
                isFirstTimeInTransaction = false;
                //get the current highest incremental number
                LoyaltyProgram lp = [SELECT Id, CurrentMembers__c FROM LoyaltyProgram LIMIT 1];
                //get 40000 of the existing non incremental numbers ordered ascending
                List<LoyaltyProgramMember> lstExistingLPMs = [SELECT Id, MembershipNumber, IncrementalExtId__c FROM LoyaltyProgramMember WHERE IncrementalExtId__c > :lp.CurrentMembers__c AND IncrementalExtId__c <= :(lp.CurrentMembers__c + 10000) ORDER BY IncrementalExtId__c ASC];
                List<Decimal> lstExistingRandomNumbers = new List<Decimal>();
                System.Debug('### lstExistingLPMs.size(): ' + lstExistingLPMs.size());
                for (LoyaltyProgramMember lpm :lstExistingLPMs) {
                    lstExistingRandomNumbers.add(lpm.IncrementalExtId__c);
                }
                for (LoyaltyProgramMember lpm : [SELECT Id, AccountId, ContactId FROM LoyaltyProgramMember WHERE ContactId IN :mapAccIdsToContactIds.values()]) {
                    setInvalidContactIds.add(lpm.ContactId);
                }
                System.Debug('### setInvalidContactIds: ' + setInvalidContactIds);
                Decimal increment = lp.CurrentMembers__c;
                List<LoyaltyProgramMember> listLPMs = new List<LoyaltyProgramMember>();
                for (Id accId : mapAccIdsToContactIds.keySet()) {
                    if (!setInvalidContactIds.contains(mapAccIdsToContactIds.get(accId))) {
                        do {
                        increment++;
                        } while (lstExistingRandomNumbers.contains(increment));
                        LoyaltyProgramMember lpm = new LoyaltyProgramMember();
                        String partialNumber = '308381100' + String.valueOf(increment).leftPad(7,'0');
                        lpm.IncrementalExtId__c = increment;
                        lpm.MembershipNumber = partialNumber + String.valueOf(OSF_REST_LoyaltyMemberRegistration.getLuhnCheckDigit(partialNumber));
                        lpm.ContactId = mapAccIdsToContactIds.get(accId);
                        lpm.ProgramId = lp.Id;
                        lpm.EnrollmentDate = Date.today();
                        lpm.MemberStatus = 'Active';                        
                        lpm.MemberType = 'Individual';
                        listLPMs.add(lpm);
                    }
                }
                System.Debug('### listLPMs: ' + listLPMs);
                if (listLPMs.size() > 0) {
                    insert listLPMs;
                    lp.CurrentMembers__c = increment;
                    update lp;
                }
                List<Id> lstLPMIds = new List<Id>();
                for(LoyaltyProgramMember lpm : listLPMs){
                    lstLPMIds.add(lpm.Id);
                }

                List<LoyaltyMemberTier> lstLMTs = [SELECT Id, LoyaltyTierId, LoyaltyTierGroupId, ReasonForChange FROM LoyaltyMemberTier WHERE LoyaltyMemberId IN :lstLPMIds];
                if (!lstLMTs.isEmpty()) {
                    for (LoyaltyMemberTier lmt : lstLMTs) {
                        lmt.TierExpirationDate = Date.today().addYears(1);
                    }
                    update lstLMTs;
                }
            }
            System.Debug('### OSF_Account_TriggerHandler processLoyaltyChanges end');
        } catch(Exception e) {
            system.debug('ex'+e);
            OSF_ErrorLogHandler.logError(e, 'OSF_Account_TriggerHandler');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
    }
}