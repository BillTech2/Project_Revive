public with sharing class SurveyTakerTrigger_Handler {
    public void updateTranscript(List<SurveyTaker__c> surveyTakers) {
        Map<String, SurveyTaker__c> surveyTakerByChatKey = new Map<String, SurveyTaker__c>();
        for (SurveyTaker__c surveyTaker : surveyTakers) {
            if (surveyTaker.LiveChatKey__c != null) {
                surveyTakerByChatKey.put(surveyTaker.LiveChatKey__c, surveyTaker);
            }
        }
        
        if (!surveyTakerByChatKey.isEmpty()) {
            List<LiveChatTranscript> transcripts = new List<LiveChatTranscript>([
                SELECT Id, ChatKey, SurveyTaken__c 
                FROM LiveChatTranscript
                WHERE ChatKey IN :surveyTakerByChatKey.keySet()
            ]);
            
            if (!transcripts.isEmpty()) {
                for (LiveChatTranscript transcript : transcripts) {
                    if (transcript.ChatKey != null) {
                        SurveyTaker__c st = surveyTakerByChatKey.get(transcript.ChatKey);
                        if (st != null && st.LiveChatKey__c != null && transcript.SurveyTaken__c == null) {
                            transcript.SurveyTaken__c = st.Id;
                        }
                    }
                }
                update transcripts;
            }
        }
    }
    
}