public with sharing class DLT_AnnualReviewTriggerHandler {

    public static Boolean isDisabled = false;
    
    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
            }

            if (System.Trigger.isUpdate) {
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {

            }

            if (System.Trigger.isUpdate) {
                updateRelatedBusinessAccount(Trigger.new);
            }
        }
    }

    public static void updateRelatedBusinessAccount(List<Annual_Review__c> annualReviewList){

    List<Business_Account__c> businessAccountsToUpdate = new List<Business_Account__c>();
    Map<Id,Annual_Review__c> businessAccountToAnnualReviewMap = new Map<Id,Annual_Review__c>();

        for(Annual_Review__c ar : annualReviewList){
            if(ar.Review_Status__c == DLT_AnnualReviewConstants.REVIEWSTATUS_PASSED_EXTENDED && ar.Completed__c != null){
                businessAccountToAnnualReviewMap.put(ar.Trading_Account__c, ar);
            }
        }

        for(Business_Account__c ba : [
            SELECT Id
            FROM Business_Account__c 
            WHERE Id IN :businessAccountToAnnualReviewMap.keySet()
                AND RecordTypeId = :DLT_BusinessAccountConstants.RECORD_TYPE_ID_AGENCY]){

            ba.Annual_Review_Reneg__c = businessAccountToAnnualReviewMap.get(ba.Id).Completed__c.addYears(1);
            businessAccountsToUpdate.add(ba);
        }

        if(businessAccountsToUpdate.size() > 0){
            DLT_BusinessAccountTriggerHandler.isDisabled = true;
            update businessAccountsToUpdate;
            DLT_BusinessAccountTriggerHandler.isDisabled = false;
        }
    }


}