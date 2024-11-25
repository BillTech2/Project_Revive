global without sharing class CompApp_COVIDCaseCloser implements Database.Batchable<sObject>, Database.Stateful {

    private string scopeQuery;
    global Boolean needRestart;

    public CompApp_COVIDCaseCloser(){
        scopeQuery = 'SELECT Id, Name, Case__c, PNR__c FROM Utility__c';
        needRestart = false;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(scopeQuery);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        if (scope.size() > 0 ) {
            needRestart = true;
            COVID19_TriggerUtils.closeRelatedCasesWhenAllCompsSucceeded(null, null, (List<Utility__c>) scope);
            List<Utility__c> utilitiesForRemoval = new List<Utility__c>();
            for (Utility__c utility : (List<Utility__c>) scope) {
                if (utility.PNR__c == null) utilitiesForRemoval.add(utility);
            }
            if (utilitiesForRemoval.size() > 0) {
                delete utilitiesForRemoval;
                if (utilitiesForRemoval.size() == scope.size()) {
                    needRestart = false;
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

        AggregateResult result = [SELECT Count(Id) size FROM Utility__c];
        List<CronTrigger> crons = [SELECT Id,CronJobDetail.Name
                                   FROM CronTrigger
                                   WHERE CronJobDetail.Name = 'COVID Case Closer'];
        if (crons.size() == 0) {
            if (needRestart || (Integer)(result.get('size')) != 0) {
                System.scheduleBatch(new CompApp_COVIDCaseCloser(), 'COVID Case Closer', 1, 200);
            }
        }
    }

}