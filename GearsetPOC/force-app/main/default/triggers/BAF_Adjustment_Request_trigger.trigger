trigger BAF_Adjustment_Request_trigger on BAF_Adjustment_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    /* Get singleton handler's instance */
    BAFAdjustmentTriggerHandler handler = BAFAdjustmentTriggerHandler.getInstance();

    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {

    }

    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert) {
       CaseQuickactionController.setRelatedCaseManualDraft(Trigger.new, null);
       handler.setCaseBusinessAccount(Trigger.new, null);
    }

    /* Before Update */
    else if (Trigger.isUpdate && Trigger.isBefore) {

    }

    /* After Update */
    else if (Trigger.isUpdate && Trigger.isAfter) {
       CaseQuickactionController.setRelatedCaseManualDraft(Trigger.new, Trigger.oldMap);
       handler.setCaseBusinessAccount(Trigger.new, Trigger.oldMap);
    }

    /* Before Delete */
    else if (Trigger.isDelete && Trigger.isBefore) {

    }

    /* After Delete */
    else if (Trigger.isDelete && Trigger.isAfter) {
        CaseQuickactionController.setRelatedCaseManualDraft(null, Trigger.oldMap);
    }

    /* After Undelete */
    else if (Trigger.isUnDelete) {

    }

}