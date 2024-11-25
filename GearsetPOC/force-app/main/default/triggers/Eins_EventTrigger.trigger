trigger Eins_EventTrigger on Event (before insert, before update, after delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Event_Automation__c) { return; }

    if (Trigger.isBefore && Trigger.isInsert) {
        Eins_EventTriggerHandler.updateDogAssistanceEvent(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        Eins_EventTriggerHandler.updateDogAssistanceEvent(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        Eins_EventTriggerHandler.cancelDogAssistanceEvent(Trigger.old);
    }
}