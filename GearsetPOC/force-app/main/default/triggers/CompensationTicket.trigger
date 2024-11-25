trigger CompensationTicket on Compensation_Ticket__c (before insert, before update, before delete, after insert, 
    after update, after delete, after undelete) {

    /* Get singleton handler's instance */
    //CompensationTicketTriggerHandler handler = CompensationTicketTriggerHandler.getInstance();

    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {
        //handler.onBeforeInsert(Trigger.new);
    }

    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert) {
        //handler.onAfterInsert(Trigger.new, Trigger.newMap);
        Set<Id> compIdSet = new Set<Id>();
        for(Compensation_Ticket__c jtk : Trigger.new){
            compIdSet.add(jtk.Compensation__c);
        }
        system.debug('Im in after insert of jtk and my compIdSet is: '+compIdSet);
        CompApp_TriggerUtils.calculateTotalCompensation(compIdSet);
    }

    /* Before Update */
    else if (Trigger.isUpdate && Trigger.isBefore) {
        //handler.onBeforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }

    /* After Update */
    else if (Trigger.isUpdate && Trigger.isAfter) {
        //handler.onAfterUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }

    /* Before Delete */
    else if (Trigger.isDelete && Trigger.isBefore) {
        //handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    }

    /* After Delete */
    else if (Trigger.isDelete && Trigger.isAfter) {
        //handler.onAfterDelete(Trigger.old, Trigger.oldMap);
    }

    /* After Undelete */
    else if (Trigger.isUnDelete) {
        //handler.onAfterUndelete(Trigger.new, Trigger.newMap);
    }
}