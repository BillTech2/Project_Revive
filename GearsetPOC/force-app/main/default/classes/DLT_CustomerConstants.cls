public inherited sharing class DLT_CustomerConstants {

    public static final String RT_ID_PERSON_ACCOUNT = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

    public static final String OBJECT_NAME = 'Account';

    public static final String SVOC_FIELD_SET_NAME = 'SVOCUpdateFields';
    public static final String TACT_FIELD_SET_NAME = 'TACTUpdateFields';

    public static final String PREF_LANG_ENGLISH = 'English (UK)';
    public static final String PREF_LANG_FRENCH = 'French';
    public static final String PREF_LANG_DUTCH = 'Dutch';
    public static final String PREF_LANG_GERMAN = 'German';
}