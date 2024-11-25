trigger UpdateDescriptionPlatformEventTrigger on Update_Description_Platform_Event__e (after insert) {
    UpdateDescriptionEventHelper.updateCaseDescription(Trigger.new);
}