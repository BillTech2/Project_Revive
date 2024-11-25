public without sharing class CompApp_CompensationCalculationJob implements Queueable{
   Set<Id> compIdSet;

	public CompApp_CompensationCalculationJob(Set<Id> compIdSet){
		this.compIdSet = compIdSet;
	}

	public void execute(QueueableContext context) {
		CompApp_TriggerUtils.compensationCalcHelper_Sync(this.compIdSet);
	}
}