public without sharing class SendEmailAfterInsertHelper {
    
    public static void sendEmailFromCase(List<Case> cases) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Case caseItem :cases) {
            if (String.isNotBlank(caseItem.TemplateId__c)) {
                Messaging.SingleEmailMessage mailMessage = EmailServiceController.createEmail(caseItem);
                emailMessages.add(mailMessage);
            }
        }
        if (!emailMessages.isEmpty()) {
            EmailServiceController.sendEmails(emailMessages);
        }
    }
}