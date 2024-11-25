public without sharing class Eins_CallSummaryTriggerHandler {
    public static Set<String> pnrs = new Set<String>();
    public static Map<String, Case> casesByPNR = new Map<String, Case>();
    public static Map<String, Case> casesByCallSummary = new Map<String, Case>();
    public static Map<String, Case> casesById = new Map<String, Case>();
    public static Map<String, Task> tasksByCallObject = new Map<String, Task>();
    public static Map<String, Case> casesByCallObject = new Map<String, Case>();
    public static List<NVMStatsSF__NVM_Call_Summary__c> callSummariesToUpdate = new List<NVMStatsSF__NVM_Call_Summary__c>();
    public static String searchGuidString = '{';

    public static Map<String, Case> updateRelatedCase(List<NVMStatsSF__NVM_Call_Summary__c> callSummaries) {
        Map<String, Case> casesByCallSummaryToUpdate = updateRelatedCase(callSummaries, false);
        if (!callSummariesToUpdate.isEmpty()) {
            try {
                update callSummariesToUpdate;
            } catch (Exception exept) {
                System.debug(exept);
            }
        }
        return casesByCallSummaryToUpdate;
    }

    public static Map<String, Case> updateRelatedCase(List<NVMStatsSF__NVM_Call_Summary__c> callSummaries, Boolean isTrigger) {
        Map<String, Case> casesByCallSummaryToUpdate = new Map<String, Case>();
        Set<String> callSummariesGuids = new Set<String>();
        Set<Id> callSummariesIds = new Set<Id>();
        Set<Id> callSummariesWithCategories = new Set<Id>();
        for (Integer i = 0; i < callSummaries.size(); i++) {
            callSummariesIds.add(callSummaries[i].Id);
            if (String.isNotBlank(callSummaries[i].NVMStatsSF__CallGuid__c)) {
                callSummariesGuids.add(callSummaries[i].NVMStatsSF__CallGuid__c);
                if (i != callSummaries.size() - 1) {
                    searchGuidString += ' "' + callSummaries[i].NVMStatsSF__CallGuid__c + '" OR';
                } else {
                    searchGuidString += ' "' + callSummaries[i].NVMStatsSF__CallGuid__c + '"}';
                }
            }
            if (String.isNotBlank(callSummaries[i].NVMStatsSF__Categories__c)) {
                callSummariesWithCategories.add(callSummaries[i].Id);
            }
        }
        searchGuidString = searchGuidString.replace('-', '\\-');

        if (!callSummariesWithCategories.isEmpty()) {
            getRelatedTasks(callSummariesGuids);
            getRelatedCases(callSummariesIds, callSummariesGuids);
    
            List<Task> tasksToUpdate = new List<Task>();
            List<Case> casesToUpdate = new List<Case>();
            for (NVMStatsSF__NVM_Call_Summary__c callSummary : callSummaries) {
                Task taskFromCall = tasksByCallObject.get(callSummary.NVMStatsSF__CallGuid__c);
                Case caseItem = new Case();
                if (casesByCallObject.get(callSummary.NVMStatsSF__CallGuid__c) != null) {
                    caseItem = casesByCallObject.get(callSummary.NVMStatsSF__CallGuid__c);
                    if (String.isBlank(caseItem.Vonage_Call_Summary__c) || (caseItem.Vonage_Call_Summary__c != callSummary.Id)) {
                        caseItem.Vonage_Call_Summary__c = callSummary.Id;
                    }
                    if (String.isBlank(callSummary.NVMStatsSF__Related_Case__c) || (callSummary.NVMStatsSF__Related_Case__c != caseItem.Id)) {
                        callSummary.NVMStatsSF__Related_Case__c = caseItem.Id;
                    }
                } 
                // else if (String.isNotBlank(callSummary.NVMStatsSF__Related_Case__c)) {
                //     caseItem = casesById.get(callSummary.NVMStatsSF__Related_Case__c);
                //     if (String.isBlank(caseItem.Vonage_Call_Summary__c) || (caseItem.Vonage_Call_Summary__c != callSummary.Id)) {
                //         caseItem.Vonage_Call_Summary__c = callSummary.Id;
                //     }
                // } else if (casesByCallSummary.get(callSummary.Id) != null) {
                //     caseItem = casesByCallSummary.get(callSummary.Id);
                //     callSummary.NVMStatsSF__Related_Case__c = caseItem.Id;
                //     callSummariesToUpdate.add(callSummary);
                // } else if (taskFromCall != null) {
                //     if (casesByPNR.get(taskFromCall.PNR__c) != null) {
                //         caseItem = casesByPNR.get(taskFromCall.PNR__c);
                //         caseItem.Vonage_Call_Summary__c = callSummary.Id;
                //         callSummary.NVMStatsSF__Related_Case__c = caseItem.Id;
                //         callSummariesToUpdate.add(callSummary);
                //     }
                // }
    
                if (caseItem != null) {
                    casesByCallSummaryToUpdate.put(caseItem.Vonage_Call_Summary__c, caseItem);
                    casesToUpdate.add(caseItem);
                    if (taskFromCall != null) {
                        if (String.isBlank(taskFromCall.WhatId)) {
                            taskFromCall.WhatId = caseItem.Id;
                            tasksToUpdate.add(taskFromCall);
                        }
                    }
                }
            }
    
            try {
                // List<SObject> sobjectsToUpdate = new List<SObject>();
                // sobjectsToUpdate.addAll(tasksToUpdate);
                // sobjectsToUpdate.addAll(casesToUpdate);
                Database.SaveResult [] updateResult = Database.update(casesToUpdate, false);
            } catch (Exception exept) {
                System.debug(exept);
            }
        }

        return casesByCallSummaryToUpdate;
    }

    public static void getRelatedTasks(Set<String> callSummariesGuids) {
        List<Task> tasks = [
            SELECT Id, PNR__c, CallObject, WhatId, Status
            FROM Task
            WHERE CallObject IN : callSummariesGuids
            LIMIT 10
        ];

        for (Task taskItem : tasks) {
            if (String.isNotBlank(taskItem.CallObject)) {
                pnrs.add(taskItem.PNR__c);
                tasksByCallObject.put(taskItem.CallObject, taskItem);
            }
        }
    }

    public static void getRelatedCases(Set<Id> callSummariesIds, Set<String> callSummariesGuids) {
        // List<Case> cases = [
        //     SELECT Id, PNR__c, Initial_Reason_For_Contact__c, Journey_Type_Product__c,
        //         Customer_Type__c, Sundry__c, Travel_Based_Disruption__c, Alternative_Disruption__c,
        //         Loyalty_Topic__c, Loyalty_Category__c, Type_of_Assistance__c, Booking_Type__c,
        //         Technical_Issue__c, Using_The_App__c, Customer_Issue__c, What_Is_The_Question__c,
        //         Area_On_Website__c, Customer_Struggle__c, Tone_of_Contact__c, Vonage_Call_Summary__c,
        //         Subject, Call_GUID__c
        //     FROM Case
        //     WHERE PNR__c IN : pnrs
        //         OR Vonage_Call_Summary__c IN : callSummariesIds
        //         OR Call_GUID__c IN :callSummariesGuids
        //     ORDER BY LastModifiedDate DESC
        //     LIMIT 100
        // ];
        if (!callSummariesGuids.isEmpty()) {
            try {
                String searchQuery= 'FIND ' + searchGuidString + ' IN ALL FIELDS RETURNING Case(Id, Status, PNR__c, Do_Not_Update_From_Call__c, Initial_Reason_For_Contact__c, Journey_Type_Product__c, Customer_Type__c, Sundry__c, Travel_Based_Disruption__c, Alternative_Disruption__c, Loyalty_Topic__c, Loyalty_Category__c, Type_of_Assistance__c, Booking_Type__c, Technical_Issue__c, Using_The_App__c, Customer_Issue__c, What_Is_The_Question__c, Area_On_Website__c, Customer_Struggle__c, Tone_of_Contact__c, Vonage_Call_Summary__c, Subject, Call_GUID__c ORDER BY LastModifiedDate DESC)'; 
                List<List<SObject>> searchList = search.query(searchQuery);
                List<Case> cases = (Case[]) searchList[0];
                for (Case caseItem : cases) {
                    if (String.isNotBlank(caseItem.PNR__c)) {
                        if (casesByPNR.get(caseItem.PNR__c) == null) {
                            casesByPNR.put(caseItem.PNR__c, caseItem);
                        }
                    }
                    if (String.isNotBlank(caseItem.Vonage_Call_Summary__c)) {
                        if (casesByCallSummary.get(caseItem.Vonage_Call_Summary__c) == null) {
                            casesByCallSummary.put(caseItem.Vonage_Call_Summary__c, caseItem);
                        }
                    }
                    if (String.isNotBlank(caseItem.Call_GUID__c)) {
                        if (casesByCallObject.get(caseItem.Call_GUID__c) == null) {
                            casesByCallObject.put(caseItem.Call_GUID__c, caseItem);
                        }
                    }
                    casesById.put(caseItem.Id, caseItem);
                }
            } catch (Exception e) {
                System.debug('Call Summary Trigger error: ' + e.getMessage());
            }
        }
    }
}