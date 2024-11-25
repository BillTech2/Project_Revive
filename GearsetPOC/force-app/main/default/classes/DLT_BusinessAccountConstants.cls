public inherited sharing class DLT_BusinessAccountConstants {
    
    public static final Schema.RecordTypeInfo CORPORATE_ACCOUNT_INFO = Schema.SObjectType.Business_Account__c.getRecordTypeInfosByDeveloperName().get('Corporate_Account');
    public static final Schema.RecordTypeInfo AGENCY_ACCOUNT_INFO = Schema.SObjectType.Business_Account__c.getRecordTypeInfosByDeveloperName().get('Agency_Account');
    public static final Id RECORD_TYPE_ID_AGENCY = AGENCY_ACCOUNT_INFO.getRecordTypeId();
    public static final Id RECORD_TYPE_ID_CORPORATE = CORPORATE_ACCOUNT_INFO.getRecordTypeId();

    //Status__c picklist
    public static final String STATUS_CONTRACTED = 'Contracted';

    //Red_Account_Type__c picklist
    public static final String RED_ACCOUNT_TYPE_TCF1 = 'TCF1';
    public static final String RED_ACCOUNT_TYPE_TCF2 = 'TCF2';

    //Blue_Account_Type__c picklist
    public static final String BLUE_ACCOUNT_TYPE_GOLD = 'Gold';
    public static final String BLUE_ACCOUNT_TYPE_PLATINUM = 'Platinum';
}