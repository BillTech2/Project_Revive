trigger CaseReportTrigger on Case_Report__c (before insert,before update,before delete,after insert,after update,after delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Case_Report_Automation__c) { return; }

    DLT_CaseReportTriggerHandler.run();

}