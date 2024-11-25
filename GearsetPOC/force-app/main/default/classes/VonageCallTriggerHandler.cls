public with sharing class VonageCallTriggerHandler {

    private static final String PHONE_CASE_ORIGIN = 'Phone';
    private static final String STATUS_CASE_CLOSED = 'Closed';
    private static final String UPDATE_ACC_ERROR_MESSAGE = 'VonageCallTriggerHandler: Last Survey Sent field on Account was not update successfully';

    public static void senCSATEmailAfterVonageCall(Map<Id, NVMStatsSF__NVM_Call_Summary__c> odlVonageCalls, List<NVMStatsSF__NVM_Call_Summary__c> vonageCalls) {
        List<Id> relatedIdCases = new List<Id>();
        List<Id> userIds = new List<Id>();
        for (NVMStatsSF__NVM_Call_Summary__c vonageCall : vonageCalls) {
            if (((odlVonageCalls == null || odlVonageCalls.get(vonageCall.Id)?.NVMStatsSF__Call_Transcription__c == null)
                    && vonageCall?.NVMStatsSF__Call_Transcription__c != null) && vonageCall?.NVMStatsSF__Related_Case__c != null
            ) {
                relatedIdCases.add(vonageCall.NVMStatsSF__Related_Case__c);
                userIds.add(vonageCall.NVMStatsSF__Agent__c);
            }
        }
        if (relatedIdCases.isEmpty()) {
            return;
        }

        CSAT_Email__mdt emailMetadata = SendCSATEmailController.metadataSelector();
        List<String> caseRTExcluded = emailMetadata.Excluded_Record_Types__c.split(';');

        List<Id> accountUpdateIds = new List<Id>();
        List<Case> caseUpdates = new List<Case>();
        for (Case caseRecord : [SELECT Id, AccountId, Account.Last_Survey_Sent__c, Origin,
                                    RecordType.DeveloperName, Preferred_language__c, ContactEmail,
                                        (SELECT Id FROM NVMStatsSF__NVM_Call_Summaries__r)
                                FROM Case
                                WHERE AccountId != null AND Account.CSAT_Opt_Out__c = FALSE
                                    AND RecordType.DeveloperName NOT IN : caseRTExcluded
                                    AND Origin =: PHONE_CASE_ORIGIN AND Status =: STATUS_CASE_CLOSED
                                    AND Id =: relatedIdCases]
        ) {
            if (caseRecord.NVMStatsSF__NVM_Call_Summaries__r.size() == 1) {
                Double countDateFromLastSent = caseRecord.Account?.Last_Survey_Sent__c == null ?
                                        emailMetadata.No_days_to_exclude_CSAT_send__c + 2 :
                                        Date.valueOf(caseRecord.Account?.Last_Survey_Sent__c).daysBetween(Date.valueOf(System.today()));
                if (emailMetadata.No_days_to_exclude_CSAT_send__c < countDateFromLastSent) {
                    accountUpdateIds.add(caseRecord.AccountId);
                    caseUpdates.add(caseRecord);
                }
            }
        }
        if (caseUpdates.isEmpty()) {
            return;
        }

        try {
            SendCSATEmailController.sendEmailMessages(caseUpdates);
            SendCSATEmailController.preapreAccountCaseToUpdate(caseUpdates);
            updateUserCSATNumbersOfSending(userIds);
        } catch(Exception e) {
            throw new SendCSATEmailException(UPDATE_ACC_ERROR_MESSAGE);
        }
    }

    @InvocableMethod(label='Update User CSAT Numbers')
    public static void updateUserCSATNumbersOfSending(List<Id> userIds) {
        List<User> usersToUpdate = new List<User>();
        for (User currentUser : [SELECT Id, Number_of_CSAT_s_sent__c FROM User WHERE Id IN: userIds]) {
            currentUser.Number_of_CSAT_s_sent__c = currentUser.Number_of_CSAT_s_sent__c == null
                                                    ? 1 : currentUser.Number_of_CSAT_s_sent__c + 1;
            usersToUpdate.add(currentUser);
        }
        if (!usersToUpdate.isEmpty() && !System.isFuture() && !System.isBatch()) {
            update usersToUpdate;
        }
    }

    private class SendCSATEmailException extends Exception {}
}