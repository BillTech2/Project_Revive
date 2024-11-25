trigger UserStatusTrigger on User (before update, after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_User_Automation__c) { return; }

    if (Trigger.isBefore && Trigger.isUpdate) {
        for (User nextUser : Trigger.new) {
            if (!nextUser.IsActive && Trigger.oldMap.get(nextUser.Id).IsActive) {
                nextUser.Inactive_Login_warning_sent__c = null;
            }
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> usersToReturnCases = new Set<Id>();
        for (User nextUser : Trigger.new) {
            if (nextUser.Out_Of_Office__c && !Trigger.oldMap.get(nextUser.Id).Out_Of_Office__c) {
                usersToReturnCases.add(nextUser.Id);
            }
        }
        if (usersToReturnCases.size() > 0)
        System.debug('------------------CPU Time upon entering returnCasesToQueue in OutOfOfficeTriggerUtils: ' + Limits.getCpuTime());
            database.executeBatch(new OutOfOfficeTriggerBatch(usersToReturnCases), 5);
    }
}