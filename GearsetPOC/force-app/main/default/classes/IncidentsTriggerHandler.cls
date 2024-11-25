/**
 * This class take care of all the logic that happens when a trigger on the object Incidents__c is triggered.
 * @createdBy   Israel Chayon, 30.8.15         
 * @lastModifiedBy  Israel Chayon, 30.8.15
 */
public with sharing class IncidentsTriggerHandler {

    public static IncidentsTriggerHandler instance;

    public static IncidentsTriggerHandler getInstance() {
        if (instance == null) {
            instance = new IncidentsTriggerHandler(); 
        }
        return instance;
    }
    /**
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    public void onBeforeInsert(final List<Incidents__c> newObjects) {
		CompApp_IncidentCompUtils.getIncidentCompensationRule(newObjects);
    }

    /**
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(final List<Incidents__c> newObjects, final Map<Id, Incidents__c> newObjectsMap) {
        CompApp_TriggerUtils.upsertCompensations(
                                            CompApp_TriggerUtils.getCompensationCreationData(newObjects, newObjectsMap)
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
    public void onBeforeUpdate(final List<Incidents__c> oldObjects, final Map<Id, Incidents__c> oldObjectsMap,
                               final List<Incidents__c> newObjects, final Map<Id, Incidents__c> newObjectsMap) {
                  CompApp_IncidentCompUtils.getIncidentCompensationRule(newObjects);
        
    }

    /**
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<Incidents__c> oldObjects, final Map<Id, Incidents__c> oldObjectsMap,
                              final List<Incidents__c> newObjects, final Map<Id, Incidents__c> newObjectsMap) { 
        CompApp_TriggerUtils.upsertCompensations(
                                            CompApp_TriggerUtils.getCompensationCreationData(newObjects, newObjectsMap)
                                        );
    }

    /**
    * @description fired on before delete event, deletes all the attached documents and sets the application active to false
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    public void onBeforeDelete(final List<Incidents__c> oldObjects, final Map<Id, Incidents__c> oldObjectsMap) {
        
    }

    /**
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */

    public void onAfterDelete(final List<Incidents__c> oldObjects, final Map<Id, Incidents__c> oldObjectsMap) {
        CompApp_TriggerUtils.upsertCompensations(
                                            CompApp_TriggerUtils.getCompensationCreationData(oldObjects, oldObjectsMap)
                                        );
    }

    /**
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    public void onAfterUndelete(final List<Incidents__c> newObjects, final Map<Id, Incidents__c> newObjectsMap) {
    }

  }