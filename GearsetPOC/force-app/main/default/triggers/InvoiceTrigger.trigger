trigger InvoiceTrigger on Invoice__c (before insert,before update,before delete,after insert,after update,after delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Invoice_Automation__c || DLT_InvoiceTriggerHandler.isDisabled) { return; }

    DLT_InvoiceTriggerHandler.run();
}