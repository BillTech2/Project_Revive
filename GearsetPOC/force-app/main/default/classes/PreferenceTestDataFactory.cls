@IsTest
public without sharing class PreferenceTestDataFactory {
    public static final String ACCOUNT_OBJECT_NAME      = Account.getSObjectType().getDescribe().getName();
    public static final STRING ACCOUNT_ENTITY_OPT_IN    = String.valueOf(Account.Entity_opt_in__c);

    public static final String TEST_ACCOUNT_FIRST_NAME  = 'Miranda';
    public static final String TEST_ACCOUNT_LAST_NAME   = 'Milson';

    public static final Datetime TEST_DATE_TIME_FROM_2_D_AGO    = System.now().addDays(-2);
    public static final Datetime TEST_DATE_TIME_FROM_1_D_AGO    = System.now().addDays(-1);

    public static final Integer ONE_PACK_OF_RECORDS = 15;
    public static final Integer TWO_PACK_OF_RECORDS = 30;

    public static final Integer NUMBER_OF_FOR_INSTANCES = (Integer)(
        (Decimal)PreferenceConstants.BATCH_CHUNK_SIZE / ONE_PACK_OF_RECORDS
    ).round(System.RoundingMode.UP);

    public static final List<Datetime> DATES_2Y_AGO_FOR_BATCH = PreferenceUtils.getDates2YAgoForBatch();

    // NOTE: (Email, SMS, Push)
    public static List<String> PREFERENCE_CHANNELS =
        PreferenceUtils.getPicklistLabelAPIMap(
            PreferenceConstants.OBJECT_NAME,
            PreferenceConstants.FIELD_NAME_CHANNEL,
            FALSE
        ).values();

    // NOTE: (Trains_opt_in, Hotels_opt_in, Trips_opt_in, Club_Eurostar_opt_in)
    public static final List<String> PREFERENCE_PREFERENCES =
        PreferenceUtils.getPicklistLabelAPIMap(
            PreferenceConstants.OBJECT_NAME,
            PreferenceConstants.FIELD_NAME_PREFERENCE,
            TRUE
        ).values();

    // NOTE: (EIL, EHL)
    public static final List<String> ENTITY_OPTIONS =
        PreferenceUtils.getPicklistLabelAPIMap(
            ACCOUNT_OBJECT_NAME,
            ACCOUNT_ENTITY_OPT_IN,
            FALSE
        ).values();

    public class AccountResearcher {
        private List<Account> customerAccounts;

        public void retrieveCustomerAccounts() {
            customerAccounts = new List<Account>();

            customerAccounts = [
                SELECT Entity_opt_in__c, Club_Eurostar_opt_in__c, Hotels_opt_in__c, Trains_opt_in__c, Trips_opt_in__c
                FROM Account
            ];
        }

        public Integer getNumberOfAccounts() {
            return customerAccounts.size();
        }

        public Account getAccount(Integer index) {
            return customerAccounts.get(index);
        }

        public Boolean isHotelsOptInSet() {
            return customerAccounts[0].Hotels_opt_in__c;
        }

        public Boolean isTrainsOptInSet() {
            return customerAccounts[0].Trains_opt_in__c;
        }

        public Boolean isTripsOptInSet() {
            return customerAccounts[0].Trips_opt_in__c;
        }

        public Boolean isClubEurostarOptInSet() {
            return customerAccounts[0].Club_Eurostar_opt_in__c;
        }

        public Boolean isEntityOptIn_EIL() {
            return customerAccounts[0].Entity_opt_in__c == ENTITY_OPTIONS[0];
        }

        public Boolean isEntityOptIn_EHL() {
            return customerAccounts[0].Entity_opt_in__c == ENTITY_OPTIONS[1];
        }
    }

    public class PreferenceAdjuster {
        private String accountId;
        private String entityOptIn      = ENTITY_OPTIONS[0];

        private Boolean consent         = TRUE;
        private Datetime dateTimeFrom   = TEST_DATE_TIME_FROM_2_D_AGO;
        private Database.SaveResult[] preferencesSaveResult;

        public PreferenceAdjuster(Id accountId, Boolean consent, Datetime dateTimeFrom, String entityOptIn) {
            this.consent        = consent;
            this.accountId      = accountId;
            this.entityOptIn    = entityOptIn;
            this.dateTimeFrom   = dateTimeFrom;
        }

        public Integer getNumberOfThePreferencesAtTheOrg() {
            return [SELECT COUNT() FROM Preference__c];
        }

        public Boolean allPreferencesDeployedSuccessfully() {
            Boolean result = true;

            for(Database.SaveResult svr : this.preferencesSaveResult) {
                if (!svr.isSuccess()) {
                    result = false;
                }
            }

            return result;
        }

        public void deployPreferences(List<Preference__c> preferences) {
            preferencesSaveResult = Database.insert(preferences, TRUE);
        }

        // -----------------------------------------------------------------------|
        // NOTE: List<Preference__c>. 15 records.
        // NOTE: 4 Preference__c.Preference__c category of every Channel__c type.
        // NOTE: One special record for language of every Channel__c type.
        // -----------------------------------------------------------------------|

        public List<Preference__c> getPreferences_AllChannels_AllTypes() {
            List<Preference__c> result = new List<Preference__c>();
            result.addAll(getPreference_EmailChannel_AllTypes());
            result.addAll(getPreference_SMSChannel_AllTypes());
            result.addAll(getPreference_PushChannel_AllTypes());

            return result;
        }

        // --------------------------------------------------------|
        // NOTE: List<Preference__c> by the Channel__c categories
        // --------------------------------------------------------|
        public List<Preference__c> getPreference_EmailChannel_AllTypes() {
            return new List<Preference__c> {
                getPreference_Email_Trains(),
                getPreference_Email_Hotels(),
                getPreference_Email_Trips(),
                getPreference_Email_ClubEurostar(),
                getPreference_Email_Language()
            };
        }

        public List<Preference__c> getPreference_SMSChannel_AllTypes() {
            return new List<Preference__c> {
                getPreference_SMS_Trains(),
                getPreference_SMS_Hotels(),
                getPreference_SMS_Trips(),
                getPreference_SMS_ClubEurostar(),
                getPreference_SMS_Language()
            };
        }

        public List<Preference__c> getPreference_PushChannel_AllTypes() {
            return new List<Preference__c> {
                getPreference_Push_Trains(),
                getPreference_Push_Hotels(),
                getPreference_Push_Trips(),
                getPreference_Push_ClubEurostar(),
                getPreference_Push_Language()
            };
        }

        // --------------------------------------------------------|
        // NOTE: Channel__c = 'Email', Preference__c - all 4 types + language
        // --------------------------------------------------------|
        public Preference__c getPreference_Email_Trains() {
            // NOTE: default Channel__c = 'Email'
            return new PreferenceBuilder(accountId)
                .withPreference(PREFERENCE_PREFERENCES[0])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Email_Hotels() {
            return new PreferenceBuilder(accountId)
                .withPreference(PREFERENCE_PREFERENCES[1])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Email_Trips() {
            return new PreferenceBuilder(accountId)
                .withPreference(PREFERENCE_PREFERENCES[2])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Email_ClubEurostar() {
            return new PreferenceBuilder(accountId)
                .withPreference(PREFERENCE_PREFERENCES[3])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Email_Language() {
            return new PreferenceBuilder(accountId)
                .withLanguage(true)
                .withPreference(PREFERENCE_PREFERENCES[5])
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        // --------------------------------------------------------|
        // NOTE: Channel__c = 'SMS', Preference__c - all 4 types + language
        // --------------------------------------------------------|
        public Preference__c getPreference_SMS_Trains() {
            return new PreferenceBuilder(accountId)
                .withPreference(PREFERENCE_PREFERENCES[0])
                .withChannel(PREFERENCE_CHANNELS[1])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_SMS_Hotels() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[1])
                .withPreference(PREFERENCE_PREFERENCES[1])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_SMS_Trips() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[1])
                .withPreference(PREFERENCE_PREFERENCES[2])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_SMS_ClubEurostar() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[1])
                .withPreference(PREFERENCE_PREFERENCES[3])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_SMS_Language() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[1])
                .withPreference(PREFERENCE_PREFERENCES[5])
                .withLanguage(true)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }


        // --------------------------------------------------------|
        // NOTE: Channel__c = 'Push', Preference__c - all 4 types + language
        // --------------------------------------------------------|
        public Preference__c getPreference_Push_Trains() {
            return new PreferenceBuilder(accountId)
                .withPreference(PREFERENCE_PREFERENCES[0])
                .withChannel(PREFERENCE_CHANNELS[2])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Push_Hotels() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[2])
                .withPreference(PREFERENCE_PREFERENCES[1])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Push_Trips() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[2])
                .withPreference(PREFERENCE_PREFERENCES[2])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Push_ClubEurostar() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[2])
                .withPreference(PREFERENCE_PREFERENCES[3])
                .withConsent(this.consent)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }

        public Preference__c getPreference_Push_Language() {
            return new PreferenceBuilder(accountId)
                .withChannel(PREFERENCE_CHANNELS[2])
                .withPreference(PREFERENCE_PREFERENCES[5])
                .withLanguage(true)
                .withDateTimeFrom(this.dateTimeFrom)
                .withEntityOptIn(this.entityOptIn)
                .build();
        }
    }

    public class PreferenceBuilder {
        private Id accountId;

        private String channel      = PREFERENCE_CHANNELS[0];
        private String preference;//   = PREFERENCE_PREFERENCES[0];
        private String entityOptIn  = ENTITY_OPTIONS[0];
        private Boolean includeLanguage  = false;

        private Boolean consent     = TRUE;

        private Datetime dateTimeFrom = TEST_DATE_TIME_FROM_2_D_AGO;

        public PreferenceBuilder(Id accountId) {
            this.accountId = accountId;
        }

        public Preference__c build() {
            return new Preference__c(
                Channel__c            = this.channel,
                Consent__c            = this.consent,
                Account__c            = this.accountId,
                Preference__c         = this.preference,
                DateTimeFrom__c       = this.dateTimeFrom,
                Entity_opt_in__c      = this.entityOptIn,
                Preferred_Language__c = includeLanguage?'French':null
            );
        }

        public PreferenceBuilder withChannel(String channel) {
            this.channel = String.escapeSingleQuotes(channel);
            return this;
        }

        public PreferenceBuilder withPreference(String preference) {
            this.preference = String.escapeSingleQuotes(preference);
            return this;
        }

        public PreferenceBuilder withConsent(Boolean consent) {
            this.consent = consent;
            return this;
        }

        public PreferenceBuilder withDateTimeFrom(Datetime dateTimeFrom) {
            this.dateTimeFrom = dateTimeFrom;
            return this;
        }

        public PreferenceBuilder withEntityOptIn(String entityOptIn) {
            this.entityOptIn = String.escapeSingleQuotes(entityOptIn);
            return this;
        }

        public PreferenceBuilder withLanguage(Boolean isInclude) {
            this.includeLanguage = isInclude;
            return this;
        }

    }
}