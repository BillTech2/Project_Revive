public without sharing class PreferenceConstants {
    public static final String OBJECT_NAME                  = Preference__c.getSObjectType().getDescribe().getName();

    public static final String FIELD_NAME_DATE_TIME_FROM    = String.valueOf(Preference__c.DateTimeFrom__c);
    public static final String FIELD_NAME_ENTITY_OPT_IN     = String.valueOf(Preference__c.Entity_opt_in__c);
    public static final String FIELD_NAME_DATE_TIME_TO      = String.valueOf(Preference__c.DateTimeTo__c);
    public static final String FIELD_NAME_PREFERENCE        = String.valueOf(Preference__c.Preference__c);
    public static final String FIELD_NAME_ACCOUNT           = String.valueOf(Preference__c.Account__c);
    public static final String FIELD_NAME_CONSENT           = String.valueOf(Preference__c.Consent__c);
    public static final String FIELD_NAME_CHANNEL           = String.valueOf(Preference__c.Channel__c);
    public static final String FIELD_NAME_REASON            = String.valueOf(Preference__c.Reason__c);
    public static final String FIELD_NAME_SOURCE            = String.valueOf(Preference__c.Source__c);
    public static final String FIELD_NAME_NAME              = String.valueOf(Preference__c.Name);
    public static final String FIELD_NAME_ID                = String.valueOf(Preference__c.Id);

    public static final String CUSTOM_SETTING_ERROR_EMAIL   = 'PreferenceProcessErrorEmail';

    public static final String REGEX_VALID_ID               = '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}';

    public static final String DYNAMIC_QUERY_TEMPLATE       = 'SELECT {0} FROM {1} WHERE {2} <= {3}';

    public final static String FULL_DATETIME_FORMAT         = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    public final static String CUSTOM_FIELD_PREFIX          = '__c';
    public final static String JOIN_COMMA                   = ', ';
    public final static String SPACE                        = ' ';

    public final static Datetime EXPIRATION_DATE_TWO_YEAR_AGO = System.now().addYears(-2);

    public static final String[] QUERY_FIELDS = new String[] {
        PreferenceConstants.FIELD_NAME_ID
    };

    public static final String EXPIRED_PREFERENCES_DELETION_TITLE = 'Preferences Records History Maintenance';

    public static final String SCHEDULED_CRON_EVERY_DAY     = '0 0 0 1/1 * ? *';
    public static final String SCHEDULED_CRON_EVERY_2_H     = '0 0 0/2 1/1 * ? *';
    public static final String SCHEDULED_CRON_EVERY_15_M    = '0 15 * * * ? *';

    public static final Integer BATCH_CHUNK_SIZE = 200;

    // NOTE: {0} AsyncApexJob.TotalJobItems, {1} Preference_Constants.BATCH_CHUNK_SIZE, {2} AsyncApexJob.NumberOfErrors
    public static final String BATCH_PROCESSING_RESULT_EMAIL_TEMPLATE = '{0} batches of {1} records processed. {2} batches containing failures.';

    // NOTE: {0} sObject name, {1} Errors
    public static final String ERRORS_DURING_INSERT_TEMPLATE    = 'The errors occurs during the {0} records inserting.\n\nErrors:\n\n {1}';
    public static final String ERRORS_DURING_INSERT_SUBJECT     = 'The errors occurs during the records inserting';

    public static final String TEST_DEFAULT_EMAIL_ADDRESS       = 'slavadonnikov@gmail.com';
}