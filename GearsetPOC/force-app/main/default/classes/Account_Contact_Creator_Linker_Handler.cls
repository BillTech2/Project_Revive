public without sharing class Account_Contact_Creator_Linker_Handler {
    public void createAndLinkCustomers(List<Case> cases) {
        set<String> emailAddresses = new set<String>();//To store Email ID without any duplicacy
            
            //Create a list of unique email ids
            for (Case caseObj : cases) {
                if (String.isNotBlank(caseObj.SuppliedEmail)) {
                    emailAddresses.add(caseObj.SuppliedEmail.toLowerCase());
                }
            }
            
            //Create a list of existing accounts with above case email ids
            List<Account> listAccount = [Select Id, Customer_Email__pc From Account Where Customer_Email__pc in :emailAddresses];
            
            //Map the existing accounts with their case email ids
            Map<String, id> ExistingemailToAccountMap = new Map<String, id>();
            
            for (Account existAcc : listAccount) {
                ExistingemailToAccountMap.put(existAcc.Customer_Email__pc , existAcc.id);
                
            }
            
            //Create a list of email ids for which account already exists
            Set<String> takenEmails = new Set<String>();
            for (Account acc : listAccount ) {
                takenEmails.add(acc.Customer_Email__pc );
            }
            
            // Select recordtypeid for personAccounts
            //Id recordtype = [SELECT Id FROM RecordType where SobjectType = 'Account' and Name = 'Person Account' limit 1].Id;
            Id recordtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            //Map to be uses to get AccountID when Email is given for New Accounts
            Map<String, Account> emailToAccountMap = new Map<String, Account>();
            
            //Create a list of All cases which have entered the System and require to be update
            List<Case> casesToUpdate = new List<Case>();
            
            //PKL
            Set<String> caseSuppliedEmails = new Set<String>();
            
            //Create accounts for new case contacts and map accounts to case emails
            for (Case caseObj : cases) {
                if (String.isNotBlank(caseObj.SuppliedEmail)) {
                    caseSuppliedEmails.add(caseObj.SuppliedEmail);
                    
                    if (!takenEmails.contains(caseObj.SuppliedEmail.toLowerCase())) {
                        //String[] nameParts= caseObj.SuppliedName.split(' ',2);
                        String nampart = caseObj.SuppliedName;
                        if (nampart == '' || nampart == null) {
                            String[] blankName = caseObj.SuppliedEmail.split('@');
                            nampart = blankName[0];
                        }
                        Account newAccount = new Account(
                            FirstName = caseObj.SuppliedCompany,
                            lastname = nampart,
                            Customer_Email__pc = caseObj.SuppliedEmail.toLowerCase(),
                            recordtypeid = recordtype
                        );
                        
                        List<String> nameParts = new List<String>();
                        
                        if (nampart.length() == 1) {
                            newAccount.LastName = nampart;
                        } else if (nampart.length() > 1) {
                            if (nameParts.size() == 2) {
                                newAccount .LastName = nameParts[1];
                            }
                            if (nameParts.size() == 3) {
                                newAccount .LastName = nameParts[1] + nameParts[2];
                            }
                            if (nameParts.size() == 4) {
                                newAccount .LastName = nameParts[1] + nameParts[2] + nameParts[3];
                            }
                            if (nameParts.size() == 5) {
                                newAccount .LastName = nameParts[1] + nameParts[2] + nameParts[3] + nameParts[4];
                            }
                            if (nameParts.size() > 5) {
                                newAccount .LastName = nameParts[1] + nameParts[2] + nameParts[3] + nameParts[4] + nameParts[5];
                            }
                            
                        }
                        emailToAccountMap.put(caseObj.SuppliedEmail.toLowerCase(), newAccount);
                    }
                    casesToUpdate.add(caseObj);
                }
            }
            //Create List of New Accounts to be used with Insert and Query to fetch Contact
            List<Account> newAccount1 = emailToAccountMap.values();
            insert newAccount1;
            
            //create a list of new contacts created.
            List<Contact> newContacts = [SELECT Id, name, accountId, Email, Customer_Email__c FROM contact where AccountId in :newAccount1];
            
            //Map the new contacts to case emails
            Map<String, Contact> emailToContactMap = new Map<String, Contact>();
            for (Contact con : [SELECT Id, Name, AccountId, Email, Customer_Email__c FROM Contact WHERE Email IN :caseSuppliedEmails]) {
                emailToContactMap.put(con.Email.toLowerCase(), con);
            }
            
            // Link the cases to corresponding Contacts
            for (Case caseObj1 : casesToUpdate) {
                // link new contacts
                if (caseObj1.SuppliedEmail != '' && caseObj1.SuppliedEmail != null) {
                    String email = caseObj1.SuppliedEmail.toLowerCase();
                    Contact cont = emailToContactMap.get(email);
                    if (cont != null) {
                        caseObj1.ContactId = Cont.Id;
                    }
                    // link existing .........
                    Id account = ExistingemailToAccountMap.get(email);
                    if (account != null) {
                        caseObj1.AccountId = account;
                    }
                }
            }
    }
    
}