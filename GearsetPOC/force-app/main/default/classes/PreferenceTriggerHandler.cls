public without sharing class PreferenceTriggerHandler {
    private static Set<Id> setOfPreferenceIDs = new Set<Id>();

    public static Map<Id, Account>          accountsToUpdate { get; set; }
    public static Map<Id, Preference__c>    preferenceToUpdate { get; set; }
    public static Boolean skipUpdatePreferences = false;
    public static Boolean isDisabled = false;
    
    public static void onAfterInsert(Map<Id, Preference__c> preferenceMap){
        CloneTrainPreference.clone(preferenceMap);
    }
    
	public static void onAfterUpdate(List<Preference__c> preferenceList, Map<Id, Preference__c> oldPreferenceMap){
        //SyncTrainPreference.sync(preferenceList, oldPreferenceMap);
    }
    
    public static List<Preference__c> weedOutTheRecordsWhichCanCauseRecursion(List<Preference__c> triggerNew) {
        List<Preference__c> validatedRecords = new List<Preference__c>();

        for (Preference__c newPreference : triggerNew) {
            if (isValidRecord(newPreference)) {
                validatedRecords.add(newPreference);
            }
        }

        return validatedRecords;
    }

    public static void markProcessedRecords(List<Preference__c> alreadyProcessedByTriggerRecords) {
        setOfPreferenceIDs.addAll(
            new Map<Id, Preference__c>(alreadyProcessedByTriggerRecords).keySet()
        );
    }

    public static void updatePreferences(List<Preference__c> triggerNew) {
        if(skipUpdatePreferences) return;
        preferenceToUpdate  = new Map<Id, Preference__c>();
        accountsToUpdate    = new Map<Id, Account>();

        Map<Id, JunctionWrapper> accountsWithOldPreferences =
            getOldAccountsAndPreferences(
                getRelatedAccounts(
                    getRelatedAccountIds(
                        triggerNew
                    )
                )
            );

        Map<String, String> preferencePicklistMap =
            PreferenceUtils.getPicklistLabelAPIMap(
                    PreferenceConstants.OBJECT_NAME,
                    PreferenceConstants.FIELD_NAME_PREFERENCE,
                    TRUE
            );

        Map<String, String> preferencePicklistLabelsMap =
            PreferenceUtils.getPicklistLabelAPIMap(
                    PreferenceConstants.OBJECT_NAME,
                    PreferenceConstants.FIELD_NAME_PREFERENCE,
                    FALSE
            );

        Preference__c previousPreference;

        DateTime today = System.now();
        String PreferenceNameDate = String.valueOf(today.day()).leftPad(2, '0') + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + today.year();

        for (Preference__c newPreference : triggerNew) {
            
            if(newPreference.Name != null && newPreference.Name.containsIgnoreCase(LABEL.New_Train_Deals)) {continue;}
            
            System.debug('newPreference.Name' + newPreference.Name);

            newPreference.Name = PreferenceNameDate + '-' + preferencePicklistLabelsMap.get(newPreference.Preference__c);

            // NOTE: getting the latest/freshest preference record in its category (fields Preference__c & Channel__c),
            // NOTE: except those one that inserting now
            if (newPreference.Account__c != null && accountsWithOldPreferences != null && accountsWithOldPreferences.get(newPreference.Account__c) != null) {
                previousPreference = getLatestPreferenceWithCorrespondedCategory(
                        newPreference,
                        accountsWithOldPreferences.get(newPreference.Account__c).account.Preferences__r
                );
            } else {
                previousPreference = null;
                newPreference.addError('Bad Account');
                continue;
            }
            
            // NOTE: if the inserting record is the first record in its category (fields Preference__c & Channel__c)
            if (previousPreference == NULL) {

                // NOTE: Set an Account.Entity_opt_in field.
                accountsWithOldPreferences.get(newPreference.Account__c).account.Entity_opt_in__c = newPreference.Entity_opt_in__c;

                // NOTE: Change the corresponded "_opt_in" field on the account.
                //TODO check if fields names are same 
                //MINIMUM - implement override for language
                try {
                    if (newPreference.Preference__c != 'Preferred_Language__pc'){
                        accountsWithOldPreferences.get(newPreference.Account__c).account.put(
                            preferencePicklistMap.get(newPreference.Preference__c),
                            newPreference.Consent__c
                        );
                    } else {
                        accountsWithOldPreferences.get(newPreference.Account__c).account.put(
                            'Preferred_Language__pc',newPreference.Preferred_Language__c
                        );
                    }
                    

                } catch (FieldNotFoundException e) {
                    sendEmailAboutErrorsOccurs(e.getMessage());
                }

                accountsToUpdate.put(
                    accountsWithOldPreferences.get(newPreference.Account__c).account.Id,
                    accountsWithOldPreferences.get(newPreference.Account__c).account
                );

            } else if (previousPreference != NULL) {
                if (newPreference.DateTimeFrom__c > previousPreference.DateTimeFrom__c) {

                    // NOTE: Change an Account.Entity_opt_in field (EIL/EHL) if DateTimeFrom__c field of the new preference record
                    // NOTE: is later than the freshest DateTimeFrom__c value from all the preferences related to the account.
                    if (newPreference.DateTimeFrom__c > accountsWithOldPreferences.get(newPreference.Account__c).latestDateTime) {
                        accountsWithOldPreferences.get(newPreference.Account__c).account.Entity_opt_in__c = newPreference.Entity_opt_in__c;
                    }

                    previousPreference.DateTimeTo__c = System.now();
                    preferenceToUpdate.put(previousPreference.Id, previousPreference);

                    // NOTE: Change the corresponded "_opt_in" field on the account.
                    try {
                        if (newPreference.Preference__c != 'Preferred_Language__pc'){
                        accountsWithOldPreferences.get(newPreference.Account__c).account.put(
                            preferencePicklistMap.get(newPreference.Preference__c),
                            newPreference.Consent__c
                        );
                        } else {
                            accountsWithOldPreferences.get(newPreference.Account__c).account.put(
                                'Preferred_Language__pc',newPreference.Preferred_Language__c
                            );
                        }

                    } catch (FieldNotFoundException e) {
                        sendEmailAboutErrorsOccurs(e.getMessage());
                    }

                    accountsToUpdate.put(
                        accountsWithOldPreferences.get(newPreference.Account__c).account.Id,
                        accountsWithOldPreferences.get(newPreference.Account__c).account
                    );

                } else {
                    newPreference.DateTimeTo__c = previousPreference.DateTimeFrom__c;
                }
            }
        }
    }

	/**
    private static String getCustomFieldDefinition(String customFieldName) {
        return customFieldName + PreferenceConstants.CUSTOM_FIELD_PREFIX;
    }**/

    private static Boolean isValidRecord(Preference__c newPreference) {
        return (
            (newPreference.Id == NULL && !setOfPreferenceIDs.contains(newPreference.Id)) ||
             newPreference.DateTimeTo__c == NULL
        );
    }
    

    //CHeck if we can query preferences to be ordered by DateTimeFrom already 
    //so that we wouldn't need to sort them manually
    //just take the first with the correct type
    private static Datetime getTheLatestPreferenceDateTimeFrom(List<Preference__c> preferencesFromAccount) {
        //TODO add proper check for an empty List
        if (preferencesFromAccount.size() == 0) { return NULL; }

        List<Datetime> sortedDatetime = new List<Datetime>();

        for (Preference__c aPreference : preferencesFromAccount) {
            sortedDatetime.add(aPreference.DateTimeFrom__c);
        }

        sortedDatetime.sort();

        return sortedDatetime[sortedDatetime.size() - 1];
    }

    private static Preference__c getLatestPreferenceWithCorrespondedCategory(Preference__c newPreference, List<Preference__c> preferencesFromAccount) {

        if (preferencesFromAccount.size() == 0) { return NULL; }

        List<Datetime> sortedDatetime = new List<Datetime>();

        for (Preference__c aPreference : preferencesFromAccount) {
            if (aPreference.Channel__c == newPreference.Channel__c && aPreference.Preference__c == newPreference.Preference__c) {
                sortedDatetime.add(aPreference.DateTimeFrom__c);
            }
        }

        if (sortedDatetime.size() == 0) { return NULL; }

        sortedDatetime.sort();

        Preference__c result;
        for (Preference__c aPreference : preferencesFromAccount) {
            if (aPreference.DateTimeFrom__c == sortedDatetime[sortedDatetime.size() - 1]
                    && aPreference.Channel__c == newPreference.Channel__c
                    && aPreference.Preference__c == newPreference.Preference__c) {
                result = aPreference;
            }
        }

        return result;
    }
    //TODO Unite getRelatedAccountIds and getRelatedAccounts methods for readability
    private static Set<Id> getRelatedAccountIds(List<Preference__c> newPreferencesList) {
        Set<Id> newPreferenceAccountIds = new Set<Id>();

        for (Preference__c aPreference : newPreferencesList) {
            newPreferenceAccountIds.add(aPreference.Account__c);
        }

        return newPreferenceAccountIds;
    }

    private static List<Account> getRelatedAccounts(Set<Id> relatedAccountIds) {
        String newTrainDeals = '%'+LABEL.New_Train_Deals+'%';
        return [
            SELECT Entity_opt_in__c, Club_Eurostar_opt_in__c, Hotels_opt_in__c, Trains_opt_in__c, Trips_opt_in__c,
               (SELECT Entity_opt_in__c, Channel__c, DateTimeFrom__c, DateTimeTo__c, Preference__c
                FROM Preferences__r
                WHERE DateTimeTo__c = null
                AND (NOT NAME LIKE :newTrainDeals)
                ORDER BY DateTimeFrom__c DESC)
            FROM Account
            WHERE Id IN : relatedAccountIds
        ];
    }

    private static Map<Id, JunctionWrapper> getOldAccountsAndPreferences(List<Account> accountsList) {
        Map<Id, JunctionWrapper> resultWrapper = new Map<Id, JunctionWrapper>();

        for (Account anAccount : accountsList) {
            resultWrapper.put(
                anAccount.Id,
                new JunctionWrapper(
                    anAccount,
                    getTheLatestPreferenceDateTimeFrom(anAccount.Preferences__r)
                )
            );
        }

        return resultWrapper;
    }

    @testVisible
    private static void sendEmailAboutErrorsOccurs(String errors) {
        PreferenceUtils.sendInsertionErrorsOccursEmail(
            PreferenceConstants.ERRORS_DURING_INSERT_SUBJECT,
            PreferenceUtils.getDefaultEmailAddress(),
            PreferenceConstants.OBJECT_NAME,
            errors
        );
    }


    public class JunctionWrapper {
        public Account  account         { get; set; }
        public DateTime latestDateTime  { get; set; }

        public JunctionWrapper(Account account, DateTime latestDatetime) {
            this.account        = account;
            this.latestDateTime = latestDatetime;
        }
    }

    private class FieldNotFoundException extends Exception {

    }
}