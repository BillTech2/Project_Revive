public inherited sharing class DLT_BusinessAccountConstants {
    
    public static final Schema.RecordTypeInfo CORPORATE_ACCOUNT_INFO = Schema.SObjectType.Business_Account__c.getRecordTypeInfosByDeveloperName().get('Corporate_Account');
    public static final Schema.RecordTypeInfo AGENCY_ACCOUNT_INFO = Schema.SObjectType.Business_Account__c.getRecordTypeInfosByDeveloperName().get('Agency_Account');
    public static final Schema.RecordTypeInfo BUSINESS_ACCOUNTS_INFO = Schema.SObjectType.Business_Account__c.getRecordTypeInfosByDeveloperName().get('Business_Accounts');
    public static final Id RECORD_TYPE_ID_AGENCY = AGENCY_ACCOUNT_INFO.getRecordTypeId();
    public static final Id RECORD_TYPE_ID_CORPORATE = CORPORATE_ACCOUNT_INFO.getRecordTypeId();
    public static final Id RECORD_TYPE_ID_BUSINESS = BUSINESS_ACCOUNTS_INFO.getRecordTypeId();

    //Status__c picklist
    public static final String STATUS_CONTRACTED = 'Contracted';

    //Red_Account_Type__c picklist
    public static final String RED_ACCOUNT_TYPE_TCF1 = 'TCF1';
    public static final String RED_ACCOUNT_TYPE_TCF2 = 'TCF2';

    //Blue_Account_Type__c picklist
    public static final String BLUE_ACCOUNT_TYPE_GOLD = 'Gold';
    public static final String BLUE_ACCOUNT_TYPE_PLATINUM = 'Platinum';

    //Type__c picklist
    public static final String TYPE_OTHER = 'Other';

    //Account Number prexif by type
    public static final Map<String,String> TYPE_TO_PREFIX = new Map<String,String>{
        'Airline' => 'AL',
        'Tour Operator' => 'TO',
        'Leisure Agent' => 'LA',
        'Distributor' => 'DI',
        'Groups / Tours / Niche' => 'GT',
        'Inbounders / DMC' => 'IN',
        'TMC' => 'GD',
        'Reward Redemption' => 'RR',
        'OTA' => 'OT',
        'Retail' => 'RE',
        'Other' => 'OO',
        null => ''
    };
}