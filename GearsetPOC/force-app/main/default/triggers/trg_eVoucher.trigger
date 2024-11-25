trigger trg_eVoucher on eVoucher__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 

	if (DLT_Automation_Settings__c.getOrgDefaults().Disable_EVoucher_Automation__c || DLT_EVoucherTriggerHandler.isDisabled) { return; }

	if(Trigger.isBefore && Trigger.isInsert){
		EVoucherTriggerHandler handler = new EVoucherTriggerHandler();
		handler.linkVouchertoCustomer(Trigger.new);
	}

	//Removed Notify Admin when eVoucher inserted and linked to already "Approved" Role
	//According to Fablece request on 12/1
	//if(Trigger.isAfter){
		//EVoucherTriggerHandler handler = new EVoucherTriggerHandler();
		//handler.FindFailuresAndSendMails(Trigger.new);
	//}

	DLT_EVoucherTriggerHandler.run();
}