public class SubmitReactivationNotification {
    @InvocableMethod
    public static void pushNotification(List<Id> usersIds) {
        List<String> emailsToSend = new List<String>();
        List<User> users = [SELECT Id, Username, Email, Profile.Name FROM User WHERE Id IN :usersIds];
        List<List_to_notify_about_Reactivation__c> settings = List_to_notify_about_Reactivation__c.getall().values();

        for (List_to_notify_about_Reactivation__c emailToSend : settings) {
            if (emailToSend.Email__c != null && !emailsToSend.contains(emailToSend.Email__c)) {
                emailsToSend.add(emailToSend.Email__c);
            }
        }

        for (User reactivatedUser : users) {
            sendMessage(emailsToSend, reactivatedUser.Username, reactivatedUser.Email, reactivatedUser.Profile.Name);
        }
    }

    @future
    private static void sendMessage(List<String> addresses, String username, String email, String profile) {
        System.debug('addresses: ' + addresses);
        if (addresses.isEmpty()) {
            return;
        }

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = addresses;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Non-active user has been reactivated by Azure SSO';
        message.plainTextBody = 'Non-active user has been reactivated by Azure SSO.\n\nUser information:\nUsername: '+ username + '\nEmail: ' + email + '\nProfile: ' + profile;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
}