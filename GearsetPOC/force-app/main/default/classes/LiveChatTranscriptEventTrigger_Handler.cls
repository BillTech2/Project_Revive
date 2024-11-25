public without sharing class LiveChatTranscriptEventTrigger_Handler {
	public void updateTranscriptAvgResponceTime(List<LiveChatTranscriptEvent> liveChatTranscriptEvents) {

        for (LiveChatTranscriptEvent transcriptEvent : liveChatTranscriptEvents) {
        	// process only for event type = Leave Visitor
            if (transcriptEvent.LiveChatTranscriptId != null && transcriptEvent.Type == 'LeaveVisitor') {

            	// search related LiveChatTranscript
            	List<LiveChatTranscript> liveChatTranscripts = [
            		SELECT Id, ChatKey, First_Response_Time__c
            		FROM LiveChatTranscript
            		WHERE Id = :transcriptEvent.LiveChatTranscriptId
            	];

            	if (!liveChatTranscripts.isEmpty()) {
            		LiveChatTranscript liveChatTranscript = liveChatTranscripts[0];

	            	if (String.isNotBlank(liveChatTranscript.ChatKey)) {

	            		// search related Chat_Log__c records
						List<Chat_Log__c> chatLogs = [
								SELECT Id, Chat_key__c, TypeChatLog__c, Timestamp__c, UserName__c
								FROM Chat_Log__c
								WHERE Chat_key__c = :liveChatTranscript.ChatKey
								ORDER BY Timestamp__c
							];

						// search first client record, store timestamp
						// then search first advisor record without autogreeting,
						// calculate difference between timestamps, store data in related transcript
						if (!chatLogs.isEmpty()) {
							// reduce chatlog for remove message from previous agent (before transfer)
							List<Chat_Log__c> chatLogsReduced = new List<Chat_Log__c>();
							string agentName = chatLogs[0].UserName__c;
							if (chatLogs[0].TypeChatLog__c == 'agent' && !String.isBlank(agentName)) {
								for (Integer i = 0; i < chatLogs.size(); i++) {
									if (chatLogs[i].TypeChatLog__c == 'agent' && chatLogs[i].UserName__c != agentName) {
										chatLogsReduced.clear();
										agentName = chatLogs[i].UserName__c;
									}
									chatLogsReduced.add(chatLogs[i]);
								}
							}

							// calculate needed metric
							if (!chatLogsReduced.isEmpty()) {
								boolean isChasitorFound = false;
								Decimal startTimeStamp = 0;
								for (Chat_Log__c chatLog : chatLogsReduced) {
									if (chatLog.TypeChatLog__c == 'chasitor') {
										isChasitorFound = true;
										if (startTimeStamp == 0) startTimeStamp = chatLog.Timestamp__c;
									}
									else if (isChasitorFound && chatLog.TypeChatLog__c == 'agent') {
										if (startTimeStamp > 0) {
											Decimal result = chatLog.Timestamp__c - startTimeStamp;
											result = Math.round(result / 1000);
											liveChatTranscript.First_Response_Time__c = result;
											UPDATE liveChatTranscript;
										}

										break;
									}
								}
							}
						}
	            	}
	            }
        	}
		}
	}
}