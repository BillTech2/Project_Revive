public without sharing class EmailServiceController {

    public static List<OrgWideEmailAddress> fromAddress = new List<OrgWideEmailAddress>();

    public static Messaging.SingleEmailMessage createEmail(Case caseItem) {
        String templateDevName = 'cu_' + caseItem.TemplateId__c;
        if (caseItem.Preferred_Language__c == 'French') {
            templateDevName = templateDevName + '_fr';
        }
        if (caseItem.Preferred_Language__c == 'Dutch') {
            templateDevName = templateDevName + '_nl';
        }
        if (caseItem.Preferred_Language__c == 'German') {
            templateDevName = templateDevName + '_de';
        }
        List<EmailTemplate> template = [
            SELECT Id, HtmlValue, Body, Subject
            FROM EmailTemplate
            WHERE DeveloperName =: templateDevName
            LIMIT 1
        ];
        if (fromAddress.isEmpty()) {
            fromAddress = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = :DLT_Settings__c.getInstance().Eurostar_Customer_Care_OrgWideEmail_Name__c
                LIMIT 1
            ];
        }
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        if (!template.isEmpty()) {
            String emailHTMLBody = template[0].HtmlValue;
            String plainTextBody = template[0].Body;
            String emailSubject = template[0].Subject;

            if (String.isNotBlank(caseItem.Customer_Name__c)) {
                emailHTMLBody = emailHTMLBody.replace('{!Contact.FirstName}', caseItem.Customer_Name__c);
            } else {
                emailHTMLBody = emailHTMLBody.replace('{!Contact.FirstName}', '');
            }
            emailHTMLBody = emailHTMLBody.replace('{CaseUrl}', HashController.createLink(caseItem.Id));
            emailHTMLBody = emailHTMLBody.replace('{!CaseUrl}', HashController.createLink(caseItem.Id));
            if(emailSubject != null) emailSubject = emailSubject.replace('{!Case.CaseNumber}', caseItem.CaseNumber);

            // if (!String.isNotBlank(plainTextBody)) {
            //     if (plainTextBody.containsIgnoreCase('{!Contact.FirstName}')) {
            //         plainTextBody = plainTextBody.replace('{!Contact.FirstName}', caseItem.Customer_Name__c);
            //     }
            //     if (plainTextBody.containsIgnoreCase('{CaseUrl}')) {
            //         plainTextBody = plainTextBody.replace('{CaseUrl}', HashController.createLink(caseItem.Id));
            //     }
            //     emailMessage.setPlainTextBody(plainTextBody);
            // }

            emailMessage.setHtmlBody(emailHTMLBody);
            emailMessage.setTargetObjectId(UserInfo.getUserId());
            emailMessage.setTreatTargetObjectAsRecipient(false);
            emailMessage.setSubject(emailSubject);
            if (Test.isRunningTest()) {
                fromAddress = new List<OrgWideEmailAddress>();
            }
            if (!fromAddress.isEmpty()) {
                emailMessage.setOrgWideEmailAddressId(fromAddress[0].Id);
            }
            emailMessage.setToAddresses(new String[] { caseItem.Email__c.trim() });
        } else {
            System.debug('Email error. No template with this developer name: ' + templateDevName);
        }

        return emailMessage;
    }

    public static void sendEmails(List<Messaging.SingleEmailMessage> emailMessages) {
        Messaging.reserveSingleEmailCapacity(emailMessages.size());
        try {
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emailMessages);
        } catch(System.EmailException ex) {
            System.debug('Case error: ' + ex.getMessage());
        }
    }

}