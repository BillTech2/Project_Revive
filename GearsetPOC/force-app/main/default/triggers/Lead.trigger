trigger Lead on Lead (before insert, before update, after update) {

    /* Get singleton handler's instance */
    LeadTriggerHandler handler = LeadTriggerHandler.getInstance();

    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('\n>>>>>>before insert');

        handler.onBeforeInsert(Trigger.new);
    }

    /* After update */
    if (Trigger.isUpdate && Trigger.isBefore) {
        System.debug('\n>>>>>>after update');

        handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }


}