public without sharing class DLT_CompensationTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                setInitialValues(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                checkIfCarrierIsDeafult(new List<Id>(Trigger.newMap.keySet()));
            }

            if (System.Trigger.isUpdate) {
                updateRelatedCases(Trigger.newMap.keySet());
            }
        }
    }

    private static void updateRelatedCases(Set<Id> compensationIds){

        if(DLT_Utils.isAsyncCtx()){
            DLT_CompensationService.updateRelatedCases(compensationIds);
        }
        else{
            System.enqueueJob(new DLT_CompensationTriggerQueHelper(
                DLT_CompensationTriggerQueHelper.Mode.UPDATE_RELATED_CASES_AFTER_COMPENSATION_UPDATE,
                compensationIds
            ));
        }
    }

    private static void setInitialValues(List<Compensation__c> compensationsToModify) {
        for (Compensation__c comp : compensationsToModify) {

            if (comp.recordTypeId == DLT_CompensationConstants.RECORD_TYPE_ID_POINTS) {
                comp.Claim_Status__c = DLT_CompensationConstants.COMP_CLAIM_STATUS_CLAIMED;
            }

            if(comp.RecordTypeId == DLT_CompensationConstants.RECORD_TYPE_ID_ONLINE){
                comp.Is_Online_Compensation__c = true;
            }
        }
    }

    public static void checkIfCarrierIsDeafult(List<Id> compensations){

        List<Compensation__c> compensationsWithDefault = [
            SELECT Id, Train__r.Carrier__c, Ticket__r.Carrier__c, Case__r.Carrier__c, CreatedBy.Train_Service__c, Train__c, Ticket__c, Case__c
            FROM Compensation__c 
            WHERE Id IN :compensations
                AND RecordTypeId = :DLT_CompensationConstants.RECORD_TYPE_ID_VOUCHER
            ];

        for(Compensation__c c : compensationsWithDefault){
        
            c.Carrier_was_defaulted__c = (c.Train__c != null && c.Train__r.Carrier__c != null && c.Train__r.Carrier__c != DLT_CaseConstants.CARRIER_PURPLE) ? false : 
                ((c.Ticket__c != null && c.Ticket__r.Carrier__c != null && c.Ticket__r.Carrier__c != DLT_CaseConstants.CARRIER_PURPLE) ? false : 
                    ((c.Case__c != null && c.Case__r.Carrier__c != null && c.Case__r.Carrier__c != DLT_CaseConstants.CARRIER_PURPLE) ? false :
                        ((c.CreatedBy.Train_Service__c != null && c.CreatedBy.Train_Service__c != DLT_CaseConstants.CARRIER_PURPLE) ? false : true)));

        }
        DLT_CompensationTriggerHandler.isDisabled = true;
        update compensationsWithDefault;
        DLT_CompensationTriggerHandler.isDisabled = false;

    }
}