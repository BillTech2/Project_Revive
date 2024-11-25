trigger CaseTrigger on Case (before insert, after insert, before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Case_Automation__c || DLT_CaseTriggerHandler.isDisabled) { return; }

    if (Trigger.isInsert && Trigger.isBefore) {
        COVID19_TriggerUtils.updateCasesWithTicketsValidityInfo(Trigger.new);
        Eins_CasePriorityHelper.prioritiseAllCases(Trigger.new);
        //bookingType&journeyTypeBy PNR
        cu_CaseForTicketsTriggerHandler.classOfServiceFields_update(Trigger.New);
        cu_CaseForTicketsTriggerHandler.bookingTypeField_update(Trigger.New);
        cu_CaseForTicketsTriggerHandler.jorneyTypeField_update(Trigger.New);
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        UserDeactivationHandler.reassignReopenedCasesToTheOriginalQueue((List<Case>) Trigger.new, (Map<Id, Case>) Trigger.oldMap);
        OutOfOfficeTriggerUtils.returnCasesToQueue(
                Trigger.newMap,
                OutOfOfficeTriggerUtils.getReopenedCasesWithOwnerHistory(Trigger.new, Trigger.oldMap)
        );
        cu_CaseForTicketsTriggerHandler.classOfServiceFields_update(Trigger.New);
        cu_CaseForTicketsTriggerHandler.bookingTypeField_update(Trigger.New);
        cu_CaseForTicketsTriggerHandler.jorneyTypeField_update(Trigger.New);
        Eins_UpdatePNRCasePriorityController.updateCasePriority(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        COVID19_TriggerUtils.reflectCOVIDCaseStatusOnTickets(Trigger.oldMap, Trigger.new);
        PhoneCaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        CaseAddFilesAfterInsert.addFilesToCase(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        COVID19_TriggerUtils.reflectCOVIDCaseStatusOnTickets(Trigger.oldMap, Trigger.new);
        //COVID19_TriggerUtils.convertOnlineCompsToVoucherRequests(Trigger.new);
        CaseAddFilesAfterInsert.addFilesToCase(Trigger.new);
        SendEmailAfterInsertHelper.sendEmailFromCase(Trigger.new);
    }

    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && !System.isFuture() && !System.isBatch()) {
        Eins_CaseIntentHandler.intentProcessing(Trigger.newMap);
    }

    DLT_CaseTriggerHandler.run();

}