public with sharing class LeaverChecklistCtrl {

  private static final List<String> fieldsForQuery = new List<String>{
      'Form_Complete__c',
      'Ensure_Payslips_Copies_Downloaded__c',
      'Ensure_Intranet_Sites_Manager_Altered__c',
      'Ensure_Financial_Approval_Rights_Reassig__c',
      'Ensure_DTP_RO_Reassigned__c',
      'Ensure_Leavers_Ticket_Raised_With_IS__c',
      'Ensure_HR_Payroll_Notified__c',
      'Ensure_Expense_Claims_Submission__c',
      'Ensure_Box_Folders_Ownership_Altered__c',
      'Return_Credit_Cards_Settle_Balance__c',
      'Mobile_Phone_Unlock_Sign_Out__c',
      'Ensure_MarkView_Queues_Cleared__c',
      'Return_IS_Equipment_Accessories__c',
      'TFL_Status_Pass__c',
      'TFL_Status_Pass_Spouse__c',
      'Return_Security_Passes_Staff_ID_Badge__c',
      'Status_Pass_Children__c',
      'Return_Clocking_Card_Locker_Keys__c',
      'Status_Pass_Spouse__c',
      'Return_Rules_Books_Publications__c',
      'Status_Pass__c',
      'Return_Uniform_Equipment__c',
      'Unused_Eurostar_Vouchers__c',
      'Contact_Payroll_Service__c',
      'BR_LUL_Residential_Pass__c',
      'Duty_Travel_Pass__c',
      'PTAC_Card__c',
      'Staff_Travel_Card_Children__c',
      'Staff_Travel_Card_Spouse__c',
      'Staff_Travel_Card__c',

      'Employee_Id__c',
      'Employee_Number__c',
      'Job_Title__c',
      'Last_Day_Of_Employment__c',

      'Employee_Id__r.Title',
      'Employee_Id__r.Name',
      'Employee_Id__r.FirstName',
      'Employee_Id__r.LastName',

      'CreatedById',
      'CreatedBy.Name',
      'CreatedDate',
      'LastModifiedById',
      'LastModifiedBy.Name',
      'LastModifiedDate',

      'Form_Completed_By__c',
      'Form_Completed_By__r.Name',
      'Form_Completion_Date__c'
  };

  @InvocableMethod(label='Check Leavers Checklist Submitted Status' description='Sends a notification email the day before the leaving date')
  public static void notifyChecklistExpiration(List<ID> checklistIds) {
    List<Messaging.SingleEmailMessage> emailsForSend = new List<Messaging.SingleEmailMessage>();
    List<Leavers_Checklist__c> checklists = [
                                              SELECT Id, CreatedById, CreatedBy.Name, CreatedBy.Email, Employee_Id__c, Employee_Id__r.Name, Form_Complete__c 
                                              FROM Leavers_Checklist__c 
                                              WHERE Id in : checklistIds
                                            ];
    
    for (Leavers_Checklist__c checklist : checklists) {
      if (!checklist.Form_Complete__c) {
        Messaging.SingleEmailMessage nextMessage = createNotificationEmail(checklist);
        emailsForSend.add(nextMessage);
      } 
    }

    List<Messaging.SendEmailResult> mailingResults = new List<Messaging.SendEmailResult>();
    if (emailsForSend.size() > 0) {
        mailingResults = Messaging.sendEmail(emailsForSend);
    }
  }

	public static Messaging.SingleEmailMessage createNotificationEmail(Leavers_Checklist__c checklist) {

		Messaging.SingleEmailMessage resultMessage = new Messaging.SingleEmailMessage();
		resultMessage.setToAddresses(new List<Id>{checklist.CreatedById});
		resultMessage.setSubject('Leavers Checklist for ' + checklist.Employee_Id__r.Name + ' expires soon');

		String FirstLines = 'Leavers Checklist for ' + checklist.Employee_Id__r.Name +  ' is about to expire within one day\r\n\r\nPlease click following link to view the checklist:\r\n';
    String link =  System.URL.getSalesforceBaseURL().toExternalForm() + '\\' + checklist.Id;
		
		resultMessage.setPlainTextBody(FirstLines + link);
		resultMessage.setSaveAsActivity(false);
		return resultMessage;
	}

  @AuraEnabled(Cacheable=true)
  public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
      searchTerm += '%';

      List<User> foundUsers = [SELECT FirstName, LastName, Title FROM User WHERE LastName LIKE :searchTerm];
      List<LookupSearchResult> results = new List<LookupSearchResult>();
      String userIcon = 'standard:user';

      for (User nextUser : foundUsers) {
          String subtitle = nextUser.Title == null ? '' : nextUser.Title;
          results.add(new LookupSearchResult(nextUser.Id, 'Employee', userIcon, nextUser.LastName + ' ' + nextUser.FirstName, subtitle));
      }

      results.sort();

      return results;
  }

  @AuraEnabled(cacheable=true)
  public static ChecklistRequestResultData getChecklistById(String recordId) {
    ChecklistRequestResultData result = new ChecklistRequestResultData();

    try {
        result.resultJSON = JSON.serialize(getChecklistDetailData(recordId));
    } catch(Exception ex) {
        result.parseError(ex);
    }

    return result;
  }

  private static ChecklistDetailData getChecklistDetailData(String recordId) {
    ChecklistDetailData data = new ChecklistDetailData();
    Leavers_Checklist__c checklist = queryChecklist(recordId, fieldsForQuery);
    if (checklist == null) throw new ChecklistException('Checklist not found');
    Boolean editAccess = queryChecklistAccess(recordId);
    Boolean isSuper = querySuperAccess();
    data.checklist = checklist;
    data.editAccess = editAccess;
    data.isSuper = isSuper;

    return data;
  }

  private static Leavers_Checklist__c queryChecklist(String recordId, List<String> fieldApiNames) {

    List<Leavers_Checklist__c> checklists = new List<Leavers_Checklist__c>();
    if (recordId != null && recordId.length() > 0) {
      checklists =
      (List<Leavers_Checklist__c>)Database.query(
          'SELECT ' + String.join(fieldApiNames, ', ') 
          + ' FROM Leavers_Checklist__c'
          + ' WHERE Id=:recordId'
          + ' LIMIT 1'
      );
    } else {
      return  new Leavers_Checklist__c();
    }

    if (checklists.isEmpty()) {
      return  null;
    }

    return checklists[0];
  }

  private static Boolean queryChecklistAccess(String recordId) {

    UserRecordAccess access;
    if (recordId != null && recordId.length() > 0) {
      access = [SELECT RecordId, HasEditAccess 
                FROM UserRecordAccess 
                WHERE UserId = :UserInfo.getUserId() AND 
                      RecordId = :recordId];
    } else {
      return true;
    }

    return access.HasEditAccess;
  }

  private static Boolean querySuperAccess() {
    String userProfileName = [SELECT Name from profile where id =: userinfo.getProfileId()].Name;

    return userProfileName == 'System Administrator';
  }

  public class ChecklistDetailData {
    @AuraEnabled public Leavers_Checklist__c checklist;
    @AuraEnabled public Boolean editAccess;
    @AuraEnabled public Boolean isSuper;
  }

  public with sharing class ChecklistRequestResultData {
    @AuraEnabled public String status  = 'SUCCESS';
    @AuraEnabled public String message = '';
    @AuraEnabled public String resultJSON;

    public void parseError(Exception ex) {
        this.status = 'ERROR';
        this.message = ex.getMessage();
    }
  } 

  public with sharing class ChecklistException extends Exception {}

}