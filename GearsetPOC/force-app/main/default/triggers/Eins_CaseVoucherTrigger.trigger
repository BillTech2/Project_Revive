trigger Eins_CaseVoucherTrigger on Case_eVoucher__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        // Eins_UpdateVoucherFromCase.updateVoucherFromCase(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Eins_CaseEVoucherTriggerHandler.sendNotification(Trigger.new, Trigger.oldMap);
    }
}