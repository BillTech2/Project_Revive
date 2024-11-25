public without sharing class DLT_SubscriptionTriggerHandler {
    public static Boolean isDisabled = false;

    public static Set<Id> processedRecordIds = new Set<Id>();

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                toggleActiveStatus(System.Trigger.new);
                populateDuration(System.Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                toggleActiveStatus(System.Trigger.new);
            }
        }

        if (System.Trigger.isAfter) {


            List<Subscription__c> newRecords = filterProcessedRecords(processedRecordIds);

            if (System.Trigger.isInsert) {
                setCustomerSubscriptionStatus(newRecords);

            }

            if (System.Trigger.isUpdate) {
                setCustomerSubscriptionStatus(newRecords);
                updateSubscriptionDuration(newRecords, Trigger.oldMap);
            }
        }
    }

    private static List<Subscription__c> filterProcessedRecords(Set<Id> processedRecordIds) {
        List<Subscription__c> filteredRecords = new List<Subscription__c>();

        if(!Trigger.isDelete) {
            for(Subscription__c newRecord : (List<Subscription__c>) Trigger.new) {
                if(processedRecordIds.contains(newRecord.Id)) { continue; }

                filteredRecords.add(newRecord);
                processedRecordIds.add(newRecord.Id);
            }
        }

        return filteredRecords;
    }


    private static void toggleActiveStatus(List<Subscription__c> newRecords) {
        if (newRecords == null) { return ; }

        Set<String> eligibleStatuses = new Set<String>{
            DLT_SubscriptionConstants.STATUS_ACTIVE,
            DLT_SubscriptionConstants.STATUS_NOT_STARTED
        };

        for (Subscription__c s : newRecords) {
            if (!eligibleStatuses.contains(s.Status__c)) { continue; }

            s.Status__c = s.Start_Date__c > Date.today() && s.End_Date__c > Date.today()
                ? DLT_SubscriptionConstants.STATUS_NOT_STARTED
                : s.Start_Date__c <= Date.today() && s.End_Date__c >= Date.today()
                    ? DLT_SubscriptionConstants.STATUS_ACTIVE
                    : DLT_SubscriptionConstants.STATUS_EXPIRED;
        }
    }

    private static void setCustomerSubscriptionStatus(List<Subscription__c> newRecords){

        List<Id> customerIds = new List<Id>();

        for(Subscription__c s : newRecords){

            if(s.Member__c == null) { continue; }

            customerIds.add(s.Member__c);
        }

        Map<Id, String> memberToStatus = new Map<Id,String>();

        for(AggregateResult ar : [
            SELECT Member__c, Status__c, MAX(End_Date__c) maxEndDate
            FROM Subscription__c
            WHERE Member__c IN :customerIds
                AND Status__c != null
                AND End_Date__c != null
            GROUP BY Member__c, Status__c
            ORDER BY MAX(End_Date__c) DESC
        ]){

            // puts Status of the subscription with biggest end date
            if(!memberToStatus.containsKey((String)ar.get('Member__c'))){
                memberToStatus.put((String)ar.get('Member__c'), (String)ar.get('Status__c'));
            }

            // puts active Status when meets Active Subscription
            if(ar.get('Status__c') == DLT_SubscriptionConstants.STATUS_ACTIVE){
                memberToStatus.put((String)ar.get('Member__c'), (String)ar.get('Status__c'));
            }  
        }

        List<Account> customersToUpdate = new List<Account>();

        for(Id customerId : memberToStatus.keySet()){
            
            customersToUpdate.add(new Account(
                Id = customerId,
                Subscription_Status__pc = memberToStatus.get(customerId)
            ));
        }

        update customersToUpdate;
    }


    private static void populateDuration(List<Subscription__c> newRecords) {
        if (newRecords == null) { return ; }

        for(Subscription__c newRecord : newRecords) {
            if (!DLT_SubscriptionTriggerHandler.processedRecordIds.contains(newRecord.Id)
                && newRecord.Start_Date__c != null
                && newRecord.End_Date__c != null
            ) {
                newRecord.Duration__c = String.valueOf(newRecord.Start_Date__c.monthsBetween(newRecord.End_Date__c));
            }
        }
    }

    private static void updateSubscriptionDuration(List<Subscription__c> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id,Subscription__c> oldSubs = (Map<Id,Subscription__c>) oldRecords;

        if (newRecords == null) { return ; }

        List<Subscription__c> newSubs = selectSubscriptionByIds(newRecords);
        
        for(Subscription__c newRecord : newSubs) {
            Boolean isStartDateChanged = oldSubs.get(newRecord.id).Start_Date__c != newRecord.Start_Date__c;
            Boolean isEndDateChanged = oldSubs.get(newRecord.id).End_Date__c != newRecord.End_Date__c;
            Boolean isStatusPending = newRecord.Status__c == DLT_SubscriptionConstants.STATUS_PENDING_PAYMENT;
            Boolean isStatusNotStarted = newRecord.Status__c == DLT_SubscriptionConstants.STATUS_NOT_STARTED;
            Boolean isStatusActive = newRecord.Status__c == DLT_SubscriptionConstants.STATUS_ACTIVE;
            Boolean isNewExtendedEndDate = newRecord.New_Extended_End_Date__c != NULL;

            if (
                (isStartDateChanged && isEndDateChanged) 
                && (isStatusPending || isStatusNotStarted)
                ) {
                newRecord.Duration__c = String.valueOf(newRecord.Start_Date__c.monthsBetween(newRecord.End_Date__c));
            }

            if (
                isNewExtendedEndDate 
                && (isStatusActive)
                ) {
                newRecord.Duration__c = String.valueOf(newRecord.Start_Date__c.monthsBetween(newRecord.New_Extended_End_Date__c));
            }

        }

        update newSubs;
    }

    private static List<Subscription__c> selectSubscriptionByIds(List<Subscription__c> subs) {
        return [
            SELECT Id, Status__c, Start_Date__c, End_Date__c, Duration__c, New_Extended_End_Date__c
            FROM Subscription__c
            WHERE Id IN :subs
        ];
    }

}