public with sharing class PublicSiteCaseHolderTriggerHandler {
	public static PublicSiteCaseHolderTriggerHandler instance;

    public static PublicSiteCaseHolderTriggerHandler getInstance() {
        if (instance == null) {
            instance = new PublicSiteCaseHolderTriggerHandler();
        }
        return instance;
    } 
    /**
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    public void onBeforeInsert(final List<Public_Site_Case_Holder__c> newObjects) {    	
    }

    /**
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(List<Public_Site_Case_Holder__c> newObjects, Map<Id, Public_Site_Case_Holder__c> newObjectsMap){
        CompApp_TriggerUtils.convertPublicSiteCaseHolderToCase(
                                                    getNewReadyForCase
                                                            (
                                                                newObjects,
                                                                null
                                                     )
                                );
    }


    /**
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onBeforeUpdate(final List<Public_Site_Case_Holder__c> oldObjects, final Map<Id, Public_Site_Case_Holder__c> oldObjectsMap,
                               final List<Public_Site_Case_Holder__c> newObjects, final Map<Id, Public_Site_Case_Holder__c> newObjectsMap) {
    }

    /**
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<Public_Site_Case_Holder__c> oldObjects, final Map<Id, Public_Site_Case_Holder__c> oldObjectsMap,
                              final List<Public_Site_Case_Holder__c> newObjects, final Map<Id, Public_Site_Case_Holder__c> newObjectsMap) {
    	CompApp_TriggerUtils.convertPublicSiteCaseHolderToCase(
                                                    getNewReadyForCase
                                                            (
                                                                newObjects,
                                                                oldObjectsMap
                                                     )
                                );
    }

    /**
    * @description fired on before delete event, deletes all the attached documents and sets the application active to false
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    public void onBeforeDelete(final List<Public_Site_Case_Holder__c> oldObjects, final Map<Id, Public_Site_Case_Holder__c> oldObjectsMap) {
        
    }

    /**
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */
    public void onAfterDelete(final List<Public_Site_Case_Holder__c> oldObjects, final Map<Id, Public_Site_Case_Holder__c> oldObjectsMap) {
    }

    /**
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    public void onAfterUndelete(final List<Public_Site_Case_Holder__c> newObjects, final Map<Id, Public_Site_Case_Holder__c> newObjectsMap) {
    }


    private List<Public_Site_Case_Holder__c> getNewReadyForCase(List<Public_Site_Case_Holder__c> triggerNewList, Map<Id,Public_Site_Case_Holder__c> triggerOldMap){
        List<Public_Site_Case_Holder__c> pCList = new List<Public_Site_Case_Holder__c>();
        for (Public_Site_Case_Holder__c pcHolder : triggerNewList){
            if (pcHolder.Convert_To_Case__c &&
                (
                    triggerOldMap == null || triggerOldMap.get(pcHolder.id).Convert_To_Case__c == false
                )){
                pCList.add(pcHolder);
            }
        }
        return pCList;
    }
}