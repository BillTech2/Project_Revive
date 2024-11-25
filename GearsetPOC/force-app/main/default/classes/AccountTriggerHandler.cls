public class AccountTriggerHandler {
    
    public static void onBeforeInsert(List<Account> accountList){
        populateCustomerEmail(accountList);
        handleContactNumberParsing(accountList);
    }
    
    public static void onBeforeUpdate(List<Account> accountList, Map<Id, Account> oldAccountMap){
        // SyncAccountGroupOptTrain.sync(accountList, oldAccountMap);
        handleContactNumberParsing(accountList);
    }
    
    public static void onAfterUpdate(List<Account> accountList, Map<Id, Account> oldAccountMap){
        // populateLoyaltyMember(accountList, oldAccountMap);
    }
    
    // Main purpose is to populate Customer_Email__pc with account.PersonEmail value
    // during standard Quick Create action
    private static void populateCustomerEmail(List<Account> accountList){
        if(System.isFuture() || System.isBatch()) return;
        
        for (Account account: accountList) {
            if (String.isNotBlank(account.PersonEmail)) {
                if (account.Customer_Email__pc == null || String.isBlank(account.Customer_Email__pc)) {
                    account.Customer_Email__pc = account.PersonEmail;
                }
            }
        }
    }
    
    //commented out as it contains deprecated loyalty

    // private static void populateLoyaltyMember(List<Account> accountList, Map<Id, Account> oldAccountMap){
    //     if(System.isFuture() || System.isBatch()) return;
        
    //     Set<Id> accountSet = new Set<Id>();
    //     for (Account account: accountList) {
    //         if (String.isNotBlank(account.Membership_Number__pc) &&
    //             String.isBlank(account.Loyalty_Member__c) && // we don't have to run this trigger while creating New Loyalty Member from UI
    //             account.membership_Number__pc != oldAccountMap.get(account.Id).membership_Number__pc) {

	// 			accountSet.add(account.Id);
	// 		}
    //     }
    //     if (!accountSet.isEmpty()) {
    //         LoyaltyInfoPopulateHelper.populateLoyaltyMember(accountSet);
    //     }
    // }
    
    /**
    * @description: to initiate Contact Number parsing, called from AccountTrigger on before insert/update event
    * @return void
    * @param triggerNew: list of account records to insert/update
    */
    public static void handleContactNumberParsing(List<Account> triggerNew) {
        PhoneNumberUtil phoneUtil = PhoneNumberUtil.getInstance();
        parseCompAppRawTelephoneNumber(triggerNew, phoneUtil);
    }

    /**
    * @description: to parse raw telephone number captured on Contact Us page of Compensation App
    * @return void
    * @param triggerNew: list of all account records to insert
    * @param phoneUtil: instance of phone number parsing utility
    */
    private static void parseCompAppRawTelephoneNumber(List<Account> triggerNew, PhoneNumberUtil phoneUtil) {

        for (Account account : triggerNew) {
            PhoneNumber parsedNumber;
            if (!String.isEmpty(account.Contact_Number__c)) {
                account.Raw_Telephone_Number__c = account.Contact_Number__c;
                parsedNumber = phoneUtil.parseAndValidateUsingCorrectionAlgo(account.Contact_Number__c);
                account.Contact_Number__c = null;
                if (parsedNumber.countryCode != 0 && parsedNumber.nationalNumber != 0) {
                    account.Contact_Number__c = String.valueOf(parsedNumber.countryCode) + ' ' + parsedNumber.nationalNumber;
                }
            }
        }
    }
}