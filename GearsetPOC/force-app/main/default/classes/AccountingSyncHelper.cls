public with sharing class AccountingSyncHelper {
    public static final String ACCOUNTS_SERVICE_NAME = 'Accounts Service';

    public static final String ACCOUNT_FORGOT_PASSWORD_OBJECT_NAME = 'AccountForgotPasswordNotification';

    public static final String ACCOUNT_WELCOME_EMAIL_OBJECT_NAME = 'AccountWelcomeNotification';

    public static final String ACCOUNT_OBJECT_NAME = 'Account';

    public static final String CONTACT_OBJECT_NAME = 'Contact';

    public static final String CREDIT_CARD_OBJECT_NAME = 'Credit_Card__c';

    public static final String TICKET_OBJECT_NAME = 'Ticket__c';

    public static final String FAVOURITE_TRAVELLER_OBJECT_NAME = 'Favourite_Traveller__c';

    public static final String NOTIFICATION_OPERATION = 'notification';

    public static final String CREATE_OPERATION = 'CREATE';

    public static final String UPDATE_OPERATION = 'UPDATE';

    public static final String DELETE_OPERATION = 'DELETE';

    public static Boolean syncIsEnabled {
        get { return integrationSettings.SetupOwnerId != null && integrationSettings.Enabled__c; }
    }

    private static final String TARGET_QUERY_STRING_TEMPLATE = 'SELECT {0} FROM {1} WHERE Id IN : recordIds LIMIT 200 ALL ROWS';

    private static final String STATION_NAME_FIELD_TO_LOOKUP = 'en_Station_Name__c';

    private static final String STATION_QUERY_STRING =
        'SELECT ' + STATION_NAME_FIELD_TO_LOOKUP +', UIC_Code__c ' +
        'FROM Stations__c ' +
        'WHERE ' + STATION_NAME_FIELD_TO_LOOKUP + ' IN : stationNames ' +
        'LIMIT 200';

    private static final String ID_PARAMETER_NAME = 'id';

    private static final String CID_PARAMETER_NAME = 'cid';

    private static final String EVENT_TIMESTAMP_PARAMETER_NAME = 'eventTimestamp';

    private static final String EVENT_TYPE_PARAMETER_NAME = 'eventType';

    private static final String ACTION_FIELD_NAME = 'action';
    private static final String WELCOME_EMAIL_FIELD_VALUE = 'welcomeEmail';
    private static final String FORGOT_PASSWORD_FIELD_VALUE = 'forgotPasswordEmail';

    private static final String DATETIME_TARGET_FORMAT = 'yyyyMMddHHmmss';

    private static final Integer CID_LENGTH = 15;

    private static final Set<String> DATETIME_TICKET_FIELDS = new Set<String> { 'Booking_DateTime__c', 'Travel_DateTime__c' };

    private static Accounts_Service_Integration_Settings__c integrationSettings {
        get {
            if (integrationSettings == null) {
                //integrationSettings = Accounts_Service_Integration_Settings__c.getOrgDefaults();
                integrationSettings = Accounts_Service_Integration_Settings__c.getInstance();
            }
            return integrationSettings;
        }
        set {}
    }

    public static String getOperationNameFromTriggerContext() {
        if (Trigger.isInsert) {
            return AccountingSyncHelper.CREATE_OPERATION;
        }
        else if (Trigger.isUpdate) {
            return AccountingSyncHelper.UPDATE_OPERATION;
        }
        else if (Trigger.isDelete) {
            return AccountingSyncHelper.DELETE_OPERATION;
        }
        return null;
    }

    public static void startSync(Set<Id> recordIds, String sObjectName, String operation) {
        if (syncIsEnabled) {
            if (recordIds.size() <= integrationSettings.Future_Record_Limit__c) {
                syncRecordsFuture(recordIds, sObjectName, operation);
            } else {
                Database.executeBatch(new AccountingSyncBatch(recordIds, sObjectName, operation), 50);
            }
        }
    }

     public static List<SyncResult> sendDirectPushNotifications(Set<Id> recordIds, String sObjectName, String operation) {
        List<SyncResult> results = new List<SyncResult>();
        List<SObject> records = Database.query(getQueryString(sObjectName));
        if (!records.isEmpty()) {
            results = syncRecords(records, sObjectName, operation);
            updateErrorLogs(results);
        }
        return results;
    }

    public static String getQueryString(String sObjectName) {
        Set<String> fieldNames = new Set<String>(AccountingSyncMapping.getMappingFor(sObjectName).values());
        if (sObjectName.equalsIgnoreCase(ACCOUNT_OBJECT_NAME)) {
            fieldNames.addAll(AccountingSyncMapping.getMappingFor(CONTACT_OBJECT_NAME).values());
        }
        if (sObjectName == AccountingSyncHelper.ACCOUNT_WELCOME_EMAIL_OBJECT_NAME ||
            sObjectName == AccountingSyncHelper.ACCOUNT_FORGOT_PASSWORD_OBJECT_NAME) {
            sObjectName = ACCOUNT_OBJECT_NAME;
        }
        return String.format(
            TARGET_QUERY_STRING_TEMPLATE,
            new List<String> { String.join(new List<String>(fieldNames), ', '), sObjectName }
        );
    }

    public static List<SyncResult> syncRecords(List<SObject> records, String sObjectName, String operation) {
        Map<String, String> mapping = AccountingSyncMapping.getMappingFor(sObjectName);
        Map<String, String> contactMapping;
        if (sObjectName.equalsIgnoreCase(ACCOUNT_OBJECT_NAME)) {
            contactMapping = AccountingSyncMapping.getMappingFor(CONTACT_OBJECT_NAME);
        }
        Map<String, String> stationNameToUicCodeMap;
        if (sObjectName.equalsIgnoreCase(TICKET_OBJECT_NAME)) {
            stationNameToUicCodeMap = getStationNameToUicCodeMap(records);
        }
        List<SyncResult> syncResults = new List<SyncResult>();
        for (SObject record : records) {
            SyncResult syncResult;
            if (sObjectName.equalsIgnoreCase(TICKET_OBJECT_NAME)) {
                syncResult = sendTicketRecord((Ticket__c)record, operation, mapping, stationNameToUicCodeMap);
            }
            else {
                syncResult = sendRecord(record, sObjectName, operation, mapping);
                if (sObjectName.equalsIgnoreCase(ACCOUNT_OBJECT_NAME)) {
                    syncResults.add(sendRecord(record, CONTACT_OBJECT_NAME, operation, contactMapping));
                }
            }
            syncResults.add(syncResult);
        }
        return syncResults;
    }

    public static void updateErrorLogs(List<SyncResult> syncResults) {
        Set<Id> recordIds = new Set<Id>();
        for (SyncResult result : syncResults) {
            recordIds.add(result.recordId);
        }
        List<Service_Integration_Log__c> actualErrorLogs = [
            SELECT Object_Api_Name__c, Record_Id__c, Sync_Operation__c, Number_of_Attempts__c
            FROM Service_Integration_Log__c
            WHERE Service_Name__c = : ACCOUNTS_SERVICE_NAME
            AND Is_Actual__c = true
            AND Record_Id__c IN : recordIds
            LIMIT 10000
        ];
        Map<String, Map<Id, Map<String, Service_Integration_Log__c>>> actualLogsMap =
            new Map<String, Map<Id, Map<String, Service_Integration_Log__c>>>();
        for (Service_Integration_Log__c log : actualErrorLogs) {
            if (!actualLogsMap.containsKey(log.Object_Api_Name__c)) {
                actualLogsMap.put(log.Object_Api_Name__c, new Map<Id, Map<String, Service_Integration_Log__c>>());
            }
            Map<Id, Map<String, Service_Integration_Log__c>> recordIdToLogMap = actualLogsMap.get(log.Object_Api_Name__c);
            if (!recordIdToLogMap.containsKey(log.Record_Id__c)) {
                recordIdToLogMap.put(log.Record_Id__c, new Map<String, Service_Integration_Log__c>());
            }
            recordIdToLogMap.get(log.Record_Id__c).put(log.Sync_Operation__c, log);
        }
        actualErrorLogs.clear();
        for (SyncResult result : syncResults) {
            Service_Integration_Log__c actualLog;
            if (actualLogsMap.containsKey(result.objectName)) {
                Map<Id, Map<String, Service_Integration_Log__c>> recordIdToLogMap = actualLogsMap.get(result.objectName);
                if (recordIdToLogMap.containsKey(result.recordId)) {
                    Map<String, Service_Integration_Log__c> operationToLogMap = recordIdToLogMap.get(result.recordId);
                    if (operationToLogMap.containsKey(result.operation)) {
                        actualLog = operationToLogMap.get(result.operation);
                        if (result.isSuccessful) {
                            actualLog.Is_Actual__c = false;
                        } else {
                            actualLog.Error_Message__c = result.errorMessage;
                            actualLog.Number_of_Attempts__c++;
                        }
                    }
                }
            }
            if (actualLog == null && !result.isSuccessful) {
                actualLog = new Service_Integration_Log__c(
                    Service_Name__c = ACCOUNTS_SERVICE_NAME,
                    Object_Api_Name__c = result.objectName,
                    Record_Id__c = result.recordId,
                    Sync_Operation__c = result.operation,
                    Error_Message__c = result.errorMessage,
                    Number_of_Attempts__c = 1,
                    Is_Actual__c = true
                );
            }
            if (actualLog != null) {
                actualErrorLogs.add(actualLog);
            }
        }
        upsert actualErrorLogs;
    }

    @Future(callout=true)
    private static void syncRecordsFuture(Set<Id> recordIds, String sObjectName, String operation) {
        List<SObject> records = Database.query(getQueryString(sObjectName));
        if (!records.isEmpty()) {
            updateErrorLogs(syncRecords(records, sObjectName, operation));
        }
    }

    private static Map<String, String> getStationNameToUicCodeMap(List<SObject> records) {
        Set<String> stationNames = new Set<String>();
        for (SObject record : records) {
            for (String stationField : AccountingSyncMapping.TIKET_STATION_FIELD_MAPPING.keySet()) {
                if (record.get(stationField) != null) {
                    stationNames.add(String.valueOf(record.get(stationField)).toUpperCase());
                }
            }
        }
        List<Stations__c> relatedStations = Database.query(STATION_QUERY_STRING);
        Map<String, String> nameToUicCodeMap = new Map<String, String>();
        for (Stations__c station : relatedStations) {
            nameToUicCodeMap.put(String.valueOf(station.get(STATION_NAME_FIELD_TO_LOOKUP)), station.UIC_Code__c);
        }
        return nameToUicCodeMap;
    }

    private static SyncResult sendRecord(SObject record, String sObjectName, String operation, Map<String, String> mapping) {
        Map<String, String> fieldMap = getFieldMap(record, sObjectName, mapping);
        return composeSyncResult(record.Id, sObjectName, operation, makeSyncRequest(sObjectName, operation, fieldMap));
    }

    private static SyncResult sendTicketRecord(Ticket__c record, String operation, Map<String, String> mapping,
        Map<String, String> stationNameToUicCodeMap) {
        Map<String, String> fieldMap = getFieldMap(record, TICKET_OBJECT_NAME, mapping);
        for (String stationField : AccountingSyncMapping.TIKET_STATION_FIELD_MAPPING.keySet()) {
            if (record.get(stationField) != null) {
                String stationName = String.valueOf(record.get(stationField)).toUpperCase();
                if (stationNameToUicCodeMap.containsKey(stationName)) {
                    fieldMap.put(
                        AccountingSyncMapping.TIKET_STATION_FIELD_MAPPING.get(stationField),
                        stationNameToUicCodeMap.get(stationName)
                    );
                }
            }
            if (!AccountingSyncMapping.TIKET_STATION_FIELD_MAPPING.containsKey(stationField)) {
                fieldMap.put(AccountingSyncMapping.TIKET_STATION_FIELD_MAPPING.get(stationField), null);
            }
        }
        return composeSyncResult(
            record.Id, TICKET_OBJECT_NAME, operation, makeSyncRequest(TICKET_OBJECT_NAME, operation, fieldMap)
        );
    }

    private static Map<String, String> getFieldMap(SObject record, String sObjectName, Map<String, String> mapping) {
        Map<String, String> fieldMap = new Map<String, String> {
            ID_PARAMETER_NAME => record.Id,
            CID_PARAMETER_NAME => generateCid(),
            EVENT_TIMESTAMP_PARAMETER_NAME => String.valueOf(System.now().format(DATETIME_TARGET_FORMAT))
        };
        for (String accountingFieldName : mapping.keySet()) {
            String sfFieldName = mapping.get(accountingFieldName);
            List<String> sfFieldPath = sfFieldName.split('\\.');
            SObject targetRecord = record;
            for (Integer i = 0; i < sfFieldPath.size() - 1 && targetRecord != null; i++) {
                targetRecord = targetRecord.getSObject(sfFieldPath[i]);
            }
            Object fieldValue;
            if (targetRecord != null) {
                fieldValue = targetRecord.get(sfFieldPath[sfFieldPath.size() - 1]);
            }
            String stringFieldValue;
            if (fieldValue != null) {
                if (fieldValue instanceof Boolean) {
                    stringFieldValue = (Boolean) fieldValue ? 'Y' : 'N';
                } else if (sObjectName.equalsIgnoreCase(TICKET_OBJECT_NAME) && DATETIME_TICKET_FIELDS.contains(sfFieldName)) {
                    // Converts dd/MM/yyyy HH:mm:ss to yyyyMMddHHmmss
                    List<String> datetimeParts = String.valueOf(fieldValue).split('/| |:');
                    String yearPart = datetimeParts[2];
                    datetimeParts[2] = datetimeParts[0];
                    datetimeParts[0] = yearPart;
                    stringFieldValue = String.join(datetimeParts, '');
                } else if (fieldValue instanceof Date || fieldValue instanceof Datetime) {
                    stringFieldValue = ((Datetime) fieldValue).format(DATETIME_TARGET_FORMAT);
                    if (fieldValue instanceof Date) {
                        stringFieldValue = stringFieldValue.substring(0, 8);
                    }
                } else {
                    stringFieldValue = String.valueOf(fieldValue);
                }
            }
            fieldMap.put(accountingFieldName, stringFieldValue);
        }
        return fieldMap;
    }

    private static String generateCid() {
        String cid = '';
        for (Integer i = 0; i < CID_LENGTH; i++) {
            cid += String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 10));
        }
        return cid;
    }

    private static String makeSyncRequest(String sObjectName, String operation, Map<String, String> fieldMap) {
        Http http = new Http();
        Map<String, Object> requestBody = new Map<String, Object> {
            EVENT_TYPE_PARAMETER_NAME => operation
        };
        if (sObjectName == ACCOUNT_WELCOME_EMAIL_OBJECT_NAME) {
            fieldMap.put(ACTION_FIELD_NAME, WELCOME_EMAIL_FIELD_VALUE);
            requestBody.put(AccountingSyncMapping.ACCOUNTING_OBJECT_NAME_MAPPING.get(sObjectName), fieldMap);
        } else  if (sObjectName == ACCOUNT_FORGOT_PASSWORD_OBJECT_NAME) {
            fieldMap.put(ACTION_FIELD_NAME, FORGOT_PASSWORD_FIELD_VALUE);
            requestBody.put(AccountingSyncMapping.ACCOUNTING_OBJECT_NAME_MAPPING.get(sObjectName), fieldMap);
        } else {
            requestBody.put(AccountingSyncMapping.ACCOUNTING_OBJECT_NAME_MAPPING.get(sObjectName), new List<Object> { fieldMap });
        }
        HttpRequest request = new HttpRequest();
        request.setEndpoint(integrationSettings.Endpoint_Url__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setHeader('cid', fieldMap.get(CID_PARAMETER_NAME));
        request.setHeader('Cache-Control', 'no-cache');
        request.setHeader('X-apikey', integrationSettings.Api_Key__c);
        request.setBody(JSON.serializePretty(requestBody));
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 202) {
            String responseBody = response.getBody();
            return String.isBlank(responseBody) ? response.getStatus() : responseBody;
        }
        return null;
    }

    private static SyncResult composeSyncResult(Id recordId, String objectName, String operation, String errorMessage) {
        SyncResult result = new SyncResult();
        result.recordId = recordId;
        result.objectName = objectName;
        result.operation = operation;
        result.isSuccessful = String.isBlank(errorMessage);
        result.errorMessage = errorMessage;
        return result;
    }

    public class SyncResult {
        public Id recordId;
        public String objectName;
        public String operation;
        public Boolean isSuccessful;
        public String errorMessage;
    }
}