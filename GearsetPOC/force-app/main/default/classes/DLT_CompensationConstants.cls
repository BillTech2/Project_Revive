public class DLT_CompensationConstants {
    public static final String COMP_APPROVAL_STATUS_AWAITING= 'Awaiting Approval';
    public static final String COMP_APPROVAL_STATUS_APPROVED = 'Approved';
    public static final String COMP_APPROVAL_STATUS_REJECTED = 'Rejected';

    public static final String COMP_CLAIM_STATUS_NOTSTARTED = 'Not Started';
    public static final String COMP_CLAIM_STATUS_INPROGRESS = 'In Progress';
    public static final String COMP_CLAIM_STATUS_CLAIMED = 'Claimed';

    public static final String COMP_REFUND_TYPE_GOODWILL = 'Goodwill';

    public static final String COMP_RECORDTYPE_BANK = 'Bank Transfer';
    public static final String COMP_RECORDTYPE_VOUCHER = 'Voucher';
    public static final String COMP_RECORDTYPE_PAYPAL = 'Paypal';
    public static final String COMP_RECORDTYPE_POINTS = 'Points';
    public static final String COMP_RECORDTYPE_ONLINE = 'Online';

    public static final String COMP_GOODWILL_COMPENSATION = 'Goodwill Compensation';
    public static final String COMP_PRR = 'PRR';

    public static final String COMP_SERVICE_RECOVERY_RULE = 'ServiceRecoveryRule';

    public static final String COMP_EVOUCHER_YES = 'Yes';
    public static final String COMP_EVOUCHER_NO = 'No';

    public static final String COMP_VOUCHER_TYPE = 'Goodwill';

    public static final String COMP_CURRENCY_GBP = 'GBP';

    public static final Id RECORD_TYPE_ID_POINTS = Schema.SObjectType.Compensation__c.getRecordTypeInfosByName().get(COMP_RECORDTYPE_POINTS).getRecordTypeId();
    public static final Id RECORD_TYPE_ID_VOUCHER = Schema.SObjectType.Compensation__c.getRecordTypeInfosByName().get(COMP_RECORDTYPE_VOUCHER).getRecordTypeId();

    public static final String CARRIER_BLUE = 'Blue';
    public static final String CARRIER_RED = 'Red';

}