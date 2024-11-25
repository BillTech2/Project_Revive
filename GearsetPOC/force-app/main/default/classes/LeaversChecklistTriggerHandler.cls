public without sharing class LeaversChecklistTriggerHandler {
	
	public static final List<String> RECIPIENTS;
  
	static {
		String recipientsRaw = Leaver_Process_Settings__c.getOrgDefaults().Recipients_Emails__c;
		if (recipientsRaw != null && recipientsRaw.length() > 5) RECIPIENTS = recipientsRaw.split(',');
	}

  public static void sendNotificationEmails(List<Leavers_Checklist__c> checklists, Set<Id> leaversUserIds) {
		if (RECIPIENTS != null && RECIPIENTS.size() > 0) { 
			List<Messaging.SingleEmailMessage> emailsForSend = new List<Messaging.SingleEmailMessage>();
			Map<Id, User> leaversUserRecordsMap = new Map<Id,User>([SELECT Name FROM User WHERE Id IN :leaversUserIds]);

			for(Leavers_Checklist__c nextChecklist : checklists) {
					Messaging.SingleEmailMessage nextMessage = createNotificationEmail(nextChecklist, leaversUserRecordsMap.get(nextChecklist.Employee_Id__c));
				emailsForSend.add(nextMessage);
			}

			List<Messaging.SendEmailResult> mailingResults = new List<Messaging.SendEmailResult>();
			
			if (emailsForSend.size() > 0) {
					mailingResults = Messaging.sendEmail(emailsForSend);
			}
		}
  }
  
	public static Messaging.SingleEmailMessage createNotificationEmail(Leavers_Checklist__c checklist, User leaver) {
		Messaging.SingleEmailMessage resultMessage = new Messaging.SingleEmailMessage();
		resultMessage.setToAddresses(RECIPIENTS);
		resultMessage.setSubject('Leavers Checklist for ' + leaver.Name);

		String FirstLines = 'Leavers Checklist for ' + leaver.Name +  ' is ready for processing\r\n\r\nPlease click following link to view the checklist:\r\n';
    String link =  System.URL.getSalesforceBaseURL().toExternalForm() + '\\' + checklist.Id;
		
		resultMessage.setPlainTextBody(FirstLines + link);
		resultMessage.setSaveAsActivity(false);
		return resultMessage;
	}

}