public without sharing class DLT_BusinessContractTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                updateAnnualReviewDateAgency(Trigger.new);
                validateContractStartDate(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                updateAnnualReviewDateAgency(Trigger.new, Trigger.oldMap);
                validateContractStartDate(Trigger.new);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                generateDuplicateContracts((Map<Id,Business_Contract__c>)Trigger.NewMap);
                populateMostRecentContract(Trigger.new);
                duplicateContractForChildRecord(Trigger.new);
                updateAnnualReviewDateCorporate(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                updateFieldsOnChildren((Map<Id, Business_Contract__c>) Trigger.oldMap, (Map<Id, Business_Contract__c>)Trigger.newMap);
                updateAnnualReviewDateCorporate(Trigger.new, Trigger.oldMap);
            }
        }
    }

    private static void setDateFields(Map<Id,Business_Account__c> businessAccounts, Business_Contract__c businessContract){
        if (businessContract.Review_Date__c != null || businessContract.EndDate__c != null) {
            return;
        }
        businessContract.Review_Date__c = businessContract.StartDate__c.addYears(1).addDays(-1);

        if(!businessAccounts.containsKey(businessContract.AccountId__c)){
            businessContract.EndDate__c = businessContract.Review_Date__c;
        }
    }

    private static Map<Id,Business_Account__c> getRelatedBusinessAccounts(List<Business_Contract__c> businessContractList, List<Id> recordTypeIds){
        
        List<Id> businessAccountIds = new List<Id>();
        
        for(Business_Contract__c contract : businessContractList){
            businessAccountIds.add(contract.AccountId__c);
        }

        return new Map<Id,Business_Account__c>([
            SELECT Id 
            FROM Business_Account__c 
            WHERE RecordTypeId IN :recordTypeIds
                AND Id IN :businessAccountIds]);
    }


    private static void updateAnnualReviewDateAgency(List<Business_Contract__c> newRecords) {

        Map<Id,Business_Account__c> businessAccounts = getRelatedBusinessAccounts(newRecords, new List<Id>{DLT_BusinessAccountConstants.RECORD_TYPE_ID_AGENCY});

        for(Business_Contract__c insertedContract: newRecords) {
            if(insertedContract.StartDate__c != null) {
                setDateFields(businessAccounts, insertedContract);
            }
        }
    }

    private static void updateAnnualReviewDateAgency(List<Business_Contract__c> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id,Business_Contract__c> oldContracts = (Map<Id,Business_Contract__c>) oldRecords;

        Map<Id,Business_Account__c> businessAccounts = getRelatedBusinessAccounts(newRecords, new List<Id>{DLT_BusinessAccountConstants.RECORD_TYPE_ID_AGENCY});

        for(Business_Contract__c updatedContract: newRecords) {
            if (oldContracts.get(updatedContract.id).StartDate__c != updatedContract.StartDate__c && updatedContract.StartDate__c != null) {
                setDateFields(businessAccounts, updatedContract);
            }
        }
    }

    private static void validateContractStartDate(List<Business_Contract__c> newRecords) {
        List<Id> accountIds = new List<Id>();
        List<Business_Contract__c> newRecordsWithAccount = new List<Business_Contract__c>();
        for(Business_Contract__c newRecord : newRecords) {
            if(newRecord.AccountId__c != null) {
                newRecordsWithAccount.add(newRecord);
            }
        }
        for(Business_Contract__c newRecord : newRecordsWithAccount) {
            accountIds.add(newRecord.AccountId__c);
        }
        List<Business_Contract__c> oldContracts = [
            SELECT Id, AccountId__c, StartDate__c 
            FROM Business_Contract__c 
            WHERE AccountId__c IN : accountIds
            AND Id NOT IN : newRecords
            AND Status__c =: DLT_BusinessContractConstants.ACTIVE
        ];
        Map<Id, List<Date>> accountToContractStartDate = new Map<Id, List<Date>>();
        for(Business_Contract__c oldRecord : oldContracts) {
            if(accountToContractStartDate.get(oldRecord.AccountId__c) == null) {
                accountToContractStartDate.put(oldRecord.AccountId__c, new List<Date>());
            }
            accountToContractStartDate.get(oldRecord.AccountId__c).add(oldRecord.StartDate__c);
        }
        for(Business_Contract__c newRecord : newRecordsWithAccount) {
            if (accountToContractStartDate.get(newRecord.AccountId__c) == null) {
                continue;
            }
            for(Date oldRecordStartDate : accountToContractStartDate.get(newRecord.AccountId__c)) {
                if (newRecord.StartDate__c == oldRecordStartDate && newRecord.Parent_Contract__c != null) {
                    newRecord.addError(DLT_BusinessContractConstants.DUPLICATION_START_DATES_OVERLAP_ERROR);
                } else if (newRecord.StartDate__c == oldRecordStartDate) {
                    newRecord.addError(DLT_BusinessContractConstants.START_DATES_OVERLAP_ERROR);
                }
            }
        }
    }

    public static void generateDuplicateContracts(Map<Id,Business_Contract__c> exBusinessContracts) {
        Map<Id, Set<Id>> childBusinessAccountMap = new Map<Id, Set<Id>>();
        Map<Id, List<Id>> accountContractsMap = new Map<Id,List<Id>>();

        for (Business_Contract__c bc : exBusinessContracts.values())  {
            List<Id> contIds = accountContractsMap.get(bc.AccountId__c);
            if (contIds == null) {
                contIds = new List<Id>();
            }
            contIds.add(bc.Id);
            accountContractsMap.put(bc.AccountId__c,contIds);
        }

        List<Business_Account__c> allAccounts = [
            SELECT Id, Red_Account_Type__c, Hierarchy_Level__c, ParentId__c, ParentId__r.Red_Account_Type__c, ParentId__r.Blue_Account_Type__c, Blue_Account_Type__c
            FROM Business_Account__c
            WHERE (Id IN: accountContractsMap.keySet()
                    OR (ParentId__c IN: accountContractsMap.keySet()
                        AND ParentId__r.Managed__c = :DLT_BusinessContractConstants.MANAGED_MANAGED
                    )
                )
                AND Managed__c = :DLT_BusinessContractConstants.MANAGED_MANAGED
                AND (Red_Account_Type__c IN: DLT_BusinessContractConstants.RED_ACCOUNT_TYPE_VALUES OR Blue_Account_Type__c != null)
                AND RecordTypeId =: DLT_BusinessAccountConstants.RECORD_TYPE_ID_AGENCY
        ];

        for (Business_Account__c ba: allAccounts) {
            if (ba.Hierarchy_Level__c == DLT_BusinessContractConstants.HIERARCHY_MAIN) {
                childBusinessAccountMap.put(ba.ParentId__c, new Set<Id>());
            }

            if (ba.Hierarchy_Level__c == DLT_BusinessContractConstants.HIERARCHY_BRANCH
                && ((ba.Red_Account_Type__c == ba.ParentId__r.Red_Account_Type__c && DLT_BusinessContractConstants.RED_ACCOUNT_TYPE_VALUES.contains(ba.Red_Account_Type__c))
                    || (ba.Blue_Account_Type__c == ba.ParentId__r.Blue_Account_Type__c && ba.Blue_Account_Type__c != null)
                )
            ) {
                Set<Id> childIds = childBusinessAccountMap.get(ba.ParentId__c);

                if (childIds == null) {
                    childIds = new Set<Id>();
                }

                childIds.add(ba.Id);
                childBusinessAccountMap.put(ba.ParentId__c, childIds);
            }
        }

        List<Business_Contract__c> newBusinessContracts = new List<Business_Contract__c>();

        for (Id parentId : childBusinessAccountMap.keySet()) {
            List<Id> contractIds = accountContractsMap.get(parentId);

            if (contractIds == null) {
                continue;
            }

            for (Id contractId: contractIds) {
                Set<Id> childAccounts = childBusinessAccountMap.get(parentId);

                if (childAccounts == null) {
                    continue;
                }

                for (Id childAccount: childBusinessAccountMap.get(parentId)) {
                    if (accountContractsMap.keySet().contains(childAccount)) {
                        continue;
                    }

                    Business_Contract__c newBC = exBusinessContracts.get(contractId).clone();

                    newBC.Parent_Contract__c = contractId;
                    newBC.AccountId__c = childAccount;
                    newBC.Parent_Account__c = parentId;

                    newBusinessContracts.add(newBC);
                }
            }
        }

        Database.insert(newBusinessContracts);
    }

    private static void populateMostRecentContract(List<Business_Contract__c> newBusinessContracts) {
        List<Id> accountsId = new List<Id>();

        for(Business_Contract__c newBC: newBusinessContracts) {
            accountsId.add(newBC.AccountId__c);
        }

        if(accountsId.isEmpty()) {
            return;
        }

        List<Business_Account__c> relatedBusinessAccounts = selectBusinessAccountsById(accountsId);

        for (Business_Contract__c newBC: newBusinessContracts) {
            for (Business_Account__c relatedBA: relatedBusinessAccounts) {
                if(relatedBA.Id == newBC.AccountId__c) {
                    relatedBA.Most_Recent_Contract__c = newBC.Id;
                }
            }
        }

        DLT_BusinessAccountTriggerHandler.isDisabled = true;
        update relatedBusinessAccounts;
        DLT_BusinessAccountTriggerHandler.isDisabled = false;
    }

    private static void duplicateContractForChildRecord(List<Business_Contract__c> businessContracts) {
        Map<Id, Business_Contract__c> parentAccountIdContractMap = new Map<Id, Business_Contract__c>();

        for (Business_Contract__c contract : businessContracts) {
            parentAccountIdContractMap.put(contract.AccountId__c, contract);
        }

        List<Business_Account__c> childAccounts = [
            SELECT Account_Status__c, Red_Account_Type__c, Blue_Account_Type__c, RecordTypeId, FCE_Continent_Active__c,
                GDS_Code_Active__c, GND_BE_Continent_Active__c, GND_NL_Continent_Active__c, FCE_London_Active__c,
                Corporate_Code_Active__c, GND_BE_London_Active__c, GND_NL_London_Active__c, ParentId__c,
                ParentId__r.ParentId__c, ParentId__r.ParentId__r.ParentId__c,
                ParentId__r.ParentId__r.ParentId__r.ParentId__c,
                ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__c,
                ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__r.ParentId__c,
                No_Continent_Account_CTC__c, Is_BusinessAccounts_Duplicate__c
            FROM Business_Account__c
            WHERE ParentId__c IN :parentAccountIdContractMap.keySet()
        ];

        if (childAccounts.isEmpty()) {
            return;
        }

        List<Business_Contract__c> duplicatedBusinessContracts = new List<Business_Contract__c>();

        for (Business_Account__c childAccount : childAccounts) {
            Business_Contract__c originalContract = parentAccountIdContractMap.get(childAccount.ParentId__c);

            if(DLT_BusinessAccountService.isNotAllowedContract(childAccount, originalContract)) {
                continue;
            }

            Business_Contract__c duplicatedContract = originalContract.clone(false, false, false, false);
            duplicatedContract.AccountId__c = childAccount.Id;
            duplicatedContract.Parent_Contract__c = originalContract.Id;
            duplicatedContract.Parent_Account__c = DLT_BusinessAccountService.getMainAccountId(childAccount);
            duplicatedContract.Contract_Legacy_Id__c = null;
            duplicatedBusinessContracts.add(duplicatedContract);

            childAccount.Is_BusinessAccounts_Duplicate__c = true;
        }

        insert duplicatedBusinessContracts;

        DLT_BusinessAccountTriggerHandler.isDisabled = true;
        update childAccounts;
        DLT_BusinessAccountTriggerHandler.isDisabled = false;
    }

    private static void updateFieldsOnChildren(Map<Id, Business_Contract__c> oldContractsMap, Map<Id, Business_Contract__c> updatedContractsMap){
        
        List<Id> changedContractIds = new List<Id>();

        for(Business_Contract__c bc : updatedContractsMap.values()){
            if(bc.EndDate__c != oldContractsMap.get(bc.Id).EndDate__c
                || (bc.StartDate__c != oldContractsMap.get(bc.Id).StartDate__c 
                    && bc.StartDate__c > Date.today())
                || bc.Review_Date__c != oldContractsMap.get(bc.Id).Review_Date__c){

                changedContractIds.add(bc.Id);
            }  
        }

        List<Business_Contract__c> childrenToUpdate = new List<Business_Contract__c>();

        for(Business_Contract__c child : [
            SELECT Id, Parent_Contract__c
            FROM Business_Contract__c 
            WHERE Parent_Contract__c IN :changedContractIds]){

            if(updatedContractsMap.get(child.Parent_Contract__c).EndDate__c != oldContractsMap.get(child.Parent_Contract__c).EndDate__c){
                child.EndDate__c = updatedContractsMap.get(child.Parent_Contract__c).EndDate__c;
            }

            if(updatedContractsMap.get(child.Parent_Contract__c).Review_Date__c != oldContractsMap.get(child.Parent_Contract__c).Review_Date__c){
                child.Review_Date__c = updatedContractsMap.get(child.Parent_Contract__c).Review_Date__c;
            }

            if(updatedContractsMap.get(child.Parent_Contract__c).StartDate__c != oldContractsMap.get(child.Parent_Contract__c).StartDate__c 
                && updatedContractsMap.get(child.Parent_Contract__c).StartDate__c > Date.today()){
                child.StartDate__c = updatedContractsMap.get(child.Parent_Contract__c).StartDate__c;
            }

            childrenToUpdate.add(child);
        }

        DLT_BusinessContractTriggerHandler.isDisabled = true;
        update childrenToUpdate;
        DLT_BusinessContractTriggerHandler.isDisabled = false;

    }

    private static void updateAnnualReviewDateCorporate(List<Business_Contract__c> newRecords, Map<Id, SObject> oldRecords) {

        Map<Id,Business_Contract__c> oldContracts = (Map<Id,Business_Contract__c>) oldRecords;

        List<Business_Contract__c> qualifiedBusinessContracts = new List<Business_Contract__c>();

        for(Business_Contract__c updatedContract: newRecords) {
            if (oldContracts.get(updatedContract.id).Status__c != updatedContract.Status__c ||
                oldContracts.get(updatedContract.id).EndDate__c != updatedContract.EndDate__c ||
                oldContracts.get(updatedContract.id).Review_Date__c != updatedContract.Review_Date__c) {

                qualifiedBusinessContracts.add(updatedContract);
            }
        }

        Map<Id,Business_Account__c> businessAccounts = getRelatedBusinessAccounts(qualifiedBusinessContracts, new List<Id>{DLT_BusinessAccountConstants.RECORD_TYPE_ID_CORPORATE, DLT_BusinessAccountConstants.RECORD_TYPE_ID_BUSINESS});

        updateRelatedBusinessAccounts(businessAccounts.keySet());
    }

    private static void updateAnnualReviewDateCorporate(List<Business_Contract__c> newRecords) {

        List<Business_Contract__c> qualifiedBusinessContracts = new List<Business_Contract__c>();

        for(Business_Contract__c updatedContract: newRecords) {

            qualifiedBusinessContracts.add(updatedContract);
        }

        Map<Id,Business_Account__c> businessAccounts = getRelatedBusinessAccounts(qualifiedBusinessContracts, new List<Id>{DLT_BusinessAccountConstants.RECORD_TYPE_ID_CORPORATE, DLT_BusinessAccountConstants.RECORD_TYPE_ID_BUSINESS});

        updateRelatedBusinessAccounts(businessAccounts.keySet());
    }

    private static void updateRelatedBusinessAccounts(Set<Id> businessAccountIds){

        Map<String, Date> businessAccountIdToEndDate = new Map<String,Date>();
        List<Business_Account__c> businessAccountsToUpdate = new List<Business_Account__c>();
        
        for(AggregateResult ar :[
            SELECT AccountId__c, AccountId__r.RecordTypeId accRecordTypeId, RecordType.Name, MAX(EndDate__c) endDate, MAX(Review_Date__c) reviewDate
            FROM Business_Contract__c
            WHERE Status__c = :DLT_BusinessContractConstants.ACTIVE
                AND AccountId__c IN :businessAccountIds
            GROUP BY AccountId__c, RecordType.Name, AccountId__r.RecordTypeId
        ]){
            if(String.valueOf(ar.get('accRecordTypeId')) == DLT_BusinessAccountConstants.RECORD_TYPE_ID_BUSINESS) {
                if(!businessAccountIdToEndDate.containsKey(String.valueOf(ar.get('AccountId__c')))){
                    businessAccountIdToEndDate.put(String.valueOf(ar.get('AccountId__c')), Date.valueOf(ar.get('reviewDate')));
                }

                if(businessAccountIdToEndDate.get(String.valueOf(ar.get('AccountId__c'))) > Date.valueOf(ar.get('reviewDate'))){
                    businessAccountIdToEndDate.put(String.valueOf(ar.get('AccountId__c')), Date.valueOf(ar.get('reviewDate')));
                }
            } else {
                if(!businessAccountIdToEndDate.containsKey(String.valueOf(ar.get('AccountId__c')))){
                    businessAccountIdToEndDate.put(String.valueOf(ar.get('AccountId__c')), Date.valueOf(ar.get('endDate')));
                }

                if(businessAccountIdToEndDate.get(String.valueOf(ar.get('AccountId__c'))) > Date.valueOf(ar.get('endDate'))){
                    businessAccountIdToEndDate.put(String.valueOf(ar.get('AccountId__c')), Date.valueOf(ar.get('endDate')));
                }
            }
        }

        for(Id businessAccountId : businessAccountIdToEndDate.keySet()){
            businessAccountsToUpdate.add( new Business_Account__c(
                Id = businessAccountId,
                Annual_Review_Reneg__c = businessAccountIdToEndDate.get(businessAccountId)));
        }

        DLT_BusinessAccountTriggerHandler.isDisabled = true;
        update businessAccountsToUpdate;
        DLT_BusinessAccountTriggerHandler.isDisabled = false;
    }

    // ========================= HELPERS =========================

    private static List<Business_Account__c> selectBusinessAccountsById(List<Id> recordIds) {
        return [
            SELECT Id, Most_Recent_Contract__c
            FROM Business_Account__c
            WHERE Id
            IN :recordIds
        ];
    }
}