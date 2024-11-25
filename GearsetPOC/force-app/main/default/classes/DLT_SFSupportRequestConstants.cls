public inherited sharing class DLT_SFSupportRequestConstants {
    
    public static final String RECORDTYPE_BUG = 'Bug';
    public static final String RECORDTYPE_IMPROVEMENT = 'Improvement';
    public static final String RECORDTYPE_KNOWLEDGE = 'Knowledge';

    public static final String GROUP_BUG = 'Senior Experts';
    public static final String GROUP_IMPROVEMENT = 'Improvement Tickets';
    public static final String GROUP_KNOWLEDGE = 'Knowledge Tickets';

    public static final String RECORDTYPEID_BUG = Schema.SObjectType.Salesforce_Support_Request__c.getRecordTypeInfosByName().get(RECORDTYPE_BUG).getRecordTypeId();
    public static final String RECORDTYPEID_IMPROVEMENT = Schema.SObjectType.Salesforce_Support_Request__c.getRecordTypeInfosByName().get(RECORDTYPE_IMPROVEMENT).getRecordTypeId();
    public static final String RECORDTYPEID_KNOWLEDGE = Schema.SObjectType.Salesforce_Support_Request__c.getRecordTypeInfosByName().get(RECORDTYPE_KNOWLEDGE).getRecordTypeId();

    public static Map<Id,String> recordTypeToGroup = new Map<Id,String>{
        RECORDTYPEID_BUG => GROUP_BUG,
        RECORDTYPEID_IMPROVEMENT => GROUP_IMPROVEMENT,
        RECORDTYPEID_KNOWLEDGE => GROUP_KNOWLEDGE
    };

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_ONHOLD = 'On Hold';

    public static final List<Id> feedbackRecordTypeIds = new List<Id>{
        RECORDTYPEID_BUG,
        RECORDTYPEID_IMPROVEMENT,
        RECORDTYPEID_KNOWLEDGE
    };
}