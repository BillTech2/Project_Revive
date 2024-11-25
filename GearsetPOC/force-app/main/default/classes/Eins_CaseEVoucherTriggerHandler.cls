public without sharing class Eins_CaseEVoucherTriggerHandler {
    public static Id queueId;

    public static void sendNotification(List<Case_eVoucher__c> newCaseVouchers, Map<Id, Case_eVoucher__c> oldCaseVouchers) {
        List<CustomNotificationType> completedNotification = [
            SELECT Id, DeveloperName 
            FROM CustomNotificationType 
            WHERE DeveloperName = 'Completed_Case_eVoucher'
            LIMIT 1
        ];
        List<QueueSobject> queue = [
            SELECT Queue.Id
            FROM QueueSobject
            WHERE Queue.Name = 'eVoucher'
            LIMIT 1
        ];
        if (!queue.isEmpty()) {
            queueId = queue[0].Queue.Id;
        }
        String completedNotificationId;
        if (!completedNotification.isEmpty()) {
            completedNotificationId = completedNotification[0].Id;
        }
        for (Case_eVoucher__c caseVoucher : newCaseVouchers) {
            if (caseVoucher.Status__c != oldCaseVouchers.get(caseVoucher.Id).Status__c &&
               (caseVoucher.Status__c == 'Completed - rejected' || caseVoucher.Status__c == 'Completed - resolved')
            ) {
                if (String.isNotBlank(completedNotificationId)) {
                    createCustomNotification(
                        'The eVoucher was completed', 
                        'The eVoucher status is ' + caseVoucher.Status__c,
                        completedNotificationId,
                        caseVoucher.Id,
                        caseVoucher.CreatedById
                    );
                }
            }
            // if (caseVoucher.OwnerId != oldCaseVouchers.get(caseVoucher.Id).OwnerId) {
            //     if (String.isNotBlank(completedNotificationId)) {
            //         Id userId;
            //         if (String.isNotBlank(queueId)) {
            //             if (oldCaseVouchers.get(caseVoucher.Id).OwnerId != queueId) {
            //                 userId = oldCaseVouchers.get(caseVoucher.Id).OwnerId;
            //             } else {
            //                 userId = caseVoucher.CreatedById;
            //             }
            //         } else {
            //             userId = oldCaseVouchers.get(caseVoucher.Id).OwnerId;
            //         }
            //         createCustomNotification(
            //             'The eVoucher Owner was changed', 
            //             'The eVoucher Owner was changed.',
            //             completedNotificationId,
            //             caseVoucher.Id,
            //             userId
            //         );
            //     }
            // }
        }
    }

    public static void createCustomNotification(String title, String body, Id completedNotificationId, Id caseVoucherId, Id userId) {
        Messaging.CustomNotification customNotification = new Messaging.CustomNotification();
        customNotification.setTitle(title);
        customNotification.setBody(body);
        customNotification.setNotificationTypeId(completedNotificationId);
        customNotification.setTargetId(caseVoucherId);

        try {
            customNotification.send(new Set<String> { userId });
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}