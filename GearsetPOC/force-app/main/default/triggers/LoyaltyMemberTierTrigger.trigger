trigger LoyaltyMemberTierTrigger on LoyaltyMemberTier (after insert, after update, before update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        OSF_LoyaltyMemberTier_TriggerHandler.createHistoryRecord(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        OSF_LoyaltyMemberTier_TriggerHandler.setTierDates(Trigger.new, Trigger.oldMap);
    }
}