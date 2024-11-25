trigger FavouriteTravellerTrigger on Favourite_Traveller__c (after insert, after update, after delete) {
	AccountingSyncHelper.startSync(
		Trigger.isDelete ? Trigger.oldMap.keySet() : Trigger.newMap.keySet(),
		AccountingSyncHelper.FAVOURITE_TRAVELLER_OBJECT_NAME,
		AccountingSyncHelper.getOperationNameFromTriggerContext()
	);
}