trigger Note_au on Note (after insert) {
    
    List<Incident__c> Inc = [select id, Modified_By__c,Modified_Date__c from Incident__c where id =: Trigger.New[0].ParentId];
                        if(Inc.size()>0)
                        {
                                    Inc[0].Modified_Date__c = system.now();
                             		Inc[0].Modified_By__c = UserInfo.getName();
                                    update Inc;
                        }    

}