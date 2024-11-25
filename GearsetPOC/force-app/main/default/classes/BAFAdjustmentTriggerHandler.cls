public with sharing class BAFAdjustmentTriggerHandler {

    public static BAFAdjustmentTriggerHandler instance;
    public static BAFAdjustmentTriggerHandler getInstance() {
        if (instance == null) {
            instance = new BAFAdjustmentTriggerHandler();
        }
        return instance;
    } 

    public void onAfterInsert(List<BAF_Adjustment_Request__c> newObjects, Map<Id, BAF_Adjustment_Request__c> oldObjectsMap) {
        setCaseBusinessAccount(newObjects, oldObjectsMap);
    }

    public void setCaseBusinessAccount(List<BAF_Adjustment_Request__c> newObjects, Map<Id, BAF_Adjustment_Request__c> oldObjectsMap) {
        List<Case> caseRecords = new List<Case>(); 
        list<Case> casesForUpdate = new List<Case>();
        List<String> caseIds = new List<String>();
        Map<Id, BAF_Adjustment_Request__c> BAFByIds = new Map<Id, BAF_Adjustment_Request__c>();

        for (BAF_Adjustment_Request__c BAFItem : newObjects) {
            if (isNeedPopulateCaseBusinessAccount(BAFItem, oldObjectsMap)) {
                caseIds.add(BAFItem.Case__c);
                BAFByIds.put(BAFItem.Case__c, BAFItem);
            }
        }

        if (!caseIds.isEmpty()) {
            caseRecords = [
                SELECT Id, Business_Account__c 
                FROM Case 
                WHERE Id IN :caseIds AND Business_Account__c = null
            ];
    
            if(!caseRecords.isEmpty()) {
                for (Case caseItem : caseRecords) {
                    Case caseForUpdate = new Case();
                    caseForUpdate.Id = caseItem.Id;
                    caseForUpdate.Business_Account__c = BAFByIds.get(caseItem.Id).Business_Account__c;
                    casesForUpdate.add(caseForUpdate);
                }
    
                update casesForUpdate;
            }
        }
    }

    private Boolean isNeedPopulateCaseBusinessAccount(BAF_Adjustment_Request__c newBAF, Map<Id, BAF_Adjustment_Request__c> oldObjectsMap) {
        Boolean needPopulated = false;
        Boolean isBAanCaseLinkPopulated = (newBAF.Business_Account__c != null) && (newBAF.Case__c != null);

        if (isBAanCaseLinkPopulated) {
            if (oldObjectsMap == null) {
                needPopulated = (newBAF.Status__c != 'Draft') && (newBAF.Status__c != 'Cancelled');
            } else {
                needPopulated = (newBAF.Status__c != 'Draft') && (newBAF.Status__c != 'Cancelled') && oldObjectsMap.containsKey(newBAF.Id) && (oldObjectsMap.get(newBAF.Id).Status__c == 'Draft');
            }
        }

        return needPopulated;

    }



}