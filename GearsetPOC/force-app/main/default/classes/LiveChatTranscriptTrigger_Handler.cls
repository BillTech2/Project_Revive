public with sharing class LiveChatTranscriptTrigger_Handler {
    public void insertLiveChat(List<LiveChatTranscript> liveChatTranscripts) {
        Map<String, LiveChatTranscript> transcriptByChatKey = new Map<String, LiveChatTranscript>();
        Map<String, SurveyTaker__c> emptySurveyByChatKey = new Map<String, SurveyTaker__c>();
        Set<String> chatKeys = new Set<String>(); 
        for (LiveChatTranscript item : liveChatTranscripts) {
            if (item.ChatKey != null) {
                transcriptByChatKey.put(item.ChatKey, item);
            }
        }
        if (!transcriptByChatKey.isEmpty()) {
            List<SurveyTaker__c> surveyTaker = [SELECT Id, LiveChatKey__c,  Case__c, Contact__c, User__c FROM SurveyTaker__c WHERE LiveChatKey__c IN :transcriptByChatKey.keySet()];
            if (!surveyTaker.isEmpty()) {
                for (SurveyTaker__c item : surveyTaker) {
                    if (transcriptByChatKey.containsKey(item.LiveChatKey__c) != null) {
                        transcriptByChatKey.get(item.LiveChatKey__c).SurveyTaken__c = item.Id;
                    }
                    if (String.isBlank(item.Case__c) || String.isBlank(item.Contact__c) || String.isBlank(item.User__c)) {
                        emptySurveyByChatKey.put(item.LiveChatKey__c, item);
                    }
                }
            }
        }
            
        // Update Customer (Account) and Client data
        Set<Id> caseIds = new Set<Id>();
        for (LiveChatTranscript transcript : liveChatTranscripts) {
            caseIds.add(transcript.CaseId);
        }
            
        Map<Id, Case> cases = new Map<Id, Case>([
            SELECT Id, AccountId, ContactId
            FROM Case
            WHERE Id IN :caseIds
        ]);
            
        if (!cases.isEmpty()) {
            for (LiveChatTranscript transcript : liveChatTranscripts) {
                Case caseObject = cases.get(transcript.CaseId);
                if (caseObject != null) {
                    if (caseObject.AccountId != null && transcript.AccountId == null) {
                        transcript.AccountId = caseObject.AccountId;                            
                    }
                    if (caseObject.ContactId != null && transcript.ContactId == null) {
                        transcript.ContactId = caseObject.ContactId;
                    }
                }
            }
        }

        if (!emptySurveyByChatKey.isEmpty() && !cases.isEmpty()) {
            for (LiveChatTranscript transcript : liveChatTranscripts) {
                if (emptySurveyByChatKey.containsKey(transcript.ChatKey)) {
                    
                    emptySurveyByChatKey.get(transcript.ChatKey).Case__c = transcript.CaseId;  
                    emptySurveyByChatKey.get(transcript.ChatKey).Contact__c = transcript.ContactId;
                    emptySurveyByChatKey.get(transcript.ChatKey).User__c = transcript.OwnerId;
                }
            }
            update emptySurveyByChatKey.values();
        }
    }
}