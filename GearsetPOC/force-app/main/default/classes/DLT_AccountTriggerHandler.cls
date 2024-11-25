public without sharing class DLT_AccountTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                setInitialIntegrationFields((List<Account>)Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                updateIntegrationFields((Map<Id,Account>)Trigger.newMap, (Map<Id,Account>)Trigger.oldMap);
                clearHashedEmail((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {

            }

            if (System.Trigger.isUpdate) {

            }
        }
    }


    private static void setInitialIntegrationFields(List<Account> newAccountList) {

        for (Account account : newAccountList) {
            if (account.RecordTypeId == DLT_CustomerConstants.RT_ID_PERSON_ACCOUNT && !DLT_Constants.IS_INTEGRATION_USER) {
                account.put('SVOC_Integration__c', true);
            } else {
                account.put('SVOC_Integration__c', false);
            }
        }
    }

    private static void updateIntegrationFields(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap) {

        if (DLT_Constants.IS_INTEGRATION_USER) { return; }

        List<Schema.FieldSetMember> SVOCfieldSet = DLT_Utils.getFieldSetMembers(DLT_CustomerConstants.OBJECT_NAME, DLT_CustomerConstants.SVOC_FIELD_SET_NAME);
        List<Schema.FieldSetMember> TACTfieldSet = DLT_Utils.getFieldSetMembers(DLT_CustomerConstants.OBJECT_NAME, DLT_CustomerConstants.TACT_FIELD_SET_NAME);

        for (Account account : newAccountMap.values()) {
            if (account.RecordTypeId != DLT_CustomerConstants.RT_ID_PERSON_ACCOUNT) { continue; }

            if (account.SVOC_Integration__c != true) {
                account.put('SVOC_Integration__c', false);

                for (Schema.FieldSetMember field : SVOCfieldSet) {
                    if (account.get(field.getSObjectField()) != oldAccountMap.get(account.Id).get(field.getSObjectField())) {
                        account.put('SVOC_Integration__c', true);
                        break;
                    }
                }
            }

            if (account.Loyalty_Integration__c != true) {

                for (Schema.FieldSetMember field : TACTfieldSet) {
                    if (account.get(field.getSObjectField()) != oldAccountMap.get(account.Id).get(field.getSObjectField())) {
                        account.put('Loyalty_Integration__c', true);
                        break;
                    }
                }
            }
        }
    }

    private static void clearHashedEmail(List<Account> newAccounts, Map<Id,Account> oldAccountsMap) {
        for (Account acc : newAccounts) {
            if (acc.PersonContactId != null
                && acc.Customer_Email__pc != null
                && acc.Customer_Email__pc != oldAccountsMap.get(acc.Id).Customer_Email__pc
            ) {
                acc.Hashed_email__pc = null;
            }
        }
    }
}