public with sharing class AccountingSyncMapping {
	public static final Map<String, String> ACCOUNTING_OBJECT_NAME_MAPPING = new Map<String, String> {
		AccountingSyncHelper.ACCOUNT_FORGOT_PASSWORD_OBJECT_NAME => 'data',
		AccountingSyncHelper.ACCOUNT_WELCOME_EMAIL_OBJECT_NAME => 'data',
		AccountingSyncHelper.ACCOUNT_OBJECT_NAME => 'account',
		AccountingSyncHelper.CONTACT_OBJECT_NAME => 'contact',
		AccountingSyncHelper.CREDIT_CARD_OBJECT_NAME => 'creditCard',
		AccountingSyncHelper.TICKET_OBJECT_NAME => 'ticket',
		AccountingSyncHelper.FAVOURITE_TRAVELLER_OBJECT_NAME => 'favouriteTraveller'
	};

	public static final Map<String, String> TIKET_STATION_FIELD_MAPPING = new Map<String, String> {
		'Origin__c' => 'originUic',
		'Destination__c' => 'destinationUic',
		'Non_Eurostar_Origin__c' => 'nonEurostarOriginUic',
		'Non_Eurostar_Destination__c' => 'nonEurostarDestinationUic'
	};

	private static final Map<String, String> ACCOUNT_EMAILS_FIELD_MAPPING = new Map<String, String> {
		'emailAddress' => 'Customer_Email__pc',
		'preferredLanguage' => 'Preferred_Language__pc',
		'customerNumber' => 'Customer_Id__pc',
		'id' => 'Id'
	};

	private static final Map<String, String> ACCOUNT_MAPPING = new Map<String, String> {
		'salesforceCustomerId' => 'Id',
		'customerNumber' => 'Customer_Id__pc',
		'countryOfResidence' => 'Country_of_Residence__pc',
		'dateOfBirth' => 'PersonBirthdate',
		'familyName' => 'LastName',
		'gender' => 'Gender__pc',
		'givenName' => 'FirstName',
		'preferredLanguage' => 'Preferred_Language__pc',
		'title' => 'PersonTitle',
		'phoneNumber' => 'PersonHomePhone',
		'salesforceAccountType' => 'Salesforce_Account_Type__c',
		'salesforceAccountStatus' => 'Salesforce_Account_Status__c',
		'enrollmentSource' => 'AccountSource',
		'membershipNumber' => 'DELTA_Loyalty_Member__r.MembershipNumber'
	};

	private static final Map<String, String> CONTACT_MAPPING = new Map<String, String> {
		'salesforceCustomerId' => 'Id',
		'customerNumber' => 'Customer_Id__pc',
		'emailAddress' => 'Customer_Email__pc',
		'addressLine1' => 'BillingStreet',
		'townCity' => 'BillingCity',
		'country' => 'BillingCountry',
		'region' => 'BillingState',
		'postCode' => 'BillingPostalCode',
		'meal' => 'Meal_Preference__pc',
		'seat' => 'Seat_Preference__pc',
		'communication' => 'Email_Opt_In__pc',
		'nominatedPerson' => 'Authorization_Name_One__pc',
		'nominatedPwd' => 'Password_Hint_One__pc'
	};

	private static final Map<String, String> CREDIT_CARD_MAPPING = new Map<String, String> {
		'salesforceCustomerId' => 'Account__c',
		'cardToken' => 'Name',
		'expiryDate' => 'Expiry_Date__c',
		'cardType' => 'Card_Type__c',
		'cardHolderName' => 'Cardholder_Name__c',
		'addressLine1' => 'Billing_Address_Line_1__c',
		'addressLine2' => 'Billing_Address_Line_2__c',
		'townCity' => 'Billing_City__c',
		'region' => 'Billing_Region__c',
		'country' => 'Billing_Country__c',
		'postcodeZipCode' => 'Billing_Postcode__c',
		'sortOrder' => 'Sort_order__c'
	};

	private static final Map<String, String> TICKET_MAPPING = new Map<String, String> {
		'salesforceCustomerId' => 'Booker__r.Id',
		'eventDate' => 'Booking_DateTime__c',
		'pnr' => 'PNR__c',
		'tcn' => 'PNR_Ticket__c',
		'departureDateTime' => 'Travel_DateTime__c',
		'origin' => 'Origin__c',
		'nonEurostarOrigin' => 'Non_Eurostar_Origin__c',
		'destination' => 'Destination__c',
		'nonEurostarDestination' => 'Non_Eurostar_Destination__c',
		'originalCurrency' => 'Original_Currency__c',
		'classOfService' => 'Class_of_Service__c',
		'fbc' => 'FBC__c',
		'passengerTitle' => 'Title__c',
		'passengerFirstname' => 'First_Name__c',
		'passengerLastname' => 'Last_Name__c',
		'bookerTitle' => 'Booker__r.PersonTitle',
		'bookerFirstname' => 'Booker__r.FirstName',
		'bookerLastname' => 'Booker__r.LastName',
		'pointOfSale' => 'Point_of_Sale__c',
		'delayMins' => 'Delay_mins__c',
		'ticketCancelled' => 'Cancelled_By_Customer__c',
		'ticketPrice' => 'Ticket_Price__c',
		'trainCancelled' => 'Cancelled__c',
		'checkedIn' => 'Checked_In__c',
		'oassisAuditRef' => 'Oassis_Audit_Reference__c'
	};

	private static final Map<String, String> FAVOURITE_TRAVELLER_MAPPING = new Map<String, String> {
		'salesforceCustomerId' => 'Account__c',
		'title' => 'Title__c',
		'firstName' => 'First_Name__c',
		'lastName' => 'Name',
		'mealPreference' => 'Meal_Preference__c',
		'membershipNumber' => 'Membership_Number__c',
		'seatPreference' => 'Seat_Preference__c',
		'emailAddress' => 'Email__c',
		'phoneNumber' => 'Phone_Number__c',
		'sortOrder' => 'Sort_order__c'
	};

	public static Map<String, String> getMappingFor(String sObjectName) {
		Map<String, String> mapping;
		if (sObjectName.equalsIgnoreCase(AccountingSyncHelper.ACCOUNT_FORGOT_PASSWORD_OBJECT_NAME) ||
			sObjectName.equalsIgnoreCase(AccountingSyncHelper.ACCOUNT_WELCOME_EMAIL_OBJECT_NAME)) {
			mapping = ACCOUNT_EMAILS_FIELD_MAPPING;
		}
		if (sObjectName.equalsIgnoreCase(AccountingSyncHelper.ACCOUNT_OBJECT_NAME)) {
			mapping = ACCOUNT_MAPPING;
		}
		if (sObjectName.equalsIgnoreCase(AccountingSyncHelper.CONTACT_OBJECT_NAME)) {
			mapping = CONTACT_MAPPING;
		}
		if (sObjectName.equalsIgnoreCase(AccountingSyncHelper.CREDIT_CARD_OBJECT_NAME)) {
			mapping = CREDIT_CARD_MAPPING;
		}
		if (sObjectName.equalsIgnoreCase(AccountingSyncHelper.TICKET_OBJECT_NAME)) {
			mapping = TICKET_MAPPING;
		}
		if (sObjectName.equalsIgnoreCase(AccountingSyncHelper.FAVOURITE_TRAVELLER_OBJECT_NAME)) {
			mapping = FAVOURITE_TRAVELLER_MAPPING;
		}
		if (mapping != null) {
			return mapping.clone();
		}
		return null;
	}
}