trigger SDT_Master_Child_Relation on Staff_and_duty_travel__c (before insert) {
    
    Set<String> staffEmailAdress = new Set <String> ();
    List<Account> accountsList = new List<Account> ();
    Id assocAccountId;
    RecordType staffPersonAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Staff Person Account' and SObjectType = 'Account' Limit 1];
    
    
    //We create the list of all the email adresses from the bookings that are inserted
    for (Staff_and_duty_travel__c Travel : Trigger.New)
    {
        staffEmailAdress.add(Travel.Staff_email_address__c);
    }
    
    //We create the list of all the accounts containing one of the emails from the bookings that are inserted
    for(Account acc :[select Id, Customer_Email__pc, Secondary_Email__pc, Aria_Email__pc from Account where Customer_Email__pc IN:staffEmailAdress OR Secondary_Email__pc IN:staffEmailAdress OR Aria_Email__pc IN:staffEmailAdress])
    {
        accountsList.add(acc);
    }
    
    
    //For every booking that is inserted, we associate an account.
    for (Staff_and_duty_travel__c Travel : Trigger.New)
    {
        assocAccountId=Null;
        
        //We check if an account is already associated
        assocAccountId=Travel.Associated_account__c;
        
        //If not, we associate one.
        If (assocAccountId==Null){
            
            //We check if an account with the Staff email exists
            for (Account acc2 : accountsList){
                if(acc2.Customer_Email__pc != null){
                    if(acc2.Customer_Email__pc.equals(Travel.Staff_email_address__c)) {
                        assocAccountId=acc2.Id;
                    } 
                }
                if(acc2.Secondary_Email__pc != null){
                    if(acc2.Secondary_Email__pc.equals(Travel.Staff_email_address__c)) {
                        assocAccountId=acc2.Id;
                    } 
                }
                if(acc2.Aria_Email__pc != null){
                    if(acc2.Aria_Email__pc.equals(Travel.Staff_email_address__c)) {
                        assocAccountId=acc2.Id;
                    } 
                }
            }
            
            //If not, we generate an error
            if (assocAccountId==Null){
                
                //Create the account
                //Account newPersonAccount = new Account();
                //newPersonAccount.FirstName = Travel.Staff_First_Name__c;
                //newPersonAccount.LastName = Travel.Staff_Last_name__c;
                //newPersonAccount.Customer_Email__pc = Travel.Staff_email_address__c;
                //newPersonAccount.PersonHomePhone=Travel.Staff_phone_number__c;
                //newPersonAccount.RecordTypeId = staffPersonAccountRecordType.Id;
                //insert newPersonAccount;
                //assocAccountId=newPersonAccount.Id;
                //accountsList.add(newPersonAccount);
                Travel.addError('The customer account for this booking does not exist');
            }
        }
        //We associate the account
        Travel.Associated_account__c=assocAccountId;
    }
    
}