public without sharing class DLT_PassingPointTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                fillDelayReasonFields((List<Passing_Point__c>) System.Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                fillDelayReasonFields((List<Passing_Point__c>) System.Trigger.new);
                syncTrainExpertFields((Map<Id, Passing_Point__c>) System.Trigger.newMap, (Map<Id, Passing_Point__c>) System.Trigger.oldMap);
                preventDelayOverride((List<Passing_Point__c>) System.Trigger.new, (Map<Id, Passing_Point__c>) System.Trigger.oldMap);
            }
        }
        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                calculateTrainGlobalDelayReason((List<Passing_Point__c>) System.Trigger.new);
            }
            if (System.Trigger.isUpdate) {
                updateDelayOnTickets((Map<Id, Passing_Point__c>) System.Trigger.newMap, (Map<Id, Passing_Point__c>) System.Trigger.oldMap);
                calculateTrainGlobalDelayReason((List<Passing_Point__c>) System.Trigger.new, (Map<Id, Passing_Point__c>) System.Trigger.oldMap);
            }
        }
    }

    private static void syncTrainExpertFields(Map<Id, Passing_Point__c> newMap, Map<Id, Passing_Point__c> oldMap){

        if(!DLT_Constants.IS_TRAIN_EXPERT) return;

        for(Passing_Point__c pp : newMap.values()){
            if(pp.PassingPoint_Arrival_Delay__c != oldMap.get(pp.Id).PassingPoint_Arrival_Delay__c){

                pp.Delay_Mins_Train_Expert__c = Integer.valueOf(pp.PassingPoint_Arrival_Delay__c);
                pp.Train_Expert__c = UserInfo.getUserId();
            }
        }
    }

    private static void updateDelayOnTickets(Map<Id, Passing_Point__c> newMap, Map<Id, Passing_Point__c> oldMap){


        if(!DLT_Constants.IS_TRAIN_EXPERT) return;

        Set<Id> trainIds = new Set<Id>();
        Set<String> uicCodes = new Set<String>();

        Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints = new Map<Id,Map<String,Passing_Point__c>>();

        for(Passing_Point__c pp : newMap.values()){
            if(pp.PassingPoint_Arrival_Delay__c != oldMap.get(pp.Id).PassingPoint_Arrival_Delay__c){

                trainIds.add(pp.Train__c);
                uicCodes.add(pp.UIC_Code__c);

                if(!trainWithPassingPoints.containsKey(pp.Train__c)){
                    Map<String,Passing_Point__c> tempMap = new Map<String, Passing_Point__c>();
                    tempMap.put(pp.UIC_Code__c, pp);
                    trainWithPassingPoints.put(pp.Train__c, tempMap);
                }
                trainWithPassingPoints.get(pp.Train__c).put(pp.UIC_Code__c, pp);

            }
        }

        trainIds.remove(null);
        uicCodes.remove(null);
        uicCodes.remove('');

        if (trainIds.isEmpty() && uicCodes.isEmpty()) { return; }

        List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();

        for(Ticket__c t : [
            SELECT Id, UIC_Code__c, Train__c
            FROM Ticket__c
            WHERE Train__c IN :trainIds
                AND UIC_Code__c IN :uicCodes
                AND Ticket_Status__c = :DLT_TicketConstants.TICKET_STATUS_ACTIVE
                AND (
                        (Train__r.Carrier__c = :DLT_TrainConstants.CARRIER_BLUE AND Checked_in__c = true)
                        OR Train__r.Carrier__c = :DLT_TrainConstants.CARRIER_RED
                    )
        ]){
            if(trainWithPassingPoints.containsKey(t.Train__c) && trainWithPassingPoints.get(t.Train__c).containsKey(t.UIC_Code__c)){
                ticketsToUpdate.add(
                    new Ticket__c (
                        Id = t.Id, 
                        Delay_mins__c = Integer.valueOf(trainWithPassingPoints.get(t.Train__c).get(t.UIC_Code__c).PassingPoint_Arrival_Delay__c),
                        Delay_Mins_Train_Expert__c = Integer.valueOf(trainWithPassingPoints.get(t.Train__c).get(t.UIC_Code__c).PassingPoint_Arrival_Delay__c),
                        Train_Expert__c = UserInfo.getUserId()
                    )
                );
            }
        }

        update ticketsToUpdate;

    }

    private static void preventDelayOverride(List<Passing_Point__c> newList, Map<Id, Passing_Point__c> oldMap){

        if(DLT_Constants.IS_TRAIN_EXPERT) return;

        for(Passing_Point__c pp : newList){

            if(pp.PassingPoint_Arrival_Delay__c != oldMap.get(pp.Id).PassingPoint_Arrival_Delay__c 
                && pp.Delay_Mins_Train_Expert__c != null){

                pp.PassingPoint_Arrival_Delay__c = String.valueOf(pp.Delay_Mins_Train_Expert__c);
            }
        }
    }

    private static void calculateTrainGlobalDelayReason(List<Passing_Point__c> newList, Map<Id, Passing_Point__c> oldMap){

        List<Id> trainIdsToCalculate = new List<Id>();

        for(Passing_Point__c pp : newList){

            if(pp.PassingPoint_Arrival_Delay__c != oldMap.get(pp.Id).PassingPoint_Arrival_Delay__c){

                trainIdsToCalculate.add(pp.Train__c);

            }
        }

        DLT_Train_Service.calculateGlobalDelayReason(trainIdsToCalculate);
    }

    private static void calculateTrainGlobalDelayReason(List<Passing_Point__c> newList){

        List<Id> trainIdsToCalculate = new List<Id>();

        for(Passing_Point__c pp : newList){

            trainIdsToCalculate.add(pp.Train__c);

        }

        DLT_Train_Service.calculateGlobalDelayReason(trainIdsToCalculate);
    }

    private static void fillDelayReasonFields(List<Passing_Point__c> newList){

        for(Passing_Point__c pp : newList){

            if(!String.isBlank(pp.Arrival_Commercial_Reason__c) && pp.PassingPoint_Delay_Reason__c != pp.Arrival_Commercial_Reason__c){

                pp.PassingPoint_Delay_Reason__c = pp.Arrival_Commercial_Reason__c;

            }
        }
    }
}