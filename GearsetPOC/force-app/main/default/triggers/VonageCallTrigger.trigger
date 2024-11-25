trigger VonageCallTrigger on NVMStatsSF__NVM_Call_Summary__c (after insert, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_VonageCall_Automation__c) { return; }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            VonageCallTriggerHandler.senCSATEmailAfterVonageCall(Trigger.oldMap, Trigger.new);
        }
        if (Trigger.isUpdate) {
            VonageCallTriggerHandler.senCSATEmailAfterVonageCall(Trigger.oldMap, Trigger.new);
        }
    }
}