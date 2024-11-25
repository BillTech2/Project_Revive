trigger SalesforceSupportRequestTrigger on Salesforce_Support_Request__c (before insert, before update) {

    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_SF_Support_Request_Automation__c || DLT_SFSupportRequestTriggerHandler.isDisabled) { return; }

    if (Trigger.isInsert && Trigger.isBefore) {
        SalesforceSupportRequestUtils.handleBeforeInsert(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        SalesforceSupportRequestUtils.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }

    DLT_SFSupportRequestTriggerHandler.run();
}