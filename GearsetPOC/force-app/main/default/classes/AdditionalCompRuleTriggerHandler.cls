/**
 * This class take care of all the logic that happens when a trigger on the object Incidents__c is triggered.
 * @createdBy   Reghunath Sreekumarnath, 02.MAY.2019         
 * @lastModifiedBy  Reghunath Sreekumarnath, 02.MAY.2019         
 */
public with sharing class AdditionalCompRuleTriggerHandler {

    public static AdditionalCompRuleTriggerHandler instance;

    public static AdditionalCompRuleTriggerHandler getInstance() {
        if (instance == null) {
            instance = new AdditionalCompRuleTriggerHandler();
        }
        return instance;
    }
      
    /**
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    public void onBeforeInsert(final List<Additional_Compensation_Rules__c> newObjects) { 
		CompApp_AdditionalCompUtils.validateAdditionalCompensationRule(newObjects);
    }

    /**
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onBeforeUpdate(final List<Additional_Compensation_Rules__c> oldObjects, final Map<Id, Additional_Compensation_Rules__c> oldObjectsMap,
                               final List<Additional_Compensation_Rules__c> newObjects, final Map<Id, Additional_Compensation_Rules__c> newObjectsMap) { 
         CompApp_AdditionalCompUtils.validateAdditionalCompensationRule(newObjects, oldObjectsMap);
    }

    /**
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<Additional_Compensation_Rules__c> oldObjects, final Map<Id, Additional_Compensation_Rules__c> oldObjectsMap,
                              final List<Additional_Compensation_Rules__c> newObjects, final Map<Id, Additional_Compensation_Rules__c> newObjectsMap) {  
                                  
          CompApp_AdditionalCompUtils.updateTrains(CompApp_AdditionalCompUtils.getTrainsToUpdate(newObjects, oldObjectsMap));                        
    }


  }