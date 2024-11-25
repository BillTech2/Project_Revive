trigger BusinessAccountTrigger on Business_Account__c (before insert, after insert, before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Business_Account_Automation__c || DLT_BusinessAccountTriggerHandler.isDisabled) { return; }

    DLT_BusinessAccountTriggerHandler.run();
}