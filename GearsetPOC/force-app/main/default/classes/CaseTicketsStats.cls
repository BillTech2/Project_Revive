public class CaseTicketsStats {

    public static final String INCORRECT_EMAIL          = 'Invalid Claim Email - incorrect email';
    public static final String NO_EMAIL                 = 'No Email on Booking';
    public static final String GROUPS                   = 'Group Bookings';
    public static final String WHEELCHAIR               = 'Wheelchair Bookings';
    public static final String PACKAGES                 = 'Package Bookings';
    public static final String INTERLINING              = 'Interlining Bookings';
    public static final String ZERO_VALUE               = 'Zero Value Bookings';
    public static final String BAD_CURRENCY             = 'Unsupported Currency';
    public static final String PARTIAL                  = 'Partial Bookings';
    public static final String COMPENSATED              = 'No Exclusion - Eligible';
    public static final String OUT_OF_SCOPE             = 'Out of Scope';
    public static final String INVALID_PNR              = 'PNR Not Valid';
    public static final String DUPLICATE                = 'Duplicate';
    public static final String COMPENSATED_ALL          = 'Already Compensated';
    public static final String RIT                      = 'RIT Bookings';
    public static final String NON_EUROSTAR_POS         = 'Non Eurostar POS';
    public Map<Id, Integer> ticketsStates;
    public Date claimDate;
    public DateTime claimDateTime;

    public Integer ticketsTotal                             = 0;
    public Integer ticketsActive                            = 0;
    public Integer ticketsHasCompRecord                     = 0;
    public Integer ticketsOutOfScope                        = 0;
    public Integer ticketsZeroPriced                        = 0;
    public Integer ticketsInClaimedScope                    = 0;
    public Integer ticketsUnsupportedCurrency               = 0;
    public Integer ticketsPartial                           = 0;
    public Integer ticketsInterliningBooking                = 0;
    public Boolean isIdentityConfirmed                      = false;
    public Boolean isThereAtLeastOneEmail                   = false;
    public Boolean isValidatedByEmail                       = false;
    public Integer groupBookingsCnt                         = 0;
    public Integer packageBookingsCnt                       = 0;
    public Integer interliningBookingsCnt                   = 0;
    public Integer wheelchairBookingsCnt                    = 0;
    public Integer eligibleTickets                          = 0;
    public Integer eligibleTicketsInClaimedScope            = 0;
    public Integer eligibleCompensatedTicketsInClaimedScope = 0;
    public Boolean excludedFromAutomation                   = false;
    public String  automationExclusionMainReason            = null;
    public Boolean containsFullJourney                      = false;
    public Boolean isDisneyBooking                          = false;
    public Boolean isNotEligibleMessagePriority             = false;
    public Boolean isCaseCreated                            = true;
    public Boolean isThere60DaysRejectionReason             = false;
    public Boolean isThereClaimPastTravelRejectionReason    = false;
    public Boolean isThereCancelledTrainsPastTheScope       = false;
    public Boolean isTherePackageTrainsPastTheScope         = false;
    public Integer ritBookingsCnt                           = 0;
    public Integer eligibleTicketsInClaimedScopeAndValidPOS = 0;


    public CaseTicketsStats() {
        this.ticketsStates = new Map<Id, Integer>();
    }

}