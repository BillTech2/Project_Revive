trigger Convert_Fields_To_Upper_TrackCode on Corp_Tracking_Type_and_Code__c (before insert, before update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Corporate_Tracking_Automation__c) { return; }

    for(Corp_Tracking_Type_and_Code__c tracking_Code : Trigger.New) {
        if(tracking_Code.Corp_Code__c != null) {
            tracking_Code.Corp_Code__c = tracking_Code.Corp_Code__c.toUpperCase();
        }
        if(tracking_Code.Entity__c != null) {
            tracking_Code.Entity__c = tracking_Code.Entity__c.toUpperCase();
        }

    }
}