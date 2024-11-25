public without sharing class CaseQuickactionController {

    private static final String DRAFT_FIELDS = 'DRAFT_FIELDS';
    private static final String PREPOPULATED_FIELDS = 'PREPOPULATED_FIELDS';
    private static Map<String, String> FIELDS_BY_TYPES = new Map<String, String>{DRAFT_FIELDS => '', PREPOPULATED_FIELDS => ''};

    private static final String DRAFT_FIELD_NAME = 'DRAFT_FIELD_NAME';
    private static final String DRAFT_FIELD_VALUE = 'DRAFT_FIELD_VALUE';
    private static final Map<String, String> COMPENSATION_MAPPING = new Map<String, String>{
        DRAFT_FIELD_NAME => 'Claim_Status__c',
        DRAFT_FIELD_VALUE => 'Draft'
    };
    private static final Map<String, String> BAF_ADJUSTMENT_MAPPING = new Map<String, String>{
        DRAFT_FIELD_NAME => 'Status__c',
        DRAFT_FIELD_VALUE => 'Draft'
    };
    private static final Map<String, String> REFUND_REQUEST_MAPPING = new Map<String, String>{
        DRAFT_FIELD_NAME => 'Is_Draft_Refund_Request__c',
        DRAFT_FIELD_VALUE => 'true'
    };

    private static final Map<String, Map<String, String>> DRFT_OBJECT_MAPPING = new Map<String, Map<String, String>>{
        'Compensation__c' => COMPENSATION_MAPPING,
        'BAF_Adjustment_Request__c' => BAF_ADJUSTMENT_MAPPING,
        'Datacash_Refund_Request__c' => REFUND_REQUEST_MAPPING
    };

    
    @AuraEnabled(cacheable=true)
    public static QuciActionSettings getpopulatedFields(QuciActionSettings quickActionSettings) {

        Map<String,Object> fieldsMap = new  Map<String,Object>();
       
        if (!String.isBlank(quickActionSettings.recordTypeName)) {
            quickActionSettings.recordTypeId = [
                SELECT Id 
                FROM RecordType
                WHERE SObjectType = :quickActionSettings.sObjectName 
                    AND DeveloperName = :quickActionSettings.recordTypeName LIMIT 1
            ].Id;

        }

        getFieldsForSOQL(quickActionSettings.fields, quickActionSettings);

        List<SObject> records = getDrafRecords(quickActionSettings);

        if (!records.isEmpty()) {
            quickActionSettings.isDraft = true;
            quickActionSettings.draftId = records[0].Id;
            quickActionSettings.objectRecord = records[0];
            quickActionSettings.isDraftOwner = UserInfo.getUserId() == (Id)records[0].get('OwnerId');
            fieldsMap = records[0].getPopulatedFieldsAsMap();
            quickActionSettings.ownerName = String.valueOf(((SObject)fieldsMap.get('Owner')).get('Name')); 
        } else {
            records = getPrepopulateRecord(quickActionSettings.caseId);
            quickActionSettings.isDraft = false;
            quickActionSettings.objectRecord = prePopulateRecord(records[0], quickActionSettings);
            fieldsMap = records[0].getPopulatedFieldsAsMap();
        }


        if (quickActionSettings.needCheckExistinPNR) {
            String PNRvalue = fieldsMap.containsKey('PNR_Draft__c') ? String.valueOf(fieldsMap.get('PNR_Draft__c')) : String.valueOf(fieldsMap.get('PNR__c')); 
            quickActionSettings.BAFAdjasmentPNRExist = checkExistingPNR(PNRvalue, quickActionSettings.sObjectName);
        }

        return quickActionSettings;
    }

    @AuraEnabled(cacheable=false)
    public static QuciActionSettings upsertDraftRecord(Map<String, Object> objectRecord, String sObjectName) {
        QuciActionSettings quciActionSettings = new QuciActionSettings();

        Schema.DescribeSObjectResult draftObjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();


        if (sObjectName == 'BAF_Adjustment_Request__c' && checkExistingPNR(String.valueOf(objectRecord.get('PNR__c')), sObjectName)) {
            quciActionSettings.BAFAdjasmentPNRExist = true;
            return quciActionSettings;
        } else {
            SObject draftRecord = Schema.getGlobalDescribe().get(sObjectName).newSObject();
            for (String fieldNameItem : objectRecord.keySet()) {
                draftRecord.put(fieldNameItem, getValueInAppropriateType(fieldNameItem, draftObjectDescribe, objectRecord.get(fieldNameItem)));
            }

            upsert draftRecord;     
            quciActionSettings.BAFAdjasmentPNRExist = false;
            return quciActionSettings;   
        }
    }

    private static Object getValueInAppropriateType(String fieldName, Schema.DescribeSObjectResult draftObjectDescribe, Object fieldValue) {
        Object fieldValueWithType;
        Schema.DescribeFieldResult fieldDescribe = draftObjectDescribe.fields.getMap().get(fieldName).getDescribe();
        if (fieldDescribe.getType() == Schema.DisplayType.Boolean) {
            fieldValueWithType = Boolean.valueOf(fieldValue);
        } else if (fieldDescribe.getType() == Schema.DisplayType.Double) {
            fieldValueWithType = Double.valueOf(fieldValue);
        } else if (fieldDescribe.getType() == Schema.DisplayType.Date) {
            fieldValueWithType = Date.valueOf(String.valueOf(fieldValue));
        } else {
            fieldValueWithType = String.valueOf(fieldValue);
        }

        return fieldValueWithType;
    }

    public static void setRelatedCaseManualDraft(List<SObject> newRecords, Map<Id, SObject> oldMapRecords) {
        String sObjectName = '';
        Map<String, String> fieldValueMapping;

        Boolean isInsert = newRecords != null && oldMapRecords == null;
        Boolean isUpdate = newRecords != null && oldMapRecords != null;
        Boolean isDelete = newRecords == null && oldMapRecords != null;
        
        if (isInsert) {
            sObjectName = newRecords[0].Id.getSObjectType().getDescribe().getName();
            fieldValueMapping = DRFT_OBJECT_MAPPING.get(sObjectName);
            handleInsertDraft(newRecords, fieldValueMapping);
        } else if (isUpdate) {
            sObjectName = newRecords[0].Id.getSObjectType().getDescribe().getName();
            fieldValueMapping = DRFT_OBJECT_MAPPING.get(sObjectName);
            handleUpdateDraft(newRecords, oldMapRecords, fieldValueMapping);
        } else if (isDelete) {
            sObjectName = oldMapRecords.values()[0].Id.getSObjectType().getDescribe().getName();
            fieldValueMapping = DRFT_OBJECT_MAPPING.get(sObjectName);
            handleDeleteDraft(oldMapRecords, fieldValueMapping);
        }  
        
    }

    private static void handleInsertDraft(List<SObject> newRecords, Map<String, String> fieldValueMapping) {
        List<Id> caseIds = new List<Id>();
        List<Case> casesForUpdate = new List<Case>();

        for (SObject objectItem : newRecords) {
            if (String.valueOf(objectItem.get((String)fieldValueMapping.get(DRAFT_FIELD_NAME))) == String.valueOf(fieldValueMapping.get(DRAFT_FIELD_VALUE))) {
                caseIds.add((Id)objectItem.get('Case__c'));
            }
        }

        for (Case caseItem : [
                        SELECT Id, Draft_Manual_Compensation__c 
                        FROM Case 
                        WHERE Id IN :caseIds AND Draft_Manual_Compensation__c = false]
        ) {
            caseItem.Draft_Manual_Compensation__c = true;
            casesForUpdate.add(caseItem);
        }

        update casesForUpdate;
    }

    private static void handleUpdateDraft(List<SObject> newRecords, Map<Id, SObject> oldMapRecords, Map<String, String> fieldValueMapping) {
        List<Id> casesSetDraft = new List<Id>();
        List<Id> casesUnsetDraft = new List<Id>();

        String draftField = fieldValueMapping.get(DRAFT_FIELD_NAME);
        String draftFieldValue = fieldValueMapping.get(DRAFT_FIELD_VALUE);

        for (SObject objectItem : newRecords) {
            String newFieldValue = String.valueOf(objectItem.get(draftField));
            String oldFieldValue = String.valueOf(oldMapRecords.get((Id)objectItem.get('Id')).get(draftField));
            if (newFieldValue == draftFieldValue && oldFieldValue != draftFieldValue) {
                casesSetDraft.add((Id)objectItem.get('Case__c'));
            } else if (newFieldValue != draftFieldValue && oldFieldValue == draftFieldValue) {
                casesSetDraft.add((Id)objectItem.get('Case__c'));
            }
        }

        setDraftCases(casesSetDraft);
    }

    private static void handleDeleteDraft(Map<Id, SObject> oldMapRecords, Map<String, String> fieldValueMapping) {
        List<Id> caseIds = new List<Id>();
        for (SObject objectItem : oldMapRecords.values()) {
            if (String.valueOf(objectItem.get((String)fieldValueMapping.get(DRAFT_FIELD_NAME))) == fieldValueMapping.get(DRAFT_FIELD_VALUE)) {
                caseIds.add((Id)objectItem.get('Case__c'));
            }
        }

        setDraftCases(caseIds);
    }

    private static void setDraftCases(List<Id> caseIdes) {
        List<Case> cases = new List<Case>();
        List<Case> casesForUpdate = [
            SELECT Id, Draft_Manual_Compensation__c, 
            (SELECT Id FROM Compensations__r WHERE Claim_Status__c = 'Draft'),
            (SELECT Id FROM BAF_Adjustment_Requests__r WHERE Status__c = 'Draft'),
            (SELECT Id FROM Datacash_Refund_Requests__r WHERE Is_Draft_Refund_Request__c = true)
            FROM Case 
            WHERE Id IN :caseIdes
        ];

        for (Case caseItem : casesForUpdate) {
            Case caseForUpdate = new Case();
            Boolean needSetDraft = (caseItem.Compensations__r.size() > 0 
                || caseItem.BAF_Adjustment_Requests__r.size() > 0 
                || caseItem.Datacash_Refund_Requests__r.size() > 0)
                && caseItem.Draft_Manual_Compensation__c == false;

            Boolean needUnsetDraft = (caseItem.Compensations__r.size() == 0 
                && caseItem.BAF_Adjustment_Requests__r.size() == 0 
                && caseItem.Datacash_Refund_Requests__r.size() == 0)
                && caseItem.Draft_Manual_Compensation__c == true;

            if (needSetDraft) {
                caseForUpdate.Draft_Manual_Compensation__c = true;
                caseForUpdate.Id = caseItem.Id;
                cases.add(caseForUpdate);
            } else if (needUnsetDraft) {
                caseForUpdate.Draft_Manual_Compensation__c = false;
                caseForUpdate.Id = caseItem.Id;
                cases.add(caseForUpdate);
            }
        }

        if (!cases.isEmpty()) {
            update cases;
        }
    }

    

    private static SObject prePopulateRecord(SObject fildsForSettingValues, QuciActionSettings quickActionSettings) {
        SObject prepopulateRecord = Schema.getGlobalDescribe().get(quickActionSettings.sObjectName).newSObject();
        
        for (List<Field> fieldsListItem : quickActionSettings.fields) {
            for (Field fieldItem : fieldsListItem) {
                if (!String.isBlank(fieldItem.fieldName)) {
                    Map<String,Object> fieldsMap = fildsForSettingValues.getPopulatedFieldsAsMap();

                    prepopulateRecord = populateDefoultLogicalValue(prepopulateRecord, fieldItem);
                    prepopulateRecord = populateRecordTypeDependlValue(prepopulateRecord, fieldItem, fieldsMap);
                    prepopulateRecord = populateRecordCombinationValue(prepopulateRecord, fieldItem, fieldsMap);
                    prepopulateRecord = populateParentRecordValue(prepopulateRecord, fieldItem, fieldsMap);
                    prepopulateRecord = populateCurrensyValue(prepopulateRecord, fieldItem, fieldsMap, quickActionSettings);
                    prepopulateRecord = populateAlternativeValue(prepopulateRecord, fieldItem, fieldsMap, quickActionSettings);
                    prepopulateRecord = populateIfEmptyValue (prepopulateRecord, fieldItem, fieldsMap);
                }
            }
        }

        if (quickActionSettings.sObjectName == 'BAF_Adjustment_Request__c') {
            prepopulateRecord.put('PNR_Draft__c', prepopulateRecord.get('PNR__c'));
        }

        
        if (!String.isBlank(quickActionSettings.recordTypeName)) {
            prepopulateRecord.put('RecordTypeId', quickActionSettings.recordTypeId);
        }

        prepopulateRecord.put(quickActionSettings.lookupToCase, quickActionSettings.caseId);

        return prepopulateRecord;
    }

    private static SObject populateDefoultLogicalValue (SObject prepopulateRecord, Field fieldItem) {
        if (fieldItem.value == 'true' || fieldItem.value == 'false') {
            prepopulateRecord.put(fieldItem.fieldName, Boolean.valueOf(fieldItem.value));
        }
        return prepopulateRecord;
    }

    private static SObject populateRecordTypeDependlValue (SObject prepopulateRecord, Field fieldItem, Map<String,Object> fieldsMap) {
        if (fieldItem.value.contains('CASE_RECORDTYPE_DEPEND')) {
            String recordTypeName = String.valueOf(((SObject)fieldsMap.get('RecordType')).get('DeveloperName'));
            String recordTypeMapping = (String)fieldItem.value.split('\\-')[1];
            Map<String, String> recordTypeMap = (Map<String, String>) JSON.deserialize(recordTypeMapping, Map<String, String>.class);

            if(recordTypeMap.containsKey(recordTypeName)) {
                if ((String.valueOf(recordTypeMap.get(recordTypeName))).contains('Case')) {
                    String fieldName = recordTypeMap.get(recordTypeName).split('\\.')[1];
                    prepopulateRecord.put(fieldItem.fieldName, fieldsMap.get(fieldName));
                } else {
                    prepopulateRecord.put(fieldItem.fieldName, recordTypeMap.get(recordTypeName));

                }
            }
        }
        return prepopulateRecord;  
    }

    private static SObject populateRecordCombinationValue (SObject prepopulateRecord, Field fieldItem, Map<String,Object> fieldsMap) {
        String prepopulateValue = '';
        if (fieldItem.value.contains('+')) {
            for(String fieldString : fieldItem.value.split('\\+')) {

                if (fieldString.contains('.')) {
                    List<String> objectFieldList = fieldString.split('\\.');
                    if (fieldsMap.containsKey(objectFieldList[0]) && ((SObject)fieldsMap.get(objectFieldList[0])).get(objectFieldList[1]) != null) {
                        prepopulateValue += ((SObject)fieldsMap.get(objectFieldList[0])).get(objectFieldList[1]) + ' ';
                    }
                } else {
                    prepopulateValue = (String)fieldsMap.get(fieldString);
                }
            }
            prepopulateRecord.put(fieldItem.fieldName, prepopulateValue);
        }
        return prepopulateRecord;
    }

    private static SObject populateParentRecordValue (SObject prepopulateRecord, Field fieldItem, Map<String,Object> fieldsMap) {
        if (fieldItem.value.contains('.') && !fieldItem.value.contains('+')) {
            List<String> objectFieldList = fieldItem.value.split('\\.');
            if (fieldsMap.containsKey(objectFieldList[0])) {
                prepopulateRecord.put(fieldItem.fieldName, ((SObject)fieldsMap.get(objectFieldList[0])).get(objectFieldList[1]));
            }
        } 
        return prepopulateRecord;
    } 

    private static SObject populateCurrensyValue (SObject prepopulateRecord, Field fieldItem, Map<String,Object> fieldsMap, QuciActionSettings quickActionSettings) {
        if ( quickActionSettings.sObjectName == 'Datacash_Refund_Request__c' && fieldItem.fieldName == 'Currency__c') {
            if (String.valueOf((String)fieldsMap.get(fieldItem.value)) == 'USD') {
                prepopulateRecord.put(fieldItem.fieldName, 'OTHER');
            }
        } 
        return prepopulateRecord;
    } 

    private static SObject populateAlternativeValue(SObject prepopulateRecord, Field fieldItem, Map<String,Object> fieldsMap, QuciActionSettings quickActionSettings) {
        if (fieldItem.value.contains('{OR}')) {
            for (String fieldValueItem : fieldItem.value.split('\\{OR\\}')) {

                String fieldStringValue = fieldValueItem.deleteWhitespace();

                if (fieldsMap.containsKey(fieldStringValue) && fieldsMap.get(fieldItem.value) != null) {
                    prepopulateRecord.put(fieldItem.fieldName, fieldsMap.get(fieldItem.value));
                } else {
                    if (fieldStringValue.contains('.')) {
                        List<String> objectFieldList = fieldStringValue.split('\\.');
                        if (fieldsMap.containsKey(objectFieldList[0]) && ((SObject)fieldsMap.get(objectFieldList[0])).get(objectFieldList[1]) != null) {
                            prepopulateRecord.put(fieldItem.fieldName, ((SObject)fieldsMap.get(objectFieldList[0])).get(objectFieldList[1]));
                        }
                    } else {
                        prepopulateRecord.put(fieldItem.fieldName, null);
                    }
                }
            }
        }

        return prepopulateRecord;
    }


    private static SObject populateIfEmptyValue (SObject prepopulateRecord, Field fieldItem, Map<String,Object> fieldsMap) {
        if (prepopulateRecord.get(fieldItem.fieldName) == null) {
            prepopulateRecord.put(fieldItem.fieldName, fieldsMap.get(fieldItem.value));
        }

        return prepopulateRecord;
    }

    private static void getFieldsForSOQL(List<List<Field>> fieldsForPrepopulating, QuciActionSettings quickActionSettings) {
        String prepopulatefieldsString = 'Id ';
        String draftfieldsString = 'Id ';

        for (List<Field> fields : fieldsForPrepopulating) {
            for (Field fieldItem : fields) {
                if (!String.isBlank(fieldItem.fieldName)) {

                    draftfieldsString += ', ' + fieldItem.fieldName;

                    if (!String.isBlank(fieldItem.value)) {
                        prepopulatefieldsString += getFieldsFromCombinationValue(fieldItem.value);
                        prepopulatefieldsString += getFieldsFromRecordTypeDepends(fieldItem.value);
                        prepopulatefieldsString += getFieldsFromAlternativeFields(fieldItem.value);
                        prepopulatefieldsString += getFieldsFromValue(fieldItem.value);
                    }
                }
            }
        }

        FIELDS_BY_TYPES.put(DRAFT_FIELDS, draftfieldsString);
        FIELDS_BY_TYPES.put(PREPOPULATED_FIELDS, prepopulatefieldsString); 
    }

    private static String getFieldsFromCombinationValue(String fieldValue) {
        String fieldNames = '';
        if (fieldValue.contains('+')) {
            for(String fieldString : fieldValue.split('\\+')) {
                fieldNames += ', ' + fieldString;
            }
        }
        return fieldNames;
    }

    private static String getFieldsFromRecordTypeDepends(String fieldValue) {
        String fieldNames = '';
        if (fieldValue.contains('CASE_RECORDTYPE_DEPEND')) {
            String recordTypeMapping = (String)fieldValue.split('\\-')[1];
            Map<String, String> recordTypeMap = (Map<String, String>) JSON.deserialize(recordTypeMapping, Map<String, String>.class);

            for (String fieldString : recordTypeMap.values()) {
                if (fieldString.contains('Case')) {
                    fieldNames += ', ' + fieldString.split('\\.')[1];
                } 
            }
        }
        
        return fieldNames;
    }

    private static string getFieldsFromAlternativeFields(String fieldValue) {
        String fieldNames = '';
        if (fieldValue.contains('{OR}')) {
            for (String fieldNameItem : fieldValue.split('\\{OR\\}')) {
                fieldNames += ', ' + fieldNameItem;
            }
        }

        return fieldNames;
    }

    private static string getFieldsFromValue(String fieldValue) {
        String fieldNames = '';
        if (!isNeedBypass(fieldValue)){

            fieldNames += ', ' + fieldValue;
        }
        
        return fieldNames;
    }

    private static Boolean isNeedBypass(String fieldValue) {
        return fieldValue.contains('true') 
            || fieldValue.contains('false') 
            || fieldValue.contains('CASE_RECORDTYPE_DEPEND') 
            || fieldValue.contains('+')
            || fieldValue.contains('{OR}')
            || fieldValue == 'Id'
            || fieldValue.contains('PNR__c') && !fieldValue.contains('.PNR__c');
    }

    private static List<SObject> getPrepopulateRecord(Id recordId) {
        List<SObject> caseRecords = new List<SObject>();

        if (!String.isBlank(FIELDS_BY_TYPES.get(PREPOPULATED_FIELDS))) {
            String query = 'SELECT ' + FIELDS_BY_TYPES.get(PREPOPULATED_FIELDS) + ', OwnerId, RecordType.DeveloperName, PNR__c FROM Case WHERE Id = ' +  '\'' + recordId + '\'';                                    
            caseRecords = Database.query(query);
        }

        return caseRecords;
    }

    private static List<SObject> getDrafRecords(QuciActionSettings quciActionSettings) {
        String query = 'SELECT ' + FIELDS_BY_TYPES.get(DRAFT_FIELDS) + ', OwnerId, Owner.Name, '; 

        if (quciActionSettings.sObjectName == 'BAF_Adjustment_Request__c') {
            query += ' PNR_Draft__c ';
        } else {
            query += quciActionSettings.lookupToCase.removeEnd('c') + 'r.PNR__c '; 
        }

        if (!String.isBlank(quciActionSettings.recordTypeName)) {
            query += ', RecordTypeId ';
        }
        query += ' FROM ' + quciActionSettings.sObjectName + ' WHERE ' + quciActionSettings.lookupToCase + ' = \'' + quciActionSettings.caseId + '\'';

        if (quciActionSettings.sObjectName == 'Datacash_Refund_Request__c') {
            query += ' AND Is_Draft_Refund_Request__c = true';
        } else {
            query += ' AND ' + quciActionSettings.statusField + '=\'' + quciActionSettings.draftStatusValue + '\'';
        }
        
        if (!String.isBlank(quciActionSettings.recordTypeName)) {
            query += ' AND RecordTypeId = \'' + quciActionSettings.recordTypeId + '\''; 
        }
        return Database.query(query);
    }

    private static Boolean checkExistingPNR(String PNR, String sObjectName) {
        String query = 'SELECT Id FROM ' + sObjectName + ' WHERE PNR__c = \'' + PNR + '\' AND PNR__c != null'; 

        return Database.query(query).size() > 0;
    }

    public class QuciActionSettings {
        @AuraEnabled
        public String cancelStatusValue { get; set; }
        @AuraEnabled
        public String caseId { get; set; }
        @AuraEnabled
        public String confirmStatusValue { get; set; }
        @AuraEnabled
        public String draftStatusValue { get; set; }
        @AuraEnabled
        public List<List<Field>> fields { get; set; }
        @AuraEnabled
        public Boolean isDraft { get; set; }
        @AuraEnabled
        public String lookupToCase { get; set; }
        @AuraEnabled
        public Boolean needCheckExistinPNR { get; set; }
        @AuraEnabled
        public SObject objectRecord { get; set; }
        @AuraEnabled
        public String recordTypeId { get; set; }
        @AuraEnabled
        public String recordTypeName { get; set; }
        @AuraEnabled
        public String sObjectName { get; set; }
        @AuraEnabled
        public String statusField { get; set; }

        @AuraEnabled
        public String draftId { get; set; }
        @AuraEnabled
        public Boolean isDraftOwner { get; set; }
        @AuraEnabled
        public String ownerName { get; set; }
        @AuraEnabled
        public Boolean BAFAdjasmentPNRExist { get; set; }
        
    }

    public class Field {
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public Boolean isRequired { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public Boolean isHidden { get; set; }
        @AuraEnabled
        public String style { get; set; }
        
    }

}