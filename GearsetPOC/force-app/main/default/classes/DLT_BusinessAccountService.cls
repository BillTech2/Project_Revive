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

    public static Boolean isNotAllowedContract(Business_Account__c account, Business_Contract__c childContract) {
        return (!isCorporate(account) || !isContracted(account))
            || (DLT_BusinessContractService.isContinent(childContract) && !(isActiveContinent(account) && isTCF(account)))
            || (DLT_BusinessContractService.isLondon(childContract) && !(isActiveLondon(account) && isGoldOrPlatinum(account)));
    }

    public static Boolean isAllowedContractContinent(Business_Account__c account) {
        return isCorporate(account) && isContracted(account) && isActiveContinent(account) && isTCF(account);
    }

    public static Boolean isAllowedContractLondon(Business_Account__c account) {
        return isCorporate(account) && isContracted(account) && isActiveLondon(account) && isGoldOrPlatinum(account);
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

    private static Boolean isTCF(Business_Account__c account) {
        return isTCF1(account) || isTCF2(account);
    }

    private static Boolean isGoldOrPlatinum(Business_Account__c account) {
        return isGold(account) || isPlatinum(account);
    }

    public static Boolean isCorporate(Business_Account__c account) {
        return account?.RecordTypeId == DLT_BusinessAccountConstants.CORPORATE_ACCOUNT_INFO.getRecordTypeId();
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
}