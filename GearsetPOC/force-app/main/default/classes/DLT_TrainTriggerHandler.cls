public without sharing class DLT_TrainTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
            }

            if (System.Trigger.isUpdate) {
                syncTrainExpertFields((Map<Id, Train__c>) System.Trigger.newMap, (Map<Id, Train__c>) System.Trigger.oldMap);
                preventDelayOverride((List<Train__c>) System.Trigger.new, (Map<Id, Train__c>) System.Trigger.oldMap);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                calculateGlobalDelayReason((Map<Id, Train__c>) System.Trigger.newMap);
            }

            if (System.Trigger.isUpdate) {
                updateDelayOnTickets((Map<Id, Train__c>) System.Trigger.newMap, (Map<Id, Train__c>) System.Trigger.oldMap);
                createCompensations((Map<Id,Train__c>)Trigger.newMap, (Map<Id,Train__c>)Trigger.oldMap);
                calculateGlobalDelayReason((Map<Id, Train__c>) System.Trigger.newMap, (Map<Id, Train__c>) System.Trigger.oldMap);
            }
        }
    }


    private static void createCompensations(Map<Id,Train__c> newTrainMap, Map<Id,Train__c> oldTrainMap){

        List<Id> trainsToCompensateIds = new List<Id>();

        for(Train__c train : newTrainMap.values()){
            if(   !train.Exempt_from_Auto_Compensation__c 
                && oldTrainMap.get(train.Id).Exempt_from_Auto_Compensation__c 
                && !train.Train_handled_by_Auto_Compensation__c){

                trainsToCompensateIds.add(train.Id);
            }
        }

        if(trainsToCompensateIds.size() > 0){
            String s = '\'' + String.join(trainsToCompensateIds,'\',\'') + '\'';

            String query = 
            'SELECT Id, Train__c, Checked_In__c, Cancelled__c, Travel_DateTime__c, Train__r.Departure_Date_Time__c, UIC_Code__c, Cancelled_By_Customer__c, ' + 
            'Train_No_Catering__c, Train_Unacceptable_Travel_Conditions__c, Delay_mins__c, Train__r.Cancelled__c FROM Ticket__c WHERE Train__r.Cancelled__c = false  AND Train__c IN  (' + s + ')';
    
            Database.executeBatch(new CompApp_ScheduledCompensation(query), 200);
        }
        
    }

    private static void updateDelayOnTickets(Map<Id, Train__c> newMap, Map<Id, Train__c> oldMap){

        if(!DLT_Constants.IS_TRAIN_EXPERT) return;

        Map<Id, Train__c> trainMap = new Map<Id, Train__c>();
        Set<String> uicCodes = new Set<String>();

        for(Train__c train : newMap.values()){
            if(train.Delay_in_Minutes__c != oldMap.get(train.Id).Delay_in_Minutes__c){

                trainMap.put(train.Id, train);
                uicCodes.add(train.UIC_To__c);

            }
        }

        trainMap.remove(null);
        uicCodes.remove(null);
        uicCodes.remove('');

        if (trainMap.isEmpty() && uicCodes.isEmpty()) { return; }

        List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();

        for(Ticket__c t : [
            SELECT Id, UIC_Code__c, Train__c
            FROM Ticket__c
            WHERE Train__c IN :trainMap.keySet()
                AND UIC_Code__c IN :uicCodes
                AND Ticket_Status__c = :DLT_TicketConstants.TICKET_STATUS_ACTIVE
                AND (
                        (Train__r.Carrier__c = :DLT_TrainConstants.CARRIER_BLUE AND Checked_in__c = true)
                        OR Train__r.Carrier__c = :DLT_TrainConstants.CARRIER_RED
                    )
        ]){
            if(trainMap.containsKey(t.Train__c) && t.UIC_Code__c == trainMap.get(t.Train__c).UIC_To__c){
                ticketsToUpdate.add(
                    new Ticket__c (
                        Id = t.Id, 
                        Delay_mins__c = trainMap.get(t.Train__c).Delay_in_Minutes__c,
                        Delay_Mins_Train_Expert__c = trainMap.get(t.Train__c).Delay_in_Minutes__c,
                        Train_Expert__c = UserInfo.getUserId()
                    )
                );
            }
        }

        update ticketsToUpdate;

    }

    private static void preventDelayOverride(List<Train__c> newList, Map<Id, Train__c> oldMap){
        
        if(DLT_Constants.IS_TRAIN_EXPERT) return;

        for(Train__c train : newList){

            if(train.Delay_in_Minutes__c != oldMap.get(train.Id).Delay_in_Minutes__c 
                && train.Delay_Mins_Train_Expert__c != null){

                train.Delay_in_Minutes__c = train.Delay_Mins_Train_Expert__c;
            }
        }
    }

    private static void syncTrainExpertFields(Map<Id, Train__c> newMap, Map<Id, Train__c> oldMap){

        if(!DLT_Constants.IS_TRAIN_EXPERT) return;

        for(Train__c train : newMap.values()){
            if(train.Delay_in_Minutes__c != oldMap.get(train.Id).Delay_in_Minutes__c){

                train.Delay_Mins_Train_Expert__c = train.Delay_in_Minutes__c;
                train.Train_Expert__c = UserInfo.getUserId();

            }

            if(train.Global_Delay_Reason__c != oldMap.get(train.Id).Global_Delay_Reason__c){

                train.Global_Delay_Reason_Train_Expert__c = train.Global_Delay_Reason__c;
                train.Train_Expert__c = UserInfo.getUserId();

            }
        }
    }

    private static void calculateGlobalDelayReason(Map<Id, Train__c> newMap, Map<Id, Train__c> oldMap){

        List<Id> trainIdsToCalculate = new List<Id>();

        for(Train__c train : newMap.values()){
            if(train.Delay_in_Minutes__c != oldMap.get(train.Id).Delay_in_Minutes__c){

                trainIdsToCalculate.add(train.Id);

            }
        }

        DLT_Train_Service.calculateGlobalDelayReason(trainIdsToCalculate);
    }

    private static void calculateGlobalDelayReason(Map<Id, Train__c> newMap){

        DLT_Train_Service.calculateGlobalDelayReason(new List<Id>(newMap.keySet()));
    }

}