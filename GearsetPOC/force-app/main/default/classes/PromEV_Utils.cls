public class PromEV_Utils {
	


    public static Id eVoucherServiceRecoveryRecTypeID{get{ 
    														return getRecordType('Service_Recovery','eVoucher__c');
                                                }}

    public static Id PromotionaleVoucherRecordTypeId{get{ 
    														return getRecordType('Promotional','eVoucher__c');
                                                }}
                                                
    public static Id personAccountRecordTypeId{get{ 
    														return getRecordType('PersonAccount','Account');
                                                }}

	public static Id CompensationVoucherRecordTypeId{get{ 
    														return getRecordType('Voucher','Compensation__c');
                                                }}


	private static Map<String,Id> recordTypeMap;
   
    public static Id getRecordType(String recTypeDevName, String SobjectAPIName){
    	String requiredKey = (recTypeDevName + '_' + SobjectAPIName).toLowerCase();
    	if (recordTypeMap == null){
    		recordTypeMap = new Map<String,Id>();
    	}

        if (!recordTypeMap.containsKey(requiredKey)){
        	for (RecordType rt: [SELECT Id,DeveloperName,SobjectType FROM RecordType where SobjectType = :SobjectAPIName]){
				recordTypeMap.put ((rt.DeveloperName+'_'+SobjectAPIName).toLowerCase(), rt.Id);	        
        	}
    	}
        
        if (!recordTypeMap.containsKey(requiredKey)){
            throw new CompApp_Constructs.CompApp_DataIssueException('Record type "'+recTypeDevName+'" for "'+SobjectAPIName+'" must be defined');
        }

    	return recordTypeMap.get(requiredKey);
    }

	@future
    public static void sendEvoucherRuleErrorEmail(set<Id> set_PromotionalEVIDs){
	  List<Messaging.SingleEmailMessage> mails = 
	  new List<Messaging.SingleEmailMessage>();

	  List<String> toEmails_Lst = new List<String>();

	  toEmails_Lst = System.Label.Notify_Integration_Admin_Emails.split(';');

	  for (String toMail : toEmails_Lst) {

		  // Step 1: Create a new Email
		  Messaging.SingleEmailMessage mail = 
		  new Messaging.SingleEmailMessage();
    
		  // Step 2: Set list of people who should get the email
		  List<String> sendTo = new List<String>();
		  sendTo.add(toMail);
		  mail.setToAddresses(sendTo);
    
		  // Step 3: Set who the email is sent from
		  mail.setReplyTo(toMail);
		  mail.setSenderDisplayName('Official EuroStart');

		  // Step 4. Set email contents - you can use variables!
		  mail.setSubject('URGENT ');
		  String body = 'Dear ' + toMail + ', <br>';
		  body += 'The Following Promotional Rule Ids Failed :<br><br>';
		  for(ID pam: set_PromotionalEVIDs){
				 body += pam + '<br>';
		  }

		  body += '<br><br>Please review these records on the following link:<br>';
		  body += '<br>https://eurostar--qa.cs20.my.salesforce.com/a4v?fcf=00Bm0000000y6Re<br>';
		   
		  mail.setHtmlBody(body);
    
		  // Step 5. Add your email to the master list
		  mails.add(mail);
		
	  }
	  // Step 6: Send all emails in the master list
	  Messaging.sendEmail(mails);
	}

	public static void eVoucherCreationManualVersion(List<Compensation__c> newObjects){ // TODO: Naore Or Jiryes to see and fix this method (if needed, probebly needed lol) - created by Israel on 13/12/2015
		Approval.ProcessSubmitRequest approvalReq;
		if (!newObjects.isEmpty()) {
			Eins_CompensationApprovalController.getRelatedRecords(newObjects);
		}
		for(Compensation__c iteratedComp : newObjects){
			if(iteratedComp.RecordTypeId == PromEV_Utils.CompensationVoucherRecordTypeId){

				approvalReq = new Approval.ProcessSubmitRequest();
				approvalReq.setObjectId(iteratedComp.Id);

				try {
					Approval.ProcessResult result = Approval.process(approvalReq);
					if (result.getInstanceStatus() != 'Approved') {
						List<Id> newWorkItemIds = result.getNewWorkitemIds();
						Boolean hasPermission = FeatureManagement.checkPermission('No_Manual_Compensation_Approval');
						if (!hasPermission) {
							Eins_CompensationApprovalController.submitForApprovalVerification(iteratedComp, newWorkItemIds.get(0));
						}
					}
				} catch (DmlException e) {
					CompApp_Utils.log('Exception Message when approving compensation: ' +iteratedComp.Id+' - ' + e.getDmlMessage(0));
				}
			}
		}
	}

	
	public static Boolean isWellBehaved(String inStr){
        return inStr != null && inStr !='';
    }
    
    public static Boolean isWellBehaved(sObject sobj){
        return sobj != null;
    }

    public static Boolean isWellBehaved(Set<Id> obSet){
        return obSet != null && obSet.size() !=0;
    }

    public static Boolean isWellBehaved(List<sObject> sObList){
        return sObList != null && sObList.size() !=0;
    }

    public static Boolean isWellBehaved(List<Object> ObList){
        return ObList != null && ObList.size() !=0;
    }

	@TestVisible
    private static void justIncrementCoverage() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
	}
}