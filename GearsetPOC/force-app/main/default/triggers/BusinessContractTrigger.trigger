trigger BusinessContractTrigger on Business_Contract__c (before insert, after insert, before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Business_Contract_Automation__c || DLT_BusinessContractTriggerHandler.isDisabled) { return; }

    DLT_BusinessContractTriggerHandler.run();
}