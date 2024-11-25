trigger PreferenceTrigger on Preference__c (before insert, after insert, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Preference_Automation__c || PreferenceTriggerHandler.isDisabled) { return; }

    List<Preference__c> validatedRecordsToProcessing = new List<Preference__c>();
    
    if (Trigger.isBefore) {
        if(Trigger.isInsert){
            validatedRecordsToProcessing = PreferenceTriggerHandler.weedOutTheRecordsWhichCanCauseRecursion(Trigger.new);

            if (validatedRecordsToProcessing.isEmpty() == FALSE) {
                PreferenceTriggerHandler.updatePreferences(validatedRecordsToProcessing);
            }
        }
    }

    if (Trigger.isAfter) {
        if(Trigger.isInsert){
            PreferenceTriggerHandler.onAfterInsert(Trigger.newMap);
        
            PreferenceTriggerHandler.markProcessedRecords(validatedRecordsToProcessing);
            
            if (PreferenceTriggerHandler.accountsToUpdate != null && PreferenceTriggerHandler.accountsToUpdate.values().isEmpty() == FALSE) {
                update PreferenceTriggerHandler.accountsToUpdate.values();
            }
    
            if (PreferenceTriggerHandler.accountsToUpdate != null && PreferenceTriggerHandler.preferenceToUpdate.values().isEmpty() == FALSE) {
                update PreferenceTriggerHandler.preferenceToUpdate.values();
            }
        }else if(Trigger.isUpdate){
            PreferenceTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}