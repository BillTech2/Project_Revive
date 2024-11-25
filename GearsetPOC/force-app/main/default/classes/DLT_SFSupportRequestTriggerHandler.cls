public without sharing class DLT_SFSupportRequestTriggerHandler {
    
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {

            List<Salesforce_Support_Request__c> filteredRecords = filterRecordsByRecordType((List<Salesforce_Support_Request__c>) System.Trigger.new);

            if (System.Trigger.isInsert) {
               assignToGroup(filteredRecords);
            }
            if (System.Trigger.isUpdate) {
               updateStatusTracker(filteredRecords, (Map<Id, Salesforce_Support_Request__c>) System.Trigger.oldMap);
               blockOwnershipChangeIfNotCreator(filteredRecords, (Map<Id, Salesforce_Support_Request__c>) System.Trigger.oldMap);
            }
            
        }
    }

    public static void assignToGroup(List<Salesforce_Support_Request__c> sFSRequestList){

        Map<String, Id> groupNameToId = new Map<String,Id>();

        for(Group g : [SELECT Id, Name FROM Group WHERE Name IN :DLT_SFSupportRequestConstants.recordTypeToGroup.values() AND Type = 'Queue']){
            groupNameToId.put(g.Name, g.Id);
        }

        for(Salesforce_Support_Request__c request : sFSRequestList){
            request.OwnerId = groupNameToId.get(DLT_SFSupportRequestConstants.recordTypeToGroup.get(request.RecordTypeId));
        }
    }

    public static void updateStatusTracker(List<Salesforce_Support_Request__c> sFSRequestList, Map<Id, Salesforce_Support_Request__c> sFSRequestOldMap){

        for(Salesforce_Support_Request__c request : sFSRequestList){
            if(request.Status__c != sFSRequestOldMap.get(request.Id).Status__c){

                if(request.Last_Status_Change__c == null) request.Last_Status_Change__c = request.CreatedDate;

                Decimal statusDurationInMinutes = (Datetime.now().getTime() - request.Last_Status_Change__c.getTime())/(1000*60);
                
                String duration = calculateDuration(statusDurationInMinutes);

                request.Status_Tracker__c = request.Status_Tracker__c == null ? 
                    sFSRequestOldMap.get(request.Id).Status__c + duration :
                    sFSRequestOldMap.get(request.Id).Status__c + duration + '\n' + request.Status_Tracker__c;
                request.Last_Status_Change__c = Datetime.now();
            }
        }
    }

    public static String calculateDuration(Decimal statusDurationInMinutes){

        Integer statusDurationInHours = 0;
        Integer statusDurationInDays = 0;

        if(statusDurationInMinutes > 60){
            statusDurationInHours = Integer.valueOf(statusDurationInMinutes/60);
            statusDurationInMinutes = statusDurationInMinutes - statusDurationInHours*60;
        }

        if(statusDurationInHours > 24){
            statusDurationInDays = Integer.valueOf(statusDurationInHours/24);
            statusDurationInHours = statusDurationInHours - statusDurationInDays*24;
        }

        return ' - ' + statusDurationInDays + ' days ' + statusDurationInHours + ' hours ' + statusDurationInMinutes + ' minutes';
    }

    public static List<Salesforce_Support_Request__c> filterRecordsByRecordType(List<Salesforce_Support_Request__c> newRecordsList){
        
        List<Salesforce_Support_Request__c> filteredRecords = new List<Salesforce_Support_Request__c>();

        for(Salesforce_Support_Request__c request : newRecordsList){
            if(DLT_SFSupportRequestConstants.feedbackRecordTypeIds.contains(request.RecordTypeId)){
                filteredRecords.add(request);
            }
        }

        return filteredRecords;
    }

    public static void blockOwnershipChangeIfNotCreator(List<Salesforce_Support_Request__c> sFSRequestList, Map<Id, Salesforce_Support_Request__c> sFSRequestOldMap){

        Boolean userHasFeedbackPermission = DLT_Constants.IS_FEEDBACK_USER || DLT_Constants.IS_ADMIN;

        for(Salesforce_Support_Request__c request : sFSRequestList){
            if(request.OwnerId != sFSRequestOldMap.get(request.Id).OwnerId && !userHasFeedbackPermission && request.CreatedById != UserInfo.getUserId()){

                request.addError('Only record creator or user with Feedback Permission can change ownership of a record');

            }
        }
    }
}