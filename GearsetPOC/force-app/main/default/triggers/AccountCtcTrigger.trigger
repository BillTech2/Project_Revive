trigger AccountCtcTrigger on B2b_AccountCTC__c (after insert, after update, after delete, after undelete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Account_CTC_Automation__c || AccountCtcTriggerHandler.isDisabled) { return; }
    AccountCtcTriggerHandler.run();
}