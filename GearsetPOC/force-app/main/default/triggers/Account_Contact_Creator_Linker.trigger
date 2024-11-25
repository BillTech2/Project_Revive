trigger Account_Contact_Creator_Linker on Case (before insert) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Case_Automation__c || DLT_CaseTriggerHandler.isDisabled) { return; }

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {    
            new Account_Contact_Creator_Linker_Handler().startmethod(Trigger.new);
        }
    }
}