public inherited sharing class DLT_CorporateTrackingConstants {
    public static final Id RT_ID_BE_CONTINENT = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('GND_Belgium_Continent').getRecordTypeId();
    public static final Id RT_ID_BE_LONDON = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('GND_Belgium_London').getRecordTypeId();
    public static final Id RT_ID_NL_CONTINENT = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('GND_The_Netherlands_Continent').getRecordTypeId();
    public static final Id RT_ID_NL_LONDON = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('GND_The_Netherlands_London').getRecordTypeId();

    public static final Id RT_ID_EUROSTAR_FOR_BUSINESS_CODE = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('Eurostar_for_Business_code').getRecordTypeId();
    public static final Id RT_ID_FCE_NEW = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('FCE_New').getRecordTypeId();
    public static final Id RT_ID_GND_BE = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('GND_BE').getRecordTypeId();
    public static final Id RT_ID_GND_NL = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('GND_NL').getRecordTypeId();
    public static final Id RT_ID_AMADEUS = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('Corporate_code_Amadeus').getRecordTypeId();
    public static final Id RT_ID_APOLLO = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('Corporate_code_Apollo').getRecordTypeId();
    public static final Id RT_ID_GALILEO = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('Corporate_code_Galileo').getRecordTypeId();
    public static final Id RT_ID_SABRE = Schema.SObjectType.Corp_Tracking_Type_and_Code__c.getRecordTypeInfosByDeveloperName().get('Corporate_code_Sabre').getRecordTypeId();

    public static final Set<Id> NCO_RECORD_TYPE_IDS = new Set<Id>{
        RT_ID_EUROSTAR_FOR_BUSINESS_CODE,
        RT_ID_FCE_NEW,
        RT_ID_GND_BE,
        RT_ID_GND_NL,
        RT_ID_AMADEUS,
        RT_ID_APOLLO,
        RT_ID_GALILEO,
        RT_ID_SABRE
    };
}