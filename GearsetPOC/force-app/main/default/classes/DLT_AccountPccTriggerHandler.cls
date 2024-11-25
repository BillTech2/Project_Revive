public without sharing class DLT_AccountPccTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
            }

            if (System.Trigger.isUpdate) {
                handlePccDelete((Map<Id, B2b_AccountPCC__c>) System.Trigger.oldMap, System.Trigger.new);
            }

            if(Trigger.isDelete) {
                deleteNrToAccountPcc(System.Trigger.old);
                handlePccDelete(System.Trigger.old);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                handlePccInsert(System.Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                handlePccFieldUpdate((Map<Id, B2b_AccountPCC__c>) System.Trigger.oldMap, System.Trigger.new);
            }
        }
    }

    private static void deleteNrToAccountPcc(List<B2b_AccountPCC__c> accountPCC) {

        List<NR_to_Account_PCC__c> junctionToDelete = [
            SELECT Id
            FROM NR_to_Account_PCC__c
            WHERE Account_PCC__c IN :accountPCC
        ];

        if(!junctionToDelete.isEmpty()) {
            delete junctionToDelete;
        }
    }

    private static void handlePccDelete(List<B2b_AccountPCC__c> oldPCCs) {
        adjustPccNumber(oldPCCs);
    }

    private static void handlePccInsert(List<B2b_AccountPCC__c> newPCCs) {
        Map<Id, B2b_AccountPCC__c> accountToPccMap = new Map<Id, B2b_AccountPCC__c>();
        for (B2b_AccountPCC__c newPCC : newPCCs) {
            if (isRecordTypeOperational(newPCC)) {
                accountToPccMap.put(newPCC.B2b_Account__c, newPCC);
            }
        }
        updateActiveRatePccData(accountToPccMap);
        adjustPccNumber(newPCCs);
        DLT_BusinessAccountService.iterateMissingAccPccCodesCount(accountToPccMap.keySet());
    }

    private static void handlePccFieldUpdate(Map<Id, B2b_AccountPCC__c> oldPCCs, List<B2b_AccountPCC__c> newPCCs) {
        Set<Id> filteredDeletedIds = new Set<Id>();
        Set<Id> filteredDeletedAccountPccIds = new Set<Id>();
        Set<Id> accIdsOfAccPccsWithNoCodes = new Set<Id>();
        Map<Id, B2b_AccountPCC__c> accountToPccMap = new Map<Id, B2b_AccountPCC__c>();
        for (B2b_AccountPCC__c updatedAccountPCC : newPCCs) {
            if (isRecordTypeChangedToDeleted(oldPCCs, updatedAccountPCC)) {
                filteredDeletedIds.add(updatedAccountPCC.B2b_Account__c);
                filteredDeletedAccountPccIds.add(updatedAccountPCC.Id);
            }
            if (isRecordTypeChangedToOperational(oldPCCs, updatedAccountPCC)) {
                accountToPccMap.put(updatedAccountPCC.B2b_Account__c, updatedAccountPCC);
            }
            if (updatedAccountPCC.Active_PCC_Codes__c == 0) {
                accIdsOfAccPccsWithNoCodes.add(updatedAccountPCC.B2b_Account__c);
            }
        }

        updateNegotiatedRatePccData(filteredDeletedIds);
        updateActiveRatePccData(accountToPccMap);
        adjustPccNumber(newPCCs);
        deactivateAccountPccCodes(filteredDeletedAccountPccIds);
        DLT_BusinessAccountService.updateMissingAccPccCodesCount(accIdsOfAccPccsWithNoCodes);
    }

    private static void handlePccDelete(Map<Id, B2b_AccountPCC__c> oldPCCs, List<B2b_AccountPCC__c> newPCCs) {
        for (B2b_AccountPCC__c updatedAccountPCC : newPCCs) {
            if (isDeletedChanged(oldPCCs, updatedAccountPCC)) {
                handleDeleteChanged(updatedAccountPCC);
            }
        }
    }

    // ========================= HELPERS =========================

    private static void deactivateAccountPccCodes(Set<Id> accountPccIds) {
        if (accountPccIds.isEmpty()) { return; }

        List<B2b_AccountPCCCode__c> codes = [
            SELECT Active__c
            FROM B2b_AccountPCCCode__c
            WHERE B2b_AccountPCC__c IN :accountPccIds
        ];

        for (B2b_AccountPCCCode__c code : codes) {
            code.Active__c = false;
        }

        update codes;
    }

    private static void updateActiveRatePccData(Map<Id, B2b_AccountPCC__c> accountToPccMap) {
        Map<Id, List<B2b_NrDetails__c>> accountToRatesMap = new Map<Id, List<B2b_NrDetails__c>>();
        List<B2b_NrDetails__c> rates = getConnectedToPccRates(accountToPccMap.keySet());

        for (B2b_NrDetails__c rate : rates) {
            rate.Account_PCC_s__c = '';
            if (accountToRatesMap.get(rate.ContractID__r.AccountId__c) == null) {
                accountToRatesMap.put(rate.ContractID__r.AccountId__c, new List<B2b_NrDetails__c>());
            }
            accountToRatesMap.get(rate.ContractID__r.AccountId__c).add(rate);
            setPccData(rate);
        }

        B2b_AccountPCC__c pcc;
        List<B2b_NrDetails__c> negotiatedRates;
        List<NR_to_Account_PCC__c> neAccountPCCs = new List<NR_to_Account_PCC__c>();
        for (Id accId : accountToPccMap.keySet()) {
            pcc = accountToPccMap.get(accId);
            negotiatedRates = accountToRatesMap.get(accId);
            if (negotiatedRates == null || negotiatedRates.isEmpty() || pcc?.Id == null) {
                continue;
            }
            for (B2b_NrDetails__c negotiatedRate : negotiatedRates) {
                DLT_NegotiatedRateTriggerHandler.skipPccUpdatedIds.add(negotiatedRate.Id);
                neAccountPCCs.add(
                    new NR_to_Account_PCC__c(
                        Negotiated_Rate__c = negotiatedRate.Id,
                        Account_PCC__c = pcc.Id
                    )
                );
                negotiatedRate.Account_PCC_s__c
                    += negotiatedRate.Account_PCC_s__c == '' ? pcc.Name : ';' + pcc.Name;

                negotiatedRate.PCC_Codes__c 
                    += String.isBlank(negotiatedRate.PCC_Codes__c) ? pcc.PCC_Code_Name__c : ';' + pcc.PCC_Code_Name__c;

                negotiatedRate.PCC_Codes__c = negotiatedRate.PCC_Codes__c.removeStart('null');
            }
        }

        insert neAccountPCCs;

        update rates;
    }

    private static void updateNegotiatedRatePccData(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        List<B2b_NrDetails__c> rates = getConnectedToPccRates(accountIds);

        for (B2b_NrDetails__c rate : rates) {
            setPccData(rate);
        }

        update rates;
    }

    private static void setPccData(B2b_NrDetails__c rate) {
        rate.PCC_Extract__c = true;
        rate.B2b_Status__c = DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED;
        rate.PCC_Changed__c = System.today();
    }

    private static void adjustPccNumber(List<B2b_AccountPCC__c> pccs) {
        Set<Id> businessIds = new Set<Id>();
        for (B2b_AccountPCC__c pcc : pccs) {
            businessIds.add(pcc.B2b_Account__c);
        }

        List<Business_Account__c> businessAccounts = [
            SELECT
                (SELECT Id
                    FROM Account_PCC_Names__r
                    WHERE RecordTypeId =: DLT_AccountPccConstants.RECORD_TYPE_OPERATIONAL
                )
            FROM Business_Account__c
            WHERE Id IN :businessIds
        ];

        for (Business_Account__c businessAccount : businessAccounts) {
            businessAccount.Account_PCC__c = businessAccount.Account_PCC_Names__r.size();
        }

        update businessAccounts;
    }

    private static void handleDeleteChanged(B2b_AccountPCC__c accountPCC) {
        if (accountPCC.B2b_Delete__c) {
            accountPCC.recordTypeId = DLT_AccountPccConstants.RECORD_TYPE_DELETED;
        } else {
            accountPCC.recordTypeId = DLT_AccountPccConstants.RECORD_TYPE_OPERATIONAL;
        }
    }

    private static Boolean isRecordTypeOperational(B2b_AccountPCC__c pcc) {
        return pcc?.recordTypeId == DLT_AccountPccConstants.RECORD_TYPE_OPERATIONAL;
    }

    private static Boolean isRecordTypeDeleted(B2b_AccountPCC__c pcc) {
        return pcc?.recordTypeId == DLT_AccountPccConstants.RECORD_TYPE_DELETED;
    }

    private static Boolean isRecordTypeChangedToOperational(Map<Id, B2b_AccountPCC__c> oldPCCs, B2b_AccountPCC__c newPCC) {
        return isRecordTypeOperational(newPCC) && oldPCCs?.get(newPCC.Id)?.recordTypeId != newPCC?.recordTypeId;
    }

    private static Boolean isRecordTypeChangedToDeleted(Map<Id, B2b_AccountPCC__c> oldPCCs, B2b_AccountPCC__c newPCC) {
        return isRecordTypeDeleted(newPCC) && oldPCCs?.get(newPCC.Id)?.recordTypeId != newPCC?.recordTypeId;
    }

    private static Boolean isDeletedChanged(Map<Id, B2b_AccountPCC__c> oldPCCs, B2b_AccountPCC__c newPCC) {
        return oldPCCs?.get(newPCC.Id)?.B2b_Delete__c != newPCC?.B2b_Delete__c;
    }

    private static List<B2b_NrDetails__c> getConnectedToPccRates(Set<Id> accountIds) {
        return [
            SELECT Id, ContractID__r.AccountId__c, Account_PCC_s__c, PCC_Codes__c
            FROM B2b_NrDetails__c
            WHERE ContractID__c IN
                (SELECT Id
                FROM Business_Contract__c
                WHERE AccountId__c IN :accountIds
                    AND (AccountId__r.FCE_Continent__c != NULL OR AccountId__r.GND_BE_Continent__c != NULL
                        OR AccountId__r.GND_NL_Continent__c != NULL OR AccountId__r.GDS_Code__c != NULL
                        OR AccountId__r.FCE_London__c != NULL OR AccountId__r.GND_BE_London__c != NULL
                        OR AccountId__r.GND_NL_London__c != NULL OR AccountId__r.Corporate_Code__c != NULL
                        OR AccountId__r.No_Continent_Account_CTC__c > 0
                    )
                )
                AND (B2b_RouteEndDate__c = NULL OR B2b_RouteEndDate__c > TODAY)
        ];
    }
}