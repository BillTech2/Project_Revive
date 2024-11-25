public without sharing class EmailMessageTriggerHandler {

    public static final List<String> URGENT_ASSISTANCE_NOTIFICATION_RECIPIENTS = new List<String>{'customercomms@eurostar.com'};
    //customercomms@eurostar.com
    public static EmailMessageTriggerHandler instance;

    public static EmailMessageTriggerHandler getInstance() {
        if (instance == null) {
            instance = new EmailMessageTriggerHandler();
        }
        return instance;
    }

    public void onBeforeInsert(List<EmailMessage> newEmails) {
        Pattern maliciousPattern = Pattern.compile('(http|https)://([-a-zA-Z0-9]+[.])+([hH][oO][sS][tT]/)[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]*');
        Matcher bodyMatcher;
        List<EmailBlockedSubject__mdt> blockedSubjectList = [SELECT Subject__c FROM EmailBlockedSubject__mdt];
        for (EmailMessage email : newEmails) {
            if (email.Incoming) {
                if (email.textBody != null && email.textBody.length() > 0) {
                    bodyMatcher = maliciousPattern.matcher(email.textBody);
                    if (bodyMatcher.find()) {
                        email.addError('Links from .host is not allowed');
                        continue;
                    }
                }
                if (email.htmlBody != null && email.htmlBody.length() > 0) {
                    bodyMatcher = maliciousPattern.matcher(email.htmlBody);
                    if (bodyMatcher.find()) {
                        email.addError('Links from .host is not allowed');
                    }
                }
            }
            for (EmailBlockedSubject__mdt subject : blockedSubjectList) {
                if (email.Subject == subject.Subject__c){
                email.addError( subject.Subject__c + 'is not allowed');
                continue;
                }
            }
        }
    }

    public void onAfterInsert(List<EmailMessage> newEmails) {
        Set<Id> affectedCaseIds = new Set<Id>();
        for (EmailMessage email : newEmails) {
            if (email.Incoming) affectedCaseIds.add(email.ParentId);
        }

        List<Reason_Code__c> reasons = [SELECT Id FROM Reason_Code__c WHERE en_Label__c = 'Urgent Assistance'];
        if (reasons.size() > 0) {
            String urgentAssistanceId = reasons[0].Id;

            List<Case> cases = [
                    SELECT Id, CaseNumber, Owner.Name
                    FROM Case
                    WHERE Id IN :affectedCaseIds AND Reason_Code__c = :urgentAssistanceId
            ];

            List<Messaging.SingleEmailMessage> emailsForSend = new List<Messaging.SingleEmailMessage>();

            for (Case nextCase : cases) {
                Messaging.SingleEmailMessage nextMessage = createNotificationEmail(nextCase);
                emailsForSend.add(nextMessage);
            }

            List<Messaging.SendEmailResult> mailingResults = new List<Messaging.SendEmailResult>();

            if (emailsForSend.size() > 0) {
                mailingResults = Messaging.sendEmail(emailsForSend);
            }
        }
    }

    public static Messaging.SingleEmailMessage createNotificationEmail(Case record) {

        Messaging.SingleEmailMessage resultMessage = new Messaging.SingleEmailMessage();
        resultMessage.setToAddresses(URGENT_ASSISTANCE_NOTIFICATION_RECIPIENTS);
        resultMessage.setSubject('New email on Urgent Assistance case');

        String FirstLines = 'Hi Team.\r\n\r\nCase '+ record.CaseNumber + ' has a new email and is owned by ' + record.Owner.Name
                             + '\r\nPlease check Case for details\r\n\r\n';
        String link =  System.URL.getSalesforceBaseURL().toExternalForm() + '\\' + record.Id;

        resultMessage.setPlainTextBody(FirstLines + link);
        resultMessage.setSaveAsActivity(false);
        return resultMessage;
    }
}