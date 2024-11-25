public without sharing class OutOfOfficeTriggerUtils {

    public static final Id CUSTOMER_CARE_QUEUE_ID;
    public static final Id CUSTOMER_CARE_FRENCH_QUEUE_ID;
    public static final Id CUSTOMER_CARE_DUTCH_QUEUE_ID;
    public static final String CUSTOMER_CARE_QUEUE_NAME        = 'ECC_Customer_Care';
    public static final String CUSTOMER_CARE_FRENCH_QUEUE_NAME = 'Customer_Care_French';
    public static final String CUSTOMER_CARE_DUTCH_QUEUE_NAME  = 'Customer_Care_Dutch';

    static {
        List<Group> queues = [SELECT Id, DeveloperName
                              FROM Group
                              WHERE (DeveloperName = :CUSTOMER_CARE_QUEUE_NAME OR
                                     DeveloperName = :CUSTOMER_CARE_FRENCH_QUEUE_NAME OR
                                     DeveloperName = :CUSTOMER_CARE_DUTCH_QUEUE_NAME) AND
                                     Type='Queue'];

        for (Group queue : queues) {
            if (queue.DeveloperName.equals(CUSTOMER_CARE_QUEUE_NAME)) CUSTOMER_CARE_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.equals(CUSTOMER_CARE_FRENCH_QUEUE_NAME)) CUSTOMER_CARE_FRENCH_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.equals(CUSTOMER_CARE_DUTCH_QUEUE_NAME)) CUSTOMER_CARE_DUTCH_QUEUE_ID = queue.Id;
        }
    }

    public static List<Case> getReopenedCasesWithOwnerHistory(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        List<ID> reopenedCaseIds = new List<ID>();
        List<ID> userIds = new List<ID>();

        for (Case nextCase : newCases) {
            system.debug('old ' + oldCasesMap.get(nextCase.Id).Status);
            system.debug('new ' + nextCase.Status);
            if (nextCase.Status == 'Reopened' && oldCasesMap.get(nextCase.Id).Status == 'Closed' &&
                nextCase.OwnerID.getSObjectType().getDescribe().getName() == 'User') {

                reopenedCaseIds.add(nextCase.Id);
                userIds.add(nextCase.OwnerID);
            }
        }

        List<Case> cases = new List<Case>();

        if (reopenedCaseIds.size() > 0) {
            List<User> absentUsers = [SELECT Id
                                      FROM USER
                                      WHERE Id IN :userIds AND (Out_Of_Office__c = TRUE OR IsActive = FALSE)];

            Set<Id> absentUserIds = new Map<Id, User>(absentUsers).keySet();

            List<ID> casesForReassign = new List<ID>();
            for (Id nextReopenedCaseId : reopenedCaseIds) {
                if (absentUserIds.contains(oldCasesMap.get(nextReopenedCaseId).OwnerId)) {
                    casesForReassign.add(nextReopenedCaseId);
                }
            }

            if (casesForReassign.size() > 0) {
                cases = [SELECT Id, OwnerID, Preferred_Language__c,
                                (SELECT NewValue, OldValue, CreatedDate
                                 FROM Histories
                                 WHERE Field = 'Owner'
                                 ORDER BY CreatedDate DESC)
                        FROM CASE
                        WHERE Id IN :casesForReassign];
            }
        }
        return cases;
    }

    public static List<Case> getCasesWithOwnerHistoryByUsers(Set<Id> userIds) {
        List<Case> cases = [SELECT Id, OwnerID, Preferred_Language__c,
                                   (SELECT NewValue, OldValue, CreatedDate
                                    FROM Histories
                                    WHERE Field = 'Owner'
                                    ORDER BY CreatedDate DESC)
                            FROM CASE
                            WHERE Status != 'Closed'
                            AND OwnerID IN : userIds];
        return cases;
    }

    public static void returnCasesToQueue(Map<Id, Case> casesForUpdateMap, List<Case> casesWithOwnerHistory) {
        Boolean needUpdate = false;

        if (casesForUpdateMap == null) {
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
                    casesForUpdateMap.get(nextCase.Id).OwnerID = CUSTOMER_CARE_FRENCH_QUEUE_ID;
                } else if (nextCase.Preferred_Language__c == 'Dutch') {
                    casesForUpdateMap.get(nextCase.Id).OwnerID = CUSTOMER_CARE_DUTCH_QUEUE_ID;
                } else {
                    casesForUpdateMap.get(nextCase.Id).OwnerID = CUSTOMER_CARE_QUEUE_ID;
                }
            }
        }

        if (casesWithOwnerHistory.size() > 0 && needUpdate)           
            update casesWithOwnerHistory;
            System.debug('------------------CPU Time after Cases update inside returnCasesToQueue (exiting) in OutOfOfficeTriggerUtils: ' + Limits.getCpuTime());

    }

}