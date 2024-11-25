trigger Ticket on Ticket__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Ticket_Automation__c || DLT_TicketTriggerHandler.isDisabled) { return; }

    //Trigger execution is skipped for KAFKA Service user.
    //Tickets inserted/updated by KAFKA are routed into trigger later via TicketUpdateBatch class 
    if (UserInfo.getName() != 'KAFKA Service') {
        /* Get singleton handler's instance */
        TicketTriggerHandler handler = TicketTriggerHandler.getInstance();

        /* Before Insert */
        if (Trigger.isInsert && Trigger.isBefore) {
            handler.onBeforeInsert(Trigger.new);
        }

        /* After Insert */
        else if (Trigger.isAfter && Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new, Trigger.newMap);
            //handler.onAfterInsertOrUpdate(Trigger.new, Trigger.newMap); // new new
        }

        /* Before Update */
        else if (Trigger.isUpdate && Trigger.isBefore) {
            handler.onBeforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
        }

        /* After Update */
        else if (Trigger.isUpdate && Trigger.isAfter) {
            if (System.IsBatch() == false && System.isFuture() == false) handler.onAfterUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
            Eins_EventTriggerHandler.updateDogAssistanceEvent(Trigger.new, Trigger.oldMap);
            //handler.onAfterInsertOrUpdate(Trigger.new, Trigger.newMap); // new new
        }

        /* Before Delete */
        else if (Trigger.isDelete && Trigger.isBefore) {
            handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
        }

        /* After Delete */
        else if (Trigger.isDelete && Trigger.isAfter) {
            handler.onAfterDelete(Trigger.old, Trigger.oldMap);
        }
    }

    DLT_TicketTriggerHandler.run();
}