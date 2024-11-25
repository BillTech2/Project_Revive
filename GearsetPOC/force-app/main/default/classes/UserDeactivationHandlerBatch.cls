public class UserDeactivationHandlerBatch implements Database.Batchable<sObject> {
    public Set<Id> caseIds;

    public UserDeactivationHandlerBatch(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Language FROM Case WHERE Id IN :caseIds');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        UserDeactivationHandler.reassignCasesToTheOriginalQueue((List<Case>) scope);
        update scope;
    }

    public void finish(Database.BatchableContext BC) {}
}