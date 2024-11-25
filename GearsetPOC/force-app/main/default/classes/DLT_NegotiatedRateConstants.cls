public inherited sharing class DLT_NegotiatedRateConstants {
    
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_EXTRACTED = 'Extracted';
    public static final String STATUS_INTEGRATED = 'Integrated';
    public static final String STATUS_TO_BE_EXTRACTED = 'To be Extracted';
    public static final String STATUS_TO_BE_APPROVED = 'To be Approved';

    public static final String ROUTE_PARIS_BELGIUM = 'Paris - Belgium';
    public static final String ROUTE_LONDON_PARIS= 'London - Paris';
    public static final String ROUTE_LONDON_FRANCE= 'London - France';
    public static final String ROUTE_BELGIUM_GERMANY= 'Belgium - Germany';

    public static final Id CORPORATE_CONTINENT = Schema.SObjectType.B2b_NrDetails__c.getRecordTypeInfosByDeveloperName().get('Negotiated_Rate_Continent').getRecordTypeId();
    public static final Id CORPORATE_LONDON = Schema.SObjectType.B2b_NrDetails__c.getRecordTypeInfosByDeveloperName().get('Negotiated_Rate_London').getRecordTypeId();
    public static final Id CORPORATE_NCO = Schema.SObjectType.B2b_NrDetails__c.getRecordTypeInfosByDeveloperName().get('Negotiated_Rate_NCO').getRecordTypeId();
    public static final Map<String, String> rateContractRecordTypeMap = new Map<String, String>{
            DLT_BusinessContractConstants.CORPORATE_CONTINENT => CORPORATE_CONTINENT,
            DLT_BusinessContractConstants.CORPORATE_LONDON => CORPORATE_LONDON,
            DLT_BusinessContractConstants.CORPORATE_NCO => CORPORATE_NCO
    };

    public static final String DISCOUNT_NEW = 'New';
    public static final String DISCOUNT_HIGHER = 'Higher';
    public static final String DISCOUNT_LOWER = 'Lower';
    public static final String DISCOUNT_SAME = 'Same';

    public static final String DEUTSCHER_BUND = 'Deutscher Bund';

    public static final Set<String> RED_ACCOUNT_TYPE_VALUES = new Set<String>{'TCF1','TCF2','COVID'};

    public static Boolean isToBeExtracted(B2b_NrDetails__c rate) {
        return rate == null ? false : rate.B2b_Status__c == STATUS_TO_BE_EXTRACTED;
    }

    public static final String APPROVAL_API_RED_NEGOTIATED_RATE = 'RED_Negotiated_Rate_AP';
    public static final String APPROVAL_COMMENT_SUBMIT = 'Submit rates with To Be Approved status';

    public static final String EUROSTAR_PREMIER_CLASS = 'Eurostar Premier';
    public static final String EUROSTAR_PLUS_CLASS = 'Eurostar Plus';
    public static final String EUROSTAR_STANDARD_CLASS = 'Eurostar Standard';

    public static final String TARIFF_GDS_AIR = 'GDS Air';
    public static final String TARIFF_IDL_AND_BENE = 'IDL and BeNe';

    public static String BUSINESS_ACCOUNT_TYPE = 'Business';
    public static String AGENCY_ACCOUNT_TYPE = 'Agency';

    public static String DISCOUNT_PERCENT_0 = '0%';
    public static String DISCOUNT_PERCENT_3 = '3%';
    public static String DISCOUNT_PERCENT_3_POINT_5 = '3.5%';
    public static String DISCOUNT_PERCENT_4 = '4%';
}