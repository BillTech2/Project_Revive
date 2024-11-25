trigger AccountPccCodeTrigger on B2b_AccountPCCCode__c (after insert, after update, after delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Account_PCC_Code_Automation__c || AccountPccCodeTriggerHandler.isDisabled) { return; }

    AccountPccCodeTriggerHandler.run();
}