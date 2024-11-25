public with sharing class UserDeactivationHandler {

    private static Map<Id, User> inactiveUsersByIdMap;

    public static void reassignCasesToTheOriginalQueue(List<Case> cases) {
        for(Case caseRecord: cases) {
            if(caseRecord.Language == 'French') {
                caseRecord.OwnerId = OutOfOfficeTriggerUtils.CUSTOMER_CARE_FRENCH_QUEUE_ID;
            } else if(caseRecord.Language == 'Dutch') {
                caseRecord.OwnerId = OutOfOfficeTriggerUtils.CUSTOMER_CARE_DUTCH_QUEUE_ID;
            } else {
                caseRecord.OwnerId = OutOfOfficeTriggerUtils.CUSTOMER_CARE_QUEUE_ID;
            }
        }
    }

    public static void reassignReopenedCasesToTheOriginalQueue(List<Case> cases, Map<Id, Case> oldCasesMap) {
        Set<Id> userIds = new Set<Id>();

        for (Case caseRecord : cases) {
            if(caseRecord.OwnerId != null && caseRecord.OwnerID.getSObjectType().getDescribe().getName() == 'User') {
                userIds.add(caseRecord.OwnerId);
            }
        }

        if (userIds.isEmpty()) { return; }

        if (inactiveUsersByIdMap == null) {
            inactiveUsersByIdMap = new Map<Id, User> ([SELECT Id FROM User WHERE Id IN :userIds AND IsActive = false]);
        }

        List<Case> casesForUpdate = new List<Case>();

        for (Case caseRecord : cases) {
            if (caseRecord.Status == 'Reopened'
                && oldCasesMap.get(caseRecord.Id).Status == 'Closed'
                && caseRecord.OwnerId != null
                && inactiveUsersByIdMap.get(caseRecord.OwnerId) != null
            ) {
                casesForUpdate.add(caseRecord);
            }
        }

        if(!casesForUpdate.isEmpty()) {
            reassignCasesToTheOriginalQueue(casesForUpdate);
        }
    }
}