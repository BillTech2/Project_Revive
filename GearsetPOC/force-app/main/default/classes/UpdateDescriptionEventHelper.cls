public without sharing class UpdateDescriptionEventHelper {

    public static void updateCaseDescription(List<Update_Description_Platform_Event__e> updateEvents) {
        Set<String> caseIds = new Set<String>();
        Map<String, String> caseDescriptionByIds = new Map<String, String>();
        for (Update_Description_Platform_Event__e updateEvent :updateEvents) {
            caseIds.add(updateEvent.Case_Id__c);
            caseDescriptionByIds.put(updateEvent.Case_Id__c, updateEvent.Comment_Long__c);
        }
        List<Case> cases = [
            SELECT Id, Description
            FROM Case
            WHERE Id IN :caseIds
        ];
        String timeStamp = getCurrentDateTime();
        List<CaseComment> caseCommentsToInsert = new List<CaseComment>();
        for (Case caseItem : cases) {
            caseCommentsToInsert.add(
                new CaseComment(
                    CommentBody = timeStamp + caseDescriptionByIds.get(caseItem.Id),
                    ParentId = caseItem.Id,
                    IsPublished = true
                )
            );
        }
        if (!caseCommentsToInsert.isEmpty()) {
            insert caseCommentsToInsert;
        }
    }

    private static String getCurrentDateTime() {
        Datetime currDateTime = Datetime.now();
        String timeStamp = '[' + currDateTime.format('MM/dd/yyyy HH:mm:ss', 'Europe/London') + '] ';
        return timeStamp;
    }
}