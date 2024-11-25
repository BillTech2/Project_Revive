public with sharing class CompensationTriggerHandler {

    public static CompensationTriggerHandler instance;
    public Set<Id> multipleTicketComensation;

    public static CompensationTriggerHandler getInstance() {
        if (instance == null) {
            instance = new CompensationTriggerHandler();
        }
        return instance;
    } 

    public void onBeforeInsert(final List<Compensation__c> newObjects) {
        CompApp_TriggerUtils.assertCaseRelatedToTicket(newObjects);
    }

    /**
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(final List<Compensation__c> newObjects, final Map<Id, Compensation__c> newObjectsMap) {
        CompApp_TriggerUtils.newObjectsMap = newObjectsMap;
        this.multipleTicketComensation = CompApp_TriggerUtils.getCompensationToTicketManyToMany(newObjects);
        CompApp_TriggerUtils.attachCompensatioToTicktsByPNR(newObjectsMap,this.multipleTicketComensation); 
        CompApp_Utils.log('insert this.multipleTicketComensation @ onBeforeUpdate: ' + this.multipleTicketComensation);
        CompApp_TriggerUtils.resetLinkCompensationFlag(this.multipleTicketComensation);
        CompApp_TriggerUtils.updateVoucherIssueTypeFlag(newObjectsMap, this.multipleTicketComensation);

        List<Compensation__c> compensationToApprove = new List<Compensation__c>();
        for (Compensation__c compensationItem: newObjects) {
            if (compensationItem.Comp_Approval_Status__c != 'Approved') {
                compensationToApprove.add(compensationItem);
            }
        }
        if (!compensationToApprove.isEmpty()) {
            CompApp_TriggerUtils.submitForApprovalMatchingCompensations(compensationToApprove);
            PromEV_Utils.eVoucherCreationManualVersion(compensationToApprove);
        }

    }

    /**
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onBeforeUpdate(final List<Compensation__c> oldObjects, final Map<Id, Compensation__c> oldObjectsMap,
                               final List<Compensation__c> newObjects, final Map<Id, Compensation__c> newObjectsMap) {
        this.multipleTicketComensation = CompApp_TriggerUtils.getCompensationToTicketManyToMany(newObjects);
        CompApp_Utils.log('this.multipleTicketComensation @ onBeforeUpdate: ' + this.multipleTicketComensation);

    }

    /**
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<Compensation__c> oldObjects, final Map<Id, Compensation__c> oldObjectsMap,
                              final List<Compensation__c> newObjects, final Map<Id, Compensation__c> newObjectsMap) {   
        CompApp_TriggerUtils.newObjectsMap = newObjectsMap;
        CompApp_TriggerUtils.calculateTotalCompensation(newObjectsMap.keySet());
        CompApp_TriggerUtils.calculateEvoucherTotalCompensation(newObjects , oldObjectsMap) ;
    }
     
    /**
    * @description fired on before delete event, deletes all the attached documents and sets the application active to false
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    public void onBeforeDelete(final List<Compensation__c> oldObjects, final Map<Id, Compensation__c> oldObjectsMap) {
        
    }

    /**
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */

    public void onAfterDelete(final List<Compensation__c> oldObjects, final Map<Id, Compensation__c> oldObjectsMap) { // ask naor if thats a good replacement to onAfterDelete method
    }

    /**
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    public void onAfterUndelete(final List<Compensation__c> newObjects, final Map<Id, Compensation__c> newObjectsMap) {
    }

    
}