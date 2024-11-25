public class SubmitDeactivationNotification {

    @InvocableMethod
    public static void pushNotification(List<Id> usersIds) {
        List<String> emailsToSend = new List<String>();
        List<User> users          = [SELECT Id, Username, Email, Profile.Name FROM User WHERE Id IN :usersIds];
        List<List_to_notify_about_Deactivation__c> settings = List_to_notify_about_Deactivation__c.getall().values();

        for (List_to_notify_about_Deactivation__c emailToSend : settings) {
            if (emailToSend.Email__c != null && !emailsToSend.contains(emailToSend.Email__c)) {
                emailsToSend.add(emailToSend.Email__c);
            }
        }

        for (User deactivatedUser : users) {
            sendMessage(emailsToSend, deactivatedUser.Username, deactivatedUser.Email, deactivatedUser.Profile.Name);
        }
    }

    private static void sendMessage(List<String> addresses, String username, String email, String profile) {
        System.debug('addresses: ' + addresses);
        if (addresses.isEmpty()) {
            return;
        }

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = addresses;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Integration user has been deactivated';
        message.plainTextBody = 'Integration user has been deactivated.\n\nUser information:\nUsername: '+ username + '\nEmail: ' + email + '\nProfile: ' + profile;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
}