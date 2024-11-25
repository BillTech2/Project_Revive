public inherited sharing class DLT_BusinessContractConstants {
    
    public static final List<String> RED_ACCOUNT_TYPE_VALUES = new List<String>{'TCF1','TCF2','COVID'};
    public static final Schema.RecordTypeInfo CORPORATE_CONTINENT_INFO = Schema.SObjectType.Business_Contract__c.getRecordTypeInfosByDeveloperName().get('Thalys');
    public static final Schema.RecordTypeInfo CORPORATE_LONDON_INFO = Schema.SObjectType.Business_Contract__c.getRecordTypeInfosByDeveloperName().get('Corporate');
    public static final Id RECORD_TYPE_ID_AGENCY = Schema.SObjectType.Business_Contract__c.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
    public static final Id CORPORATE_CONTINENT = CORPORATE_CONTINENT_INFO.getRecordTypeId();
    public static final Id CORPORATE_LONDON = CORPORATE_LONDON_INFO.getRecordTypeId();

    // Managed? picklist
    public static final String MANAGED_MANAGED = 'Managed';
    public static final String MANAGED_UNMANAGED = 'Unmanaged';

    // Hierarchy Level picklist
    public static final String HIERARCHY_MAIN = 'Main Account';
    public static final String HIERARCHY_BRANCH = 'Branch Account';

    // Red Account Type picklist
    public static final String REDACCTYPE_TCF1 = 'TCF1';

    //Blue Account Type picklist
    public static final String BLUEACCTYPE_GOLD = 'Gold';

    //Status picklist
    public static final String ACTIVE = 'Active';
    public static final String CONTRACTED = 'Contracted';
}