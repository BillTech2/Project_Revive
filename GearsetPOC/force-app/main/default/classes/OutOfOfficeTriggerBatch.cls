public class OutOfOfficeTriggerBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Set<Id> usersToReturnCases = new Set<Id>();
    // public List<Group> queues = new List<Group>();
    // public Id CUSTOMER_CARE_QUEUE_ID;
    // public Id CUSTOMER_CARE_FRENCH_QUEUE_ID;
    // public Id CUSTOMER_CARE_DUTCH_QUEUE_ID;

    public OutOfOfficeTriggerBatch(Set<Id> usersToReturnCases) {
        this.usersToReturnCases = usersToReturnCases;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Adding the user id of the user that triggered the OOO functionality to help identify if FraudCaseHandler was called from OOO operation
        Current_OOO_session_users__c OOO_session = new Current_OOO_session_users__c();
        OOO_session.Name = UserInfo.getUserId();
        OOO_session.User_id__c = UserInfo.getUserId();
        insert OOO_session;
        return Database.getQueryLocator([SELECT Id, OwnerID, Preferred_Language__c,
                                            (SELECT NewValue, OldValue, CreatedDate
                                            FROM Histories
                                            WHERE Field = 'Owner'
                                            ORDER BY CreatedDate DESC)
                                        FROM CASE
                                        WHERE Status != 'Closed'
                                        AND OwnerID IN : usersToReturnCases]);
    }
    public void execute(Database.BatchableContext BC, List<Case> casesWithOwnerHistory) {
        // if (queues.isEmpty()) {
        //     queues = [SELECT Id, DeveloperName
        //               FROM Group
        //               WHERE (DeveloperName = 'ECC_Customer_Care' OR
        //                      DeveloperName = 'Customer_Care_French' OR
        //                      DeveloperName = 'Customer_Care_Dutch') AND
        //                      Type='Queue'];
        //     for (Group queue : queues) {
        //         if (queue.DeveloperName.equals('ECC_Customer_Care')) CUSTOMER_CARE_QUEUE_ID = queue.Id;
        //         if (queue.DeveloperName.equals('Customer_Care_French')) CUSTOMER_CARE_FRENCH_QUEUE_ID = queue.Id;
        //         if (queue.DeveloperName.equals('Customer_Care_Dutch')) CUSTOMER_CARE_DUTCH_QUEUE_ID = queue.Id;
        //     }
        // }
        Boolean needUpdate = false;
        Map<Id, Case> casesForUpdateMap = new Map<Id, Case>();
        if (casesForUpdateMap.isEmpty()) {
            casesForUpdateMap = new Map<Id, Case>(casesWithOwnerHistory);
            needUpdate = true;
        }
        for (Case nextCase : casesWithOwnerHistory) {
            Boolean isOwnerUpdated = false;
            for (CaseHistory historyRecord : nextCase.Histories) {
                if (!isOwnerUpdated &&  ((String)(historyRecord.OldValue)).startsWith('00G')) {
                    casesForUpdateMap.get(nextCase.Id).OwnerID = (Id)historyRecord.OldValue;
                    isOwnerUpdated = true;
                    break;
                }
            }
            if (!isOwnerUpdated) {
                if (nextCase.Preferred_Language__c == 'French') {
                    casesForUpdateMap.get(nextCase.Id).OwnerID = OutOfOfficeTriggerUtils.CUSTOMER_CARE_FRENCH_QUEUE_ID;
                } else if (nextCase.Preferred_Language__c == 'Dutch') {
                    casesForUpdateMap.get(nextCase.Id).OwnerID = OutOfOfficeTriggerUtils.CUSTOMER_CARE_DUTCH_QUEUE_ID;
                } else {
                    casesForUpdateMap.get(nextCase.Id).OwnerID = OutOfOfficeTriggerUtils.CUSTOMER_CARE_QUEUE_ID;
                }
            }
        }

        if (casesWithOwnerHistory.size() > 0 && needUpdate)           
            update casesWithOwnerHistory;
            System.debug('------------------CPU Time after Cases update inside returnCasesToQueue (exiting) in OutOfOfficeTriggerUtils: ' + Limits.getCpuTime());
    }

    public void finish(Database.BatchableContext BC) {
        OutOfOfficeCtrl outOfOffice = new OutOfOfficeCtrl();
        outOfOffice.refreshData();
        //Removing the user id of the user that triggered the OOO functionality after completion of OOO status change operation
        String Current_User_Id = UserInfo.getUserId(); 
        List<Current_OOO_session_users__c> OOO_session_del = [Select Id,Name,User_id__c from Current_OOO_session_users__c where User_id__c = :Current_User_Id];
        delete OOO_session_del;
    }
}