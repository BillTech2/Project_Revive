trigger LoyaltyProgramMemberTrigger on LoyaltyProgramMember (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        OSF_LoyaltyProgramMember_TriggerHandler.createHistoryRecord(Trigger.new, Trigger.oldMap);
    }
}