trigger PassingPointTrigger on Passing_Point__c (before insert, after insert, before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Passing_Points_Automation__c || DLT_PassingPointTriggerHandler.isDisabled) { return; }

    DLT_PassingPointTriggerHandler.run();
}