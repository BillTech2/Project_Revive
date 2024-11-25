trigger ApplicationAuditTrigger on Application_Audit__c (before insert, after insert, before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Application_Audit_Automation__c || DLT_BusinessAccountTriggerHandler.isDisabled) { return; }

    DLT_ApplicationAuditTriggerHandler.run();
}