public without sharing class SalesforceSupportRequestUtils {

    public static final Id CHANGE_REQUEST_QUEUE_ID;
    public static final Id BUG_QUEUE_ID;
    public static final String CHANGE_REQUEST_TYPE = 'Change Request';
    public static final String BUG_REQUEST_TYPE = 'Bug Request';
    public static final Id SALESFORCE_CHANGE_REQUEST_RECORD_TYPE_ID;
    public static final Id SALESFORCE_SUPPORT_REQUEST_RECORD_TYPE_ID;
    public static final Id SALESFORCE_BUG_REQUEST_RECORD_TYPE_ID;

    static {
        List<RecordType> recordTypes = [SELECT Id, DeveloperName
                FROM RecordType
                WHERE SobjectType = 'Salesforce_Support_Request__c' AND
                      (DeveloperName = 'Salesforce_Support' OR
                       DeveloperName = 'Salesforce_Change_Request')
        ];
        for (RecordType nextrecordType : recordTypes) {
            if (nextrecordType.DeveloperName.contains('Salesforce_Support')) SALESFORCE_SUPPORT_REQUEST_RECORD_TYPE_ID = nextrecordType.Id;
            if (nextrecordType.DeveloperName.contains('Salesforce_Change_Request')) SALESFORCE_CHANGE_REQUEST_RECORD_TYPE_ID = nextrecordType.Id;
            //if (nextrecordType.DeveloperName.contains('Salesforce_Bug_Request')) SALESFORCE_BUG_REQUEST_RECORD_TYPE_ID = nextrecordType.Id;
        }
        List<Group> queues = [SELECT Id, DeveloperName
                              FROM Group
                              WHERE (DeveloperName = 'Salesforce_Change_Request_Queue' OR
                              DeveloperName = 'Salesforce_Bug_Queue') AND
                              Type='Queue'];
        system.debug(queues);
        for (Group queue : queues) {
            if (queue.DeveloperName.contains('Salesforce_Change_Request_Queue')) CHANGE_REQUEST_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.contains('Salesforce_Bug_Queue')) BUG_QUEUE_ID = queue.Id;
        }
    }

    public static void handleBeforeInsert(List<Salesforce_Support_Request__c> newList) {
        for (Salesforce_Support_Request__c nextReq : newList) {
            if (nextReq.RecordTypeId == SALESFORCE_CHANGE_REQUEST_RECORD_TYPE_ID && !DLT_SFSupportRequestConstants.feedbackRecordTypeIds.contains(nextReq.RecordTypeId)) {
                nextReq.Type__c = CHANGE_REQUEST_TYPE;
                nextReq.OwnerId = CHANGE_REQUEST_QUEUE_ID;
            }
//            if (nextReq.RecordTypeId == SALESFORCE_BUG_REQUEST_RECORD_TYPE_ID) {
//                nextReq.Type__c = BUG_REQUEST_TYPE;
//                nextReq.OwnerId = BUG_QUEUE_ID;
//            }
        }
    }

    public static void handleBeforeUpdate(Map<Id, Salesforce_Support_Request__c> oldMap, Map<Id, Salesforce_Support_Request__c> newMap) {
        List<Messaging.SingleEmailMessage> closedEmailsForSend = new List<Messaging.SingleEmailMessage>();
        List<Salesforce_Support_Request__c> requestsRequiredJira = new List<Salesforce_Support_Request__c>();
        for (Id nextReqId : oldMap.keyset()) {
            Salesforce_Support_Request__c oldReq = oldMap.get(nextReqId);
            Salesforce_Support_Request__c newReq = newMap.get(nextReqId);

            if(DLT_SFSupportRequestConstants.feedbackRecordTypeIds.contains(newReq.RecordTypeId)) { continue; }

            if (oldReq.Type__c != newReq.Type__c)  {
                if (newReq.Type__c == CHANGE_REQUEST_TYPE) {
                    newReq.RecordTypeId = SALESFORCE_CHANGE_REQUEST_RECORD_TYPE_ID;
                }
                //if (newReq.Type__c == BUG_REQUEST_TYPE) {
                //    newReq.RecordTypeId = SALESFORCE_BUG_REQUEST_RECORD_TYPE_ID;
                //}
            }
            if (oldReq.RecordTypeId != newReq.RecordTypeId)  {
                if (newReq.RecordTypeId == SALESFORCE_CHANGE_REQUEST_RECORD_TYPE_ID) {
                    newReq.OwnerId = CHANGE_REQUEST_QUEUE_ID;
                }
                //if (newReq.RecordTypeId == SALESFORCE_BUG_REQUEST_RECORD_TYPE_ID) {
                //    newReq.OwnerId = BUG_QUEUE_ID;
                //}
            }
            if (oldReq.Status__c != newReq.Status__c && (newReq.Status__c == 'Closed' || newReq.Status__c == 'Rejected'))  {
                newReq.Cumulative_Request_Age__c = oldReq.Request_Age__c;
                newReq.Date_Time_Closed__c = Datetime.now();
                newReq.Closed_By__c = UserInfo.getUserId();
                if (newReq.Status__c == 'Closed') {
                    closedEmailsForSend.add(buildOnRequestCloseResponseEmail(newReq));
                }
            }
            if (oldReq.Status__c != newReq.Status__c && (oldReq.Status__c == 'Closed' || oldReq.Status__c == 'Rejected'))  {
                newReq.Date_Time_ReOpened__c = Datetime.now();
            }
            if (newReq.RecordTypeId == SALESFORCE_CHANGE_REQUEST_RECORD_TYPE_ID &&
               (newReq.Associated_Jira_Id__c == null ||
                newReq.Associated_Jira_Id__c == '' ||
                newReq.Associated_Jira_Id__c == JiraConnectorUtils.OPERATION_FAILED) &&
                oldReq.Status__c != newReq.Status__c && newReq.Status__c == 'Backlog') {
                requestsRequiredJira.add(newReq);
            }
        }
        CloseResponseEmailDisabled__c isDisabled = CloseResponseEmailDisabled__c.getInstance('Disabled');
        if (isDisabled != null) {
            if (closedEmailsForSend.size() > 0 && isDisabled.Disabled__c == false) Messaging.sendEmail(closedEmailsForSend);
        }

        //create jira only for single record updates
        if (newMap.keyset().size() == 1 && requestsRequiredJira.size() == 1) {
            createIssue(requestsRequiredJira[0].Id);
        }
    }

    @future(callout=true)
    public static void createIssue(Id requestId) {
        List<Salesforce_Support_Request__c> targetRequests = [
                SELECT Subject__c, Description__c, Associated_Jira_Id__c
                FROM Salesforce_Support_Request__c
                WHERE Id = : requestId
                LIMIT 1
        ];

        if (targetRequests.size() > 0 && (targetRequests[0].Associated_Jira_Id__c == JiraConnectorUtils.OPERATION_FAILED) ||
                                          targetRequests[0].Associated_Jira_Id__c == '' ||
                                          targetRequests[0].Associated_Jira_Id__c == null) {

            targetRequests[0].Associated_Jira_Id__c = JiraConnectorUtils.createIssue(targetRequests[0]);
            if (targetRequests[0].Associated_Jira_Id__c != JiraConnectorUtils.OPERATION_FAILED)
                update targetRequests[0];
        }
    }

    public static void sendAutoResponseEmail(Salesforce_Support_Request__c baseRequest) {
        Messaging.SingleEmailMessage resultMessage = new Messaging.SingleEmailMessage();
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = : baseRequest.Requester_Email__c];
        if (contacts.size() > 0) {
            Id templateId = [SELECT Id from EmailTemplate WHERE DeveloperName='Salesforce_Support_Auto_Response' LIMIT 1].Id;
            resultMessage.setTargetObjectId(contacts[0].Id);
            resultMessage.setTemplateId(templateId);
            resultMessage.setWhatId(baseRequest.Id);
        } else {
            resultMessage.setToAddresses(new List<String>{baseRequest.Requester_Email__c});
            resultMessage.setSubject('Thanks for your email.');
            String body = 'Hi ' + baseRequest.Requester_Name__c + ',\r\n\r\nThanks for your email, we have received your request. This is your request no ' + baseRequest.Name + '.\r\n\r\nIf you have any additional questions or information in regards to your issue, please reply to this email.\r\n\r\nWe will respond as soon as soon as possible.\r\n\r\n\r\n\r\nRegards,\r\n\r\nThe Salesforce team\r\n\r\n' + baseRequest.ThreadID__c;
            resultMessage.setPlainTextBody(body);
        }
        resultMessage.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{resultMessage});

    }

    public static Messaging.SingleEmailMessage buildOnRequestCloseResponseEmail(Salesforce_Support_Request__c baseRequest) {
        Messaging.SingleEmailMessage resultMessage = new Messaging.SingleEmailMessage();
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = : baseRequest.Requester_Email__c];
        if (contacts.size() > 0) {
            Id templateId = [SELECT Id from EmailTemplate WHERE DeveloperName='Salesforce_Support_On_Request_Close_Auto_Notification' LIMIT 1].Id;
            resultMessage.setTargetObjectId(contacts[0].Id);
            resultMessage.setTemplateId(templateId);
            resultMessage.setWhatId(baseRequest.Id);
        } else {
            resultMessage.setToAddresses(new List<String>{baseRequest.Requester_Email__c});
            resultMessage.setSubject('Thanks for your email.');
            String body = 'Hi ' + baseRequest.Requester_Name__c + ',\r\n\r\nThanks for your email, we have received your request. This is your request no ' + baseRequest.Name + '.\r\n\r\nIf you have any additional questions or information in regards to your issue, please reply to this email.\r\n\r\nWe will respond as soon as soon as possible.\r\n\r\n\r\n\r\nRegards,\r\n\r\nThe Salesforce team\r\n\r\n' + baseRequest.ThreadID__c;
            resultMessage.setPlainTextBody(body);
        }
        resultMessage.setSaveAsActivity(false);

        return resultMessage;
    }
}