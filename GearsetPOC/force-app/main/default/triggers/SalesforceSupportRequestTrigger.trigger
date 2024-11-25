trigger SalesforceSupportRequestTrigger on Salesforce_Support_Request__c (before insert, before update) {

    if (Trigger.isInsert && Trigger.isBefore) {
        SalesforceSupportRequestUtils.handleBeforeInsert(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        SalesforceSupportRequestUtils.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
}