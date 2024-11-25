trigger Eins_GuideAssistanceDogTrigger on Guide_assistance_dog__c (before insert, before update, after update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        Eins_GuideAssistanceDogTriggerHandler.updateDogApprovalDates(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Eins_GuideAssistanceDogTriggerHandler.sendNotificationEmail(Trigger.new, Trigger.oldMap);
    }
}