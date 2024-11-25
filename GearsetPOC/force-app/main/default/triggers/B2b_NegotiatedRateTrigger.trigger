trigger B2b_NegotiatedRateTrigger on B2b_NrDetails__c (before insert,before update,before delete,after insert,after update,after delete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Negotiated_Rate_Automation__c || DLT_NegotiatedRateTriggerHandler.isDisabled) { return; }

    DLT_NegotiatedRateTriggerHandler.run();

}