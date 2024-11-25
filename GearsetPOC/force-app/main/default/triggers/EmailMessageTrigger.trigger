trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Email_Message_Automation__c || DLT_EmailMessageTriggerHandler.isDisabled) { return; }

    EmailMessageTriggerHandler handler = EmailMessageTriggerHandler.getInstance();
    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {
        handler.onBeforeInsert(Trigger.new);
    }
    /* After Insert */
    if (Trigger.isInsert && Trigger.isAfter) {
        handler.onAfterInsert(Trigger.new);
    }

    DLT_EmailMessageTriggerHandler.run();
}