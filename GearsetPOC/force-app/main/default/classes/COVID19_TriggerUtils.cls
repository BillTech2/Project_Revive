public without sharing class COVID19_TriggerUtils {

    public class CoronaVirus_NotEligibleException extends Exception{}

    public static final Id ONLINE_COMPENSATION_RECORD_TYPE_ID = CompApp_Utils.compensationOnlineRecTypeID;
    public static final Integer OUT_OF_SCOPE                 =        1;
    public static final Integer GROUP_BOOKING                =        2;
    public static final Integer PACKAGE_BOOKING              =        4;
    public static final Integer CHECKED_IN                   =        8;
    public static final Integer ZERO_PRICED                  =       16;
    public static final Integer CANCELLED                    =       32;
    public static final Integer OUTBOUND                     =       64;
    public static final Integer INBOUND                      =      128;
    public static final Integer IN_CLAIMED_SCOPE             =      256;
    public static final Integer EXCLUDED_FROM_AUTO           =      512;
    public static final Integer HAS_OUTBOUND_IN_SCOPE        =     1024;
    public static final Integer INTERLINING_BOOKINGS         =     2048;
    public static final Integer HAS_INBOUND_IN_SCOPE         =     4096;
    public static final Integer ACTIVE                       =     8192;
    public static final Integer UNSUPPORTED_CURRENCY         =    16384;
    public static final Integer PARTIAL                      =    32768;
    public static final Integer HAS_OUTBOUND_ACTIVE          =    65536;
    public static final Integer HAS_INBOUND_ACTIVE           =   131072;
    public static final Integer OUT_OF_SCOPE_BEFORE          =   262144;
    public static final Integer OUT_OF_SCOPE_AFTER           =   524288;
    public static final Integer HAS_ACTIVE_OUTBOUND_IN_SCOPE =  1048576;
    public static final Integer HAS_ACTIVE_INBOUND_IN_SCOPE  =  2097152;
    public static final Integer ALREADY_COMPENSATED          =  4194304;
    public static final Integer RIT_TYPE                     =  8388608;
    public static final Integer WHEELCHAIR_BOOKING           = 16777216;


    public static final Date GENERAL_SCOPE_BEGIN = COVID_Logic_Rules__c.getOrgDefaults().General_Journeys_Scope_Begin__c;
    public static final Date GENERAL_SCOPE_END = COVID_Logic_Rules__c.getOrgDefaults().General_Journeys_Scope_End__c;
    public static final Date DISNEY_SCOPE_BEGIN = COVID_Logic_Rules__c.getOrgDefaults().Disney_Journeys_Scope_Begin__c;
    public static final Date DISNEY_SCOPE_END = COVID_Logic_Rules__c.getOrgDefaults().Disney_Journeys_Scope_End__c;
    public static final Date SKI_SCOPE_BEGIN = COVID_Logic_Rules__c.getOrgDefaults().Ski_Journeys_Scope_Begin__c;
    public static final Date SKI_SCOPE_END = COVID_Logic_Rules__c.getOrgDefaults().Ski_Journeys_Scope_End__c;
    public static final Date POLICY_THRESHOLD_DATE = COVID_Logic_Rules__c.getOrgDefaults().Policy_Threshold_Date__c;
    public static final Date CANCELLED_SCOPE_BEGIN = COVID_Logic_Rules__c.getOrgDefaults().Cancelled_Trains_Scope_Begin__c;
    public static final Date CANCELLED_SCOPE_END = COVID_Logic_Rules__c.getOrgDefaults().Cancelled_Trains_Scope_End__c;
    public static final Date PACKAGE_SCOPE_BEGIN = COVID_Logic_Rules__c.getOrgDefaults().Package_Journeys_Scope_Begin__c;
    public static final Date PACKAGE_SCOPE_END = COVID_Logic_Rules__c.getOrgDefaults().Package_Journeys_Scope_End__c;

    public static final Id CORONAVIRUS_REASON_CODE_ID;

    public static final Id EMERGENCY_GUEST_USER_ID = [SELECT Id
                                                      FROM User
                                                      WHERE Name = 'Emergency Response Site Guest User' LIMIT 1].Id;

    public static final Id EMERGENCY_RECORD_OWNER_ID = [SELECT Name, GuestRecordDefaultOwnerId
                                                        FROM Site
                                                        WHERE Name = 'Emergency_Response' LIMIT 1].GuestRecordDefaultOwnerId;

    public static final Id GROUP_QUEUE_ID;
    public static final Id PACKAGE_QUEUE_ID;
    public static final Id RIT_QUEUE_ID;
    public static final Id OTHER_QUEUE_ID;

    //public static final Id CORONAVIRUS_QUEUE_ID = [SELECT Id
    //                                               FROM Group
    //                                               WHERE DeveloperName = 'Coronavirus_eVoucher_Req' LIMIT 1].Id;

    public static final Set<String> THIRD_PARTY_EMAILS = new Set<String>{'confirm@eurostar.com',
                                                                         'hello@loco2.com',
                                                                         'railtrade@stc.co.uk',
                                                                         'technical_support_sci@raileurope.com',

    'admin@instantbreaks.com', 'alistair.randall@gulliverstravel.co.uk', 'auto.ticketing@railplus.com.au',
    'booking@vlctravel.com', 'bookings@railtourguide.com', 'bookingslccvpfr@viptrip.com', 'capmonde.sncf@gmail.com',
    'concierge@ocspecial.com', 'confirmations@europeexpress.com', 'confirmations@keytravel.com', 'confirmations@magicbreaks.co.uk',
    'cooptraveladmin@cooptravel.co.uk', 'customer_service@egencia.co.uk', 'customerexperience@vjv.co.uk',
    'cvoyages.rts@orange.fr', 'dan.may@ffestiniogtravel.co.uk', 'dlp.transport.prod.rail@disney.com',
    'dorina@citeduvoyage.com', 'est-transport@euro-study-tours.co.uk', 'etap_uk@voyages-sncf.com',
    'eurostarprod@gmail.com', 'fit@jactravel.com', 'groundtransport@hb-ed.co.uk', 'grouptravel@reedmackay.com',
    'info@railbookers.com', 'irene_jaramillo@fr.loewe.com', 'itineraries@inghams.co.uk', 'joshua.evans@ffestiniogtravel.co.uk',
    'lee@thetravelbureau.co.uk', 'lonkso@jalpak.co.uk', 'lowcost@h24travel.com', 'lucas.gilles@wavestone.com',
    'marion.faure@wavestone.com', 'marius.gautier@wavestone.com', 'newbook@ohshu.com', 'nicole.alauzet@nacel.fr',
    'noemail@ecc.com', 'noemail@eurostar.com', 'ns@stedentrips.nl', 'ops@skiworld.co.uk', 'ops9f@crestaworldtravel.co.uk',
    'paris@voyagexpert.fr', 'rail@avantidestinations.com', 'rail@planetrail.co.uk', 'reservations@grj-independent.com',
    'reservations@osprey-holidays.co.uk', 'tech-reserved@klook.com', 'teresa@citeduvoyage.com', 'thalys@re4a.net',
    'travel.desk@keplercheuvreux.com', 'trens@ttoperadora.com.br', 'trips@travelperk.com', 'uktravel@amexgbt.com',
    'valentin.cressens@wavestone.com', 'wdtc-ukair@disney.com', 'yj@envol-espace.fr'};

    public static final Set<String> THIRD_PARTY_EMAIL_DOMAINS = new Set<String>{'@alias.trainline.com',
                                                                           '@x.trainline.eu'};

    public static final List<String> VALID_POS_LIST = new List<String> {
            'EIL stations',
            'EIL_DIGITAL',
            'EUROSTAR',//'Eurostar'
            'MIGRATION',
            'Not known', //'not known'
            'BACKOFFICE'
    };

    public static final Set<String> FRENCH_STATIONS;



    public static List<Ticket__c> relatedTickets { get; set; }
    public static Set<Id> excludedTickets { get; set; }
    public static Map<Id, Id> TicketsToCompensations  { get; set; }
    public static Map<Id, Id> TicketsToPendingCompensations { get; set; }
    public static Map<Id, Id> TicketsToSuccessfulCompensations { get; set; }
    public static Map<Id, Id> TicketsToFailedCompensations { get; set; }
    public static Map<Id, Id> CompensationsToTickets { get; set; }
    public static Map<Id, Compensation__c> relatedCompensationsMap { get; set; }
    public static List<Compensation__c> relatedCompensations { get; set; }
    public static Map<String, CaseTicketsStats> statsByPNR { get; set; }
    public static Set<String> excludedPNRs { get; set; }
    public static Boolean batchMode { get; set; }

    static {
        List<Reason_Code__c> codes = [SELECT Id FROM Reason_Code__c WHERE en_Label__c = 'Coronavirus (COVID-19)'];
        if (codes.size() > 0) {
            CORONAVIRUS_REASON_CODE_ID = codes[0].Id;
        } else {
            CORONAVIRUS_REASON_CODE_ID = null;
        }
        FRENCH_STATIONS = new Set<String>();
        List <Stations__c> stations = [SELECT Full_Station_s_name__c FROM Stations__c WHERE Station_Code_5_Letter__c LIKE 'FR%'];
        for (Stations__c station : stations) {
            FRENCH_STATIONS.add(station.Full_Station_s_name__c);
        }
        List<Group> queues = [SELECT Id, DeveloperName
                              FROM Group
                              WHERE (DeveloperName = 'Group_Bookings' OR
                                     DeveloperName = 'Package_Bookings' OR
                                     DeveloperName = 'RIT_Bookings' OR
                                     DeveloperName = 'Other') AND
                                     Type='Queue'];
        system.debug(queues);
        for (Group queue : queues) {
            if (queue.DeveloperName.startsWith('G')) GROUP_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.startsWith('P')) PACKAGE_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.startsWith('R')) RIT_QUEUE_ID = queue.Id;
            if (queue.DeveloperName.startsWith('O')) OTHER_QUEUE_ID = queue.Id;
        }
    }
    /**
    * @description fired on before insert event
    * @return void
    * @param insertedCases: trigger.new - list of all cases that were inserted
    * Converts online compensations for tickets bound to PNR from inserted case to eVoucher requests
    */
    public static void updateCasesWithTicketsValidityInfo(List<Case> insertedCases) {
        batchMode = System.isBatch();
        Map<String, Case> COVID19Cases = new Map<String, Case>();

        for (Case nextCase : insertedCases) {
            if (CORONAVIRUS_REASON_CODE_ID != null && ((nextCase.Reason_Code__c == CORONAVIRUS_REASON_CODE_ID) || Test.isRunningTest()) &&
                nextCase.Status != 'Closed' /* null here(before insert) && nextCase.CreatedById == EMERGENCY_GUEST_USER_ID*/
            ) {
                if ((UserInfo.getUserId() == EMERGENCY_GUEST_USER_ID) ||
                    (System.isQueueable() && nextCase.CreatedById == EMERGENCY_GUEST_USER_ID) ||
                    (System.isBatch() && nextCase.CreatedById == EMERGENCY_GUEST_USER_ID)
                ) {
                    COVID19Cases.put(nextCase.PNR__c, nextCase);
                }

            }
        }

        COVID19Cases.remove(null);
        COVID19Cases.remove('');

        if (COVID19Cases.size() > 0) {

            //select all tickets related to inserted cases via PNR
            //tickets is sorted in order to ease Outbound/Inbound finding
            List<Ticket__c> relatedTicketsRaw = [
                    SELECT Id, Name_Check__c, Departure_Date__c, PAX_Type_Filter__c, PAX_type_name__c, Checked_In__c,
                            Package_Booking__c, Cancelled_By_Customer__c, PNR__c, Name,
                            Email__c, Booker__r.PersonContactId, Booker__r.Customer_Email__pc, /*Train__r.Delay_in_Minutes__c,
                            Train__r.Departure_Date__c, */Ticket_Price__c, Original_Currency__c, Train__c, Coach__c,
                            Train__r.Train_Number__c, Origin__c, Destination__c, Disney__c, First_Name__c, Last_Name__c,
                            Non_Eurostar_Origin__c, Non_Eurostar_Destination__c, ETAP_Email__c, Departure_Time__c,
                            Train__r.Cancelled__c, Point_of_Sale__c, Departure_Date_Time_Format__c, PAX_Type_Description__c
                    FROM Ticket__c
                    WHERE PNR__c IN :COVID19Cases.KeySet() AND Departure_Date__c > :Date.today().addDays(-180) AND Etap_info_only__c = FALSE
                    ORDER BY PNR__c ASC, Name_Check__c ASC, Departure_Date__c ASC, Departure_Time__c ASC, Origin__c ASC
            ];


            Map<Id, Ticket__c> relatedTicketsMap = new Map<Id, Ticket__c>(relatedTicketsRaw);

            //select all junction tickets for cases related tickets
            List<Compensation_Ticket__c> relatedJunctionsRaw = [SELECT Compensation__c, Ticket__c
            FROM Compensation_Ticket__c
            WHERE Ticket__c in : relatedTicketsMap.keySet()];

            //build crisscross indexes
            TicketsToCompensations = new Map<Id,Id>();
            CompensationsToTickets = new Map<Id,Id>();
            for (Compensation_Ticket__c nexJunction : relatedJunctionsRaw) {
                TicketsToCompensations.put(nexJunction.Ticket__c, nexJunction.Compensation__c);
                CompensationsToTickets.put(nexJunction.Compensation__c, nexJunction.Ticket__c);
            }

            //select all compensation records related to tickets
            relatedCompensations = [SELECT Id, Claim_Status__c, Claimed_Compensation_Type__c,
                                           Last_Name__c, First_Name__c, Claim_Email__c,
                                           Voucher_Expiry_Date__c, Integration_Status__c, PNR__c, Case__r.CaseNumber
                                    FROM Compensation__c
                                    WHERE Id IN :CompensationsToTickets.KeySet() AND
                                          RecordTypeId = :ONLINE_COMPENSATION_RECORD_TYPE_ID AND
                                          (Integration_Status__c = 'Not Claimed' OR
                                           Integration_Status__c = 'Pending' OR
                                           Integration_Status__c = 'Success' OR
                                          (Integration_Status__c = 'Failed' AND Pre_Travel__c = TRUE))];

            relatedCompensationsMap = new Map<Id, Compensation__c>(relatedCompensations);

            //rebuild crisscross indexes to contain existing 'Not Started' online compensations links only
            TicketsToCompensations = new Map<Id,Id>();
            TicketsToPendingCompensations = new Map<Id,Id>();
            TicketsToSuccessfulCompensations = new Map<Id,Id>();
            TicketsToFailedCompensations = new Map<Id,Id>();
            CompensationsToTickets = new Map<Id,Id>(); //not used in part 2
            for (Compensation_Ticket__c nexJunction : relatedJunctionsRaw) {
                if (relatedCompensationsMap.keySet().contains(nexJunction.Compensation__c)) {
                    if (relatedCompensationsMap.get(nexJunction.Compensation__c).Integration_Status__c == 'Not Claimed') {
                        TicketsToCompensations.put(nexJunction.Ticket__c, nexJunction.Compensation__c);
                    }
                    if (relatedCompensationsMap.get(nexJunction.Compensation__c).Integration_Status__c == 'Pending') {
                        TicketsToPendingCompensations.put(nexJunction.Ticket__c, nexJunction.Compensation__c);
                    }
                    if (relatedCompensationsMap.get(nexJunction.Compensation__c).Integration_Status__c == 'Success') {
                        TicketsToSuccessfulCompensations.put(nexJunction.Ticket__c, nexJunction.Compensation__c);
                    }
                    if (relatedCompensationsMap.get(nexJunction.Compensation__c).Integration_Status__c == 'Failed') {
                        TicketsToFailedCompensations.put(nexJunction.Ticket__c, nexJunction.Compensation__c);
                    }
                    //CompensationsToTickets.put(nexJunction.Compensation__c, nexJunction.Ticket__c);
                }
            }

            Set<String> validPNRsByEmail = new Set<String>();
            excludedTickets = new Set<Id>();

            statsByPNR = new Map<String, CaseTicketsStats>();
            CaseTicketsStats currentStats;

            Integer ticketThroughoutPos = 0;
            while (ticketThroughoutPos < relatedTicketsRaw.size()) {
                String nextPNR = relatedTicketsRaw[ticketThroughoutPos].PNR__c;
                String nextPassenger = relatedTicketsRaw[ticketThroughoutPos].Name_Check__c;
                Case relatedCase = COVID19Cases.get(nextPNR);
                String claimEmail = (relatedCase.SuppliedEmail != null ? relatedCase.SuppliedEmail.toLowerCase() : '');

                List<Ticket__c> passengerTickets = new List<Ticket__c>();
                while (ticketThroughoutPos < relatedTicketsRaw.size() &&
                       nextPNR == relatedTicketsRaw[ticketThroughoutPos].PNR__c &&
                       nextPassenger == relatedTicketsRaw[ticketThroughoutPos].Name_Check__c ) {

                    passengerTickets.add(relatedTicketsRaw[ticketThroughoutPos]);
                    //here we have no stats for PNR yet, so create them
                    //and check for matching emails by the way
                    if (!statsByPNR.keySet().contains(nextPNR)) {
                        currentStats = new CaseTicketsStats();
                        if (relatedCase.Claim_Date_COVID__c != null) {
                            currentStats.claimDate = relatedCase.Claim_Date_COVID__c.date();
                            currentStats.claimDateTime = relatedCase.Claim_Date_COVID__c;
                        } else {
                            if (relatedCase.CreatedDate != null) {
                                currentStats.claimDate = relatedCase.CreatedDate.date();
                                currentStats.claimDateTime = relatedCase.CreatedDate;
                            } else {
                                currentStats.claimDate = Date.today();
                                currentStats.claimDateTime = DateTime.now();
                            }
                        }
                        statsByPNR.put(nextPNR, currentStats);
                    } else {
                        currentStats = statsByPNR.get(nextPNR);
                    }

                    if (!currentStats.isDisneyBooking) currentStats.isDisneyBooking = relatedTicketsRaw[ticketThroughoutPos].Disney__c;
                    currentStats.isThereAtLeastOneEmail = currentStats.isThereAtLeastOneEmail || isAnyEmailOnTicket(relatedTicketsRaw[ticketThroughoutPos]);

                    statsByPNR.put(relatedTicketsRaw[ticketThroughoutPos].PNR__c, currentStats);
                    ticketThroughoutPos++;
                }

                markOutboundAndInbound(passengerTickets, statsByPNR.get(nextPNR));
            }

            for (Ticket__c nextTicket : relatedTicketsRaw) {
                Boolean excludedFromCompensation = false;

                currentStats = statsByPNR.get(nextTicket.PNR__c);
                currentStats.ticketsTotal++;
                Integer currentTicketState = currentStats.ticketsStates.get(nextTicket.Id);
                Boolean isOutboundTicket = ((currentTicketState & OUTBOUND) == OUTBOUND);
                Boolean isInboundTicket = ((currentTicketState & INBOUND) == INBOUND);
                Boolean isActiveTicket = ((currentTicketState & ACTIVE) == ACTIVE);

                Boolean hasActiveInboundInScope = ((currentTicketState & HAS_ACTIVE_INBOUND_IN_SCOPE) == HAS_ACTIVE_INBOUND_IN_SCOPE);
                Boolean hasActiveOutboundInScope = ((currentTicketState & HAS_ACTIVE_OUTBOUND_IN_SCOPE) == HAS_ACTIVE_OUTBOUND_IN_SCOPE);

                Case relatedCase = COVID19Cases.get(nextTicket.PNR__c);
                Boolean isOutboundRequested;
                Boolean isInboundRequested;
                if (relatedCase.Direction_requested__c != null) {
                    isOutboundRequested = relatedCase.Direction_requested__c.contains('Outbound') ||
                                          relatedCase.Direction_requested__c.contains('Both');
                    isInboundRequested = relatedCase.Direction_requested__c.contains('Inbound') ||
                                         relatedCase.Direction_requested__c.contains('Both');
                } else {
                    isOutboundRequested = relatedCase.Description.contains('Outbound');
                    isInboundRequested = relatedCase.Description.contains('Inbound');
                }
                Boolean isBothRequested = isOutboundRequested && isInboundRequested;
                Boolean isClaimed = (isOutboundRequested && isOutboundTicket) || (isInboundRequested && isInboundTicket);

                if (!isActiveTicket) {
                    excludedFromCompensation = true;
                }

                if (isClaimed) {
                    currentTicketState = currentTicketState | IN_CLAIMED_SCOPE;
                    currentStats.ticketsInClaimedScope++;
                }

                if ((currentTicketState & OUT_OF_SCOPE_BEFORE) ==  OUT_OF_SCOPE_BEFORE) {
                    if (isOutboundTicket) {
                        if (isActiveTicket) {
                            if (isClaimed) {
                                //if (hasInboundInScope && hasActiveInbound && isInboundRequested){
                                if (hasActiveInboundInScope && isInboundRequested){
                                    currentTicketState = currentTicketState | PARTIAL | EXCLUDED_FROM_AUTO;
                                    currentStats.ticketsPartial++;
                                    currentStats.excludedFromAutomation = true;
                                } else {
                                    //excluded as not claimed
                                    excludedFromCompensation = true;
                                }
                            } else {
                                //excluded as not claimed
                                excludedFromCompensation = true;
                            }
                        } else {
                            //excluded as non-active
                            excludedFromCompensation = true;
                        }
                    } else {
                        //excluded as inbound out of scope before ticket
                        excludedFromCompensation = true;
                    }
                }


                if ((currentTicketState & OUT_OF_SCOPE_AFTER) ==  OUT_OF_SCOPE_AFTER) {
                    if (isInboundTicket) {
                        //if (hasOutboundInScope && hasActiveOutbound && isOutboundRequested) {
                        if (hasActiveOutboundInScope && isOutboundRequested) {
                            if (isActiveTicket) {
                                if (isClaimed) {
                                    // try to process ticket as if it was in scope, FORCE IT to be in scope
                                    currentTicketState = currentTicketState ^ OUT_OF_SCOPE;
                                    currentStats.ticketsOutOfScope--;
                                    //currentStats.eligibleTicketsInClaimedScope++;
                                } else {
                                    // make it partial claim
                                    currentTicketState = currentTicketState | PARTIAL | EXCLUDED_FROM_AUTO;
                                    currentStats.ticketsPartial++;
                                    currentStats.excludedFromAutomation = true;
                                }
                            } else {
                                //excluded as non-active
                                excludedFromCompensation = true;
                            }
                        } else {
                            //excluded as no claimed active outbound in scope
                            excludedFromCompensation = true;
                        }
                    } else {
                        //excluded as inbound out of scope before ticket
                        excludedFromCompensation = true;
                    }
                }


                if ((currentTicketState & OUT_OF_SCOPE) == 0) {
                    if (isActiveTicket) {
                        if (isClaimed) {
                            currentStats.eligibleTicketsInClaimedScope++;
                            if (isPOSValid(nextTicket)) {
                                currentStats.eligibleTicketsInClaimedScopeAndValidPOS++;
                            }
                        } else {
                            if (currentStats.containsFullJourney) {
                                //if ((hasInboundInScope && hasActiveInbound && isInboundRequested) ||
                                //    (hasOutboundInScope && hasActiveOutbound && isOutboundRequested)) {
                                if ((hasActiveInboundInScope && isInboundRequested) ||
                                    (hasActiveOutboundInScope && isOutboundRequested)) {

                                    // make it partial claim
                                    currentTicketState = currentTicketState | PARTIAL | EXCLUDED_FROM_AUTO;
                                    currentStats.ticketsPartial++;
                                    currentStats.excludedFromAutomation = true;
                                } else {
                                    // leave it as simply not claimed
                                }
                            } else {
                                // it is single journey - must be HONOURED DISREGARDING CLAIM DIRECTION
                                currentStats.eligibleTicketsInClaimedScope++;
                                if (isPOSValid(nextTicket)) {
                                    currentStats.eligibleTicketsInClaimedScopeAndValidPOS++;
                                }
                                currentTicketState = currentTicketState | IN_CLAIMED_SCOPE;
                            }
                        }
                    } else {
                        //excluded as non-active ticket
                        excludedFromCompensation = true;
                        if (isClaimed) {
                            currentStats.isNotEligibleMessagePriority = true;
                        }
                    }
                }

                if (TicketsToSuccessfulCompensations.keySet().contains(nextTicket.Id)) {
                    currentTicketState = currentTicketState | ALREADY_COMPENSATED;
                    if ((currentTicketState & IN_CLAIMED_SCOPE) == IN_CLAIMED_SCOPE &&
                        (currentTicketState & OUT_OF_SCOPE) == 0 && (currentTicketState & ACTIVE) == ACTIVE){
                        currentStats.eligibleCompensatedTicketsInClaimedScope++;
                    }
                }


                currentStats.isIdentityConfirmed = currentStats.isIdentityConfirmed ||
                                                   isIdentityConfirmed(nextTicket, relatedCase, isOutboundTicket, currentStats);

                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                //the checks should be for the Claim
                //so if they havent requested a leg.....it deosnt need to be validated
                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


                if (!excludedFromCompensation) {
                    if ((nextTicket.PAX_type_name__c == 'Group Booking' || nextTicket.PAX_Type_Filter__c == 'GROUP')) {
                        currentTicketState = currentTicketState | GROUP_BOOKING | EXCLUDED_FROM_AUTO;
                        currentStats.groupBookingsCnt++;
                        currentStats.excludedFromAutomation = true;
                    }

                    if (nextTicket.Package_Booking__c) {
                        currentTicketState = currentTicketState | PACKAGE_BOOKING | EXCLUDED_FROM_AUTO;
                        currentStats.packageBookingsCnt++;
                        currentStats.excludedFromAutomation = true;
                    }

                    if (nextTicket.PAX_Type_Description__c != null &&  nextTicket.PAX_Type_Description__c.containsIgnoreCase('wheelchair')) {
                        currentTicketState = currentTicketState | WHEELCHAIR_BOOKING | EXCLUDED_FROM_AUTO;
                        currentStats.wheelchairBookingsCnt++;
                        currentStats.excludedFromAutomation = true;
                    }

                    if (nextTicket.PAX_Type_Filter__c != null && nextTicket.PAX_Type_Filter__c.contains('RIT')) {
                        currentTicketState = currentTicketState | RIT_TYPE | EXCLUDED_FROM_AUTO;
                        currentStats.ritBookingsCnt++;
                        currentStats.excludedFromAutomation = true;
                    }

                    if ((nextTicket.Non_Eurostar_Origin__c != null && !FRENCH_STATIONS.contains(nextTicket.Non_Eurostar_Origin__c))
                            || (nextTicket.Non_Eurostar_Destination__c != null && !FRENCH_STATIONS.contains(nextTicket.Non_Eurostar_Destination__c))) {
                        currentTicketState = currentTicketState | INTERLINING_BOOKINGS | EXCLUDED_FROM_AUTO;
                        currentStats.interliningBookingsCnt++;
                        currentStats.excludedFromAutomation = true;
                    }

                    if (nextTicket.Ticket_Price__c == 0) {
                        currentTicketState = currentTicketState | ZERO_PRICED | EXCLUDED_FROM_AUTO;
                        currentStats.ticketsZeroPriced++;
                        currentStats.excludedFromAutomation = true;
                    }

                    if (nextTicket.Original_Currency__c != 'GBP' && nextTicket.Original_Currency__c != 'EUR' &&
                            nextTicket.Original_Currency__c != 'USD') {

                        currentTicketState = currentTicketState | UNSUPPORTED_CURRENCY | EXCLUDED_FROM_AUTO;
                        currentStats.ticketsUnsupportedCurrency++;
                        currentStats.excludedFromAutomation = true;
                    }

                    if ((currentTicketState & EXCLUDED_FROM_AUTO) == EXCLUDED_FROM_AUTO ||
                        (currentTicketState & IN_CLAIMED_SCOPE) == 0 || (currentTicketState & ACTIVE) == 0) {
                        excludedTickets.add(nextTicket.Id);
                    }
                    //currentTicketState = currentTicketState | ELIGIBLE;
                    currentStats.eligibleTickets++;

                } else {
                    excludedTickets.add(nextTicket.Id);
                }

                currentStats.ticketsStates.put(nextTicket.Id, currentTicketState);
            }

            relatedTickets = relatedTicketsRaw;

            excludedPNRs = new Set<String>();

            for (String nextCasePNR : COVID19Cases.KeySet()) {
                Case nextCase = COVID19Cases.get(nextCasePNR);
                CaseTicketsStats nextStats = statsByPNR.get(nextCasePNR);

                if (nextStats != null) {

                    if (!nextStats.isIdentityConfirmed) {
                        if (nextStats.isThereAtLeastOneEmail) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.INCORRECT_EMAIL;
                        } else {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.NO_EMAIL;
                        }
                        nextStats.excludedFromAutomation = true;
                    }

                    if (nextStats.groupBookingsCnt != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.GROUPS;
                        }
                    }
                    if (nextStats.wheelchairBookingsCnt != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.WHEELCHAIR;
                        }
                    }
                    if (nextStats.packageBookingsCnt != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.PACKAGES;
                        }
                    }
                    if (nextStats.ritBookingsCnt != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.RIT;
                        }
                    }
                    if (nextStats.ticketsPartial != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.PARTIAL;
                        }
                    }
                    if (nextStats.interliningBookingsCnt != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.INTERLINING;
                        }
                    }
                    if (nextStats.ticketsZeroPriced != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.ZERO_VALUE;
                        }
                    }
                    if (nextStats.ticketsUnsupportedCurrency != 0) {
                        if (nextStats.automationExclusionMainReason == null) {
                            nextStats.automationExclusionMainReason = CaseTicketsStats.BAD_CURRENCY;
                        }
                    }

                    nextCase.COVID_Error_Category__c = nextStats.automationExclusionMainReason;
                    nextCase.Validation_Error__c = BuildErrorsReport(nextStats, relatedTicketsMap);
                }




                //PNR NOT EXIST (or tickets older than half of year or shell tickets only)
                //cases with invalid PNR submitted from web form will never get inside
                if (nextStats == null) {
                    //there will be no tickets, so no need to be concerned by after update part but anyway...
                    excludedPNRs.add(nextCasePNR);
                    nextCase.Validation_Error__c = CaseTicketsStats.INVALID_PNR;
                    nextCase.COVID_Error_Category__c = CaseTicketsStats.INVALID_PNR;
                    nextCase.Processing_Type__c = 'Manual - Backlog';
                    nextCase.OwnerId = OTHER_QUEUE_ID;
                    continue;
                }

                // Prevent case creation if identity was not confirmed by any way
                if (!nextStats.isIdentityConfirmed) {
                    if (nextStats.isThereAtLeastOneEmail) {
                        //nextCase.Validation_Error__c = CaseTicketsStats.INCORRECT_EMAIL + '\r\n' + nextCase.Validation_Error__c;
                        nextCase.addError(new CoronaVirus_NotEligibleException('Email mismatch'));
                        continue;
                    } else {
                        //nextCase.Validation_Error__c = CaseTicketsStats.NO_EMAIL + '\r\n' + nextCase.Validation_Error__c;
                        nextCase.addError(new CoronaVirus_NotEligibleException('Not confirmed identity'));
                        continue;
                    }
                    //nextCase.Status = 'Closed';
                    //nextCase.Allow_Re_submission__c = TRUE;
                }

                //ALL tickets out of scope - no case from page
                if ((nextStats != null && ((nextStats.ticketsTotal == nextStats.ticketsOutOfScope) || nextStats.eligibleTicketsInClaimedScope == 0) &&
                        !nextStats.isNotEligibleMessagePriority && nextStats.ticketsPartial == 0)) {

                    excludedPNRs.add(nextCasePNR);
                    if (UserInfo.getUserId() != EMERGENCY_GUEST_USER_ID) {
                        nextCase.Validation_Error__c = 'Booking out of scope';
                        nextCase.COVID_Error_Category__c = CaseTicketsStats.OUT_OF_SCOPE;
                        nextCase.Status = 'Closed';
                        nextCase.Processing_Type__c = 'Manual - Backlog';
                        nextCase.OwnerId = OTHER_QUEUE_ID;
                    } else {
                        //SUSPEND CASE CREATION FOR WEBFORM and supply webform with "No tickets in scope" error message
                        if (nextStats != null) nextStats.isCaseCreated = false;
                        if (false/*nextStats.isDisneyBooking*/) {
                            //nextCase.addError(new CoronaVirus_NotEligibleException('No tickets in Disney date scope'));
                        } else {
                            if(nextStats.isThereClaimPastTravelRejectionReason) {
                                nextCase.addError(new CoronaVirus_NotEligibleException('Tickets claimed past threshold date'));
                            } else if(nextStats.isThere60DaysRejectionReason) {
                                nextCase.addError(new CoronaVirus_NotEligibleException('Tickets claimed out of 60 days date scope'));
                            } else if(nextStats.isThereCancelledTrainsPastTheScope) {
                                nextCase.addError(new CoronaVirus_NotEligibleException('Tickets on cancelled trains past the scope'));
                            } else if(nextStats.isTherePackageTrainsPastTheScope) {
                                nextCase.addError(new CoronaVirus_NotEligibleException('Package booking past the scope'));
                            } else {
                                nextCase.addError(new CoronaVirus_NotEligibleException('No tickets in date scope'));
                            }
                        }
                    }
                    continue;
                }


                //ALL tickets cancelled or checked in - no case from page
                if (nextStats == null || nextStats.ticketsActive == 0 || (nextStats.eligibleTicketsInClaimedScope == 0 && nextStats.ticketsPartial == 0) ) {
                    excludedPNRs.add(nextCasePNR);
                    if (UserInfo.getUserId() != EMERGENCY_GUEST_USER_ID) {
                        nextCase.Validation_Error__c = CaseTicketsStats.INVALID_PNR;
                        nextCase.COVID_Error_Category__c = CaseTicketsStats.INVALID_PNR;
                        nextCase.Status = 'Closed';
                        nextCase.Processing_Type__c = 'Manual - Backlog';
                        nextCase.OwnerId = OTHER_QUEUE_ID;
                    } else {
                        //SUSPEND CASE CREATION and supply webform with "Not Eligible" error message
                        if (nextStats != null) nextStats.isCaseCreated = false;
                        nextCase.addError(new CoronaVirus_NotEligibleException('Not Eligible'));
                    }
                    continue;
                }

                //THIS IS NOT ABOUT ELIGIBILITY !!! THIS IS ABOUT EXCLUSION FROM AUTOMATED CLAIM COMPENSATION !!!!
                if (nextStats.excludedFromAutomation) {
                    //CREATE CASE, PUSH to Customer Care, FLAG AS MANUAL, AND LEAVE OPEN, or close if email check failed
                    excludedPNRs.add(nextCasePNR);
                    nextCase.OwnerId = OTHER_QUEUE_ID;

                    if (nextStats.automationExclusionMainReason == CaseTicketsStats.GROUPS || nextStats.groupBookingsCnt > 0) {
                        nextCase.Validation_Error__c = nextCase.Validation_Error__c + '\r\n' + CaseTicketsStats.GROUPS;
                        nextCase.OwnerId = GROUP_QUEUE_ID;
                    }
                    if (nextStats.automationExclusionMainReason == CaseTicketsStats.WHEELCHAIR || nextStats.wheelchairBookingsCnt > 0) {
                        nextCase.Validation_Error__c = nextCase.Validation_Error__c + '\r\n' + CaseTicketsStats.WHEELCHAIR;
                        nextCase.OwnerId = OTHER_QUEUE_ID;//OTHER - CORRECT!
                    }
                    if (nextStats.automationExclusionMainReason == CaseTicketsStats.PACKAGES || nextStats.packageBookingsCnt > 0) {
                        nextCase.Validation_Error__c = nextCase.Validation_Error__c + '\r\n' + CaseTicketsStats.PACKAGES;
                        nextCase.OwnerId = PACKAGE_QUEUE_ID;
                    }
                    if (nextStats.automationExclusionMainReason == CaseTicketsStats.RIT) {
                        nextCase.Validation_Error__c = nextCase.Validation_Error__c + '\r\n' + CaseTicketsStats.RIT;
                        nextCase.OwnerId = RIT_QUEUE_ID;
                    }

                    if (UserInfo.getUserId() != EMERGENCY_GUEST_USER_ID) {
                        nextCase.Processing_Type__c = 'Manual - Backlog';
                    } else {
                        nextCase.Processing_Type__c = 'Manual';
                    }
                    continue;
                }

                //There are eligible tickets hopefully all of them will be claimed
                if (nextStats.eligibleTickets > 0 && nextStats.eligibleTicketsInClaimedScope != 0) {
                    //Check if all eligible claimed tickets already compensated
                    if (nextStats.eligibleCompensatedTicketsInClaimedScope == nextStats.eligibleTicketsInClaimedScope) {
                        nextCase.COVID_Error_Category__c = CaseTicketsStats.COMPENSATED_ALL;
                        nextCase.Status = 'Closed';
                    } else {
                        //There are cancelled or checked in tickets
                        if (nextStats.ticketsInClaimedScope > nextStats.eligibleTicketsInClaimedScope) {
                            nextCase.Incomplete_Voucher_Set__c = True;
                        }
                        if (nextStats.isThereAtLeastOneEmail) {
                            if (currentStats.eligibleTicketsInClaimedScopeAndValidPOS > 0) {
                                //there are eligible tickets and at least one email was correct and POS is Eurostar
                                nextCase.addError(new CoronaVirus_NotEligibleException('Please check out our MYB page'));
                                continue;
                            } else {
                                //there are eligible tickets and at least one email was correct but POS is non-Eurostar - create case
                                nextCase.COVID_Error_Category__c = CaseTicketsStats.NON_EUROSTAR_POS;
                            }
                        } else {
                            //there are eligible tickets but no personal emails on them and no booker record associated
                            //so identity was confirmed only by Last Name or Travel Date on one of outbound tickets
                            nextCase.COVID_Error_Category__c = CaseTicketsStats.NO_EMAIL;
                        }
                        nextStats.excludedFromAutomation = true;
                    }
                    //check if case just created from site
                    if (UserInfo.getUserId() != EMERGENCY_GUEST_USER_ID) {
                        nextCase.Processing_Type__c = 'Manual - Backlog';
                    } else {
                        nextCase.Processing_Type__c = 'Manual';
                    }
                    nextCase.OwnerId = OTHER_QUEUE_ID;
                    continue;
                }

                //There are eligible tickets but none of them were claimed
                if (nextStats.eligibleTickets > 0 && nextStats.eligibleTicketsInClaimedScope == 0) {

                    if (UserInfo.getUserId() != EMERGENCY_GUEST_USER_ID) {
                        nextCase.Validation_Error__c = 'Booking out of scope';
                        nextCase.COVID_Error_Category__c = CaseTicketsStats.OUT_OF_SCOPE;
                        nextCase.Status = 'Closed';
                        nextCase.Processing_Type__c = 'Manual - Backlog';
                        nextCase.OwnerId = OTHER_QUEUE_ID;
                    } else {
                        //SUSPEND CASE CREATION FOR WEBFORM and supply webform with "No tickets in scope" error message
                        if (nextStats != null) nextStats.isCaseCreated = false;
                        if (false/*nextStats.isDisneyBooking*/) {
                            nextCase.addError(new CoronaVirus_NotEligibleException('No tickets in Disney date scope'));
                        } else {
                            nextCase.addError(new CoronaVirus_NotEligibleException('No tickets in date scope'));
                        }
                    }
                }
            }
        }
    }

    public static void reflectCOVIDCaseStatusOnTickets(Map<Id, Case> oldCases, List<Case> newCases) {
        Set<String> PNRsForFlagging = new Set<String>();
        Set<String> PNRsForDeflagging = new Set<String>();
        for (Case nextCase : newCases) {
            if (CORONAVIRUS_REASON_CODE_ID != null && nextCase.Reason_Code__c == CORONAVIRUS_REASON_CODE_ID) {
                if (oldCases == null) {
                    PNRsForFlagging.add(nextCase.PNR__c);
                } else {
                    if (nextCase.Status != oldCases.get(nextCase.Id).Status && (nextCase.Status == 'Closed')) {
                        PNRsForDeflagging.add(nextCase.PNR__c);
                    }
                }
            }
        }

        Set<String> allPNRs = new Set<String>(PNRsForFlagging);
        allPNRs.addAll(PNRsForDeflagging);
        allPNRs.remove(null);
        allPNRs.remove('');

        if (allPNRs.isEmpty()) { return; }

        List<Ticket__c> ticketsForUpdate = new List<Ticket__c>();

        List<Ticket__c> relatedTickets = [
                SELECT Id, Open_Evoucher_Request__c, PNR__c
                FROM Ticket__c
                WHERE PNR__c IN : allPNRs
                ORDER BY PNR__c
        ];

        for (Ticket__c nexTicket : relatedTickets) {
            if (PNRsForFlagging.contains(nexTicket.PNR__c)) {
                if (!nexTicket.Open_Evoucher_Request__c) {
                    nexTicket.Open_Evoucher_Request__c = true;
                    ticketsForUpdate.add(nexTicket);
                }
            } else {
                if (nexTicket.Open_Evoucher_Request__c) {
                    nexTicket.Open_Evoucher_Request__c = false;
                    ticketsForUpdate.add(nexTicket);
                }
            }
        }

        if (ticketsForUpdate.size() > 0)
            update ticketsForUpdate;
    }

    public static void convertOnlineCompsToVoucherRequests(List<Case> insertedCases) {

        Map<String, Case> COVID19Cases = new Map<String, Case>();
        Map<String, Case> compensatedCases = new Map<String, Case>();

        // SELECT CASES POSSIBLY REQUIRING COMP PROCESSION/CREATION
        for (Case nextCase : insertedCases) {
            CaseTicketsStats relatedCaseStats;
            if (statsByPNR != null) {
                relatedCaseStats = statsByPNR.get(nextCase.PNR__c);
                Boolean isCaseCreated = relatedCaseStats != null ? relatedCaseStats.isCaseCreated : false;
                if (CORONAVIRUS_REASON_CODE_ID != null && ((nextCase.Reason_Code__c == CORONAVIRUS_REASON_CODE_ID) || Test.isRunningTest()) && !excludedPNRs.contains(nextCase.PNR__c) &&
                        nextCase.Status != 'Closed') {
                    if ((UserInfo.getUserId() == EMERGENCY_GUEST_USER_ID && isCaseCreated) ||
                        (System.isQueueable() && nextCase.CreatedById == EMERGENCY_GUEST_USER_ID) ||
                        (System.isBatch() && nextCase.CreatedById == EMERGENCY_GUEST_USER_ID)) {
                        COVID19Cases.put(nextCase.PNR__c, nextCase);
                    }
                }
            }
        }

        COVID19Cases.remove(null);
        COVID19Cases.remove('');

        if (COVID19Cases.size() > 0) {

            if(relatedTickets.size() > 0) {
                List<Compensation__c> compensationsForUpdate = new List<Compensation__c>();
                List<Compensation__c> compensationsForCreate = new List<Compensation__c>();
                Map<Id, Compensation__c> compensationsForCreateByTicketId = new Map<Id, Compensation__c>();

                Integer ticketListPos = 0;

                while (ticketListPos < relatedTickets.size()) {
                    Case relatedCase = COVID19Cases.get(relatedTickets[ticketListPos].PNR__c);
                    if (relatedCase != null) {
                        CaseTicketsStats relatedCaseStats = statsByPNR.get(relatedCase.PNR__c);
                        Ticket__c nextTicket = relatedTickets[ticketListPos];
                        if (!excludedPNRs.contains(nextTicket.PNR__c)) {
                            if (!TicketsToSuccessfulCompensations.keySet().contains(nextTicket.Id)) {
                                Compensation__c relatedComp = relatedCompensationsMap.get(TicketsToCompensations.get(nextTicket.Id));
                                if (relatedComp == null) {
                                    relatedComp = relatedCompensationsMap.get(TicketsToFailedCompensations.get(nextTicket.Id));
                                }
                                if (relatedComp == null) {
                                    relatedComp = relatedCompensationsMap.get(TicketsToPendingCompensations.get(nextTicket.Id));
                                }
                                //UNIFIED BRANCH
                                if (!relatedCaseStats.excludedFromAutomation && (excludedTickets == null || !excludedTickets.contains(nextTicket.Id))) {
                                    if (relatedComp != null) {
                                        relatedComp = createNewCompOrFillExisting(nextTicket, relatedComp);
                                        compensationsForUpdate.add(prepareCompensationForVoucherClaim(relatedComp, relatedCase, nextTicket, relatedCaseStats));
                                    } else {
                                        relatedComp = createNewCompOrFillExisting(nextTicket, null);
                                        compensationsForCreate.add(prepareCompensationForVoucherClaim(relatedComp, relatedCase, nextTicket, relatedCaseStats));
                                        compensationsForCreateByTicketId.put(relatedComp.Ticket__c, relatedComp);
                                    }
                                    //multithreading issue workaround
                                    compensatedCases.put(relatedCase.Id, relatedCase);
                                } else {
                                    if (relatedComp != null) {
                                        relatedComp.Case__c = relatedCase.Id;
                                        compensationsForUpdate.add(relatedComp);
                                    }
                                }
                            } else {
                                compensatedCases.put(relatedCase.Id, relatedCase);
                            }
                        }
                    }
                    ticketListPos++;

                }

                if (compensationsForUpdate.size() > 0) {
                    update compensationsForUpdate;
                }

                if (compensationsForCreate.size() > 0 ) {

                    insert compensationsForCreate;

                    List<Compensation_Ticket__c> compensationsTicketsForCreate = new List<Compensation_Ticket__c>();
                    for (Id nextCompTicketId : compensationsForCreateByTicketId.keySet()){
                        Compensation_Ticket__c compTicket = new Compensation_Ticket__c (
                                Ticket__c = nextCompTicketId,
                                Compensation__c = compensationsForCreateByTicketId.get(nextCompTicketId).Id
                        );
                        compensationsTicketsForCreate.add(compTicket);
                    }
                    insert compensationsTicketsForCreate;
                }
                //prepare data for multithreading issue workaround
                if (compensatedCases.size() > 0) {
                    List<Utility__c> utilities = new List<Utility__c>();
                    for (Case nextCase : compensatedCases.values()) {
                        utilities.add(new Utility__c(Case__c = nextCase.Id, PNR__c = nextCase.PNR__c));
                    }
                    insert utilities;

                    List<CronTrigger> crons = [SELECT Id,CronJobDetail.Name
                                              FROM CronTrigger
                                              WHERE CronJobDetail.Name = 'COVID Case Closer'];
                    if (crons.size() == 0) {
                        System.scheduleBatch(new CompApp_COVIDCaseCloser(), 'COVID Case Closer', 1, 200);
                    }
                }
            }
        }
    }

    public static Compensation__c createNewCompOrFillExisting(Ticket__c relatedTicket, Compensation__c comp) {

        Compensation__c newComp;
        if (comp == null) {
            newComp = new Compensation__c();
        } else {
            newComp = comp;
        }

        newComp.RecordTypeId = ONLINE_COMPENSATION_RECORD_TYPE_ID;
        newComp.Pre_Travel__c = TRUE;
        newComp.Claimed_Date__c = DateTime.now();
        newComp.Ticket__c = relatedTicket.Id;
        newComp.Ticket_Read_Only__c = relatedTicket.Name;
        newComp.Ticket_Number__c = relatedTicket.Name;
        newComp.Ticket_Price__c = relatedTicket.Ticket_Price__c;
        newComp.CustomerC__c = relatedTicket.Booker__r.PersonContactId;
        newComp.Payment_Currency__c = relatedTicket.Original_Currency__c;
        newComp.Total_Online_Compensation__c = relatedTicket.Ticket_Price__c;
        newComp.Train__c = 	relatedTicket.Train__c;
        newComp.Carriage__c = relatedTicket.Coach__c;
        newComp.PNR__c = relatedTicket.PNR__c;

        return newComp;
    }

    public static Compensation__c prepareCompensationForVoucherClaim(Compensation__c comp, Case relatedCase, Ticket__c relatedTicket, CaseTicketsStats currentStats) {

        Integer middle = relatedCase.SuppliedName.indexOf(' ');
        Boolean isFixedVoucherExpiryDate = false;

        comp.Claim_Status__c = 'Claimed';
        comp.Language__c = relatedCase.Website_Language__c == 'nl-NL' ? 'Dutch':
                relatedCase.Website_Language__c == 'fr-fr' ? 'French':
                        'English';
        comp.Claimed_Date__c = currentStats.claimDate;
        comp.Claimed_Compensation_Type__c = 'Voucher';
        if (relatedTicket.Last_Name__c == null || relatedTicket.First_Name__c == null) {
            comp.Last_Name__c = relatedCase.SuppliedName.left(middle);
            comp.First_Name__c = relatedCase.SuppliedName.right(relatedCase.SuppliedName.length() - middle);
        } else {
            comp.Last_Name__c = relatedTicket.Last_Name__c;
            comp.First_Name__c = relatedTicket.First_Name__c;
        }
        comp.Claim_Email__c = relatedCase.SuppliedEmail;


        Date claimDate= currentStats.claimDate;
        if (relatedTicket.Train__r.Cancelled__c) {
            comp.Voucher_Expiry_Date__c = claimDate.addMonths(12);
        } else {
            if (relatedTicket.Departure_Date__c < POLICY_THRESHOLD_DATE) {
                comp.Voucher_Expiry_Date__c = claimDate.addMonths(12);
            } else {
                comp.Voucher_Expiry_Date__c = Date.newInstance(2021, 06, 01);
                isFixedVoucherExpiryDate = true;
            }
        }

        if (!isFixedVoucherExpiryDate) {
            //Friday +3 day, Saturday +2 day, Others +1 day
            Integer dayOfWeekSurplus = Math.mod(Date.newInstance(1900, 1, 1).daysBetween(claimDate), 7);
            if (dayOfWeekSurplus == 4 || dayOfWeekSurplus == 5) {
                dayOfWeekSurplus = 7 - dayOfWeekSurplus;
            } else {
                dayOfWeekSurplus = 1;
            }
            comp.Voucher_Expiry_Date__c = comp.Voucher_Expiry_Date__c.addDays(dayOfWeekSurplus);
        }

        comp.Integration_Status__c = 'Pending';
        comp.Case__c = relatedCase.Id;
        comp.Automation_System__c = true;

        return comp;
    }

    public static void closeRelatedCasesWhenAllCompsSucceeded(final List<Compensation__c> newObjects, final Map<Id, Compensation__c> oldObjectsMap, List<Utility__c> utilities) {

        if(DLT_Utils.isAsyncCtx()){
            closeRelatedCasesWhenAllCompsSucceededSync(newObjects, oldObjectsMap, null);
        }
        else{
            System.enqueueJob(new DLT_CompensationTriggerQueHelper(
                DLT_CompensationTriggerQueHelper.Mode.CLOSE_RELATED_CASES_WHEN_COPMS_SUCCEED,
                newObjects,
                oldObjectsMap,
                null
            ));
        }
    }

    public static void closeRelatedCasesWhenAllCompsSucceededSync(List<Compensation__c> newObjects, Map<Id, Compensation__c> oldObjectsMap, List<Utility__c> utilities) {
        Set<Id> Cases = new Set<Id>();
        Set<String> CasePNRs = new Set<String>();
        List<Case> casesForUpdate;
        Map<Id,Utility__c> utilitiesMap;
        Map<Id,List<Id>> casesToUtilitiesMap = new Map<Id,List<Id>>();

        if (utilities != null) {
            utilitiesMap = new Map<Id,Utility__c>(utilities);
            for (Utility__c utility : utilities) {
                Cases.add(utility.Case__c);
                CasePNRs.add(utility.PNR__c);
                if (!casesToUtilitiesMap.keyset().contains(utility.Case__c)){
                    List<Id> currentCaseUtilities = new List<Id>();
                    currentCaseUtilities.add(utility.Id);
                    casesToUtilitiesMap.put(utility.Case__c, currentCaseUtilities);
                } else {
                    casesToUtilitiesMap.get(utility.Case__c).add(utility.Id);
                }
            }
        }  else {
            if(newObjects != null && !newObjects.isEmpty()){
                for (Compensation__c nextComp : newObjects) {

                    if (nextComp.PNR__c != null && nextComp.RecordTypeId == COVID19_TriggerUtils.ONLINE_COMPENSATION_RECORD_TYPE_ID
                            && nextComp.Integration_Status__c == 'Success' && nextComp.Pre_Travel__c == true
                            && oldObjectsMap.get(nextComp.Id).Integration_Status__c != 'Success') {
                        Cases.add(nextComp.Case__c);
                        CasePNRs.add(nextComp.PNR__c);
                    }
                }
            }  
        }

        Cases.remove(null);
        CasePNRs.remove(null);
        CasePNRs.remove('');

        if (!Cases.isEmpty() && !CasePNRs.isEmpty()) {

            List<Case> relatedCases;
            if (!Test.isRunningTest()) {
                relatedCases = [
                        SELECT Id, Status, PNR__c, Description, Validation_Error__c, (SELECT Id, PNR__c, Integration_Status__c FROM Compensations__r)
                        FROM Case
                        WHERE Reason_Code__c = :COVID19_TriggerUtils.CORONAVIRUS_REASON_CODE_ID AND CreatedById = :COVID19_TriggerUtils.EMERGENCY_GUEST_USER_ID AND
                        Id IN :Cases
                ];
            } else {
                relatedCases = [
                        SELECT Id, Status, PNR__c, Description, Validation_Error__c, (SELECT Id, PNR__c, Integration_Status__c FROM Compensations__r)
                        FROM Case
                        WHERE Id IN :Cases
                ];
            }

            List<Ticket__c> allTickets = [SELECT Id, Name FROM Ticket__c WHERE PNR__c IN :CasePNRs];
            Map<Id,Ticket__c> allTicketsMap = new Map<Id,Ticket__c>(allTickets);
            List<Compensation_Ticket__c> allTicketsJunctions = [SELECT Compensation__c, Ticket__c
                                                                FROM Compensation_Ticket__c
                                                                WHERE Ticket__c in : allTicketsMap.keySet()];

            Map<Id, Id> compsToAllTickets = new Map<Id,Id>();
            for (Compensation_Ticket__c nextJunction : allTicketsJunctions) {
                compsToAllTickets.put(nextJunction.Compensation__c, nextJunction.Ticket__c);
            }

            List<Ticket__c> ticketsForUpdate =  new List<Ticket__c>();
            Set<Id> ticketsIdsForUpdate =  new Set<Id>();


            if (relatedCases.size() > 0) {
                casesForUpdate = new List<Case>();
                for (Case nextCase : relatedCases) {
                    if (nextCase.Status != 'Closed') {
                        List<Ticket__c> currentCaseTicketsForUpdate = new List<Ticket__c>();
                        if (nextCase.Compensations__r.size() > 0) {
                            Integer successCompsCount = 0;
                            Integer pendingCompsCount = 0;
                            Integer failedCompsCount = 0;
                            Integer notClaimedCompsCount = 0;
                            Boolean caseNeedUpdate = false;

                            for (Compensation__c nextComp : nextCase.Compensations__r) {
                                if (nextComp.Integration_Status__c == 'Success') {
                                    successCompsCount++;
                                    Ticket__c relatedTicket = allTicketsMap.get(compsToAllTickets.get(nextComp.Id));

                                    if (relatedTicket != null) {
                                        relatedTicket.S3_Cancel__c = TRUE;
                                        if (!ticketsIdsForUpdate.contains(relatedTicket.Id)) {
                                            currentCaseTicketsForUpdate.add(relatedTicket);
                                            ticketsIdsForUpdate.add(relatedTicket.Id);
                                        }
                                    }
                                }
                                if (nextComp.Integration_Status__c == 'Pending') {
                                    pendingCompsCount++;
                                }
                                if (nextComp.Integration_Status__c == 'Failed') {
                                    failedCompsCount++;
                                }
                            }

                            if (successCompsCount > 0 && pendingCompsCount == 0 && failedCompsCount == 0) {
                                nextCase.Status = 'Closed';
                                nextCase.Outcome__c = 'Resolved Query Or Answered Question';
            					nextCase.Tone_Of_Contact__c = 'Neutral';
                                caseNeedUpdate = true;
                                ticketsForUpdate.addAll(currentCaseTicketsForUpdate);
                            }

                            if (utilities != null) {
                                if (failedCompsCount != 0 || (successCompsCount > 0 && pendingCompsCount == 0 && failedCompsCount == 0)) {
                                    for (Id utilityId : casesToUtilitiesMap.get(nextCase.Id)) {
                                        utilitiesMap.get(utilityId).PNR__c = null;
                                    }
                                }
                            }

                            if (caseNeedUpdate) {
                                CasesForUpdate.add(nextCase);
                            }

                        }
                    } else {
                        //exclude case from utilities
                        if (utilities != null) {
                            for (Id utilityId : casesToUtilitiesMap.get(nextCase.Id)) {
                                utilitiesMap.get(utilityId).PNR__c = null;
                            }
                        }
                    }
                }

                if(casesForUpdate.size() > 0) {
                    update CasesForUpdate;
                }
                if(ticketsForUpdate.size() > 0) {
                    if (utilities != null) {
                        System.enqueueJob(new TicketsS3SetJob(ticketsForUpdate));
                    } else {
                        update ticketsForUpdate;
                    }
                }
            }
        }
    }


    public static String BuildErrorsReport(CaseTicketsStats stats, Map<Id, Ticket__c> tickets) {
        String result = '';
        if (stats != null) {
            for (Id ticketId : stats.ticketsStates.keySet()) {
                Boolean ticketReported = false;
                String tcn = tickets.get(ticketId).Name;
                Integer ticketStates = stats.ticketsStates.get(ticketId);

                if ((ticketStates & ALREADY_COMPENSATED) == ALREADY_COMPENSATED) {
                    result = result + '\r\nTCN ' + tcn + ' is already compensated on case ' +
                    relatedCompensationsMap.get(TicketsToSuccessfulCompensations.get(ticketId)).Case__r.CaseNumber;
                }

                if ( stats.excludedFromAutomation && (ticketStates & ACTIVE) == ACTIVE &&
                        (((ticketStates & OUT_OF_SCOPE) == 0 && (ticketStates & IN_CLAIMED_SCOPE) == IN_CLAIMED_SCOPE)
                         || (ticketStates & PARTIAL) == PARTIAL) ) {

                    if ((ticketStates & GROUP_BOOKING) == GROUP_BOOKING) {
                        //result = result + '\r\nTCN ' + tcn + ' is part of a Group Booking';
                        ticketReported = true;
                    }

                    if (!ticketReported) {
                        if ((ticketStates & WHEELCHAIR_BOOKING) == WHEELCHAIR_BOOKING) {
                            //result = result + '\r\nTCN ' + tcn + ' is part of a Wheelchair Booking';
                            ticketReported = true;
                        }
                    }

                    if (!ticketReported) {
                        if ((ticketStates & PACKAGE_BOOKING) == PACKAGE_BOOKING) {
                            //result = result + '\r\nTCN ' + tcn + ' is part of a Package Booking';
                            ticketReported = true;
                        }
                    }

                    if (!ticketReported) {
                        if ((ticketStates & RIT_TYPE) == RIT_TYPE) {
                            //result = result + '\r\nTCN ' + tcn + ' is part of a RIT Booking';
                            ticketReported = true;
                        }
                    }

                    if (!ticketReported &&
                        stats.automationExclusionMainReason != CaseTicketsStats.INCORRECT_EMAIL &&
                        stats.automationExclusionMainReason != CaseTicketsStats.NO_EMAIL) {

                        if (!ticketReported) {
                            if ((ticketStates & PARTIAL) == PARTIAL &&
                                    stats.automationExclusionMainReason == CaseTicketsStats.PARTIAL) {
                                result = result + '\r\nTCN ' + tcn + ' - Partial booking requested';
                                ticketReported = true;
                            }
                        }
                        if (!ticketReported) {
                            if ((ticketStates & INTERLINING_BOOKINGS) == INTERLINING_BOOKINGS &&
                                 stats.automationExclusionMainReason == CaseTicketsStats.INTERLINING) {

                                result = result + '\r\nTCN ' + tcn + ' is an Interlining booking';
                                ticketReported = true;
                            }
                        }
                        if (!ticketReported) {
                            if ((ticketStates & ZERO_PRICED) == ZERO_PRICED &&
                                 stats.automationExclusionMainReason == CaseTicketsStats.ZERO_VALUE) {
                                result = result + '\r\nTCN ' + tcn + ' is zero value ticket';
                                ticketReported = true;
                            }
                        }
                        if (!ticketReported) {
                            if ((ticketStates & UNSUPPORTED_CURRENCY) == UNSUPPORTED_CURRENCY &&
                                 stats.automationExclusionMainReason == CaseTicketsStats.BAD_CURRENCY) {
                                result = result + '\r\nTCN ' + tcn + ' - unsupported currency';
                                ticketReported = true;
                            }
                        }

                    }
                }

                //later may be required
                if (!stats.excludedFromAutomation && ((ticketStates & IN_CLAIMED_SCOPE) == IN_CLAIMED_SCOPE)) {

                    if (!ticketReported) {
                        if ((ticketStates & OUT_OF_SCOPE) == OUT_OF_SCOPE) {
                            result = result + '\r\nTCN ' + tcn + ' travel date out of scope';
                            ticketReported = true;
                        }
                    }

                    if (!ticketReported) {
                        if ((ticketStates & CANCELLED) == CANCELLED) {
                            result = result + '\r\nTCN ' + tcn + ' was cancelled by customer';
                            ticketReported = true;
                        }
                    }

                    if (!ticketReported) {
                        if ((ticketStates & CHECKED_IN) == CHECKED_IN) {
                            result = result + '\r\nTCN ' + tcn + ' was checked in';
                            ticketReported = true;
                        }
                    }

                }

            }

        } else {
            result = 'no tickets within last 6 months';
        }
        return result;
    }

    public static Boolean isAnyEmailOnTicket(Ticket__c tick) {
        Boolean isEmailPresent = tick.Email__c != null &&
                                 !THIRD_PARTY_EMAILS.contains(tick.Email__c.toLowerCase()) &&
                                 !THIRD_PARTY_EMAIL_DOMAINS.contains(tick.Email__c.toLowerCase().substring(tick.Email__c.indexOf('@')));
        Boolean isETAPEmailPresent = tick.ETAP_Email__c != null &&
                                     !THIRD_PARTY_EMAILS.contains(tick.ETAP_Email__c.toLowerCase()) &&
                                     !THIRD_PARTY_EMAIL_DOMAINS.contains(tick.ETAP_Email__c.toLowerCase().substring(tick.ETAP_Email__c.indexOf('@')));
        Boolean isBookerEmailPresent = tick.Booker__r != null && tick.Booker__r.Customer_Email__pc != null &&
                                       !THIRD_PARTY_EMAILS.contains(tick.Booker__r.Customer_Email__pc.toLowerCase()) &&
                                       !THIRD_PARTY_EMAIL_DOMAINS.contains(tick.Booker__r.Customer_Email__pc.toLowerCase().substring(tick.Booker__r.Customer_Email__pc.indexOf('@')));

        return (isEmailPresent || isETAPEmailPresent || isBookerEmailPresent);
    }

    public static Boolean isIdentityConfirmed(Ticket__c tick, Case relatedCase, Boolean outbound, CaseTicketsStats stats) {

        String filteredEmail = ((tick.Email__c != null && (THIRD_PARTY_EMAILS.contains(tick.Email__c.toLowerCase()))) ||
                                (tick.Email__c != null && THIRD_PARTY_EMAIL_DOMAINS.contains(tick.Email__c.toLowerCase().substring(tick.Email__c.indexOf('@')))))
                                ? null : tick.Email__c;
        String filteredETAPEmail = ((tick.ETAP_Email__c != null && (THIRD_PARTY_EMAILS.contains(tick.ETAP_Email__c.toLowerCase()))) ||
                                    (tick.ETAP_Email__c != null && THIRD_PARTY_EMAIL_DOMAINS.contains(tick.ETAP_Email__c.toLowerCase().substring(tick.ETAP_Email__c.indexOf('@')))))
                                    ? null : tick.ETAP_Email__c;
        String filteredBookerEmail = ((tick.Booker__r != null && tick.Booker__r.Customer_Email__pc != null &&
                                             (THIRD_PARTY_EMAILS.contains(tick.Booker__r.Customer_Email__pc.toLowerCase()))) ||
                                       (tick.Booker__r != null && tick.Booker__r.Customer_Email__pc != null &&
                                             (THIRD_PARTY_EMAIL_DOMAINS.contains(tick.Booker__r.Customer_Email__pc.toLowerCase().substring(tick.Booker__r.Customer_Email__pc.indexOf('@'))))))
                                       ? null : tick.Booker__r.Customer_Email__pc;


        String claimEmail = relatedCase.SuppliedEmail.toLowerCase();
        Boolean result = (filteredEmail != null && claimEmail == filteredEmail.toLowerCase()) ||
                         (filteredETAPEmail != null && claimEmail == filteredETAPEmail.toLowerCase()) ||
                         (filteredBookerEmail != null && claimEmail == filteredBookerEmail.toLowerCase());

        if (result) {
            stats.isValidatedByEmail = true;
            return result;
        }

        if (!stats.isThereAtLeastOneEmail) {
            if (tick.Last_Name__c != null) {
                result = relatedCase.SuppliedName.startsWith(tick.Last_Name__c.toLowerCase());
                if (!result) {
                    String suppliedNameNormalized = AccentTools.normalizeAndReplaceDiacritics(relatedCase.SuppliedName, false);
                    String ticketSurnameNormalized = AccentTools.normalizeAndReplaceDiacritics(tick.Last_Name__c, false);
                    result = suppliedNameNormalized.startsWith(ticketSurnameNormalized);
                    if (!result) {
                        ticketSurnameNormalized = AccentTools.normalizeAndReplaceDiacritics(tick.Last_Name__c, true);
                        result = suppliedNameNormalized.startsWith(ticketSurnameNormalized);
                        if (!result) {
                            suppliedNameNormalized = AccentTools.normalizeAndReplaceDiacritics(relatedCase.SuppliedName, true);
                            result = suppliedNameNormalized.startsWith(ticketSurnameNormalized);
                            if (!result) {
                                ticketSurnameNormalized = AccentTools.normalizeAndReplaceDiacritics(tick.Last_Name__c, false);
                                result = suppliedNameNormalized.startsWith(ticketSurnameNormalized);
                            }
                        }
                    }
                }
            }
            if (result) {
                return result;
            } else if (outbound) {
                result = (relatedCase.Departure_Date__c == tick.Departure_Date__c);
            }
        }
        return result;
    }

    /*
      check for name match - if full name matches then process
      or check for surname match - if surname matches then process
      or check for outbound departure date - if request matches any active ticket then process

      also....any case which results in mismatch email - should have 'allow re-submission' flag updated to TRUE as part of its update
    */

    public static Boolean isSkiTrain(Ticket__c ticket) {
        String trainNumberDenulled = ticket.Train__r.Train_Number__c.replaceFirst('^0+','');
        if (trainNumberDenulled == '9092' || trainNumberDenulled == '9095' ||
                trainNumberDenulled == '9096' || trainNumberDenulled == '9099'  ) {

            return true;
        }
        return false;
    }

    public static Date getEarliestValidDate(Ticket__c ticket, CaseTicketsStats currentStats) {
        Date result;
        Date earliestDateCutoff = ticket.Train__r.Cancelled__c ? CANCELLED_SCOPE_BEGIN :
                                    (ticket.Package_Booking__c ? PACKAGE_SCOPE_BEGIN :
                                           (isSkiTrain(ticket) ? SKI_SCOPE_BEGIN :
                                             (ticket.Disney__c ? DISNEY_SCOPE_BEGIN : GENERAL_SCOPE_BEGIN)));

        if (ticket.Departure_Date__c < POLICY_THRESHOLD_DATE) {
            //all tickets with departure date before policy change
            //can be claimed within 60 days after departure
            result = currentStats.claimDate.addDays(-60);
        } else {
            if (ticket.Train__r.Cancelled__c) {
                //cancelled tickets with departure date after policy change
                //can be claimed within 60 days after departure
                result = currentStats.claimDate.addDays(-60);
            } else {
                //regular tickets with departure date after policy change
                //can be claimed starting from their scope beginning based on type
                //but currently there are no use for that
                //because policy change date currently later than their scope begins
                result = earliestDateCutoff;
            }
        }
        return result;
    }

    public static Boolean isPOSValid(Ticket__c ticket) {
        for (String nextPOS : VALID_POS_LIST) {
            if (ticket.Point_of_Sale__c.containsIgnoreCase(nextPOS)) return true;
        }
        return false;
    }

    public static Date getLatestDateCutoff(Ticket__c ticket) {
        return ticket.Train__r.Cancelled__c ? CANCELLED_SCOPE_END :
                 (ticket.Package_Booking__c ? PACKAGE_SCOPE_END :
                        (isSkiTrain(ticket) ? SKI_SCOPE_END :
                          (ticket.Disney__c ? DISNEY_SCOPE_END : GENERAL_SCOPE_END)));
    }

    public static Date getLatestValidDate(Ticket__c ticket, CaseTicketsStats currentStats) {
        Date result;
        Date latestDateCutoff = getLatestDateCutoff(ticket);

        if (ticket.Departure_Date__c <= latestDateCutoff) {
            //all tickets in this branch have their departure date
            //NOT LATER than end of scope for their particular type (regular, disney, cancelled, package, etc)
            if (ticket.Departure_Date__c < POLICY_THRESHOLD_DATE) {
                if (currentStats.claimDate < ticket.Departure_Date__c) {
                    //all tickets with departure date before policy change
                    //and claimed before departure a granted
                    result = ticket.Departure_Date__c.addDays(1);
                } else {
                    //all tickets with departure date before policy change
                    //can also be claimed within 60 days after departure
                    if (ticket.Departure_Date__c.addDays(60) >= currentStats.claimDate) {
                        result = ticket.Departure_Date__c.addDays(1);
                    } else {
                        result = ticket.Departure_Date__c.addDays(-1);
                    }
                }
            } else {
                if (ticket.Train__r.Cancelled__c) {
                    if (currentStats.claimDate < ticket.Departure_Date__c) {
                        //CANCELLED with departure date after policy threshold and withing their particular scope
                        //always granted when claimed before departure
                        result = ticket.Departure_Date__c.addDays(1);
                    } else {
                        if (ticket.Departure_Date__c.addDays(60) >= currentStats.claimDate) {
                            //CANCELLED trains with departure date after policy threshold and withing their particular scope
                            //also granted when claimed within 60 days after departure
                            result = ticket.Departure_Date__c.addDays(1);
                        } else {
                            //CANCELLED trains with departure date after policy threshold and withing their particular scope
                            //never granted when claimed more than 60 days after departure
                            result = ticket.Departure_Date__c.addDays(-1);
                        }
                    }
                } else {
                    //RUNNING trains with departure date after policy threshold and withing their scope
                    //granted ONLY when claimed before departure day(by new rules before 168 hours departure day)
                    if (currentStats.claimDateTime < ticket.Departure_Date_Time_Format__c.addHours(-168)) {
                        result = ticket.Departure_Date__c.addDays(1);
                    } else {
                        result = ticket.Departure_Date__c.addDays(-1);
                    }
                }
            }
        } else {
            //all tickets in this branch have their departure date LATER than end of scope
            //for their particular type (regular, disney, cancelled, package, etc)
            result = ticket.Departure_Date__c.addDays(-1);
        }
        return result;
    }


    public static void markOutboundAndInbound(List<Ticket__c> passengerTickets, CaseTicketsStats currentStats ) {

        Integer ticketListPos = 0;
        while (ticketListPos < passengerTickets.size()) {
            Ticket__c nextTicket = passengerTickets[ticketListPos];
            Ticket__c possiblePairTicket = (ticketListPos + 1 < passengerTickets.size()) ? passengerTickets[ticketListPos + 1] : null;
            Boolean isFoundOutboundInScope = false;
            Boolean isFoundInboundInScope = false;
            Boolean isFoundOutboundActive = false;
            Boolean isFoundInboundActive = false;
            Integer firstOutboundIndex = -1;
            Integer lastOutboundIndex = -1;
            Integer currentTicketState;
            Boolean isFoundActiveOutboundInScope = false;
            Boolean isFoundActiveInboundInScope = false;
            //FIRST_OUTBOUND
            currentTicketState = OUTBOUND;
            if (nextTicket.Cancelled_By_Customer__c) {
                currentTicketState = currentTicketState | CANCELLED;
            } else if (nextTicket.Checked_In__c) {
                currentTicketState = currentTicketState | CHECKED_IN;
            } else {
                currentTicketState = currentTicketState | ACTIVE;
                currentStats.ticketsActive++;
                isFoundOutboundActive = true;
            }

            if (nextTicket.Departure_Date__c < POLICY_THRESHOLD_DATE){
                if (nextTicket.Departure_Date__c < getEarliestValidDate(nextTicket, currentStats)){
                    currentTicketState = currentTicketState | OUT_OF_SCOPE_BEFORE | OUT_OF_SCOPE;
                    currentStats.ticketsOutOfScope++;
                } else if (nextTicket.Departure_Date__c > getLatestValidDate(nextTicket, currentStats)){
                    currentTicketState = currentTicketState | OUT_OF_SCOPE_AFTER | OUT_OF_SCOPE;
                    currentStats.ticketsOutOfScope++;
                }
                if ((currentTicketState & OUT_OF_SCOPE) == OUT_OF_SCOPE) {
                    currentStats.isThere60DaysRejectionReason = true;
                }
            } else {
                if (nextTicket.Departure_Date__c < getEarliestValidDate(nextTicket, currentStats)){
                    currentTicketState = currentTicketState | OUT_OF_SCOPE_BEFORE | OUT_OF_SCOPE;
                    currentStats.ticketsOutOfScope++;
                } else if (nextTicket.Departure_Date__c > getLatestValidDate(nextTicket, currentStats)){
                    currentTicketState = currentTicketState | OUT_OF_SCOPE_AFTER | OUT_OF_SCOPE;
                    currentStats.ticketsOutOfScope++;
                }
                if ((currentTicketState & OUT_OF_SCOPE) == OUT_OF_SCOPE) {
                    if (nextTicket.Departure_Date__c <= getLatestDateCutoff(nextTicket)) {
                        if (nextTicket.Train__r.Cancelled__c) {
                            currentStats.isThere60DaysRejectionReason = true;
                        } else {
                            currentStats.isThereClaimPastTravelRejectionReason = true;
                        }
                    } else {
                        if (nextTicket.Train__r.Cancelled__c) currentStats.isThereCancelledTrainsPastTheScope = true;
                        if (nextTicket.Package_Booking__c) currentStats.isTherePackageTrainsPastTheScope = true;
                    }
                }
            }

            if ((currentTicketState & OUT_OF_SCOPE) == 0) {
                isFoundOutboundInScope = true;
            }

            if (isFoundOutboundActive && isFoundOutboundInScope) {
                isFoundActiveOutboundInScope = true;
            }

            currentStats.ticketsStates.put(nextTicket.Id, currentTicketState);

            firstOutboundIndex = ticketListPos;
            lastOutboundIndex = ticketListPos;

            String baseDestination = nextTicket.Destination__c;

            ticketListPos++; //!!!!!!!!!!!!!!!!

            if (possiblePairTicket != null) {
                // OUTBOUND TICKETS
                while (possiblePairTicket != null && possiblePairTicket.Destination__c == baseDestination) {
                    lastOutboundIndex++;

                    isFoundOutboundActive = false;
                    isFoundOutboundInScope = false;

                    currentTicketState = OUTBOUND;
                    if (possiblePairTicket.Cancelled_By_Customer__c) {
                        currentTicketState = currentTicketState | CANCELLED;
                    } else if (possiblePairTicket.Checked_In__c) {
                        currentTicketState = currentTicketState | CHECKED_IN;
                    } else {
                        currentTicketState = currentTicketState | ACTIVE;
                        currentStats.ticketsActive++;
                        isFoundOutboundActive = true;
                    }

                    if (possiblePairTicket.Departure_Date__c < POLICY_THRESHOLD_DATE){
                        if (possiblePairTicket.Departure_Date__c < getEarliestValidDate(possiblePairTicket, currentStats)){
                            currentTicketState = currentTicketState | OUT_OF_SCOPE_BEFORE | OUT_OF_SCOPE;
                            currentStats.ticketsOutOfScope++;
                        } else if (possiblePairTicket.Departure_Date__c > getLatestValidDate(possiblePairTicket, currentStats)){
                            currentTicketState = currentTicketState | OUT_OF_SCOPE_AFTER | OUT_OF_SCOPE;
                            currentStats.ticketsOutOfScope++;
                        }
                        if ((currentTicketState & OUT_OF_SCOPE) == OUT_OF_SCOPE) {
                            currentStats.isThere60DaysRejectionReason = true;
                        }
                    } else {
                        if (possiblePairTicket.Departure_Date__c < getEarliestValidDate(possiblePairTicket, currentStats)){
                            currentTicketState = currentTicketState | OUT_OF_SCOPE_BEFORE | OUT_OF_SCOPE;
                            currentStats.ticketsOutOfScope++;
                        } else if (possiblePairTicket.Departure_Date__c > getLatestValidDate(possiblePairTicket, currentStats)){
                            currentTicketState = currentTicketState | OUT_OF_SCOPE_AFTER | OUT_OF_SCOPE;
                            currentStats.ticketsOutOfScope++;
                        }
                        if ((currentTicketState & OUT_OF_SCOPE) == OUT_OF_SCOPE) {
                            if (possiblePairTicket.Departure_Date__c <= getLatestDateCutoff(possiblePairTicket)) {
                                if (possiblePairTicket.Train__r.Cancelled__c) {
                                    currentStats.isThere60DaysRejectionReason = true;
                                } else {
                                    currentStats.isThereClaimPastTravelRejectionReason = true;
                                }
                            } else {
                                if (possiblePairTicket.Train__r.Cancelled__c) currentStats.isThereCancelledTrainsPastTheScope = true;
                                if (possiblePairTicket.Package_Booking__c) currentStats.isTherePackageTrainsPastTheScope = true;
                            }
                        }
                    }

                    if ((currentTicketState & OUT_OF_SCOPE) == 0) {
                        isFoundOutboundInScope = true;
                    }

                    if (isFoundOutboundActive && isFoundOutboundInScope) {
                        isFoundActiveOutboundInScope = true;
                    }
                    currentStats.ticketsStates.put(possiblePairTicket.Id, currentTicketState);

                    ticketListPos++;
                    possiblePairTicket = (ticketListPos < passengerTickets.size()) ? passengerTickets[ticketListPos] : null;
                }
                // INBOUND TICKETS
                if (possiblePairTicket != null) {
                    String baseOrigin = possiblePairTicket.Origin__c;

                    if (possiblePairTicket.Origin__c == baseOrigin) {
                        while (possiblePairTicket != null && possiblePairTicket.Origin__c == baseOrigin) {

                            currentStats.containsFullJourney = true;

                            isFoundInboundActive = false;
                            isFoundInboundInScope = false;

                            Integer statsForInbound = INBOUND;
                            if (possiblePairTicket.Cancelled_By_Customer__c) {
                                statsForInbound = statsForInbound | CANCELLED;
                            } else if (possiblePairTicket.Checked_In__c) {
                                statsForInbound = statsForInbound | CHECKED_IN;
                            } else {
                                statsForInbound = statsForInbound | ACTIVE;
                                currentStats.ticketsActive++;
                                isFoundInboundActive = true;
                            }

                            if (possiblePairTicket.Departure_Date__c < POLICY_THRESHOLD_DATE){
                                if (possiblePairTicket.Departure_Date__c < getEarliestValidDate(possiblePairTicket, currentStats)){
                                    statsForInbound = statsForInbound | OUT_OF_SCOPE_BEFORE | OUT_OF_SCOPE;
                                    currentStats.ticketsOutOfScope++;
                                } else if (possiblePairTicket.Departure_Date__c > getLatestValidDate(possiblePairTicket, currentStats)){
                                    statsForInbound = statsForInbound | OUT_OF_SCOPE_AFTER | OUT_OF_SCOPE;
                                    currentStats.ticketsOutOfScope++;
                                }
                                if ((currentTicketState & OUT_OF_SCOPE) == OUT_OF_SCOPE) {
                                    currentStats.isThere60DaysRejectionReason = true;
                                }
                            } else {
                                if (possiblePairTicket.Departure_Date__c < getEarliestValidDate(possiblePairTicket, currentStats)){
                                    statsForInbound = statsForInbound | OUT_OF_SCOPE_BEFORE | OUT_OF_SCOPE;
                                    currentStats.ticketsOutOfScope++;
                                } else if (possiblePairTicket.Departure_Date__c > getLatestValidDate(possiblePairTicket, currentStats)){
                                    statsForInbound = statsForInbound | OUT_OF_SCOPE_AFTER | OUT_OF_SCOPE;
                                    currentStats.ticketsOutOfScope++;
                                }
                                if ((statsForInbound & OUT_OF_SCOPE) == OUT_OF_SCOPE) {
                                    if (possiblePairTicket.Departure_Date__c <= getLatestDateCutoff(possiblePairTicket)) {
                                        if (possiblePairTicket.Train__r.Cancelled__c) {
                                            currentStats.isThere60DaysRejectionReason = true;
                                        } else {
                                            currentStats.isThereClaimPastTravelRejectionReason = true;
                                        }
                                    } else {
                                        if (possiblePairTicket.Train__r.Cancelled__c) currentStats.isThereCancelledTrainsPastTheScope = true;
                                        if (possiblePairTicket.Package_Booking__c) currentStats.isTherePackageTrainsPastTheScope = true;
                                    }
                                }
                            }

                            if ((statsForInbound & OUT_OF_SCOPE) == 0) {
                                isFoundInboundInScope = true;
                            }

                            if (isFoundInboundActive && isFoundInboundInScope) {
                                isFoundActiveInboundInScope = true;
                            }

                            // mark next inbound ticket as having outbound in scope and/or having outbound active
                            if (isFoundOutboundInScope) {
                                statsForInbound = statsForInbound | HAS_OUTBOUND_IN_SCOPE;
                            }
                            if (isFoundOutboundActive) {
                                statsForInbound = statsForInbound | HAS_OUTBOUND_ACTIVE;
                            }
                            if (isFoundActiveOutboundInScope) {
                                statsForInbound = statsForInbound | HAS_ACTIVE_OUTBOUND_IN_SCOPE;
                            }
                            currentStats.ticketsStates.put(possiblePairTicket.Id, statsForInbound);

                            ticketListPos++;
                            possiblePairTicket = (ticketListPos < passengerTickets.size()) ? passengerTickets[ticketListPos] : null;
                        }
                        // mark previous outbound tickets as having inbound in scope and/or having inbound active
                        if (isFoundInboundInScope || isFoundInboundActive) {
                            for (Integer nextOutboundIndex = firstOutboundIndex; nextOutboundIndex <= lastOutboundIndex; nextOutboundIndex++ ) {
                                Integer outboundTicketStates = currentStats.ticketsStates.get(passengerTickets[nextOutboundIndex].Id);
                                if (isFoundInboundInScope) {
                                    outboundTicketStates = outboundTicketStates | HAS_INBOUND_IN_SCOPE;
                                }
                                if (isFoundInboundActive) {
                                    outboundTicketStates = outboundTicketStates | HAS_INBOUND_ACTIVE;
                                }
                                if (isFoundActiveInboundInScope) {
                                    outboundTicketStates = outboundTicketStates | HAS_ACTIVE_INBOUND_IN_SCOPE;
                                }
                                currentStats.ticketsStates.put(passengerTickets[nextOutboundIndex].Id, outboundTicketStates);
                            }
                        }
                    } else {
                        //return to beginning of MAIN while loop
                    }
                    //here we supposed to have last inbound ticket from full trip marked
                    //if previous while loop worked at leas once
                    //so we should return to beginning of MAIN while loop
                }
            } else {
                ticketListPos++;
            }
        }
    }

}