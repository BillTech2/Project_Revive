public without sharing class DLT_BusinessAccountTriggerHandler {
    public static Boolean isDisabled = false;

    public static Integer currentHierarchyDepth = 1;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                processAccountNameAndHierarchy(Trigger.New);
                setDuplicatedFlag(Trigger.New);
                getStatusFromParent(Trigger.New);
            }

            if (System.Trigger.isUpdate) {
                processAccountNameAndHierarchy(Trigger.New);
                setDuplicatedFlag(Trigger.New);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                duplicateContractAndNegotiatedRates((Map<Id, Business_Account__c>) Trigger.oldMap, Trigger.new);
                setAccountIdToTrackingCodes((Map<Id, Business_Account__c>) Trigger.oldMap, Trigger.New);
                setAccountNumber((Map<Id, Business_Account__c>) Trigger.newMap);
            }

            if (System.Trigger.isUpdate) {
                updateNegotiatedRatesAccountType((Map<Id, Business_Account__c>) Trigger.oldMap, Trigger.new);
                duplicateContractAndNegotiatedRates((Map<Id, Business_Account__c>) Trigger.oldMap, Trigger.new);
                updateRelatedNegotiatedRates((Map<Id, Business_Account__c>) Trigger.oldMap, Trigger.new);
                setAccountIdToTrackingCodes((Map<Id, Business_Account__c>) Trigger.oldMap, Trigger.New);
                updateFieldsOnChildren((Map<Id, Business_Account__c>) Trigger.oldMap, (Map<Id, Business_Account__c>)Trigger.newMap);
            }
        }
    }


    private static void processAccountNameAndHierarchy(List<Business_Account__c> newRecords) {
        for (Business_Account__c ba : newRecords) {
            ba.Name = ba.Name.toUpperCase();

            if (DLT_Constants.IS_SALES_USER) { ba.Business_Account_Name_TEXT__c = ba.Name; }

            ba.Hierarchy_Level__c = ba.ParentId__c == null ? 
                DLT_BusinessContractConstants.HIERARCHY_MAIN : 
                DLT_BusinessContractConstants.HIERARCHY_BRANCH;
        }
    }

    private static void setDuplicatedFlag(List<Business_Account__c> newAccounts) {
        for (Business_Account__c newAccount : newAccounts) {
            if (!DLT_BusinessAccountService.isContinentDuplicated(newAccount)
                && DLT_BusinessAccountService.isAllowedContractContinent(newAccount)) {
                newAccount.Is_Continent_Duplicated__c = true;
            }
            if (!DLT_BusinessAccountService.isLondonDuplicated(newAccount)
                && DLT_BusinessAccountService.isAllowedContractLondon(newAccount)) {
                newAccount.Is_London_Duplicated__c = true;
            }
        }
    }

    private static void updateNegotiatedRatesAccountType(Map<Id, Business_Account__c> oldAccountsMap, List<Business_Account__c> newAccountsList) {
        Map<Id, String> idToAccountTypeMap = new Map<Id, String>();
        for (Business_Account__c account : newAccountsList) {
            if (account.RecordTypeId == DLT_BusinessAccountConstants.RECORD_TYPE_ID_BUSINESS && oldAccountsMap.get(account.Id).Type__c != account.Type__c) {
                idToAccountTypeMap.put(account.Id, account.Type__c);
            }
        }

        if (idToAccountTypeMap.isEmpty()) { return; }

        Map<Id, B2b_NrDetails__c> ratesToUpdate = new Map<Id, B2b_NrDetails__c>();
        for (B2b_NrDetails__c rate : [SELECT ContractId__r.AccountId__c, AccountType__c
                                      FROM B2b_NrDetails__c
                                      WHERE ContractId__r.AccountId__c IN :idToAccountTypeMap.keySet()
        ]) {
            if (idToAccountTypeMap.get(rate.ContractId__r.AccountId__c) != null) {
                rate.AccountType__c = idToAccountTypeMap.get(rate.ContractId__r.AccountId__c);
                ratesToUpdate.put(rate.Id, rate);
            }
        }

        if (!ratesToUpdate.isEmpty()) {
            update ratesToUpdate.values();
        }
    }

    private static void duplicateContractAndNegotiatedRates(Map<Id, Business_Account__c> oldAccounts, List<Business_Account__c> newAccounts) {
        Map<Id, Business_Account__c> parentIdChildAccountMap = getParentIdChildAccountMap(newAccounts);

        if(parentIdChildAccountMap.values().isEmpty()) {
            return;
        }

        Map<Id, List<Business_Contract__c>> parentContracts = selectContractsByAccountId(parentIdChildAccountMap.keySet());
        Map<Id, Business_Account__c> idParentAccountMap = getIdParentAccountMap(parentIdChildAccountMap.keySet());

        if (parentContracts.isEmpty()) {
            return;
        }

        Map<Id, List<B2b_NrDetails__c>> parentNegotiatedRates = selectNegotiatedRatesByContractId(parentContracts.values());

        Date nextMonthStartDate = Date.today().addMonths(1).toStartOfMonth();

        Map<Id,Business_Contract__c> childContractsToInsert = new Map<Id,Business_Contract__c>();
        List<B2b_NrDetails__c> childNegotiatedRatesToInsert = new List<B2b_NrDetails__c>();
        List<Business_Account__c> accountsToSetDuplicateFlag = new List<Business_Account__c>();

        for (Business_Account__c childAccount : parentIdChildAccountMap.values()) {
            Business_Account__c parentAccount = idParentAccountMap.get(childAccount.ParentId__c);
            List<Business_Contract__c> listParentContrants = filterOutParentContracts(
                parentContracts.get(childAccount.ParentId__c),
                oldAccounts?.get(childAccount.Id),
                childAccount
            );
            parentContracts.put(childAccount.ParentId__c, listParentContrants);

            if(listParentContrants.isEmpty()) {
                continue;
            }

            for (Business_Contract__c parentContract : listParentContrants) {
                Business_Contract__c duplicatedContract = parentContract.clone(false, false, false, false);
                duplicatedContract.StartDate__c = nextMonthStartDate;
                duplicatedContract.AccountId__c = childAccount.Id;
                duplicatedContract.Parent_Contract__c = parentContract.Id;
                duplicatedContract.Parent_Account__c = DLT_BusinessAccountService.getMainAccountId(parentAccount);
                duplicatedContract.Contract_Legacy_Id__c = null;
                childContractsToInsert.put(parentContract.id, duplicatedContract);
            }
            
            if (DLT_BusinessAccountService.isBusinessAccountsRT(childAccount) && !DLT_BusinessAccountService.isBusinessAccountsDuplicated(childAccount)) {
                accountsToSetDuplicateFlag.add(new Business_Account__c(
                    Id = childAccount.Id,
                    Is_BusinessAccounts_Duplicate__c = true
                ));
            }
        }

        insert childContractsToInsert.values();

        if (!accountsToSetDuplicateFlag.isEmpty()) {
            isDisabled = true;
            update accountsToSetDuplicateFlag;
            isDisabled = false;
        }

        if (parentNegotiatedRates.isEmpty()) {
            return;
        }

        for (Business_Account__c childAccount : parentIdChildAccountMap.values()) {
            List<Business_Contract__c> listParentContrants = parentContracts.get(childAccount.ParentId__c);
            if(listParentContrants.isEmpty() && childContractsToInsert.isEmpty()) {
                continue;
            }

            for (Business_Contract__c parentContract : listParentContrants) {
                List<B2b_NrDetails__c> parentNrs = parentNegotiatedRates.get(parentContract.Id);
                if(parentNrs == null || parentNrs.isEmpty()) {
                    continue;
                }

                for (B2b_NrDetails__c parentNr : parentNrs) {

                    if(parentNr.B2b_RouteEndDate__c != null) continue;

                    B2b_NrDetails__c dublicateNr = parentNr.clone(false, false, false, false);
                    dublicateNr.B2b_RouteStartDate__c = nextMonthStartDate;
                    dublicateNr.ContractID__c = childContractsToInsert.get(parentContract.Id).Id;
                    dublicateNr.B2b_ParentNrDetail__c = parentNr.Id;
                    dublicateNr.Legacy_Id__c = null;
                    if (parentNr.ContractId__r.AccountId__r.Type__c == parentIdChildAccountMap.get(parentNr.ContractId__r.AccountId__c).Type__c) {
                        dublicateNr.B2b_PercentageDiscountE_Premier__c = parentNr.B2b_PercentageDiscountE_Premier__c;
                        dublicateNr.B2b_PercentageDiscountE_Plus__c = parentNr.B2b_PercentageDiscountE_Plus__c;
                        dublicateNr.B2b_PercentageDiscountE_Standard__c = parentNr.B2b_PercentageDiscountE_Standard__c;
                    }
                    if(parentNr.B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_INTEGRATED
                        || parentNr.B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_EXTRACTED) {

                        dublicateNr.B2b_Status__c = DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED;
                    }
                    childNegotiatedRatesToInsert.add(dublicateNr);
                }
            }
        }

        insert childNegotiatedRatesToInsert;
    }

    /* 
    Let NCO parent contract go if:
    - child acc is Business_AccountS RT
    - child acc is Contracted
    - the parent contract is NCO RT and child acc has active Acc CTC
    - the parent contract is NCO RT and old child acc is NOT duplicated
     */
    private static List<Business_Contract__c> filterOutParentContracts(List<Business_Contract__c> listParentContrants, Business_Account__c oldAccount, Business_Account__c childAccount) {
        List<Business_Contract__c> filteredParentContrants = new List<Business_Contract__c>();

        for (Business_Contract__c parentContract : listParentContrants) {
            Boolean isNotAllowedToDuplicate = DLT_BusinessAccountService.isNotAllowedContract(childAccount, parentContract)
                || (DLT_BusinessContractService.isContinent(parentContract) && DLT_BusinessAccountService.isContinentDuplicated(oldAccount))
                || (DLT_BusinessContractService.isLondon(parentContract) && DLT_BusinessAccountService.isLondonDuplicated(oldAccount))
                || (DLT_BusinessContractService.isNCO(parentContract) && DLT_BusinessAccountService.isBusinessAccountsDuplicated(oldAccount));

            if(!isNotAllowedToDuplicate) {
                filteredParentContrants.add(parentContract);
            }
        }
        return filteredParentContrants;
    }
    /* 
    ON UPDATE
    Let account go if:
    - ParentId__c != null
    - new acc is Business_AccountS RT
    - new acc is Contracted
    - new acc has active Acc CTC
    - old acc is not duplicated (Is_BusinessAccounts_Duplicated__c == false)
     */
    private static Map<Id, Business_Account__c> getParentIdChildAccountMap(List<Business_Account__c> newAccounts) {
        Map<Id, Business_Account__c> parentIdChildAccountMap = new Map<Id, Business_Account__c>();
        Business_Account__c oldAccount;
        for (Business_Account__c account : newAccounts) {
            oldAccount = (Business_Account__c) Trigger.oldMap?.get(account.Id);
            if(account.ParentId__c != null
                && (System.Trigger.isInsert
                        || (DLT_BusinessAccountService.isAllowedContractContinent(account) && !DLT_BusinessAccountService.isContinentDuplicated(oldAccount))
                        || (DLT_BusinessAccountService.isAllowedContractLondon(account) && !DLT_BusinessAccountService.isLondonDuplicated(oldAccount))
                        || (DLT_BusinessAccountService.isAllowedContractNCO(account) && !DLT_BusinessAccountService.isBusinessAccountsDuplicated(oldAccount))
                    )
                ) {
                parentIdChildAccountMap.put(account.ParentId__c, account);
            }
        }
        return parentIdChildAccountMap;
    }

    private static void updateRelatedNegotiatedRates(Map<Id, Business_Account__c> oldAccountMap, List<Business_Account__c> updatedAccountList) {
        Map<Id, B2b_NrDetails__c> accountIdRateMap = new Map<Id, B2b_NrDetails__c>();
        Business_Account__c oldAccount;
        for (Business_Account__c account : updatedAccountList) {
            oldAccount = oldAccountMap.get(account.Id);
            if (oldAccount.FCE_Continent_Active__c != account.FCE_Continent_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(FCE_Continent_Linked__c = account.FCE_Continent_Active__c));
            }
            if (oldAccount.FCE_London_Active__c != account.FCE_London_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(FCE_London_Linked__c = account.FCE_London_Active__c));
            }
            if (oldAccount.GND_BE_Continent_Active__c != account.GND_BE_Continent_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(GND_BE_Continent_Linked__c = account.GND_BE_Continent_Active__c));
            }
            if (oldAccount.GND_BE_London_Active__c != account.GND_BE_London_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(GND_BE_London_Linked__c = account.GND_BE_London_Active__c));
            }
            if (oldAccount.GND_NL_Continent_Active__c != account.GND_NL_Continent_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(GND_NL_Continent_Linked__c = account.GND_NL_Continent_Active__c));
            }
            if (oldAccount.GND_NL_London_Active__c != account.GND_NL_London_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(GND_NL_London_Linked__c = account.GND_NL_London_Active__c));
            }
            if (oldAccount.Corporate_Code_Active__c != account.Corporate_Code_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(Corporate_Code_Linked__c = account.Corporate_Code_Active__c));
            }
            if (oldAccount.GDS_Code_Active__c != account.GDS_Code_Active__c) {
                accountIdRateMap.put(account.Id, new B2b_NrDetails__c(GDS_Code_Linked__c = account.GDS_Code_Active__c));
            }
        }

        if (accountIdRateMap.keySet().isEmpty()) { return; }

        List<B2b_NrDetails__c> rates = [
            SELECT ContractID__r.AccountId__c
            FROM B2b_NrDetails__c
            WHERE ContractID__r.AccountId__c IN :accountIdRateMap.keySet()
        ];

        List<B2b_NrDetails__c> ratesToUpdate = new List<B2b_NrDetails__c>();

        for (B2b_NrDetails__c rate : rates) {
            if (accountIdRateMap.get(rate.ContractID__r.AccountId__c) == null) { continue; }

            B2b_NrDetails__c newRate = accountIdRateMap.get(rate.ContractID__r.AccountId__c);

            newRate.B2b_Status__c = 'To be extracted';
            newRate.Id = rate.Id;

            ratesToUpdate.add(newRate);
        }

        if (!ratesToUpdate.isEmpty()) {
            update accountIdRateMap.values();
        }
    }

    private static void setAccountIdToTrackingCodes(Map<Id, Business_Account__c> oldAccounts, List<Business_Account__c> newAccounts) {
        List<Corp_Tracking_Type_and_Code__c> corpTrackingTypeToUpdateList = new List<Corp_Tracking_Type_and_Code__c>();
        for (Business_Account__c accountNew : newAccounts) {
            Business_Account__c oldAccount = oldAccounts?.get(accountNew.Id);

            if(oldAccount?.GND_BE_Continent__c != accountNew?.GND_BE_Continent__c && accountNew?.GND_BE_Continent__c != null) {
                corpTrackingTypeToUpdateList.add(
                    new Corp_Tracking_Type_and_Code__c(Id = accountNew.GND_BE_Continent__c, B2b_Account__c = accountNew.Id)
                );
            }

            if(oldAccount?.GND_NL_Continent__c != accountNew?.GND_NL_Continent__c && accountNew?.GND_NL_Continent__c != null) {
                corpTrackingTypeToUpdateList.add(
                    new Corp_Tracking_Type_and_Code__c(Id = accountNew.GND_NL_Continent__c, B2b_Account__c = accountNew.Id)
                );
            }

            if(oldAccount?.GND_BE_London__c != accountNew?.GND_BE_London__c && accountNew?.GND_BE_London__c != null) {
                corpTrackingTypeToUpdateList.add(
                    new Corp_Tracking_Type_and_Code__c(Id = accountNew.GND_BE_London__c, B2b_Account__c = accountNew.Id)
                );
            }

            if(oldAccount?.GND_NL_London__c != accountNew?.GND_NL_London__c && accountNew?.GND_NL_London__c != null) {
                corpTrackingTypeToUpdateList.add(
                    new Corp_Tracking_Type_and_Code__c(Id = accountNew.GND_NL_London__c, B2b_Account__c = accountNew.Id)
                );
            }
        }

        if (corpTrackingTypeToUpdateList.isEmpty()) {
            return;
        }

        update corpTrackingTypeToUpdateList;
    }

    private static void getStatusFromParent(List<Business_Account__c> newAccounts){
        
        List<Id> parentAccountIds = new List<Id>();

        for(Business_Account__c ba : newAccounts){
            if(ba.ParentId__c != null &&
               (ba.RecordTypeId == DLT_BusinessAccountConstants.RECORD_TYPE_ID_CORPORATE ||
                ba.RecordTypeId == DLT_BusinessAccountConstants.RECORD_TYPE_ID_BUSINESS)
            ) {
                parentAccountIds.add(ba.ParentId__c);
            }
        }

        Map<Id, Business_Account__c> parentAccount = new Map<Id, Business_Account__c>([
            SELECT Id, Account_Status__c, Blue_Account_Type__c, Red_Account_Type__c, Secondary_Account_Owner__c, Type__c
            FROM Business_Account__c 
            WHERE Id IN :parentAccountIds
        ]);

        for(Business_Account__c ba : newAccounts){
            if(ba.ParentId__c != null && ba.RecordTypeId == DLT_BusinessAccountConstants.RECORD_TYPE_ID_CORPORATE){
                ba.Account_Status__c = parentAccount.get(ba.ParentId__c).Account_Status__c;
                ba.Blue_Account_Type__c = parentAccount.get(ba.ParentId__c).Blue_Account_Type__c;
                ba.Red_Account_Type__c = parentAccount.get(ba.ParentId__c).Red_Account_Type__c;
            } else if (ba.ParentId__c != null && ba.RecordTypeId == DLT_BusinessAccountConstants.RECORD_TYPE_ID_BUSINESS) {
                ba.Account_Status__c = parentAccount.get(ba.ParentId__c).Account_Status__c;
                ba.Type__c = parentAccount.get(ba.ParentId__c).Type__c;
            }
        }
    }

    private static void updateFieldsOnChildren(Map<Id, Business_Account__c> oldAccountMap, Map<Id, Business_Account__c> updatedAccountMap){

        if(DLT_BusinessAccountTriggerHandler.currentHierarchyDepth >= DLT_Settings__c.getInstance().Business_Account_Hierarchy_Depth__c) return; 

        
        List<Id> changedBusinessAccountIds = new List<Id>();

        for(Business_Account__c ba : updatedAccountMap.values()){
            if(ba.OwnerId != oldAccountMap.get(ba.Id).OwnerId
                || ba.Secondary_Account_Owner__c != oldAccountMap.get(ba.Id).Secondary_Account_Owner__c 
                || (ba.RecordTypeId == DLT_BusinessAccountConstants.RECORD_TYPE_ID_CORPORATE && (
                    ba.Account_Status__c != oldAccountMap.get(ba.Id).Account_Status__c
                    || ba.Blue_Account_Type__c != oldAccountMap.get(ba.Id).Blue_Account_Type__c
                    || ba.Red_Account_Type__c != oldAccountMap.get(ba.Id).Red_Account_Type__c
                )) 
                 ){

                    changedBusinessAccountIds.add(ba.Id);
            }  
        }

        List<Business_Account__c> childrenToUpdate = new List<Business_Account__c>();

        for(Business_Account__c child : [
            SELECT Id, ParentId__c, RecordTypeId
            FROM Business_Account__c 
            WHERE ParentId__c IN :changedBusinessAccountIds]){

                if(child.RecordTypeId == DLT_BusinessAccountConstants.RECORD_TYPE_ID_CORPORATE){
                    child.Account_Status__c = updatedAccountMap.get(child.ParentId__c).Account_Status__c;
                    child.Blue_Account_Type__c = updatedAccountMap.get(child.ParentId__c).Blue_Account_Type__c;
                    child.Red_Account_Type__c = updatedAccountMap.get(child.ParentId__c).Red_Account_Type__c;
                }
                child.Secondary_Account_Owner__c = updatedAccountMap.get(child.ParentId__c).Secondary_Account_Owner__c;
                child.OwnerId = updatedAccountMap.get(child.ParentId__c).OwnerId;

                childrenToUpdate.add(child);
        }

        DLT_BusinessAccountTriggerHandler.currentHierarchyDepth++;

        update childrenToUpdate;

    }


    // ========================= HELPERS =========================

    private static Map<Id, List<Business_Contract__c>> selectContractsByAccountId(Set<Id> accountIds) {
        Map<Id, List<Business_Contract__c>> result = new Map<Id, List<Business_Contract__c>>();
        if (accountIds == null || accountIds.isEmpty()) {
            return result;
        }
        List<Business_Contract__c> contracts = [
            SELECT AccountId__c, B2b_ContractStartDate__c, B2b_FCE__c, B2b_Status__c, Business_Account_Status__c,
                Calendar_Text__c, Campaign__c, Contract_Legacy_Id__c, Contract_Review_Due__c, Contract_Type__c,
                Corp_Tracking__c, CreatedById, CreatedDate, Discount_Level_BP__c, Discount_Level_SP__c, EndDate__c,
                End_of_Contract__c, Established_Date__c, FCE_Code__c, Fare_Range__c, Id, IsDeleted, IsManager__c,
                IsOwner__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate,
                Most_Recent_Contract__c, Name, Other_Discount_NL__c, OwnerId, Parent_Account__c, Parent_Contract__c,
                RecordTypeId, Review_Date__c, Secondary_Contract_Owner__c, Signatory_Contact__c, StartDate__c, Status__c,
                SystemModstamp, Unique_Contract__c
            FROM Business_Contract__c 
            WHERE AccountId__c IN : accountIds
                AND (EndDate__c > THIS_MONTH OR EndDate__c = null) 
                AND End_of_Contract__c	= FALSE
            ];

        for (Business_Contract__c contract: contracts) {
            if(result.get(contract.AccountId__c) == null) {
                result.put(contract.AccountId__c, new List<Business_Contract__c>());
            }
            result.get(contract.AccountId__c).add(contract);
        }

        return result;
    }

    private static Map<Id, List<B2b_NrDetails__c>> selectNegotiatedRatesByContractId(List<List<Business_Contract__c>> contractsList) {
        List<Business_Contract__c> contractsId = new List<Business_Contract__c>();
        Map<Id, List<B2b_NrDetails__c>> result = new Map<Id, List<B2b_NrDetails__c>>();

        if (contractsList == null || contractsList.isEmpty()) {
            return result;
        }

        for (List<Business_Contract__c> contracts : contractsList) {
            contractsId.addAll(contracts);
        }

        List<B2b_NrDetails__c> negotiatedRates = [
            SELECT Account_PCC_s__c, Action_Type__c, B2b_Account__c, B2b_ApprovalInProgress__c, B2b_Approved__c,
                B2b_BeneLastExtractionDate__c, B2b_Bene_Extract__c, B2b_Code_type__c, B2b_EudoNetExternalId__c,
                B2b_Extract_Date__c, B2b_GDS3LastExtractionDate__c, B2b_GDS3_Extract__c, B2b_GDS_Air_Comfort_Tariff_Code__c,
                B2b_GDS_Air_Premium_Tariff_Code__c, B2b_GDS_Air_Standard_Tariff_Code__c, B2b_LastExtractionDate__c,
                B2b_NegotiatedRateDetailCode__c, B2b_ParentNrDetail__c, B2b_PercentageDiscountBp__c,
                B2b_PercentageDiscountComfort__c, B2b_PercentageDiscountFirst__c, B2b_PercentageDiscountPremium__c,
                B2b_PercentageDiscountSp__c, B2b_PercentageDiscountStandard__c, B2b_PercentageNl__c,
                B2b_PercentagePossibleComfort__c, B2b_PercentagePossibleFirst__c, B2b_PercentagePossibleStandard__c,
                B2b_PercentageTGN__c, B2b_Percentage_Discount_Comfort__c, B2b_Percentage_Discount_Premium__c,
                B2b_Percentage_Discount_Standard__c, B2b_Resarail_Extract__c, B2b_RoadEndDate__c, B2b_RoadStartDate__c,
                B2b_Road__c, B2b_RouteEndDate__c, B2b_RouteStartDate__c, B2b_Route__c, B2b_S3_BeNe_Comfort_Tariff_Code__c,
                B2b_S3_BeNe_Premium_Tariff_Code__c, B2b_S3_BeNe_Standard_Tariff_Code__c, B2b_Status__c, B2b_TicketsComfort__c,
                B2b_TicketsFirst__c, B2b_TicketsStandard__c, B2b_TurnoverComfort__c, B2b_TurnoverFirst__c,
                B2b_TurnoverStandard__c, ContractID__c, CreatedById, CreatedDate, Discount__c, Extract_Requested__c,
                GDS_Air_Extract__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, 
                LastViewedDate, Legacy_Id__c, Name, OwnerId, PCC_Changed__c, PCC_Extract__c, RecordTypeId, S3_Extract__c,
                Skip_Validation__c, SystemModstamp, B2b_PercentageDiscountE_Premier__c, B2b_PercentageDiscountE_Plus__c,
                B2b_PercentageDiscountE_Standard__c, AccountType__c, ContractId__r.AccountId__r.Type__c
            FROM B2b_NrDetails__c
            WHERE ContractID__c IN : contractsId
                AND (B2b_RouteEndDate__c > THIS_MONTH OR B2b_RouteEndDate__c = null) 
            ];

        for (B2b_NrDetails__c rate: negotiatedRates) {
            if(result.get(rate.ContractID__c) == null) {
                result.put(rate.ContractID__c, new List<B2b_NrDetails__c>());
            }
            result.get(rate.ContractID__c).add(rate);
        }

        return result;
    }

    private static Map<Id, Business_Account__c> getIdParentAccountMap(Set<Id> parentIds) {
        if (parentIds == null || parentIds.isEmpty()) {
            return new Map<Id, Business_Account__c>();
        }
        return new Map<Id, Business_Account__c>([
            SELECT ParentId__c,
                ParentId__r.ParentId__c,
                ParentId__r.ParentId__r.ParentId__c,
                ParentId__r.ParentId__r.ParentId__r.ParentId__c,
                ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__c,
                ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__c
            FROM Business_Account__c
            WHERE Id IN :parentIds
        ]);
    }

    public static void setAccountNumber(Map<Id, Business_Account__c> businessAccountNewMap){

        Id agencyRecordTypeId = DLT_BusinessAccountConstants.RECORD_TYPE_ID_AGENCY;

        List<Business_Account__c> businessAccountsToUpdate = new List<Business_Account__c>();

        for(Business_Account__c ba : businessAccountNewMap.values()){

            if(ba.RecordTypeId != agencyRecordTypeId) continue;

            businessAccountsToUpdate.add(new Business_Account__c(
                Id = ba.Id,
                AccountNumber__c = DLT_BusinessAccountConstants.TYPE_TO_PREFIX.containsKey(ba.Type__c) ? 
                    DLT_BusinessAccountConstants.TYPE_TO_PREFIX.get(ba.Type__c) + ba.Auto_Number_3__c : 
                    ba.Auto_Number_3__c
            ));
        }

        isDisabled = true;
        update businessAccountsToUpdate;
        isDisabled = false;

    }
}