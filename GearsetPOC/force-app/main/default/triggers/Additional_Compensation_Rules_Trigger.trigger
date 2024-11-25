trigger Additional_Compensation_Rules_Trigger  on Additional_Compensation_Rules__c (before insert, before update, after update ) {

/* Get singleton handler's instance */
    AdditionalCompRuleTriggerHandler handler = AdditionalCompRuleTriggerHandler.getInstance();
/* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {
        handler.onBeforeInsert(Trigger.New);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        handler.onBeforeUpdate(Trigger.Old, Trigger.OldMap, Trigger.New, Trigger.NewMap);
    } 
    if (Trigger.isUpdate && Trigger.isAfter) {
        handler.onAfterUpdate(Trigger.Old, Trigger.OldMap, Trigger.New, Trigger.NewMap);
    } 
}