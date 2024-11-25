public with sharing class PhoneCaseTriggerHandler {
    public static final Id CUSTOMER_CARE_QUEUE_ID;
    public static final Id CUSTOMER_CARE_FRENCH_QUEUE_ID;
    public static final Id CUSTOMER_CARE_DUTCH_QUEUE_ID;
    public static final String CUSTOMER_CARE_QUEUE_NAME        = 'ECC_Customer_Care';
    public static final String CUSTOMER_CARE_FRENCH_QUEUE_NAME = 'Customer_Care_French';
    public static final String CUSTOMER_CARE_DUTCH_QUEUE_NAME  = 'Customer_Care_Dutch';

    static {
        List<Group> queues = [SELECT Id, DeveloperName
                              FROM Group
                              WHERE (DeveloperName = :CUSTOMER_CARE_QUEUE_NAME OR
                                     DeveloperName = :CUSTOMER_CARE_FRENCH_QUEUE_NAME OR
                                     DeveloperName = :CUSTOMER_CARE_DUTCH_QUEUE_NAME) AND
                                     Type='Queue'];

        for (Group queue : queues) {
            if (queue.DeveloperName.equals(CUSTOMER_CARE_QUEUE_NAME)) CUSTOMER_CARE_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.equals(CUSTOMER_CARE_FRENCH_QUEUE_NAME)) CUSTOMER_CARE_FRENCH_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.equals(CUSTOMER_CARE_DUTCH_QUEUE_NAME)) CUSTOMER_CARE_DUTCH_QUEUE_ID = queue.Id;
        }
    }

    public static void afterUpdate(List<Case> newCases, Map<Id, Case> oldCases) {

        String errorText = 'Please review and complete to continue.';
        for(Case newCase: newCases){
            System.debug('Owner' + newCase.OwnerId);
            System.debug(newCase.Exclude_Delete__c == oldCases.get(newCase.Id).Exclude_Delete__c);
            System.debug(newCase.Origin == 'Phone' || newCase.Origin == 'Web');
            System.debug(!(newCase.OwnerId == CUSTOMER_CARE_QUEUE_ID || newCase.OwnerId == CUSTOMER_CARE_FRENCH_QUEUE_ID || newCase.OwnerId == CUSTOMER_CARE_DUTCH_QUEUE_ID) && newCase.Origin != 'Web');
            System.debug(newCase.Subject == oldCases.get(newCase.Id).Subject );
            System.debug( newCase.Date_Queued__c == oldCases.get(newCase.Id).Date_Queued__c);
            if(newCase.Exclude_Delete__c == oldCases.get(newCase.Id).Exclude_Delete__c 
                && (newCase.Origin == 'Phone') 
                && !((newCase.OwnerId == CUSTOMER_CARE_QUEUE_ID || newCase.OwnerId == CUSTOMER_CARE_FRENCH_QUEUE_ID || newCase.OwnerId == CUSTOMER_CARE_DUTCH_QUEUE_ID) && newCase.Origin != 'Web') 
                && newCase.Subject == oldCases.get(newCase.Id).Subject 
                && newCase.Subject != 'Duplicate'
                && newCase.Date_Queued__c == oldCases.get(newCase.Id).Date_Queued__c
                && newCase.Status == 'Closed') {
                    if(newCase.What_Is_The_Question__c == 'Phone Case - please complete' || newCase.What_Is_The_Question__c == 'Webform case - please review') {
                        newCase.addError('What_Is_The_Question__c', errorText);  
                    }
                    if(newCase.Topic__c == 'Phone Case - please complete' || newCase.Topic__c == 'Webform case - please review') {
                        newCase.addError('Topic__c', errorText);  
                    }
                    if(newCase.Category__c == 'Phone Case - please complete' || newCase.Category__c == 'Webform case - please review') {
                        newCase.addError('Category__c', errorText);  
                    }	
                    if(newCase.Customer_Struggle__c == 'Phone Case - please complete' || newCase.Customer_Struggle__c == 'Webform case - please review') {
                        newCase.addError('Customer_Struggle__c', errorText);  
                    }
                    if(newCase.Customer_Type__c == 'Phone - please complete' || newCase.Customer_Type__c == 'Webform case - please review') {
                        newCase.addError('Customer_Type__c', errorText);  
                    }
                    if(newCase.Initial_Reason_For_Contact__c == 'Phone Case - please complete' || newCase.Initial_Reason_For_Contact__c == 'Webform case - please review') {
                        newCase.addError('Initial_Reason_For_Contact__c', errorText);       
                    }
                    if(newCase.Journey_Type_Product__c == 'Webform case - please review') {
                        newCase.addError('Journey_Type_Product__c', errorText);       
                    }
            }
        }
    }
}