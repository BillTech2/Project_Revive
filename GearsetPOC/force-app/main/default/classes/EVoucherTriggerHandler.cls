public with sharing class EVoucherTriggerHandler {

	public class SFDC_EVOUCHER_COMMIT_FAILURE_EXCEPTION extends Exception{}

    public Integer VOUCHER_CODE_LENGTH = 17;
	public String AUTHORIZED_CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	public Integer NB_AUTHORIZED_CHARACTERS = AUTHORIZED_CHARACTERS.length();

	public Id personAccountRecordTypeId;
	public Id staffPersonAccountRecordTypeId;
	public Id PromotionaleVoucherRecordTypeId;
	public Id PartnereVoucherRecordTypeId;

	public EVoucherTriggerHandler(){
		Set<String> SobjectTypeSet = new Set<String> {'Account', 'eVoucher__c'};
		Set<String> recTypeSet = new Set<String> {'Promotional', 'PersonAccount', 'Partner', 'Staff_Person_Account'};

    	for (RecordType rt: [SELECT Id,DeveloperName,SobjectType FROM RecordType where SobjectType In :SobjectTypeSet AND DeveloperName In :recTypeSet]){
			personAccountRecordTypeId = (rt.SobjectType == 'Account' && rt.DeveloperName == 'PersonAccount')? rt.id : personAccountRecordTypeId;
			staffPersonAccountRecordTypeId = (rt.SobjectType == 'Account' && rt.DeveloperName == 'Staff_Person_Account')? rt.id : staffPersonAccountRecordTypeId;
			PromotionaleVoucherRecordTypeId = (rt.SobjectType == 'eVoucher__c' && rt.DeveloperName == 'Promotional')? rt.id : PromotionaleVoucherRecordTypeId;
			PartnereVoucherRecordTypeId = (rt.SobjectType == 'eVoucher__c' && rt.DeveloperName == 'Partner')? rt.id : PartnereVoucherRecordTypeId;
    	}
    	if (personAccountRecordTypeId == null || staffPersonAccountRecordTypeId == null || PromotionaleVoucherRecordTypeId == null || PartnereVoucherRecordTypeId == null){
    		throw new SFDC_EVOUCHER_COMMIT_FAILURE_EXCEPTION ('Unable to detect required recordtypes. Account.PersonAccount And eVoucher__c.Promotional');
    	}
	}


	public void linkVouchertoCustomer(List<eVoucher__c> eVoucher_Lst){
	System.debug('xxxx Start method linkVouchertoCustomer eVoucher_Lst ==>' +eVoucher_Lst);
		if (!PromEV_Utils.isWellBehaved(eVoucher_Lst)){
			return;
		}

		Boolean isPartner = true;
		Integer i = 0;

		while (i < eVoucher_Lst.size() && isPartner){
			if(eVoucher_Lst.get(i).RecordTypeId != PartnereVoucherRecordTypeId){
				isPartner = false;
			}
			i = i+1;
		}

		Map<String, List<eVoucher__c>> map_EmailtoeVoucher = (Map<String, List<eVoucher__c>>) CompApp_Utils.getFieldValueMap2list(eVoucher_Lst,'Email__c');
		Map<Id, List<eVoucher__c>> evoucherRuleMap = (Map<Id, List<eVoucher__c>>) CompApp_Utils.getFieldIdMap2list(eVoucher_Lst,'Promotional_eVoucher_rule__c');

		//------------------ IF PARTNER VOUCHERS ---------------------//
		if (isPartner){
			Set<Id> validEvoucherRuleIdSet = (new Map<Id,Sobject>
												([	select
														Id
													From
														Promotional_eVoucher_rule__c
													Where
															ID IN: evoucherRuleMap.keySet()
												])).KeySet();

			Set<Id> RejectedEvoucherRuleIdSet = (new Map<Id,Sobject>
												([	select
														Id
													From
														Promotional_eVoucher_rule__c
													Where
															ID IN: evoucherRuleMap.keySet()
														AND
															Status__c =: 'Rejected'
												])).KeySet();

			for (eVoucher__c iteratedEvoucher : eVoucher_Lst){
	            generateVoucherCode(iteratedEvoucher);

				System.debug('xxxx iteratedEvoucher ==>' +iteratedEvoucher);
				if (RejectedEvoucherRuleIdSet.contains(iteratedEvoucher.Promotional_eVoucher_rule__c))
				{
					iteratedEvoucher.addError('Can not insert eVoucher related to non Approved Rules');
				}

	        	iteratedEvoucher.Integration_Status__c = 'Pending Integration';
	    	}

	    //------------------ IF NOT PARTNER VOUCHERS ---------------------//
		} else {
				if (map_EmailtoeVoucher.containsKey(NULL) || map_EmailtoeVoucher.containsKey('')){
				//throw new SFDC_EVOUCHER_COMMIT_FAILURE_EXCEPTION('Empty Email is not allowed , Please correct the inserted data');
				return;
			}

			Map<String,Id> mailToAccountIdMap = getEmailToAccountIdMap(map_EmailtoeVoucher);

			Set<Id> validEvoucherRuleIdSet = (new Map<Id,Sobject>
												([	select
														Id
													From
														Promotional_eVoucher_rule__c
													Where
															ID IN: evoucherRuleMap.keySet()
												])).KeySet();

			Set<Id> RejectedEvoucherRuleIdSet = (new Map<Id,Sobject>
												([	select
														Id
													From
														Promotional_eVoucher_rule__c
													Where
															ID IN: evoucherRuleMap.keySet()
														AND
															Status__c =: 'Rejected'
												])).KeySet();

			for (eVoucher__c iteratedEvoucher : eVoucher_Lst){
				if (iteratedEvoucher.RecordTypeId == PromotionaleVoucherRecordTypeId)
				{
	                generateVoucherCode(iteratedEvoucher);
					iteratedEvoucher.Customer__c =
							iteratedEvoucher.Customer__c == null?
							mailToAccountIdMap.get(iteratedEvoucher.Email__c):
							iteratedEvoucher.Customer__c;

					System.debug('xxxx iteratedEvoucher ==>' +iteratedEvoucher);
					if (RejectedEvoucherRuleIdSet.contains(iteratedEvoucher.Promotional_eVoucher_rule__c))
					{
						iteratedEvoucher.addError('Can not insert eVoucher related to non Approved Rules');
					}
				}

	            iteratedEvoucher.Integration_Status__c = 'Pending Integration';
			}
		}
		System.debug('>>>eVoucher_Lst: ' + eVoucher_Lst);

	}

	private Map<String,Id> getEmailToAccountIdMap(Map<String, List<eVoucher__c>> map_EmailtoeVoucher){
		Map<String,Id> retMap = getEmailToExistingAccountMap(map_EmailtoeVoucher.keySet());
		if (!retMap.keySet().containsAll(map_EmailtoeVoucher.keySet())){
			Set<String> orphanedEmails = map_EmailtoeVoucher.keySet().clone();
			orphanedEmails.removeAll(retMap.keySet());
			retMap.putAll(getEmailToNewAccountsMap(orphanedEmails, map_EmailtoeVoucher));
		}
		return retMap;
	}


    private void generateVoucherCode(eVoucher__c ev){
	String res = '';
	Integer hyphenCounter = 0;

	while (res.length() < VOUCHER_CODE_LENGTH){
		if ((res.length() > 0) && (Math.mod(res.length() - hyphenCounter, 5) == 0)){
			res = res + '-';
			hyphenCounter = hyphenCounter + 1;
		}
		Integer i = Math.mod(Math.abs(Crypto.getRandomInteger()), NB_AUTHORIZED_CHARACTERS);
		res = res + AUTHORIZED_CHARACTERS.substring(i,i+1);
	}
		ev.Voucher_Code__c = res;
	}


	private Map<String,Id> getEmailToNewAccountsMap(Set<String> orphanedEmails, Map<String, List<eVoucher__c>> map_EmailtoeVoucher){
		Map<String,Id> retMap = new Map<String,Id>();
		List<Account> PersonAccountsToInsert_Lst = new List<Account>();

		eVoucher__c tmpVouch;
		for (String newEmail: orphanedEmails){
			tmpVouch = map_EmailtoeVoucher.get(newEmail)[0];

			PersonAccountsToInsert_Lst.add(
					 new Account(
						//FirstName = (tmpVouch.Email__c).split('@')[0],
						LastName  = (tmpVouch.Email__c).split('@')[0],
						RecordTypeId = personAccountRecordTypeId,
						Customer_Email__pc = tmpVouch.Email__c,
						Customer_Email__c =  tmpVouch.Email__c
					)
				);
		}
		insert PersonAccountsToInsert_Lst;

		Set<Id> accIds_Set = new Set<Id>();
		for (Account acc : PersonAccountsToInsert_Lst){
			accIds_Set.add(acc.Id);
		}

		for (Account acc : [	select
									Id,Customer_Email__pc,Secondary_Email__pc ,PersonContactId ,Customer_Email__c
							  	From
								  	Account
							  	Where Id IN: accIds_Set]){
			retMap.put(acc.Customer_Email__pc, acc.PersonContactId);
		}

		return retMap;
	}



	private Map<String,Id> getEmailToExistingAccountMap(Set<String> emailSet){
		Map<String,Id> retMap = new Map<String,Id>();

		for (Account acc : [	select
									Id,Customer_Email__pc,Secondary_Email__pc ,PersonContactId
							  	From
								  	Account
							  	Where
							  			(RecordTypeId =: personAccountRecordTypeId OR RecordTypeId =: staffPersonAccountRecordTypeId)
							  		AND
							  			Customer_Email__c IN:emailSet
							]){
			if (emailSet.contains(acc.Customer_Email__pc)){
				retMap.put(acc.Customer_Email__pc, acc.PersonContactId);
			}else{
				retMap.put(acc.Secondary_Email__pc, acc.PersonContactId);
			}
		}

		return retMap;
	}

	/*Method should be deleted when tests are done , Replaced with validation rule on eVoucher object
	public void FindFailuresAndSendMails(List<eVoucher__c> eVoucher_Lst){

		List<Promotional_eVoucher_rule__c> preApprovedeVoucherRuleList =	[ 	select
														Id
													From
														Promotional_eVoucher_rule__c
													Where
															ID IN: CompApp_Utils.getFieldIdMap2list(eVoucher_Lst,'Promotional_eVoucher_rule__c').keySet()
														AND
															Status__c =: 'Approved'
														AND
															(
																Last_Failure_Notification_Sent__c = NULL
															OR
																Last_Failure_Notification_Sent__c < :DateTime.now().addMinutes(-20)
															)
													];

		if (PromEV_Utils.isWellBehaved(preApprovedeVoucherRuleList))
		{
			for (Promotional_eVoucher_rule__c ERule:preApprovedeVoucherRuleList){
			ERule.Last_Failure_Notification_Sent__c = DateTime.now();
			}

			update preApprovedeVoucherRuleList;

			PromEV_Utils.sendEvoucherRuleErrorEmail((new Map<Id,Sobject>(preApprovedeVoucherRuleList)).keySet());
		}
	}
	*/
}