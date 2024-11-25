trigger AccountPccTrigger on B2b_AccountPCC__c (before insert, after insert, before update, after update, before delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Account_PCC_Automation__c || DLT_AccountPccTriggerHandler.isDisabled) { return; }

    DLT_AccountPccTriggerHandler.run();
}