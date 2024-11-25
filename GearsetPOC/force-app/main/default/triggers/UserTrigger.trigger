trigger UserTrigger on User (before insert, after insert,
    before update, after update,
    before delete, after delete,
    after undelete) {

        if (DLT_Automation_Settings__c.getOrgDefaults().Disable_User_Automation__c) { return; }

        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                Map<Id, User> userByIds = (Map<Id, User>) Trigger.oldMap;
                Set<Id> usedIds = new Set<Id>();
                for(User u : (List<User>) Trigger.new) {
                    if(u.IsActive == false && userByIds.get(u.Id).IsActive == true) {
                        usedIds.add(u.Id);
                    }
                }
                List<Case> cases = [SELECT Id, Language, OwnerId FROM Case WHERE OwnerId IN :usedIds AND Status != 'Closed'];

                Map<Id, Case> caseByIds = new Map<Id, Case>(cases);

                UserDeactivationHandlerBatch btch = new UserDeactivationHandlerBatch(caseByIds.keySet());
                Database.executeBatch(btch);
            }
        }
}