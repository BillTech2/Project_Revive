trigger Eins_TaskTrigger on Task (after update, before insert) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Task_Automation__c) { return; }

    if (Trigger.isBefore && Trigger.isInsert) {
        //Eins_TaskTriggerHandler.updateCaseByTask(Trigger.new, Trigger.oldMap);
    }
}