trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert, after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            new LiveChatTranscriptTrigger_Handler().insertLiveChat(Trigger.new);
        }
        
    }
}