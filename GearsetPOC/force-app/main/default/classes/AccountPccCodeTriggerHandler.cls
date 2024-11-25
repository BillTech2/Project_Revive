public without sharing class AccountPccCodeTriggerHandler {
    public static Boolean isDisabled = false;
    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }
        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                updateRelatedNegotiatedRates(Trigger.new);
                updateRelatedBusinessAccounts(Trigger.new, null);
            }

            if (System.Trigger.isUpdate) {
                updateRelatedNegotiatedRates(Trigger.new, (Map<Id, B2b_AccountPCCCode__c>) Trigger.oldMap);
                updateRelatedBusinessAccounts(Trigger.new, (Map<Id, B2b_AccountPCCCode__c>) Trigger.oldMap);
            }

            if (System.Trigger.isDelete) {
                updateRelatedNegotiatedRates(Trigger.old);
            }
        }
    }

    private static void updateRelatedBusinessAccounts(List<B2b_AccountPCCCode__c> accountPccCodeList, Map<Id, B2b_AccountPCCCode__c> oldAccountPccCodeMap) {
        Set<Id> accountPccIds = new Set<Id>();
        Map<Id, Integer> codeIdsInAssignmentProcess = new Map<Id, Integer>();

        for (B2b_AccountPCCCode__c accountPccCode : accountPccCodeList) {
            if (oldAccountPccCodeMap == null || accountPccCode.Active__c != oldAccountPccCodeMap.get(accountPccCode.Id).Active__c) {
                accountPccIds.add(accountPccCode.B2b_AccountPCC__c);

                // count how many codes activated and deactivated to recalculate values from rollup fields
                if (!codeIdsInAssignmentProcess.containsKey(accountPccCode.Corp_Tracking_Type_and_Code__c)) {
                    codeIdsInAssignmentProcess.put(accountPccCode.Corp_Tracking_Type_and_Code__c, accountPccCode.Active__c ? 1 : -1);
                } else {
                    Integer currNum = accountPccCode.Active__c ?
                                      codeIdsInAssignmentProcess.get(accountPccCode.Corp_Tracking_Type_and_Code__c) + 1 :
                                      codeIdsInAssignmentProcess.get(accountPccCode.Corp_Tracking_Type_and_Code__c) - 1;
                    codeIdsInAssignmentProcess.put(accountPccCode.Corp_Tracking_Type_and_Code__c, currNum);
                }
            }
        }

        Set<Id> businessAccountIds = getBusinessAccountIds(accountPccIds);
        DLT_BusinessAccountService.updateMissingAccPccCodesCount(businessAccountIds, codeIdsInAssignmentProcess);
    }

    private static Set<Id> getBusinessAccountIds(Set<Id> accountPccIds) {
        Set<Id> businessAccountIds = new Set<Id>();
        for (B2b_AccountPCC__c accountPcc : [SELECT B2b_Account__c FROM B2b_AccountPCC__c WHERE Id IN : accountPccIds]) {
            businessAccountIds.add(accountPcc.B2b_Account__c);
        }
        return businessAccountIds;
    }

    private static void updateRelatedNegotiatedRates(List<B2b_AccountPCCCode__c> accountPccCodeList, Map<Id, B2b_AccountPCCCode__c> oldAccountPccCodeMap) {
        List<B2b_AccountPCCCode__c> accountPccCodeChangedList = new List<B2b_AccountPCCCode__c>();
        for (B2b_AccountPCCCode__c accountPccCode : accountPccCodeList) {
            if(accountPccCode.Active__c != oldAccountPccCodeMap.get(accountPccCode.Id).Active__c) {
                accountPccCodeChangedList.add(accountPccCode);
            }
        }
        if(!accountPccCodeChangedList.isEmpty()) {
            updateRelatedNegotiatedRates(accountPccCodeChangedList);
        }
    }
    private static void updateRelatedNegotiatedRates(List<B2b_AccountPCCCode__c> accountPccCodeList) {
        Set<Id> accountPccIds = new Set<Id>();
        for (B2b_AccountPCCCode__c accountPccCode : accountPccCodeList) {
            accountPccIds.add(accountPccCode.B2b_AccountPCC__c);
        }
        List<B2b_AccountPCC__c> accountPccList = [
            SELECT B2b_Account__c 
            FROM B2b_AccountPCC__c 
            WHERE Id IN : accountPccIds
        ];
        Set<Id> accountIds = new Set<Id>();
        for (B2b_AccountPCC__c accountPcc : accountPccList) {
            accountIds.add(accountPcc.B2b_Account__c);
        }
        
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
}