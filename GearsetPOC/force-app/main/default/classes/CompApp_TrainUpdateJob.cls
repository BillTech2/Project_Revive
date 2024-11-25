public without sharing class CompApp_TrainUpdateJob implements Queueable{ 
    List<TRain__c> trainList;
    public CompApp_TrainUpdateJob(List<Train__c> trains){
        this.trainList = trains;
    }

    public void execute(QueueableContext context) { 

        system.debug('tickList.size() @CompApp_CompensationPreCalculationJob: '+trainList.size()); 

        update trainList[0];

        if (trainList.size()>1){
            trainList.remove(0);
            if(!test.isRunningTest())
            	System.enqueueJob(new CompApp_TrainUpdateJob(trainList));
        }
    }
}