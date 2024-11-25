public inherited sharing class DLT_Constants {

    public static final String CUSTOM_PERMISSION_INTEGRATION_USER = 'Integration_User';
    public static final String CUSTOM_PERMISSION_TRAIN_EXPERT = 'Train_Expert';
    public static final String CUSTOM_PERMISSION_SALES_USER = 'Sales_User';
    public static final String CUSTOM_PERMISSION_LAMBDA = 'Lambda_Integration_User';
    public static final String CUSTOM_PERMISSION_FEEDBACK = 'Feedback_Permission';
    public static final String CUSTOM_PERMISSION_ADMIN = 'System_Administrator';

    public static final Boolean IS_INTEGRATION_USER = FeatureManagement.checkPermission(CUSTOM_PERMISSION_INTEGRATION_USER);
    public static Boolean IS_TRAIN_EXPERT = FeatureManagement.checkPermission(CUSTOM_PERMISSION_TRAIN_EXPERT);
    public static final Boolean IS_SALES_USER = FeatureManagement.checkPermission(CUSTOM_PERMISSION_SALES_USER);
    public static final Boolean IS_LAMBDA_USER = FeatureManagement.checkPermission(CUSTOM_PERMISSION_LAMBDA);
    public static final Boolean IS_FEEDBACK_USER = FeatureManagement.checkPermission(CUSTOM_PERMISSION_FEEDBACK);
    public static final Boolean IS_ADMIN = FeatureManagement.checkPermission(CUSTOM_PERMISSION_ADMIN);

    // Mass Handle Simple Cases

    public static final String LANGUAGE_ENGLISH = 'English';
    public static final String LANGUAGE_FRENCH = 'French';
    public static final String LANGUAGE_DUTCH = 'Dutch';
    public static final String LANGUAGE_GERMAN = 'German';

    public static final Map<String,String> MASS_HANDLE_EMAIL_TEMPLATES = new Map<String,String>{
        'SimpleMassHandlingEN' => LANGUAGE_ENGLISH,
        'SimpleMassHandlingFR' => LANGUAGE_FRENCH,
        'SimpleMassHandlingNL' => LANGUAGE_DUTCH,
        'SimpleMassHandlingDE' => LANGUAGE_GERMAN
    };

    public static final Map<String,String> LANG_CODE_TO_EMAIL_TEMPLATE = new Map<String,String>{
        'SimpleMassHandlingEN' => 'en-gb',
        'SimpleMassHandlingFR' => 'fr-ca',
        'SimpleMassHandlingNL' => 'nl',
        'SimpleMassHandlingDE' => 'de'
    };

    public static final String MASS_HANDLE_ERROR = 'Simple Case Mass Handling Failed';
    public static final String MASS_HANDLE_EMAIL_ERROR = 'Simple Case Mass Handling Failed - Exception while sending email';

    public static final String DYNAMIC_CONTENT_PLACEHOLDER = '##dynamic_content##';

    public static final String JOB_STATUS_COMPLETED = 'Completed';
    public static final String JOB_STATUS_FAILED = 'Failed';
    public static final String JOB_STATUS_ABORTED = 'Aborted';

}