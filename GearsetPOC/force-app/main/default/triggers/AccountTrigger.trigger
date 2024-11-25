trigger AccountTrigger on Account (before insert, after insert, before update, after update, after delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Account_Automation__c || DLT_AccountTriggerHandler.isDisabled) { return; }

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountTriggerHandler.onBeforeInsert(Trigger.new);            
        }else if(Trigger.isUpdate){
            AccountTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }else if (Trigger.isAfter) {
        if(Trigger.isUpdate){
            AccountTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    //if (!System.isFuture() && !System.isBatch()) {
    //before Quick Create action email workaround trigger was not supposed to be invoked on "before insert"
    if (!(Trigger.isInsert && Trigger.isBefore) && (!System.isFuture() && !System.isBatch())) {
        AccountingSyncHelper.startSync(
            Trigger.isDelete ? Trigger.oldMap.keySet() : Trigger.newMap.keySet(),
            AccountingSyncHelper.ACCOUNT_OBJECT_NAME,
            AccountingSyncHelper.getOperationNameFromTriggerContext()
        );
    }

    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter && !System.isFuture() && !System.isBatch()) {
        OSF_Account_TriggerHandler.processLoyaltyChanges(Trigger.New, Trigger.oldMap);
    }

    DLT_AccountTriggerHandler.run();
}