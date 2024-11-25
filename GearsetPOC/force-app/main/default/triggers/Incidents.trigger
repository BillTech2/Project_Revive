trigger Incidents on Incidents__c (before insert, before update, before delete, after insert, 
    after update, after delete, after undelete) {

	/* Get singleton handler's instance */
    IncidentsTriggerHandler handler = IncidentsTriggerHandler.getInstance();

    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {
        handler.onBeforeInsert(Trigger.new);
    }

    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new, Trigger.newMap);
    }

    /* Before Update */
    else if (Trigger.isUpdate && Trigger.isBefore) {
        handler.onBeforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }

    /* After Update */
    else if (Trigger.isUpdate && Trigger.isAfter) {
        handler.onAfterUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }

    /* Before Delete */
    else if (Trigger.isDelete && Trigger.isBefore) {
        handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    }

    /* After Delete */
    else if (Trigger.isDelete && Trigger.isAfter) {
        handler.onAfterDelete(Trigger.old, Trigger.oldMap);
    }

    /* After Undelete */
    else if (Trigger.isUnDelete) {
        handler.onAfterUndelete(Trigger.new, Trigger.newMap);
    }
}