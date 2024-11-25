public without sharing class CompApp_CompensationPreCalculationJob implements Queueable{
   CompApp_Constructs.CompensationCreationDataWrapper dataWrapper;

	public CompApp_CompensationPreCalculationJob(CompApp_Constructs.CompensationCreationDataWrapper dataWrapper){
		this.dataWrapper = dataWrapper;
	}

	public void execute(QueueableContext context) {
        if (dataWrapper.chunkedTicketList.size()>=1){
            dataWrapper.tickList = dataWrapper.chunkedTicketList[0];
        }

        system.debug('tickList.size() @CompApp_CompensationPreCalculationJob: '+dataWrapper.tickList.size());
        system.debug('incList.size() @CompApp_CompensationPreCalculationJob: '+dataWrapper.incList.size());

        CompApp_TriggerUtils.upsertCompensations_SyncHelper(dataWrapper);

        if (dataWrapper.chunkedTicketList.size()>1){
            dataWrapper.chunkedTicketList.remove(0);
            System.enqueueJob(new CompApp_CompensationPreCalculationJob(dataWrapper));
        }
	}
}