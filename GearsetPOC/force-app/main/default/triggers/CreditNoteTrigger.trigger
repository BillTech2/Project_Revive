trigger CreditNoteTrigger on Credit_Note__c (before insert,before update,before delete,after insert,after update,after delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Credit_Note_Automation__c || DLT_CreditNoteTriggerHandler.isDisabled) { return; }

    DLT_CreditNoteTriggerHandler.run();
}