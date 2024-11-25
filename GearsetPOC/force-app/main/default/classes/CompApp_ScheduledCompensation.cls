global class CompApp_ScheduledCompensation implements Database.Batchable<sObject> {

    private string scopeQuery;

    public CompApp_ScheduledCompensation(String scopeQuery){
        this.scopeQuery = scopeQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(scopeQuery);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('entering batch portion');
        Map<Id,Ticket__c> scopeMap = new Map<Id,Ticket__c>((List<Ticket__c>)scope);
        CompApp_TriggerUtils.upsertCompensations(
                CompApp_TriggerUtils.getCompensationCreationData((List<Ticket__c>)scope, (Map<Id,Ticket__c>)scopeMap)
        );

    }

    global void finish(Database.BatchableContext BC) {}

}