public without sharing class DLT_ContactTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                handlePersonAccountCreation(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                handlePersonAccountLinking(Trigger.new);
            }

            if (System.Trigger.isUpdate) {

            }
        }
    }


    private static void handlePersonAccountCreation(List<Contact> newRecords) {

        if(!DLT_Constants.IS_INTEGRATION_USER) return;

        Map<String, Id> contIdAccountMap = new Map<String, Id>();
        List<Account> newAccounts = new List<Account>();

		for (Contact newContact : newRecords){
            if (newContact.AccountId == null) {
                newAccounts.add(new Account(Name = newContact.FirstName + newContact.LastName));
            }
		}

        insert newAccounts;

        for (Account accRecord : newAccounts) {
            contIdAccountMap.put(accRecord.Name, accRecord.Id);
        }

        for (Contact newContact : newRecords) {
            if (newContact.AccountId == null) {
                newContact.AccountId = contIdAccountMap.get(newContact.FirstName + newContact.LastName);
            }
        }
    }

    private static void handlePersonAccountLinking(List<Contact> newRecords) {

        if(!DLT_Constants.IS_INTEGRATION_USER) return;

	    Map<Id, Account> accountsMap = new Map<Id, Account>([
            SELECT Id, Name 
            FROM Account 
            WHERE Id IN (
                SELECT AccountId 
                FROM Contact 
                WHERE Id IN :newRecords)
        ]);

        List<Account> accountsToUpdate = new List<Account>();
        for(Contact c : newRecords){
            if(accountsMap.get(c.AccountId).Name != c.FirstName + c.LastName) return;
            accountsToUpdate.add(new Account(
                Id = c.AccountId, 
                RecordTypeId = DLT_CustomerConstants.RT_ID_PERSON_ACCOUNT
            ));
        }

        update accountsToUpdate;
    }
}