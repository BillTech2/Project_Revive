public class DLT_CaseConstants {
    //Record Type Names
    public static final String RT_DEV_NAME_NEW_STANDARD_CASE = 'New_Standard_Case';
    public static final String RT_DEV_NAME_E4A_SUBSCRIBER_REQUEST = 'E4A_Subscriber_Request';
    public static final String RT_NAME_GROUP_BOOKING_CASE = 'Group Booking Case';
    public static final String RT_NAME_B2B_GROUP_BOOKING_CASE = 'B2B_group_booking';
    public static final String RT_NAME_GDS_HELPDESK = 'GDS_Helpdesk';
    public static final String RT_DEV_NAME_GROUP_BOOKING_CASE = 'Group_Booking_Case';

    // Record Type IDs
    public static final String RT_ID_NEW_STANDARD_CASE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_DEV_NAME_NEW_STANDARD_CASE).getRecordTypeId();
    public static final String RT_ID_E4A_SUBSCRIBER_REQUEST = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_DEV_NAME_E4A_SUBSCRIBER_REQUEST).getRecordTypeId();
    public static final String RT_ID_B2B_GROUP_BOOKING_CASE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_NAME_B2B_GROUP_BOOKING_CASE).getRecordTypeId();
    public static final String RT_ID_GDS_HELPDESK = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_NAME_GDS_HELPDESK).getRecordTypeId();
    public static final String RT_ID_GROUP_BOOKING_CASE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_DEV_NAME_GROUP_BOOKING_CASE).getRecordTypeId();

    //Dates
    public static final Date DATE_LAST_6_MONTH = Date.today().addMonths(-6);

    //Carrier__c values
    public static final String CARRIER_PURPLE = 'Purple';
    public static final String CARRIER_BLUE = 'Blue';
    public static final String CARRIER_RED = 'Red';
    public static final Set<String> BOTH_CARRIERS = new Set<String>{
        CARRIER_BLUE,
        CARRIER_RED
    };

    public static final String CUSTOMER_TYPE_SOCIAL_MEDIA = 'Social media - please review';
    public static final String CUSTOMER_TYPE_SPECIAL_ASSISTANCE = 'Special Assistance';

    public static final String CUSTOMER_STRUGGLE_SYSTEM = 'System - please review';
    public static final String CUSTOMER_STRUGGLE_WEBFORM = 'Webform case - please review';

    public static final String CATEGORY_DOCUMENT_REQUEST = 'Document request';
    public static final String CATEGORY_SYSTEM = 'System - please review';
    public static final String CATEGORY_PRE_TRAVEL = 'Pre Travel';

    public static final String TOPIC_TRAVEL_PROOF = 'Travel Proof';
    public static final String TOPIC_TRAVEL_SYSTEM = 'System - please review';
    public static final String TOPIC_URGENT_ASSISTANCE = 'Urgent special assistance';

    public static final String WHAT_IS_THE_QUESTION_PROOF_OF_CANCELATION = 'Proof of cancellation';
    public static final String WHAT_IS_THE_QUESTION_PROOF_OF_DISRUPTION = 'Proof of disruption';
    public static final String WHAT_IS_THE_QUESTION_PROOF_OF_TRAVEL = 'Proof of travel';
    public static final String WHAT_IS_THE_QUESTION_SYSTEM = 'System - please review';
    public static final String WHAT_IS_THE_QUESTION_PRM = 'PRM Notification';

    //Origin values
    public static final String ORIGIN_EMAIL_RED = 'Email (Red)';
    public static final String ORIGIN_EMAIL_BLUE = 'Email (Blue)';
    public static final String ORIGIN_BRANDWATCH = 'Brandwatch';
    public static final String ORIGIN_E4A = 'E4A';
    public static final String ORIGIN_TACT = 'TACT';
    public static final String ORIGIN_PRM = 'PRM Notification';
    public static final String ORIGIN_WEB = 'Web';

    //Booking Type values
    public static final String BOOKING_TYPE_THIRD_PARTY_BOOKING = '3rd party booking';
    public static final String BOOKING_TYPE_ASSISTANCE = 'Assistance';
    public static final String BOOKING_TYPE_CHILD_ADD_ON_BOOKING = 'Child Add on booking';
    public static final String BOOKING_TYPE_CONCESSION_FARE = 'Concession fare';
    public static final String BOOKING_TYPE_CUSTOMER_ROOM_BOOKINGS = 'Customer room bookings';
    public static final String BOOKING_TYPE_GENERAL_QUERY = 'General Query';
    public static final String BOOKING_TYPE_GIFT_CERTIFICATE_PRIZEWINNER = 'Gift certificate/Prizewinner';
    public static final String BOOKING_TYPE_GIFT_HOTEL_ONLY = 'Hotel only';
    public static final String BOOKING_TYPE_LAST_MINUTE = 'Last-Minute';
    public static final String BOOKING_TYPE_MUSICAL_INSTRUMENT = 'Musical Instrument';
    public static final String BOOKING_TYPE_PACKAGE = 'Package';
    public static final String BOOKING_TYPE_PASSHOLDER_FARE = 'Passholder fare';
    public static final String BOOKING_TYPE_POINTS_BOOKING = 'Points Booking';
    public static final String BOOKING_TYPE_PUBLIC_BOOKING = 'Public Booking';
    public static final String BOOKING_TYPE_SPECIALIST_FARE_OR_PROMO = 'Specialist fare or Promo';
    public static final String BOOKING_TYPE_STAFF_TRAVEL = 'Staff travel';
    public static final String BOOKING_TYPE_SUNDRY_ANCILLARY = 'Sundry/Ancillary';
    public static final String BOOKING_TYPE_TRADE_BOOKING = 'Trade booking';

    //Contact From values
    public static final String CONTACT_FROM_SOCIAL_MEDIA = 'Social Media';

    //Reason for Contact values
    public static final String REASON_FOR_CONTACT_FEEDBACK = 'Feedback';

    //Initial Reason for Contact values
    public static final String INITIAL_REASON_FOR_CONTACT_FEEDBACK = 'Feedback';
    public static final String INITIAL_REASON_FOR_CONTACT_ROOM_BOOKING = 'Customer Room Booking';
    public static final String INITIAL_REASON_FOR_CONTACT_SOCIAL_MEDIA = 'Social media - please review';
    public static final String INITIAL_REASON_FOR_CONTACT_INFOADVICE = 'Info or Advice or Confirmation';

    //Public Groups names
    public static final String GROUP_ECC_CUSTOMER_CARE = 'ECC_Customer_Care';
    public static final String GROUP_CUSTOMER_CARE_FRENCH = 'Customer_Care_French';
    public static final String GROUP_CUSTOMER_CARE_DUTCH = 'Customer_Care_Dutch';

    //Language values
    public static final String LANGUAGE_FRENCH = 'French';
    public static final String LANGUAGE_DUTCH = 'Dutch';

    //Preferred_Language__c values
    public static final String PREF_LANG_EN = 'English';
    public static final String PREF_LANG_DE = 'German';
    public static final String PREF_LANG_FR = 'French';
    public static final String PREF_LANG_NL = 'Dutch';

    //Status values
    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_REOPENED = 'Reopened';
    public static final String STATUS_AWAITING_INTERNAL = 'Awaiting Internal';
    public static final String STATUS_AWAITING_CUSTOMER = 'Awaiting Customer';

    //Case Sub Status values
    public static final String SUB_STATUS_CASE_COMMENT_RECEIVED = 'Case Comment Received';
    public static final String SUB_STATUS_CUSTOMER_RESPONDED = 'Customer Responded';
    public static final String SUB_STATUS_COMPENSATION_PENDING= 'Compensation pending';
    public static final String SUB_STATUS_COMPENSATION_APPROVED = 'Compensation approved';
    public static final String SUB_STATUS_COMPENSATION_REJECTED = 'Compensation rejected';

    //Group Booking Status values
    public static final String GROUP_BOOKING_STATUS_QUOTE = 'Quote';
    public static final String GROUP_BOOKING_STATUS_PROVISIONAL = 'Provisional';
    public static final String GROUP_BOOKING_STATUS_DEPOSIT_TAKEN = 'Deposit taken';
    public static final String GROUP_BOOKING_STATUS_PAID = 'Paid';

    public static final List<String>  GROUP_BOOKING_ACTIVE_STATUSES = new List<String> {
        GROUP_BOOKING_STATUS_QUOTE,
        GROUP_BOOKING_STATUS_PROVISIONAL,
        GROUP_BOOKING_STATUS_DEPOSIT_TAKEN,
        GROUP_BOOKING_STATUS_PAID
    };

    public static final String BUSINESS_HOURS_NAME_SERVICE_DESK_HOURS = '24x7x365 Service Desk Hours';

    public static final String ENTITLMENT_NAME_CASE_PRODUCTIVITY = 'Case Productivity';
    public static final String ENTITLMENT_TYPE_DELTA_SUPPORT = 'Delta Support';
    public static final String ENTITLMENT_STATUS_ACTIVE = 'Active';

    public static final Map<String,String> APPROVAL_STATUS_TO_SUBSTATUS_MAP = new Map<String,String>{
        DLT_CompensationConstants.COMP_APPROVAL_STATUS_AWAITING => DLT_CaseConstants.SUB_STATUS_COMPENSATION_PENDING,
        DLT_CompensationConstants.COMP_APPROVAL_STATUS_APPROVED => DLT_CaseConstants.SUB_STATUS_COMPENSATION_APPROVED,
        DLT_CompensationConstants.COMP_APPROVAL_STATUS_REJECTED => DLT_CaseConstants.SUB_STATUS_COMPENSATION_REJECTED
    };

    public static final String SUBJECT_E4A = 'E4A Newsletter Registration';
    public static final String SUBJECT_E4A_UNSUBSCRIBE = 'E4A Unsubscribe';
    public static final String SUBJECT_PRM = 'PRM Notification';

    public static final Set<String> E4A_SUBJECTS = new Set<String>{
        SUBJECT_E4A,
        SUBJECT_E4A_UNSUBSCRIBE
    };

    public static final String E4A_SUBSCRIBER_STATUS_APPROVED = 'Approved';

    public static final String SUNDRY_URGENT_ASSISTANCE = 'Urgent assistance';

    public static final String EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_EN = 'Welcome_email_EN';
    public static final String EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_DE = 'Welcome_email_DE';
    public static final String EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_FR = 'Welcome_email_FR';
    public static final String EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_NL = 'Welcome_email_NL';

    public static final String EMAIL_TEMPLATE_DEVNAME_GENERIC_HELP_AND_FAQS_1 = 'Generic_Help_and_FAQs_1';
    public static final String EMAIL_TEMPLATE_DEVNAME_LASTMINUTE_FAQS = 'Last_minute_FAQs';

}