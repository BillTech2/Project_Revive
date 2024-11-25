public class compensationCustomerNameUpdate {

     //For Compensation [Bank Transfer] records validations , [Jira  Id : SFDCI-789]
     
    @InvocableMethod ()
    public Static void UpdateCustName(List<Id> ids){ 
        system.debug('compIds : '+ids );
		List<Compensation__c> CompList = [SELECT Id,Name,CustomerC__r.Customer_Email__c,CustomerC__r.LastName,CustomerC__r.FirstName,
                                          CustomerC__c,Bank_Account_Name__c,RecordType.Name,Paypal_email__c FROM Compensation__c where id in :ids];
		system.debug('CompList : '+CompList );

		Contact contactObj;
        List<Compensation__c> CompensationList = new List<Compensation__c> ();
        if(CompList != null ){
            for(Compensation__c compObj :  CompList){
                system.debug('compObj : '+compObj );
                contactObj = new Contact();
                
                String lastName = compObj.CustomerC__r.LastName != null ? compObj.CustomerC__r.LastName : '' ; 
                String firstName = compObj.CustomerC__r.FirstName != null ? compObj.CustomerC__r.FirstName : '';
                String paypalEmail = compObj.Paypal_email__c != null ? compObj.Paypal_email__c : '';
                system.debug(' contactObj.custname : '+ (firstName+''+lastName).deleteWhitespace().toLowerCase() );
                
                if((firstName+''+lastName).deleteWhitespace().toLowerCase().contains('missingsurname')){

                    //if Customer name equals Missing Surname, deriving the customer name from bank account name or paypal email
                	if(compObj.RecordType.Name == 'Bank Transfer'){
                        contactObj.LastName = (compObj.Bank_Account_Name__c).replaceAll('[0-9!#$%&\'*+/=?^_`{|}~@"]', '');
                    	contactObj.FirstName = '';

                	}else if(compObj.RecordType.Name == 'Paypal'){
                        contactObj.LastName = (paypalEmail.split('@').get(0)).replaceAll('[0-9!#$%&\'*+/=?^_`{|}~@"]', '');
                    	contactObj.FirstName = '';
                	}
                }else{
                    //Removing special characters and numbers from customer name
                 	if(compObj.CustomerC__r.LastName != null ){
                     	contactObj.LastName = compObj.CustomerC__r.LastName.replaceAll('[0-9!#$%&\'*+/=?^_`{|}~@"]', '');
                 	}

                 	if(compObj.CustomerC__r.FirstName != null ){
                 		contactObj.FirstName = compObj.CustomerC__r.FirstName.replaceAll('[0-9!#$%&\'*+/=?^_`{|}~@"]', '');
                 	}
                
                }
                
                 system.debug('contactObj.LastName  : '+contactObj.LastName  );
                 system.debug('contactObj.FirstName  : '+contactObj.FirstName  );

                
               
                contactObj.id = compObj.CustomerC__c;
                CompensationList.add(compObj);
                update contactObj;
            }
            update CompensationList;
        }
    }

}