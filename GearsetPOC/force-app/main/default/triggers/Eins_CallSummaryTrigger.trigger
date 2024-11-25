trigger Eins_CallSummaryTrigger on NVMStatsSF__NVM_Call_Summary__c (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        Eins_CallSummaryTriggerHandler.updateRelatedCase(Trigger.new, true);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Eins_TaskTriggerHandler.updateCase(Trigger.new);
    }

}