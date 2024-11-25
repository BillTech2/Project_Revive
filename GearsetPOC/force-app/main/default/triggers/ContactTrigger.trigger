trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Contact_Automation__c || DLT_ContactTriggerHandler.isDisabled) { return; }

    DLT_ContactTriggerHandler.run();
}