public without sharing class DLT_Train_Service {
    
    public static void calculateGlobalDelayReason(List<Id> trainIds){

        if(DLT_Utils.isAsyncCtx()){
            calculateAndAssignGlobalDelayReason(trainIds);
        } else{
            calculateAndAssignGlobalDelayReasonInFuture(trainIds);
        }
    }

    @future
    public static void calculateAndAssignGlobalDelayReasonInFuture(List<Id> trainIds){
        calculateAndAssignGlobalDelayReason(trainIds);
    }

    public static void calculateAndAssignGlobalDelayReason(List<Id> trainIds){
        
        // create required maps

        Map<Id, List<Passing_Point__c>> trainWithPassingPoint = new Map<Id, List<Passing_Point__c>>();
        Map<Id, Train__c> trainById = new Map<Id, Train__c>();

        for (Train__c t : [
            SELECT Id, Delay_in_Minutes__c, Destination_Commercial_Reason__c
            FROM Train__c
            WHERE Id IN :trainIds
                AND Global_Delay_Reason_Train_Expert__c = null
        ]){
            trainWithPassingPoint.put(t.Id, new List<Passing_Point__c>());
            trainById.put(t.Id, t);
        }

        for (Passing_Point__c pp: [
            SELECT Id, PassingPoint_Arrival_Delay__c, PassingPoint_Departure_Delay__c, Arrival_Commercial_Reason__c, 
                Departure_Commercial_Reason__c, Train__c, PassingPoint_Delay_Reason__c
            FROM Passing_Point__c
            WHERE Train__c IN :trainById.keySet()
            ORDER BY Departure_Date_Time__c 
        ]){
            trainWithPassingPoint.get(pp.Train__c).add(pp);
        }

        // calculate Global Delay Reason

        List<Train__c> trainsToUpdate = new List<Train__c>();

        for(Id trainId : trainWithPassingPoint.keySet()){

            Map<String, Integer> delayReasonToTime = new Map<String, Integer>();
            Integer currentDelay = 0;

            // going from first to last passing point 
            for(Passing_Point__c p : trainWithPassingPoint.get(trainId)){

                if(String.isBlank(p.PassingPoint_Arrival_Delay__c)) continue; 

                // calculate delay difference 
                Integer arrivalDelayDifference = Integer.valueOf(p.PassingPoint_Arrival_Delay__c) - currentDelay;
                // update current delay
                currentDelay = Integer.valueOf(p.PassingPoint_Arrival_Delay__c);

                if(arrivalDelayDifference <= 0) continue;

                // add delay difference to correct delay reason
                if(!delayReasonToTime.containsKey(p.PassingPoint_Delay_Reason__c)){
                    delayReasonToTime.put(p.PassingPoint_Delay_Reason__c, 0);
                }
                delayReasonToTime.put(p.PassingPoint_Delay_Reason__c, delayReasonToTime.get(p.PassingPoint_Delay_Reason__c) + arrivalDelayDifference);
         
            }

            Train__c currentTrain = trainById.get(trainId);

            // final destination 
            if(currentTrain.Delay_in_Minutes__c != null){
                // difference between last passing point and destination
                Integer trainDelay = Integer.valueOf(currentTrain.Delay_in_Minutes__c) - currentDelay;

                // add delay difference to correct delay reason
                if(!delayReasonToTime.containsKey(currentTrain.Destination_Commercial_Reason__c)){
                    delayReasonToTime.put(currentTrain.Destination_Commercial_Reason__c, trainDelay);
                } else {
                    delayReasonToTime.put(currentTrain.Destination_Commercial_Reason__c, delayReasonToTime.get(currentTrain.Destination_Commercial_Reason__c) + trainDelay);
                }
            }
            
            // find biggest delay and corresponding reason
            String globalDelayReason = '';
            Integer maxDelay = 0;

            for(String reason : delayReasonToTime.keySet()){
                if(delayReasonToTime.get(reason) > maxDelay){
                    maxDelay = delayReasonToTime.get(reason);
                    globalDelayReason = reason;
                }
            }

            trainsToUpdate.add(new Train__c(Id = trainId, Global_Delay_Reason__c = globalDelayReason));

        }
        DLT_TrainTriggerHandler.isDisabled = true;
        update trainsToUpdate;
        DLT_TrainTriggerHandler.isDisabled = false;
    }

}