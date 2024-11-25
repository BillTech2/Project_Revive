public without sharing class AccountCtcTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                createNRtoAccountCTCs(Trigger.new);
                updateRelatedNegotiatedRates(Trigger.new);
                updateRelatedBusinessAccounts(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                updateRelatedNegotiatedRates(Trigger.new, (Map<Id, B2b_AccountCTC__c>) Trigger.oldMap);
                updateRelatedBusinessAccounts(Trigger.old, (Map<Id, B2b_AccountCTC__c>) Trigger.newMap);
            }

            if (System.Trigger.isDelete) {
                updateRelatedBusinessAccounts(Trigger.old);
            }

            if (System.Trigger.isUndelete) {
                updateRelatedBusinessAccounts(Trigger.new);
            }
        }
    }

    private static void createNRtoAccountCTCs(List<B2b_AccountCTC__c> newAccountCTCs) {
        Set<Id> businessAccountIds = new Set<Id>();
        List<B2b_AccountCTC__c> accountCTCsToProcess = new List<B2b_AccountCTC__c>();

        for (B2b_AccountCTC__c actc : newAccountCTCs) {
            if (actc.B2b_AccountId__c != null) {
                businessAccountIds.add(actc.B2b_AccountId__c);
                accountCTCsToProcess.add(actc);
            }
        }

        if (businessAccountIds.isEmpty()) { return; }

        Map<Id, Business_Contract__c> activeContracts = new Map<Id, Business_Contract__c>([
            SELECT Id
            FROM Business_Contract__c
            WHERE AccountId__c IN :businessAccountIds
            AND (EndDate__c = NULL OR EndDate__c > TODAY)
            AND End_of_Contract__c = FALSE
        ]);

        if (activeContracts.isEmpty()) { return; }

        List<B2b_NrDetails__c> ratesToProcess = [
            SELECT ContractId__r.AccountId__c
            FROM B2b_NrDetails__c
            WHERE ContractId__c IN :activeContracts.keySet()
            AND (B2b_RouteEndDate__c = NULL OR B2b_RouteEndDate__c > TODAY)
        ];

        if (ratesToProcess.isEmpty()) { return; }

        List<NR_to_AccountCTC__c> nrToAccountCTCs = new List<NR_to_AccountCTC__c>();

        for (B2b_AccountCTC__c accountCTC : accountCTCsToProcess) {
            for (B2b_NrDetails__c nr : ratesToProcess) {
                if (accountCTC.B2b_AccountId__c == nr.ContractId__r.AccountId__c) {
                    nrToAccountCTCs.add(new NR_to_AccountCTC__c(
                        Account_CTC__c = accountCTC.Id,
                        Negotiated_Rate__c = nr.Id
                    ));
                }
            }
        }

        if (!nrToAccountCTCs.isEmpty()) {
            insert nrToAccountCTCs;
        }
    }

    private static void updateRelatedNegotiatedRates(List<B2b_AccountCTC__c> accountCtcList, Map<Id, B2b_AccountCTC__c> oldAccountCtcMap) {
        List<B2b_AccountCTC__c> accountCTCsChangedList = new List<B2b_AccountCTC__c>();
        for (B2b_AccountCTC__c accountCtc : accountCtcList) {
            if (accountCtc.Active__c != oldAccountCtcMap.get(accountCtc.Id).Active__c) {
                accountCTCsChangedList.add(accountCtc);
            }
        }

        if (!accountCTCsChangedList.isEmpty()) {
            updateRelatedNegotiatedRates(accountCTCsChangedList);
        }
    }

    private static void updateRelatedNegotiatedRates(List<B2b_AccountCTC__c> accountCtcList) {
        Set<Id> accountIds = new Set<Id>();
        for (B2b_AccountCTC__c accountCtc : accountCtcList) {
            if (accountCtc.B2b_AccountId__c != null) {
                accountIds.add(accountCtc.B2b_AccountId__c);
            }
        }

        if (accountIds.isEmpty()) { return; }

        List<B2b_NrDetails__c> rates = [
            SELECT ContractID__r.AccountId__c
            FROM B2b_NrDetails__c
            WHERE ContractID__r.AccountId__c IN : accountIds
                AND ContractID__r.End_of_Contract__c = false
                AND (B2b_RouteEndDate__c = null
                    OR B2b_RouteEndDate__c = TODAY
                    OR B2b_RouteEndDate__c > TODAY)
        ];

        if (rates.isEmpty()) { return; }

        for (B2b_NrDetails__c rate : rates) {
            rate.B2b_Status__c = DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED;
        }

        update rates;
    }

    private static void updateRelatedBusinessAccounts(List<B2b_AccountCTC__c> accountCtcList) {
        Set<Id> businessAccountIds = new Set<Id>();
        for (B2b_AccountCTC__c ctc : accountCtcList) {
            if (ctc.B2b_AccountId__c != null) {
                businessAccountIds.add(ctc.B2b_AccountId__c);
            }
        }

        updateAccountCTCsCount(businessAccountIds);
        DLT_BusinessAccountService.updateMissingAccPccCodesCount(businessAccountIds);
    }

    private static void updateRelatedBusinessAccounts(List<B2b_AccountCTC__c> oldAccountCtcList, Map<Id, B2b_AccountCTC__c> newAccountCtcMap) {
        Set<Id> businessAccountIds = new Set<Id>();
        for (B2b_AccountCTC__c oldCtc : oldAccountCtcList) {
            B2b_AccountCTC__c newCtc = newAccountCtcMap.get(oldCtc.Id);
            if (oldCtc.B2b_AccountId__c != newCtc.B2b_AccountId__c || oldCtc.Active__c != newCtc.Active__c) {
                if (newCtc.B2b_AccountId__c != null) {
                    businessAccountIds.add(newCtc.B2b_AccountId__c);
                }
                if (oldCtc.B2b_AccountId__c != null && newCtc.B2b_AccountId__c == null) {
                    businessAccountIds.add(oldCtc.B2b_AccountId__c);
                }
            }
        }

        updateAccountCTCsCount(businessAccountIds);
        DLT_BusinessAccountService.updateMissingAccPccCodesCount(businessAccountIds);
    }

    private static void updateAccountCTCsCount(Set<Id> businessAccountIds) {
        if (businessAccountIds == null || businessAccountIds.isEmpty()) { return; }

        List<AggregateResult> results = [
            SELECT B2b_AccountId__c, COUNT(Id)
            FROM B2b_AccountCTC__c
            WHERE B2b_AccountId__c IN :businessAccountIds
              AND Active__c = true
              AND Corp_Tracking_Type_and_Code__r.RecordTypeId IN :DLT_CorporateTrackingConstants.NCO_RECORD_TYPE_IDS
            GROUP BY B2b_AccountId__c
        ];

        Map<Id, Integer> accountCtcCountMap = new Map<Id, Integer>();
        //save into the map the count of active Account CTCs
        for (AggregateResult ar : results) {
            Id accountId = (Id) ar.get('B2b_AccountId__c');
            Integer count = (Integer) ar.get('expr0');
            accountCtcCountMap.put(accountId, count);
        }

        //add to map the businesss account ids with no active Account CTCs
        for (Id accountId : businessAccountIds) {
            if(!accountCtcCountMap.containsKey(accountId)) {
                accountCtcCountMap.put(accountId, 0);
            }
        }

        List<Business_Account__c> accountsToUpdate = new List<Business_Account__c>();
        for (Id accountId : accountCtcCountMap.keySet()) {
            Business_Account__c account = new Business_Account__c(
                Id = accountId,
                No_Continent_Account_CTC__c = accountCtcCountMap.get(accountId)
            );
            accountsToUpdate.add(account);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate; //we should not disable a Business Account trigger as this update needs to trigger the duplication logic
        }
    }
}