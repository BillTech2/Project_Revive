public with sharing class AccountingSyncBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
	private Set<Id> recordIds;
	
	private String sObjectName;
	
	private String operation;
	
	public AccountingSyncBatch(Set<Id> recordIds, String sObjectName, String operation) {
		this.recordIds = recordIds;
		this.sObjectName = sObjectName;
		this.operation = operation;
	}
	
	public Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator(AccountingSyncHelper.getQueryString(sObjectName));
	}
	
	public void execute(Database.BatchableContext context, List<SObject> scope) {
		AccountingSyncHelper.updateErrorLogs(AccountingSyncHelper.syncRecords(scope, sObjectName, operation));
	}
	
	public void finish(Database.BatchableContext context) {
		
	}
}