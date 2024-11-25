trigger SurveyTakerTrigger on SurveyTaker__c (after insert) {
	new SurveyTakerTrigger_Handler().updateTranscript(Trigger.new);    
}