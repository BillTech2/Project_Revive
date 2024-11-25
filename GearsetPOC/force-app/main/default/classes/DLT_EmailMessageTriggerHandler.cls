public without sharing class DLT_EmailMessageTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {

            }

            if (System.Trigger.isUpdate) {
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                updateCasesWhenCustomerReplyByEmail(filterCaseIdFromEmails(Trigger.new));
            }

            if (System.Trigger.isUpdate) {

            }
        }
    }


    private static void updateCasesWhenCustomerReplyByEmail(Set<Id> caseIds) {

        List<Case> caseToUpdate = new List<Case>();

        for (Case c :[
            SELECT Id, Status, Sub_Status__c
            FROM Case
            WHERE Id IN :caseIds
        ]) {

            c.Status = DLT_CaseConstants.STATUS_REOPENED;
            c.Sub_Status__c = DLT_CaseConstants.SUB_STATUS_CUSTOMER_RESPONDED;

            caseToUpdate.add(c);
        }

        update caseToUpdate;
    }

    private static Set<Id> filterCaseIdFromEmails(List<EmailMessage> emails) {

        Set<Id> caseIds = new Set<Id>();

        for (EmailMessage email : emails) {
            if (email.Incoming && email.TextBody.contains(':ref') && email.TextBody.contains('ref:')) {
                caseIds.add(email.ParentId);
            }
        }

        return caseIds;
    }

}