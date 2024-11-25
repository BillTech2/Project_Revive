public without sharing class DLT_CaseReportTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                fillLookupFields(Trigger.new);
            }

            if (System.Trigger.isUpdate) {

            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {

            }

            if (System.Trigger.isUpdate) {

            }
        }
    }

    private static void fillLookupFields(List<Case_Report__c> newRecords){

        List<Id> caseIds = new List<Id>();

        for(Case_Report__c cr : newRecords){
            caseIds.add(cr.Case__c);
        }

        Map<Id,Case> relatedCases = new Map<Id,Case>([
            SELECT Id, OwnerId, Owner.Name, Owner.Type, LastModifiedById 
            FROM Case 
            WHERE Id 
            IN :caseIds
        ]);

        for(Case_Report__c caseReport : newRecords){

            if(!relatedCases.containsKey(caseReport.Case__c)) continue;

            Case currentCase = relatedCases.get(caseReport.Case__c);

            caseReport.Last_Modified_By__c = currentCase.LastModifiedById;

            if(currentCase.Owner.Type == 'Queue'){
                caseReport.Case_Owner_Queue_Name__c = currentCase.Owner.Name;
            }
            else{
                caseReport.Case_Owner_User__c = currentCase.OwnerId;
            }
        }
    }
}