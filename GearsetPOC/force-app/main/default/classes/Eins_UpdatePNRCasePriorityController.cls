public without sharing class Eins_UpdatePNRCasePriorityController {

    public static void updateCasePriority(List<Case> newCases, Map<Id,Case> oldCases) {
        List<Case> casesWithUpdatedPNR = new List<Case>();
        for (Case caseItem: newCases) {
            Case oldCaseItem = oldCases.get(caseItem.Id);
            if (caseItem.PNR__c != oldCaseItem.PNR__c) {
                casesWithUpdatedPNR.add(caseItem);
            }
        }
        Eins_CasePriorityHelper.prioritiseAllCases(casesWithUpdatedPNR);
    }
}