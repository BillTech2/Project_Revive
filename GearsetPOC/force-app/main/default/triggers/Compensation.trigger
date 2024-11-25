trigger Compensation on Compensation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Compensation_Automation__c || DLT_CompensationTriggerHandler.isDisabled) { return; }

    /* Get singleton handler's instance */
    CompensationTriggerHandler handler = CompensationTriggerHandler.getInstance();

    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {

        Map<String, List<Sobject>> caseToCompensationMap = CompApp_Utils.getFieldValueMap2list(Trigger.new, 'case__c');
        caseToCompensationMap.remove(null);
        caseToCompensationMap.remove('');

        for (Case iteratedCase: [select id, TCN__c FROM Case where id In:caseToCompensationMap.keySet()]){
            if (iteratedCase.TCN__c == null && caseToCompensationMap.containsKey(iteratedCase.id)){
                for (Compensation__c iteratedComp : (List<Compensation__c>) caseToCompensationMap.get(iteratedCase.id)){
                    if (iteratedComp.isCaseDriven__c && iteratedComp.Link_to_all_tickets_for_same_train_PNR__c){
                        iteratedComp.addError('This case does not relate to a ticket, and cannot be compensated.');
                    }
                }
            }
        }

        handler.onBeforeInsert(Trigger.new);
    }

    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert) {
       handler.onAfterInsert(Trigger.new, Trigger.newMap); // new new
       CaseQuickactionController.setRelatedCaseManualDraft(Trigger.new, null);
    }

    /* Before Update */
    else if (Trigger.isUpdate && Trigger.isBefore) {
        handler.onBeforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }

    /* After Update */
    else if (Trigger.isUpdate && Trigger.isAfter) {
       COVID19_TriggerUtils.closeRelatedCasesWhenAllCompsSucceeded(Trigger.new, Trigger.oldMap, null);
       handler.onAfterUpdate(Trigger.old,Trigger.oldMap,Trigger.new,Trigger.newMap);
       CaseQuickactionController.setRelatedCaseManualDraft(Trigger.new, Trigger.oldMap);
    }

    /* Before Delete */
    else if (Trigger.isDelete && Trigger.isBefore) {
        handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    }

    /* After Delete */
    else if (Trigger.isDelete && Trigger.isAfter) {
        handler.onAfterDelete(Trigger.old, Trigger.oldMap);
        CaseQuickactionController.setRelatedCaseManualDraft(null, Trigger.oldMap);
    }

    /* After Undelete */
    else if (Trigger.isUnDelete) {
        handler.onAfterUndelete(Trigger.new, Trigger.newMap);
    }

    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter && !System.isFuture() && !System.isBatch()) {
        OSF_Compensation_TriggerHandler.createTransactionJournals(Trigger.New, Trigger.oldMap);
    }

    DLT_CompensationTriggerHandler.run();

}