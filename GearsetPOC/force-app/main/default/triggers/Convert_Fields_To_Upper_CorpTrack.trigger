trigger Convert_Fields_To_Upper_CorpTrack on Corp_Tracking__c (before insert, before update) {
    for(Corp_Tracking__c corp_Tracking : Trigger.New) {
        
        System.debug('Before converting text fields to upper case = '+ corp_Tracking.client_name__c );
        
        if(corp_Tracking.client_name__c != null)
            corp_Tracking.client_name__c = corp_Tracking.client_name__c.toUpperCase();
               
        System.debug('After converting text fields to upper case = '+ corp_Tracking.client_name__c );
    }
}