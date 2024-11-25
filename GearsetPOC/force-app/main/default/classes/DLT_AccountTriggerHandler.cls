public without sharing class DLT_AccountTriggerHandler {
    public static Boolean isDisabled = false;

    private static Set<Id> processedRecordIdsInsert = new Set<Id>();
    @TestVisible
    private static Set<Id> processedRecordIdsUpdate = new Set<Id>();


    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
            }

            if (System.Trigger.isUpdate) {
                clearHashedEmail((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap);
            }
        }

        if (System.Trigger.isAfter) {

            if (System.Trigger.isInsert) {
                List<Account> newRecords = filterProcessedRecords(processedRecordIdsInsert);

                fireLoyaltyEvents(newRecords);
                createPreferencesE4A(newRecords);
            }

            if (System.Trigger.isUpdate) {
                List<Account> newRecords = filterProcessedRecords(processedRecordIdsUpdate);

                fireLoyaltyEvents(newRecords, (Map<Id,Account>) Trigger.oldMap);
                createPreferencesE4A(newRecords, (Map<Id,Account>) Trigger.oldMap);
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

    private static void createPreferencesE4A(List<Account> newAccounts) {
        Set<Account> validAccounts = new Set<Account>();

        for (Account a : newAccounts) {

            if (a.Company_Registered_Name__c != null
                || a.E4A_Customer_Type__c != null
                || a.E4A_Subscriber_Status__c != null
                || a.Indirect_Sales_Topics__c != null
                || a.E4A_Newsletter_Opt_In__c != false
            ) {
                validAccounts.add(a);
            }
        }

        if (!validAccounts.isEmpty()) {
            createPreferencesE4A(validAccounts);
        }
    }

    private static void createPreferencesE4A(List<Account> newAccounts, Map<Id,Account> oldAccountsMap) {
        Set<Account> validAccounts = new Set<Account>();

        for (Account a : newAccounts) {
            Account oldAccount = oldAccountsMap.get(a.Id);

            if (a.Company_Registered_Name__c != oldAccount.Company_Registered_Name__c
                || a.E4A_Customer_Type__c != oldAccount.E4A_Customer_Type__c
                || a.E4A_Subscriber_Status__c != oldAccount.E4A_Subscriber_Status__c
                || a.Indirect_Sales_Topics__c != oldAccount.Indirect_Sales_Topics__c
                || a.E4A_Newsletter_Opt_In__c != oldAccount.E4A_Newsletter_Opt_In__c
            ) {
                validAccounts.add(a);
            }
        }

        if (!validAccounts.isEmpty()) {
            createPreferencesE4A(validAccounts);
        }
    }

    private static void createPreferencesE4A(Set<Account> validAccounts) {
        if (validAccounts.isEmpty()) { return; }

        Datetime dtNow = Datetime.now();
        String prefName = dtNow.format('DD-MM-YYYY') + '-E4A Subscriber';
        List<Preference__c> prefs = new List<Preference__c>();

        for (Account a : validAccounts) {
            prefs.add(new Preference__c(
                Name = prefName,
                Account__c = a.Id,
                DateTimeFrom__c = dtNow,
                Channel__c = DLT_PreferenceConstants.CHANNEL_EMAIL,
                E4A_Newsletter_Opt_In__c = a.E4A_Newsletter_Opt_In__c,
                E4A_Subscriber_Status__c = a.E4A_Subscriber_Status__c,
                E4A_Opt_Out_Reason__c = a.E4A_Opt_Out_Reason__c,
                E4A_Opt_Out_Other_Reason__c = a.E4A_Opt_Out_Other_Reason__c,
                Indirect_Sales_Topics__c = a.Indirect_Sales_Topics__c,
                Preference__c = DLT_PreferenceConstants.PREFERENCE_E4A
            ));
        }


        if (!prefs.isEmpty()) {
            PreferenceTriggerHandler.isDisabled = true;

            insert prefs;

            PreferenceTriggerHandler.isDisabled = false;
        }
    }

    private static List<Account> filterProcessedRecords(Set<Id> processedRecordIds) {
        List<Account> filteredRecords = new List<Account>();

        for(Account newRecord : (List<Account>) Trigger.new) {
            if(processedRecordIds.contains(newRecord.Id)) { continue; }

            filteredRecords.add(newRecord);
            processedRecordIds.add(newRecord.Id);
        }

        return filteredRecords;
    }

    private static void fireLoyaltyEvents(List<Account> newAccounts) {
        if (DLT_Utils.isAsyncCtx()){
            DLT_AccountService.fireLoyaltyEvents(newAccounts);
        } else {
            System.enqueueJob(new DLT_AccountTriggerQueHelper(
                DLT_AccountTriggerQueHelper.Mode.FIRE_LOYALTY_EVENTS,
                newAccounts,
                null
            ));
        }
    }

    private static void fireLoyaltyEvents(List<Account> newAccounts, Map<Id,Account> oldAccountMap) {
        if (DLT_Utils.isAsyncCtx()){
            DLT_AccountService.fireLoyaltyEvents(newAccounts, oldAccountMap);
        } else {
            System.enqueueJob(new DLT_AccountTriggerQueHelper(
                DLT_AccountTriggerQueHelper.Mode.FIRE_LOYALTY_EVENTS,
                newAccounts,
                oldAccountMap
            ));
        }
    }

}