trigger LiveChatTranscriptEventTrigger on LiveChatTranscriptEvent (after insert) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
    		new LiveChatTranscriptEventTrigger_Handler().updateTranscriptAvgResponceTime(Trigger.new);
		}
	}
}