public with sharing class TrainTriggerHandler{
    public static TrainTriggerHandler instance;

    public static TrainTriggerHandler getInstance() {
        if (instance == null) {
            instance = new TrainTriggerHandler();
        }
        return instance;
    }

    /**
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */ 
    public void onBeforeInsert(final List<Train__c> newObjects) {
        CompApp_AdditionalCompUtils.getAdditionalCompensationRule(newObjects);
    }

    /**
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(final List<Train__c> newObjects, final Map<Id, Train__c> newObjectsMap) {
    }


    /**
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onBeforeUpdate(final List<Train__c> oldObjects, final Map<Id, Train__c> oldObjectsMap,
                               final List<Train__c> newObjects, final Map<Id, Train__c> newObjectsMap) {
                                   CompApp_AdditionalCompUtils.getAdditionalCompensationRule(newObjects, oldObjectsMap );
    }

    /**
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<Train__c> oldObjects, final Map<Id, Train__c> oldObjectsMap,
                              final List<Train__c> newObjects, final Map<Id, Train__c> newObjectsMap) {
        /*
         * Commented because of errors while updating bulk load
         * 
         * Map<Id,Train__c> newProcceedTrainObjects = CompApp_TriggerUtils.getProcceedTrains(newObjects, oldObjectsMap); 
        if (newProcceedTrainObjects.size() != 0){
            CompApp_TriggerUtils.upsertCompensations(
                CompApp_TriggerUtils.getCompensationCreationData(newProcceedTrainObjects)
            );
        }*/
    }

    /**
    * @description fired on before delete event, deletes all the attached documents and sets the application active to false
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    public void onBeforeDelete(final List<Train__c> oldObjects, final Map<Id, Train__c> oldObjectsMap) {
    }

    /**
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */
    //public void onAfterDelete(final List<Train__c> oldObjects, final Map<Id, Train__c> oldObjectsMap) {
    //    delete [SELECT Id FROM Compensation__c where Train__c IN : oldObjects];
    //}

    public void onAfterDelete(final List<Train__c> oldObjects, final Map<Id, Train__c> oldObjectsMap) {
    }

    /**
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    public void onAfterUndelete(final List<Train__c> newObjects, final Map<Id, Train__c> newObjectsMap) {
    }

}