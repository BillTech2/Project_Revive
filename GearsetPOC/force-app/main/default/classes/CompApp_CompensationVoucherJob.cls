public without sharing class CompApp_CompensationVoucherJob  implements Queueable{
   List<Compensation__c> compLst;

	public CompApp_CompensationVoucherJob(List<Compensation__c> compLst){
		this.compLst = compLst;
	}

	public void execute(QueueableContext context) {
	CompApp_Utils.log('CompVouch Process @@@ this.compLst: '+this.compLst);
		CompApp_TriggerUtils.CreateEvouchers(this.compLst);
	}
}