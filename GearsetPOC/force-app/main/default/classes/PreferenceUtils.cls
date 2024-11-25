public with sharing class PreferenceUtils {

    public static Map<String, String> getPicklistLabelAPIMap(String sObjectName, String sObjectField, Boolean returnAPI) {
        Type objType = Type.forName(sObjectName);
        Schema.DescribeSObjectResult desSObjResult = ((Sobject)objType.newInstance()).getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> sObjFieldMap = desSObjResult.fields.getMap();
        Schema.DescribeFieldResult fieldDescResult = sObjFieldMap.get(sObjectField).getDescribe();
        List<Schema.PicklistEntry> pickListValues  = fieldDescResult.getPicklistValues();

        Map<String, String> picklistItems = new Map<String, String>();
        for (Schema.PicklistEntry e : pickListValues){
            if (returnAPI) {
                picklistItems.put(e.getValue(), e.getValue());
            } else {
                picklistItems.put(e.getValue(), e.getLabel());
            }
        }

        return picklistItems;
    }

    public static void sendBatchProcessingResultEmail(AsyncApexJob job, String emailAddress, String emailSubject) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { emailAddress });
        mail.setSubject(emailSubject + PreferenceConstants.SPACE + job.Status);
        mail.setPlainTextBody(String.format(
            PreferenceConstants.BATCH_PROCESSING_RESULT_EMAIL_TEMPLATE,
            new String[] {
                String.valueOf(job.TotalJobItems),
                String.valueOf(PreferenceConstants.BATCH_CHUNK_SIZE),
                String.valueOf(job.NumberOfErrors)
            }
        ));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static void sendInsertionErrorsOccursEmail(String emailSubject, String emailAddress, String sObjectName, String errors) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { emailAddress });
        mail.setSubject(emailSubject);
        mail.setPlainTextBody(String.format(
            PreferenceConstants.ERRORS_DURING_INSERT_TEMPLATE,
            new String[] {
                String.valueOf(sObjectName),
                String.valueOf(errors)
            }
        ));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static void createCustomerAccount() {
        insert new List<Account>{new Account(
            FirstName = PreferenceTestDataFactory.TEST_ACCOUNT_FIRST_NAME,
            LastName  = PreferenceTestDataFactory.TEST_ACCOUNT_LAST_NAME
        )};
    }

    public static List<Datetime> getDates2YAgoForBatch() {
        List<Datetime> listOfDates = new List<Datetime>();

        for (Integer i = 0; i <= PreferenceTestDataFactory.NUMBER_OF_FOR_INSTANCES; i++) {
            listOfDates.add(System.now().addYears(-2).addMonths(-1).addDays(-i));
        }

        listOfDates.sort();

        return listOfDates;
    }

    public static void createEmailCustomSetting() {
        Preference_Center_Configuration__c emailCustomSetting = new Preference_Center_Configuration__c();
        emailCustomSetting.Data__c = PreferenceConstants.TEST_DEFAULT_EMAIL_ADDRESS;
        emailCustomSetting.Name = PreferenceConstants.CUSTOM_SETTING_ERROR_EMAIL;

        insert emailCustomSetting;
    }

    public static String getDefaultEmailAddress() {
        return Preference_Center_Configuration__c.getValues(PreferenceConstants.CUSTOM_SETTING_ERROR_EMAIL).Data__c;
    }
}