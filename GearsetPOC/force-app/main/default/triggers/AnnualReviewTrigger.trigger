trigger AnnualReviewTrigger on Annual_Review__c (before insert, after insert, before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Annual_Review_Automation__c || DLT_BusinessAccountTriggerHandler.isDisabled) { return; }

    DLT_AnnualReviewTriggerHandler.run();
}