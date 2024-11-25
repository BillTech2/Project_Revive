trigger SubscriptionTrigger on Subscription__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Subscription_Automation__c || DLT_SubscriptionTriggerHandler.isDisabled) { return; }

    DLT_SubscriptionTriggerHandler.run();
}