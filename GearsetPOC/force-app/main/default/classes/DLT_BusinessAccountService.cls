public inherited sharing class DLT_BusinessAccountService {
    public static Id getMainAccountId(Business_Account__c businessAccount) {
        Id mainAccountId;

        if (businessAccount?.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__c != null) {
            mainAccountId = businessAccount.ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__c;
        } else if (businessAccount?.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__c != null) {
            mainAccountId = businessAccount.ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__c;
        } else if (businessAccount?.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__c != null) {
            mainAccountId = businessAccount.ParentId__r.ParentId__r.ParentId__r.ParentId__c;
        } else if (businessAccount?.ParentId__r?.ParentId__r?.ParentId__c != null) {
            mainAccountId = businessAccount.ParentId__r.ParentId__r.ParentId__c;
        } else if (businessAccount?.ParentId__r?.ParentId__c != null) {
            mainAccountId = businessAccount.ParentId__r.ParentId__c;
        } else if (businessAccount?.ParentId__c != null) {
            mainAccountId = businessAccount.ParentId__c;
        }

        return mainAccountId == null ? businessAccount.Id : mainAccountId;
    }

    public static Boolean isNotAllowedContract(Business_Account__c childAccount, Business_Contract__c parentContract) {
        return ((!isCorporate(childAccount) && !isBusinessAccountsRT(childAccount)) || !isContracted(childAccount))
            || (DLT_BusinessContractService.isContinent(parentContract) && !(isActiveContinent(childAccount) && isTCF(childAccount)))
            || (DLT_BusinessContractService.isLondon(parentContract) && !(isActiveLondon(childAccount) && isGoldOrPlatinum(childAccount)))
            || (DLT_BusinessContractService.isNCO(parentContract) && !(hasActiveAccountCTC(childAccount)));
    }

    public static Boolean isAllowedContractContinent(Business_Account__c account) {
        return isCorporate(account) && isContracted(account) && isActiveContinent(account) && isTCF(account);
    }

    public static Boolean isAllowedContractLondon(Business_Account__c account) {
        return isCorporate(account) && isContracted(account) && isActiveLondon(account) && isGoldOrPlatinum(account);
    }

    public static Boolean isAllowedContractNCO(Business_Account__c account) {
        return isBusinessAccountsRT(account) && isContracted(account) && hasActiveAccountCTC(account);
    }

    private static Boolean isActiveContinent(Business_Account__c account) {
        return account.FCE_Continent_Active__c ||
            account.GDS_Code_Active__c ||
            account.GND_BE_Continent_Active__c ||
            account.GND_NL_Continent_Active__c;
    }

    private static Boolean isActiveLondon(Business_Account__c account) {
        return account.FCE_London_Active__c ||
            account.Corporate_Code_Active__c ||
            account.GND_BE_London_Active__c ||
            account.GND_NL_London_Active__c;
    }

    private static Boolean hasActiveAccountCTC(Business_Account__c account) {
        return account?.No_Continent_Account_CTC__c != null && account.No_Continent_Account_CTC__c > 0;
    }

    private static Boolean isTCF(Business_Account__c account) {
        return isTCF1(account) || isTCF2(account);
    }

    private static Boolean isGoldOrPlatinum(Business_Account__c account) {
        return isGold(account) || isPlatinum(account);
    }

    public static Boolean isCorporate(Business_Account__c account) {
        return account?.RecordTypeId == DLT_BusinessAccountConstants.CORPORATE_ACCOUNT_INFO.getRecordTypeId();
    }

    public static Boolean isBusinessAccountsRT(Business_Account__c account) {
        return account?.RecordTypeId == DLT_BusinessAccountConstants.BUSINESS_ACCOUNTS_INFO.getRecordTypeId();
    }

    public static Boolean isContracted(Business_Account__c account) {
        return account?.Account_Status__c == DLT_BusinessAccountConstants.STATUS_CONTRACTED;
    }

    public static Boolean isTCF1(Business_Account__c account) {
        return account?.Red_Account_Type__c == DLT_BusinessAccountConstants.RED_ACCOUNT_TYPE_TCF1;
    }

    public static Boolean isTCF2(Business_Account__c account) {
        return account?.Red_Account_Type__c == DLT_BusinessAccountConstants.RED_ACCOUNT_TYPE_TCF2;
    }

    public static Boolean isGold(Business_Account__c account) {
        return account?.Blue_Account_Type__c == DLT_BusinessAccountConstants.BLUE_ACCOUNT_TYPE_GOLD;
    }

    public static Boolean isPlatinum(Business_Account__c account) {
        return account?.Blue_Account_Type__c == DLT_BusinessAccountConstants.BLUE_ACCOUNT_TYPE_PLATINUM;
    }

    public static Boolean isContinentDuplicated(Business_Account__c account) {
        return account == null ? false : account?.Is_Continent_Duplicated__c;
    }

    public static Boolean isLondonDuplicated(Business_Account__c account) {
        return account == null ? false : account?.Is_London_Duplicated__c;
    }

    public static Boolean isBusinessAccountsDuplicated(Business_Account__c account) {
        return account?.Is_BusinessAccounts_Duplicate__c == true;
    }

    public static void iterateMissingAccPccCodesCount(Set<Id> businessAccountIds) {
        List<Business_Account__c> accsToUpdate = [SELECT Missing_Account_PCC_Code__c FROM Business_Account__c WHERE Id IN :businessAccountIds];

        for (Business_Account__c acc : accsToUpdate) {
            acc.Missing_Account_PCC_Code__c = acc.Missing_Account_PCC_Code__c != null ? acc.Missing_Account_PCC_Code__c + 1 : 1;
        }

        DLT_BusinessAccountTriggerHandler.isDisabled = true;
        update accsToUpdate;
        DLT_BusinessAccountTriggerHandler.isDisabled = false;
    }

    public static void updateMissingAccPccCodesCount(Set<Id> businessAccountIds) {
        updateMissingAccPccCodesCount(businessAccountIds, null);
    }

    public static void updateMissingAccPccCodesCount(Set<Id> businessAccountIds, Map<Id, Integer> codeIdsInAssignmentProcess) {
        if (businessAccountIds == null || businessAccountIds.isEmpty()) { return; }

        List<B2b_AccountCTC__c> accountCTCs = [
            SELECT Corp_Tracking_Type_and_Code__c,
                   Corp_Tracking_Type_and_Code__r.Active_Account_PCCs__c,
                   B2b_AccountId__c,
                   B2b_AccountId__r.Missing_Account_PCC_Code__c
            FROM B2b_AccountCTC__c
            WHERE B2b_AccountId__c IN :businessAccountIds AND Active__c = true
        ];

        Map<Id, Set<Id>> accToCodesMap = new Map<Id, Set<Id>>();
        for (B2b_AccountCTC__c actc : accountCTCs) {
            //recalculate number of Active_Account_PCCs__c to include the AccountPCC Codes if they are currently in process as roll-up recalculation has a delay
            Integer activeAccountPCCsNum = codeIdsInAssignmentProcess != null &&  codeIdsInAssignmentProcess.containsKey(actc.Corp_Tracking_Type_and_Code__c) ?
                                           Integer.valueOf(actc.Corp_Tracking_Type_and_Code__r.Active_Account_PCCs__c) + codeIdsInAssignmentProcess.get(actc.Corp_Tracking_Type_and_Code__c) :
                                           Integer.valueOf(actc.Corp_Tracking_Type_and_Code__r.Active_Account_PCCs__c);

            if (activeAccountPCCsNum == 0) {
                if (!accToCodesMap.containsKey(actc.B2b_AccountId__c)) {
                    accToCodesMap.put(actc.B2b_AccountId__c, new Set<Id>());
                }
                accToCodesMap.get(actc.B2b_AccountId__c).add(actc.Corp_Tracking_Type_and_Code__c);
            }
        }

        Map<Id, Business_Account__c> businessAccountsToUpdateMap  = new Map<Id, Business_Account__c>();
        for (B2b_AccountCTC__c actc : accountCTCs) {
            businessAccountsToUpdateMap.put(actc.B2b_AccountId__c, new Business_Account__c(
                Id = actc.B2b_AccountId__c,
                Missing_Account_PCC_Code__c = accToCodesMap.containsKey(actc.B2b_AccountId__c) ? accToCodesMap.get(actc.B2b_AccountId__c).size() : 0
            ));
        }

        if (!businessAccountsToUpdateMap.isEmpty()) {
            DLT_BusinessAccountTriggerHandler.isDisabled = true;
            update businessAccountsToUpdateMap.values();
            DLT_BusinessAccountTriggerHandler.isDisabled = false;
        }
    }
}