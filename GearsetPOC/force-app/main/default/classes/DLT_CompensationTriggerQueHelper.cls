public inherited sharing class DLT_CompensationTriggerQueHelper implements Queueable {

    public enum Mode {
        UPDATE_RELATED_CASES_AFTER_COMPENSATION_UPDATE,
        CLOSE_RELATED_CASES_WHEN_COPMS_SUCCEED
    }

    private Mode helperMode;
    private Set<Id> compensationIds;
    private List<Compensation__c> newComps;
    private Map<Id, Compensation__c> oldCompsMap;
    private List<Utility__c> utilities;
    
    public DLT_CompensationTriggerQueHelper(Mode helperMode, Set<Id> compensationIds) {
        this.helperMode = helperMode;
        this.compensationIds = compensationIds;
    }

    public DLT_CompensationTriggerQueHelper(Mode helperMode, final List<Compensation__c> newComps, final Map<Id, Compensation__c> oldCompsMap, List<Utility__c> utilities) {
        this.helperMode = helperMode;
        this.newComps = newComps;
        this.oldCompsMap = oldCompsMap;
        this.utilities = utilities;
    }

    public void execute(QueueableContext context) {
        switch on helperMode {
            when UPDATE_RELATED_CASES_AFTER_COMPENSATION_UPDATE {
                DLT_CompensationService.updateRelatedCases(this.compensationIds);
            }
            when CLOSE_RELATED_CASES_WHEN_COPMS_SUCCEED {
                COVID19_TriggerUtils.closeRelatedCasesWhenAllCompsSucceeded(this.newComps, this.oldCompsMap, this.utilities);
            }
        }
    }
}