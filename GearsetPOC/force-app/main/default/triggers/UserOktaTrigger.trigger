trigger UserOktaTrigger on User (before insert, before update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_User_Automation__c) { return; }

List<String> Approverusername= new List<String>();
Map<String, ID> userid = new Map<String,ID>();
    for (User u : Trigger.new){
        if (u.ManagerUsername__c <>'' && u.ManagerUsername__c != null)
            Approverusername.add((u.ManagerUsername__c).tolowercase());
    }
    for (User usr : [select id, username from user where username in :Approverusername]){
       userid.put(usr.username, usr.id);
    }
    User uo;
    for (User u : Trigger.new){
       //System.debug('From Truigger : Inside Loop  ');
       if (Trigger.isInsert) { /* When inserting a new user if the manager is set directly, then dont do anything */ 
           //System.debug('From Trigger : Insert Operation  ');          
            if (u.ManagerID == null){
                if (u.ManagerUsername__c !='' && u.ManagerUsername__c != null){
                    //System.debug('From Trigger : Manager ID Is null ');
                    u.ManagerID=userid.get((u.ManagerUsername__c ).tolowercase());
                }
            }
            else{
                User um =[select UserName,id from User where id=:u.managerID];
                u.managerUserName__c=um.userName; 
                //System.debug('From Trigger : Manager user Name Is ' + u.managerUserName__c);
            }
       }
       if (Trigger.isBefore && Trigger.isUpdate){ //Update Records
           if (Trigger.OldMap.get(u.id).ManagerID!=u.managerID ){ //If managerId is changed then               
               if (u.managerID != null ){ //if new managerid is not null then set manager user name field
                   User um =[select UserName,id from User where id=:u.managerID];
                   u.managerusername__c = um.username;
               }
               else // clear managerusername field
                   u.managerusername__c ='';
           }
           else if (Trigger.OldMap.get(u.id).Managerusername__c!=u.Managerusername__c){//If managerusername is changed then 
              if (u.ManagerUsername__c !='' && u.ManagerUsername__c != null) // if new manager user name  is not null then set manager id
                   u.ManagerID=userid.get((u.ManagerUsername__c).tolowercase());
              else // clear manager id field
                  u.ManagerID =null;  
           }
       }
    } 
}