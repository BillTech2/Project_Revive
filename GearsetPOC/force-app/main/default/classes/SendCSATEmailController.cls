public with sharing class SendCSATEmailController {

    @AuraEnabled
    public static Map<String, String> prepareSendCSATMessage(Id caseId, Id userId) {
        try {
            CSAT_Email__mdt emailMetadata = metadataSelector();
            Case recordCase = currentCaseRecordSelector(caseId, emailMetadata.Excluded_Case_Origins__c.split(';'),
                                                            emailMetadata.Excluded_Record_Types__c.split(';'));
            return calculateCSATSendEmailoperations(emailMetadata, recordCase, userId);
        } catch (Exception e) {
            Map<String, String> returnResultMap = new Map<String, String>();
            returnResultMap.put('Error', 'CSAT cannot be sent for this case');
            return returnResultMap;
        }
    }

    public static CSAT_Email__mdt metadataSelector() {
        CSAT_Email__mdt csatEmail;
        if (Test.isRunningTest()) {
            csatEmail = metadataCreation();
        } else {
            csatEmail = [
                SELECT Id, Sender_Email__c, English_Email_Template__c, French_Email_Template__c,
                    German_Email_Template__c, Dutch_Email_Template__c, Default_Email_Template__c,
                    No_days_to_exclude_CSAT_send__c, Excluded_Case_Origins__c, Excluded_Record_Types__c
                FROM CSAT_Email__mdt LIMIT 1
            ];
        }
        return csatEmail;
    }

    public static void sendEmailMessages(List<Case> caseRecords) {
        Map<String, Object> params = new Map<String, Object>();
        params.put('caseRecords', caseRecords);
        Flow.Interview.Send_CSAT_Email_Flow yourFlow = new Flow.Interview.Send_CSAT_Email_Flow(params);
        if (!Test.isRunningTest()) {
            yourFlow.start();
        }
    }

    @InvocableMethod(label='Update Case/Account records')
    public static void preapreAccountCaseToUpdate(List<Case> caseUpdates) {
        Set<Account> accountToUpdate = new Set<Account>();
        Set<Case> caseToUpdate = new Set<Case>();
        for (Case caseRecord : caseUpdates) {
            caseToUpdate.add(new Case(
                Id = caseRecord.Id,
                CSAT_Survey_Sent__c = System.today()
            ));
            accountToUpdate.add(new Account(
                Id = caseRecord.AccountId,
                Last_Survey_Sent__c = System.today()
            ));
        }
        update new List<Account>(accountToUpdate);
        update new List<Case>(caseToUpdate);
    }

    private static Map<String, String> calculateCSATSendEmailoperations(CSAT_Email__mdt emailMetadata, Case caseRecord, Id userId) {
        Map<String, String> returnResultMap = new Map<String, String>();
        Double countDateFromLastSent = caseRecord.Account?.Last_Survey_Sent__c == null ?
                                        emailMetadata.No_days_to_exclude_CSAT_send__c + 2 :
                                        Date.valueOf(caseRecord.Account?.Last_Survey_Sent__c)
                                                .daysBetween(Date.valueOf(System.today()));
        if (emailMetadata.No_days_to_exclude_CSAT_send__c < countDateFromLastSent) {
            sendEmailMessages(new List<Case>{caseRecord});
            preapreAccountCaseToUpdate(new List<Case> {caseRecord});
            VonageCallTriggerHandler.updateUserCSATNumbersOfSending(new List<Id>{userId});
            returnResultMap.put('Success',
                                'CSAT Email has sent.'
            );
        } else {
            returnResultMap.put('Error',
                                'Please pay attention that previous CSAT Email was sent '
                                    + Integer.valueOf(countDateFromLastSent) + ' days ago.'
                                    + ' You don\'t have a permission to send messages often.'
            );
        }
        return returnResultMap;
    }

    private static Case currentCaseRecordSelector(Id caseId, List<String> caseOriginExcluded, List<String> caseRTExcluded) {
        return [
            SELECT Id, AccountId, Account.Last_Survey_Sent__c, Origin,
                RecordType.DeveloperName, Preferred_language__c, ContactEmail
            FROM Case
            WHERE AccountId != null AND Account.CSAT_Opt_Out__c = FALSE
                AND RecordType.DeveloperName NOT IN : caseRTExcluded
                AND Origin NOT IN : caseOriginExcluded AND Id =: caseId
        ];
    }

    private static CSAT_Email__mdt metadataCreation() {
        CSAT_Email__mdt csatEmail = new CSAT_Email__mdt(
            English_Email_Template__c = 'test EN',
            French_Email_Template__c = 'test FR',
            German_Email_Template__c = 'test GR',
            Dutch_Email_Template__c = 'test DU',
            Default_Email_Template__c = 'test Default',
            No_days_to_exclude_CSAT_send__c = 7,
            Excluded_Case_Origins__c = 'Email Lost Property;Email Exec;Email SpecialServices',
            Excluded_Record_Types__c = 'B2B_group_booking;DPAX;Disruption_Case;E4A_Subscriber_Request;Fraud_Audit;GDPR;GDS_HelpDesk;MICE_Booking;PRR_Case;Trade'
        );
        return csatEmail;
    }
}