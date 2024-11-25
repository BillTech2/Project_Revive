trigger CreditCardTrigger on Credit_Card__c (after insert, after update, after delete) {
    AccountingSyncHelper.startSync(
        Trigger.isDelete ? Trigger.oldMap.keySet() : Trigger.newMap.keySet(),
        AccountingSyncHelper.CREDIT_CARD_OBJECT_NAME,
        AccountingSyncHelper.getOperationNameFromTriggerContext()
    );
}