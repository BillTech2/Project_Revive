public with sharing class DLT_ApplicationAuditTriggerHandler {

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
                updateRelatedBusinessAccount(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
            }
        }
    }

    public static void updateRelatedBusinessAccount(List<Application_Audit__c> appAuditList){

    List<Business_Account__c> businessAccountsToUpdate = new List<Business_Account__c>();

        for(Application_Audit__c aa : appAuditList){
            if(aa.Contract_Start__c != null){
                businessAccountsToUpdate.add(new Business_Account__c( 
                    Id = aa.Trading_Account__c,
                    Annual_Review_Reneg__c = aa.Contract_Start__c.addYears(1)
                ));
            }
        }

        if(businessAccountsToUpdate.size() > 0){
            DLT_BusinessAccountTriggerHandler.isDisabled = true;
            update businessAccountsToUpdate;
            DLT_BusinessAccountTriggerHandler.isDisabled = false;
        }
    }


}