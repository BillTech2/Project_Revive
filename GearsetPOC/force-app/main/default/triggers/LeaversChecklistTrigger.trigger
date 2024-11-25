trigger LeaversChecklistTrigger on Leavers_Checklist__c (before insert, after insert, before update) {
    List<Leavers_Checklist__c> checklistsForSend = new List<Leavers_Checklist__c>();
    Set<Id> leaversUserIds = new Set<Id>();

    if (Trigger.isBefore && Trigger.isInsert) {
        for (Leavers_Checklist__c nextChecklist : Trigger.new) {
            if (nextChecklist.Form_Complete__c) {
                nextChecklist.Form_Completion_Date__c = Datetime.now();
                nextChecklist.Form_Completed_By__c = UserInfo.getUserId();
            }
        }
    } else if (Trigger.isAfter && Trigger.isInsert) {
        List<Leavers_Checklist__Share> ChkLstShares  = new List<Leavers_Checklist__Share>();

        for (Leavers_Checklist__c nextChecklist : Trigger.new) {
            if (nextChecklist.Form_Complete__c) {
                leaversUserIds.add(nextChecklist.Employee_Id__c);
                checklistsForSend.add(nextChecklist);
            }
            Leavers_Checklist__Share nextShare  = new Leavers_Checklist__Share();
            nextShare.ParentId = nextChecklist.Id;
            nextShare.UserOrGroupId = nextChecklist.Employee_Id__c;
            nextShare.AccessLevel = 'edit';
            nextShare.RowCause = Schema.Leavers_Checklist__Share.RowCause.Manual;
            ChkLstShares.add(nextShare);
        }

        Database.SaveResult[] lsr = Database.insert(ChkLstShares,false);

    } else if (Trigger.isBefore && Trigger.isUpdate) {
        for(Id nextChecklistId : Trigger.newMap.keySet()) { 
            Leavers_Checklist__c oldChecklist = Trigger.oldMap.get(nextChecklistId); 
            Leavers_Checklist__c newChecklist = Trigger.newMap.get(nextChecklistId);
            if (newChecklist.Form_Complete__c && oldChecklist.Form_Complete__c != newChecklist.Form_Complete__c) {
                newChecklist.Form_Completion_Date__c = Datetime.now();
                newChecklist.Form_Completed_By__c = UserInfo.getUserId();
                leaversUserIds.add(newChecklist.Employee_Id__c);
                checklistsForSend.add(newChecklist);
            }
        }
    }

    if (checklistsForSend.size() > 0) {
        LeaversChecklistTriggerHandler.sendNotificationEmails(checklistsForSend, leaversUserIds);
    }
}