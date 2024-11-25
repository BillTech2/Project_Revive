public class OutOfOfficeCtrl {

    public Boolean OOOState {
        get;
        set;
    }

    public Boolean OOOSavedState {
        get {
            return userRecord.Out_Of_Office__c;
        }
    }

    public Boolean updatedToOut {
        get;
        set;
    }

    public Boolean updatedToIn {
        get;
        set;
    }

    public Id statusChangedOfID;
    public void setStatusChangedOfID(Id paramValue) {
        this.statusChangedOfID = paramValue;
    }
    public Id getStatusChangedOfID() {
        return this.statusChangedOfID;
    }

    public Boolean hasTeamMembers {
        get;
        set;
    }

    public Integer scrollPosition {
        get;
        set;
    }

    public Integer casesOwned {
        get {
            List<AggregateResult> res = [SELECT OwnerId Id, COUNT(Status) caseCount
                                         FROM Case
                                         WHERE Status != 'Closed' and OwnerId = :UserInfo.getUserId()
                                         GROUP BY OwnerId];

            return (res.size() > 0) ? Integer.valueOf(res[0].get('caseCount')) : 0;
        }
    }

    public User userRecord;

    public List<User> teamMembers;

    public Map<Id, DecoratedUser> decoratedTeamMembersMap;

    public List<DecoratedUser> decoratedTeamMembers;

    public List<DecoratedUser> getDecoratedTeamMembers() {
        return decoratedTeamMembers;
    }

    public OutOfOfficeCtrl() {
        scrollPosition = 0;
        refreshData();
    }

    public void refreshData() {
        OOOState = getOutOfOfficeState(null).Out_Of_Office__c;
        teamMembers = [SELECT Id, Name, Out_Of_Office__c FROM User WHERE ManagerId = : UserInfo.getUserId() ];
        Set<ID> teamMemberIDs = new Map<Id, User>(teamMembers).keySet();
        Map<Id,AggregateResult> caseNumbers = new Map<Id,AggregateResult>(
            [SELECT OwnerId Id, COUNT(Status) caseCount
             FROM Case
             WHERE Status != 'Closed' and OwnerId IN : teamMemberIDs
             GROUP BY OwnerId]
        );
        system.debug(caseNumbers);
        decoratedTeamMembersMap = new Map<Id, DecoratedUser>();
        decoratedTeamMembers = new List<DecoratedUser>();
        for (User teamMember : teamMembers) {
            DecoratedUser nextUser = new DecoratedUser(teamMember);
            system.debug(teamMemberIDs);
            if (caseNumbers.keySet().contains(teamMember.Id)) {
                nextUser.caseCount = Integer.valueOf(caseNumbers.get(teamMember.Id).get('caseCount'));
            } else {
                nextUser.caseCount = 0;
            }
            decoratedTeamMembers.add(nextUser);
            decoratedTeamMembersMap.put(teamMember.Id, nextUser);
        }
        hasTeamMembers = decoratedTeamMembers.size() > 0 ? true : false;
    }

    public void updateStatus() {
        //Adding the user id of the user that triggered the OOO functionality to help identify if FraudCaseHandler was called from OOO operation
        /*Current_OOO_session_users__c OOO_session = new Current_OOO_session_users__c();
        OOO_session.Name = UserInfo.getUserId();
        OOO_session.User_id__c = UserInfo.getUserId();
        insert OOO_session;*/
        
        if (OOOState != OOOSavedState) {
            userRecord.Out_Of_Office__c = OOOState;
            update userRecord;
            if (userRecord.Out_Of_Office__c) {
                updatedToOut = true;
                updatedToIn = false;
            } else {
                updatedToOut = false;
                updatedToIn = true;
            }
        }
        
        //Removing the user id of the user that triggered the OOO functionality after completion of OOO status change operation
        /*String Current_User_Id = UserInfo.getUserId(); 
        List<Current_OOO_session_users__c> OOO_session_del = [Select Id,Name,User_id__c from Current_OOO_session_users__c where User_id__c = :Current_User_Id];
        delete OOO_session_del;*/     
    }

    public void flipStatus() {
        Boolean currentStatus =  decoratedTeamMembersMap.get(statusChangedOfID).teamMember.Out_Of_Office__c;
        decoratedTeamMembersMap.get(statusChangedOfID).teamMember.Out_Of_Office__c = !currentStatus;
        update decoratedTeamMembersMap.get(statusChangedOfID).teamMember;
        refreshData();
    }

    public User getOutOfOfficeState(Id userId) {
        if (userId == null) userId = UserInfo.getUserId();
        userRecord = [SELECT Id, Out_Of_Office__c,
        (SELECT Id, Name, Out_Of_Office__c FROM ManagedUsers)
        FROM User
        WHERE Id = :userId LIMIT 1];
        return userRecord;
    }
/*
    public Integer getNumberOfCases(Id userId) {
        List<AggregateResult> res = [SELECT OwnerId Id, COUNT(Status) caseCount
                                     FROM Case
                                     WHERE Status != 'Closed' and OwnerId = :userId
                                     GROUP BY OwnerId];
        return res[0].get('caseCount');
    }
*/
    public class DecoratedUser {

        public User teamMember { get; private set; }

        public Boolean OOOState {
            get;
            set;
        }

        public Boolean OOOSavedState {
            get {
                return teamMember.Out_Of_Office__c;
            }
        }

        public Boolean updatedToOut {
            get;
            set;
        }

        public Boolean updatedToIn {
            get;
            set;
        }

        public DecoratedUser (User teamMember) {
            this.teamMember = teamMember;
        }

        public Integer caseCount { get; private set; }
    }
}