public without sharing class Eins_GuideAssistanceDogTriggerHandler {

    public static void updateDogApprovalDates(List<Guide_assistance_dog__c> newDogs, Map<Id, Guide_assistance_dog__c> oldDogs) {
        for (Guide_assistance_dog__c dog : newDogs) {
            if ((dog.Status__c == 'Approved') && (dog.Status__c != oldDogs.get(dog.Id).Status__c)) {
                dog.Approval_Date__c = Date.today();
                dog.Expiry_Date__c = Date.today().addYears(1);
            }
            if ((dog.Status__c != oldDogs.get(dog.Id).Status__c) && (oldDogs.get(dog.Id).Status__c == 'Approved')) {
                dog.Approval_Date__c = null;
                dog.Expiry_Date__c = null;
            }
        }
    }

    public static void sendNotificationEmail(List<Guide_assistance_dog__c> newDogs, Map<Id, Guide_assistance_dog__c> oldDogs) {
        List<Guide_assistance_dog__c> notificationCorrectionsDogs = new List<Guide_assistance_dog__c>();
        List<Guide_assistance_dog__c> notificationApprovedDogs = new List<Guide_assistance_dog__c>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Guide_assistance_dog__c dog : newDogs) {
            if ((dog.Status__c == 'Needs corrections') && (dog.Status__c != oldDogs.get(dog.Id).Status__c)) {
                notificationCorrectionsDogs.add(dog);
            }
            if ((dog.Status__c == 'Approved') && (dog.Status__c != oldDogs.get(dog.Id).Status__c)) {
                notificationApprovedDogs.add(dog);
            }
        }
        if (!notificationCorrectionsDogs.isEmpty()) {
            emailMessages.addAll(Eins_SendEmailController.sendCorrectionsEmails(notificationCorrectionsDogs));
        }
        if (!notificationApprovedDogs.isEmpty()) {
            emailMessages.addAll(Eins_SendEmailController.sendApprovalEmails(notificationApprovedDogs));
        }

        if (!emailMessages.isEmpty()) {
            Eins_SendEmailController.sendEmails(emailMessages);
        }
    }
}