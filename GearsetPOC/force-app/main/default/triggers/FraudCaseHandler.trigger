trigger FraudCaseHandler on Case (before insert,after insert,  before update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Case_Automation__c || DLT_CaseTriggerHandler.isDisabled) { return; }

    //Fetch all user ids added as part of OOO operation and comparing user id that triggered FraudCaseHandler trigger to identify if it was called from OOO operation itself 
    String FCH_User_Id = UserInfo.getUserId();
    boolean FraudCaseHandler_Called_From_OOO_Session = false;
    
    for(Current_OOO_session_users__c OOO_Session : FraudCaseTriggerHandler.OOO_SessionList)
    {   
        if(OOO_Session.User_id__c==FCH_User_Id)
        {
            FraudCaseHandler_Called_From_OOO_Session = true;
            break;
        }
    }
    //If FraudCaseHandler was triggered from OOO operation, the flow inside the trigger is not executed
    if(FraudCaseHandler_Called_From_OOO_Session == false){
    //
        if (!User_trigger_settings__c.getInstance().isDisabled__c){
            if (Trigger.IsInsert && Trigger.IsBefore ){
                FraudCaseTriggerHandler.beforeInsert(Trigger.new);
            }
            if (Trigger.IsUpdate && Trigger.IsBefore){
                FraudCaseTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap); 
            }
            if (Trigger.IsInsert && Trigger.IsAfter){
                FraudCaseTriggerHandler.afterInsert(Trigger.new);
            }
    
        }       
    }
}