public inherited sharing class DLT_CompensationService {
    
    public static void updateRelatedCases(Set<Id> compensationIds) {
        Map<Id,Case> casesToUpdate = new Map<Id,Case>();

        for (Compensation__c comp : [
            SELECT Id, Case__c, Case__r.Status, Comp_Approval_Status__c, RecordType.Name, Payment_Currency__c, Payment_Amount__c, Case__r.Sub_Status__c
            FROM Compensation__c
            WHERE Id IN :compensationIds
                AND Case__c != null
                AND ((
                        Comp_Approval_Status__c = :DLT_CompensationConstants.COMP_APPROVAL_STATUS_AWAITING
                        AND Case__r.Sub_Status__c != :DLT_CaseConstants.SUB_STATUS_COMPENSATION_PENDING
                    )
                    OR (
                        Comp_Approval_Status__c = :DLT_CompensationConstants.COMP_APPROVAL_STATUS_APPROVED
                        AND Case__r.Sub_Status__c != :DLT_CaseConstants.SUB_STATUS_COMPENSATION_APPROVED
                    )
                    OR (
                        Comp_Approval_Status__c = :DLT_CompensationConstants.COMP_APPROVAL_STATUS_REJECTED
                        AND Case__r.Sub_Status__c != :DLT_CaseConstants.SUB_STATUS_COMPENSATION_REJECTED
                    )
                    OR RecordType.Name = :DLT_CompensationConstants.COMP_RECORDTYPE_VOUCHER
                )
        ]) {

            if ((
                comp.Comp_Approval_Status__c == DLT_CompensationConstants.COMP_APPROVAL_STATUS_AWAITING
                && comp.Case__r.Sub_Status__c != DLT_CaseConstants.SUB_STATUS_COMPENSATION_PENDING
            )
            || (
                comp.Comp_Approval_Status__c == DLT_CompensationConstants.COMP_APPROVAL_STATUS_APPROVED
                && comp.Case__r.Sub_Status__c != DLT_CaseConstants.SUB_STATUS_COMPENSATION_APPROVED
            )
            || (
                comp.Comp_Approval_Status__c == DLT_CompensationConstants.COMP_APPROVAL_STATUS_REJECTED
                && comp.Case__r.Sub_Status__c != DLT_CaseConstants.SUB_STATUS_COMPENSATION_REJECTED
            )) {
                casesToUpdate.put(
                    comp.Case__c,
                    new Case(
                        Id = comp.Case__c,
                        Status = DLT_CaseConstants.STATUS_AWAITING_INTERNAL,
                        Sub_Status__c = DLT_CaseConstants.APPROVAL_STATUS_TO_SUBSTATUS_MAP.get(comp.Comp_Approval_Status__c)
                    )
                );
            }

            if (comp.RecordType.Name == DLT_CompensationConstants.COMP_RECORDTYPE_VOUCHER) {
                if (casesToUpdate.containsKey(comp.Case__c)) {
                    casesToUpdate.get(comp.Case__c).Voucher_Amount__c = comp.Payment_Amount__c;
                    casesToUpdate.get(comp.Case__c).Currency__c = comp.Payment_Currency__c;
                } else {
                    casesToUpdate.put(
                        comp.Case__c,
                        new Case(
                            Id = comp.Case__c,
                            Voucher_Amount__c = comp.Payment_Amount__c,
                            Currency__c = comp.Payment_Currency__c
                        )
                    );
                }
            }

        }

        if (!casesToUpdate.isEmpty()) {
            DLT_CaseTriggerHandler.isDisabled = true;

            update casesToUpdate.values();

            DLT_CaseTriggerHandler.isDisabled = false;
        }
    }
}