public with sharing class cu_CaseForTicketsTriggerHandler {

    private static final string CASE_TYPE = 'New Standard Case';
    private static final Integer TOP_PRIORITY = 1;

    private static Map<String, Case> mapCasesToUpdate = new Map<String, Case>();
    private static Map<String, List<Ticket__c>> mapTickets = new Map<String, List<Ticket__c>>();

    private static List<String> BOOKING_TYPE_CONCESSION_FARE_PAX_FILTERS = new List<String> {
        'TFL', 'TRADE', 'CONCESSIONS', 'REWRD','PAX'
    };
    private static List<String> BOOKING_TYPE_CONCESSION_FARE_PAX_DESCRIPTIONS = new List<String> {
        'TFL', 'PARTN'
    };
    private static List<String> BOOKING_TYPE_STAFF_TRAVEL_PAX_FILTERS = new List<String> {
        'CONT', 'FIP', 'STAFF', 'DUTY', 'JOL', 'DTOLL', 'MICE', 'MOM', 'PALS'
    };
    private static List<String> BOOKING_TYPE_STAFF_TRAVEL_PAX_DESCRIPTIONS = new List<String> {
        'Educational', 'Contr', 'Duty', 'MICE', 'MOM', 'PALS'
    };
    private static List<String> BOOKING_TYPE_NON_THIRD_PARTY_BOOKING_POS = new List<String> {
        'EIL', 'EHL', 'EUROSTAR'
    };
    private static List<String> BOOKING_TYPE_TRADE_BOOKING_FOP = new List<String> {
        'BAF', 'INV'
    };
    private static List<String> BOOKING_TYPE_TRADE_BOOKING_POS = new List<String> {
        'Package', 'EHL'
    };
    private static List<String> BOOKING_TYPE_ASSISTANCE_PAX_DESCRIPTIONS = new List<String> {
        'Wheelchair', 'WC'
    };
    private static List<String> BOOKING_TYPE_ASSISTANCE_CLASS_OF_SERVICE = new List<String> {
        'Wheelchair', 'companion'
    };

    private static Set<String> CROSS_CHANEL_ROUTES = new Set<String>{
        cu_Utils.ASHFORD_INTERNATIONAL.toLowerCase(),
        cu_Utils.EBBSFLEET_INTERNATIONAL.toLowerCase(),
        cu_Utils.ST_PANCRAS_INTERNATIONAL.toLowerCase()
    };
    private static Set<String> SKI_ROUTES = new Set<String>{
        cu_Utils.ALBERTVILLE.toLowerCase(),
        cu_Utils.AIME_LA_PLAGNE.toLowerCase(),
        cu_Utils.BOURG_ST_MAURICE.toLowerCase(),
        cu_Utils.CHAMBERY.toLowerCase(),
        cu_Utils.LANDRY.toLowerCase(),
        cu_Utils.MOUTIERS.toLowerCase()
    };
    private static Set<String> SUN_ROUTES = new Set<String>{
        cu_Utils.AIX_EN_PROVENCE.toLowerCase(),
        cu_Utils.AVIGNON.toLowerCase(),
        cu_Utils.MARSEILLES.toLowerCase(),
        cu_Utils.VALENCE.toLowerCase()
    };
    private static Set<String> CONTINENTAL_ROUTES = new Set<String>{
        cu_Utils.PARIS_CHARLES_DE_GAULLE_AIRPORT_WITHOUT_DASH.toLowerCase(),
        cu_Utils.ANTWERP.toLowerCase(),
        cu_Utils.LIEGE.toLowerCase(),
        cu_Utils.AACHEN.toLowerCase(),
        cu_Utils.COLOGNE.toLowerCase(),
        cu_Utils.DUISBURG.toLowerCase(),
        cu_Utils.DORTMUND.toLowerCase(),
        cu_Utils.DUSSELDORF.toLowerCase(),
        cu_Utils.DUSSELDORF_AIRPORT.toLowerCase(),
        cu_Utils.ESSEN.toLowerCase()
    };
    private static Set<String> MULTI_ROUTES = new Set<String>{
        cu_Utils.CALAIS_FRETHUN.toLowerCase(),
        cu_Utils.DISNEYLAND_PARIS.toLowerCase(),
        cu_Utils.LILLE_EUROPE.toLowerCase(),
        cu_Utils.LYON_PART_DIEU.toLowerCase(),
        cu_Utils.PARIS_GARE_DU_NORD.toLowerCase(),
        cu_Utils.BRUSSELS_MIDI_ZUID.toLowerCase(),
        cu_Utils.AMSTERDAM_CENTRAAL.toLowerCase(),
        cu_Utils.ROTTERDAM_CENTRAAL.toLowerCase(),
        cu_Utils.SCHIPHOL_AIRPORT.toLowerCase()
    };


    private static ID getRecordTypeId(){
        return Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_TYPE).getRecordTypeId();
    }

    private static Map<string, Case> getCasesForCheck(List<Case> cases){
        Map<string, Case> mapCases = new Map<string, Case>();
        ID recordTypeId = getRecordTypeId();
        for (Case caseRecord: cases){
            if(caseRecord.RecordTypeId == recordTypeId ){
                if (string.isNotEmpty(caseRecord.PNR__c)) {
                    mapCases.put(caseRecord.PNR__c, caseRecord);
                }

            }
        }
        return mapCases;
    }

    public static void ClassOfServiceFields_update(list <Case> cases){
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            system.debug('ClassOfServiceFields_update');

            Map<String, Set<String>> classesOfServiceByTicketPnr = new Map<String, Set<String>>();
            mapCasesToUpdate = mapCasesToUpdate.keySet().size() == 0 ? getCasesForCheck(cases) : mapCasesToUpdate;
            List <Ticket__c> listTickets = cu_CaseUpdateHelper.getTicketsByCase(new list<string>(mapCasesToUpdate.keySet()));

            //check case owner
            Map <string, List<Ticket__C>> ticketsByPnr = new Map<string, List<Ticket__C>>();
            for (Ticket__C ticket : listTickets) {
                List<Ticket__C> ticketList = ticketsByPnr.containsKey(ticket.PNR__c)?  ticketsByPnr.get(ticket.PNR__c) : new List<Ticket__C>();
                ticketList.add(ticket);
                ticketsByPnr.put(ticket.PNR__c, ticketList);

                if (String.isBlank(ticket.Class_of_Service__c)) {continue;}
                if (classesOfServiceByTicketPnr.containsKey(ticket.PNR__c)) {
                    classesOfServiceByTicketPnr.get(ticket.PNR__c).add(ticket.Class_of_Service__c);
                } else {
                    classesOfServiceByTicketPnr.put(ticket.PNR__c, new Set<String>{ticket.Class_of_Service__c});
                }
            }
            listTickets = new List<Ticket__C>();
            for(Case caseRecord: cases) {
                if (!mapCasesToUpdate.containsKey(caseRecord.PNR__c)) {continue;}

                List<Ticket__c> tickets = ticketsByPnr.get(caseRecord.PNR__c) == null
                        ? new List<Ticket__C>()
                        : ticketsByPnr.get(caseRecord.PNR__c);

                for (Ticket__c ticket : tickets){
                    caseRecord.Train_LInked_With_TCN__c = ticket.Train__c;
                    if (classesOfServiceByTicketPnr.containsKey(ticket.PNR__c) && classesOfServiceByTicketPnr.get(ticket.PNR__c).size() > 1) {
                        caseRecord.Class_of_Service__c = cu_Utils.CASE_CLASS_OF_SERVICE_COMBINATION;
                    } else {
                        caseRecord.Class_of_Service__c = ticket.Class_of_Service__c;
                    }
                }
            }
        }
    }

    public static void BookingTypeField_update(List<Case> cases, Map<Id, Case> oldCases){
        system.debug('BookingTypeField_update');
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            mapCasesToUpdate = mapCasesToUpdate.keySet().size() == 0 
                ? getCasesForCheck(cases) 
                : mapCasesToUpdate;
            
            mapTickets = mapTickets.keySet().size() == 0
                ? cu_CaseUpdateHelper.getTicketsWithBookingByPNR(new List<String>(mapCasesToUpdate.keySet()), Date.today())
                : mapTickets;

            for (Case caseRecord : cases) {
                if (String.isBlank(caseRecord.PNR__c)
                    && caseRecord.RecordTypeId == getRecordTypeId()
                    && String.isBlank(caseRecord.Booking_Type__c)
                ) {
                    caseRecord.Booking_Type__c = cu_Utils.BOOKING_TYPE_GENERAL_QUERY;
                    continue;
                }

                if(!mapCasesToUpdate.containsKey(caseRecord.PNR__c)) { continue; }

                Boolean isPNRChanged = oldCases.isEmpty() || (oldCases.containsKey(caseRecord.Id) && oldCases.get(caseRecord.Id).PNR__c != caseRecord.PNR__c);
                
                if (String.isBlank(caseRecord.Booking_Type__c) || isPNRChanged) {
                    List<Ticket__c> tickets = mapTickets.get(caseRecord.PNR__c) == null 
                        ? new List<Ticket__C>() 
                        : mapTickets.get(caseRecord.PNR__c);
                    
                    caseRecord.Booking_Type__c = getBookingValue(tickets);
                }
            }
       }
    }

    public static void CaseSubject_update(list <Case> cases){
        for  (Case caseRecord : cases) {
            if (caseRecord.Subject != null && caseRecord.Subject.contains(CaseService.CASE_SUBJECT_PLACEHOLDER)) {
                caseRecord.Subject = caseRecord.Subject.replace(CaseService.CASE_SUBJECT_PLACEHOLDER, String.isBlank(caseRecord.Booking_type__c) ? caseRecord.Topic__c : caseRecord.Booking_type__c);
            }
        }
    }

    public static void TypeOfAssistance_update(List<Case> newCases, Map<Id, Case> oldCases){
        mapCasesToUpdate = mapCasesToUpdate.keySet().size() == 0 ? getCasesForCheck(newCases) : mapCasesToUpdate;
        mapTickets = mapTickets.keySet().size() == 0
                ? cu_CaseUpdateHelper.getTicketsWithBookingByPNR(new List<string>(mapCasesToUpdate.keySet()), Date.today())
                : mapTickets;

        for (Case caseRecord : newCases) {
            if(!mapCasesToUpdate.containsKey(caseRecord.PNR__c)){continue;}

            Boolean isPNRChanged = oldCases.isEmpty() || (oldCases.containsKey(caseRecord.Id) && oldCases.get(caseRecord.Id).PNR__c != caseRecord.PNR__c);
            if (String.isBlank(caseRecord.Type_of_Assistance__c) || isPNRChanged) {

                List<Ticket__c> tickets = mapTickets.get(caseRecord.PNR__c) == null ? new List<Ticket__C>() : mapTickets.get(caseRecord.PNR__c);
                String typeOfAssistance = '';

                if (isListContainsValue(tickets, 'PAX_Type__c', 'DOG')) {
                    if (isListContainsValue(tickets, 'PAX_Type__c', 'Adult') || isListContainsValue(tickets, 'PAX_Type__c', 'Child')) {
                        caseRecord.Type_of_Assistance__c = cu_Utils.TYPE_OF_ASSISTANCE_TRAVEL_WITH_ANIMAL;
                        continue;
                    } else if (isListContainsValue(tickets, 'PAX_Type_Description__c', 'Wheelchair')) {
                        caseRecord.Type_of_Assistance__c = cu_Utils.TYPE_OF_ASSISTANCE_WHEELCHAIR_WITH_ANIMAL;
                        continue;
                    }
                    typeOfAssistance = cu_Utils.TYPE_OF_ASSISTANCE_ASSISTANCE_ANIMAL; 
                }
                if (isListContainsValue(tickets, 'PAX_Type_Description__c', 'WC') || isListContainsValue(tickets, 'Class_of_Service__c', 'Wheelchair')) {
                    typeOfAssistance = cu_Utils.TYPE_OF_ASSISTANCE_WHEELCHAIR_TRAVELLER;
                }
                if (String.isNotBlank(typeOfAssistance)) {
                    caseRecord.Type_of_Assistance__c  = typeOfAssistance;
                }
            }
        }
    }

    public static void jorneyTypeField_update(List<Case> cases, Map<Id, Case> oldCases){
        system.debug('jorneyTypeField_update');
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            mapCasesToUpdate = mapCasesToUpdate.keySet().size() == 0 ? getCasesForCheck(cases) : mapCasesToUpdate;
            mapTickets = mapTickets.keySet().size() == 0
                    ? cu_CaseUpdateHelper.getTicketsWithBookingByPNR(new list<string>(mapCasesToUpdate.keySet()), Date.today())
                    : mapTickets;
            Journey_Type_By_PNR__c settings = Journey_Type_By_PNR__c.getInstance('Default');

            for (Case caseRecord : cases) {
                if (string.isBlank(caseRecord.DLT_Destination__c)
                        && string.isBlank(caseRecord.DLT_Origin__c)
                        && string.isBlank(caseRecord.PNR__c)
                        && caseRecord.RecordTypeId == getRecordTypeId()
                        && String.isBlank(caseRecord.Journey_Type_Product__c)) {
                    continue;
                }
                if (String.isNotBlank(caseRecord.DLT_Origin__c) || String.isNotBlank(caseRecord.DLT_Destination__c)) {
                    updateJourneyTypeByDLTOriginAndDLTDestination(caseRecord, oldCases.keySet().size() > 0 ? oldCases.get(caseRecord.Id) : null);
                }

                Boolean isPNRChanged = oldCases.isEmpty() || (oldCases.containsKey(caseRecord.Id) && oldCases.get(caseRecord.Id).PNR__c != caseRecord.PNR__c);
                if(mapTickets.get(caseRecord.PNR__c) != null && (String.isBlank(caseRecord.Journey_Type_Product__c) || isPNRChanged)){
                    List<Ticket__c> tickets = mapTickets.get(caseRecord.PNR__c);
                    string journeyType =  string.isNotBlank(caseRecord.Journey_Type_Product__c) ? caseRecord.Journey_Type_Product__c : '';
                    if (String.isNotBlank(caseRecord.PNR__c)
                            && String.isBlank(caseRecord.DLT_Origin__c) 
                            && String.isBlank(caseRecord.DLT_Destination__c)
                            && !journeyType.containsIgnoreCase(cu_Utils.CASE_JOURNEY_PRODUCT_LUGGAGE)) {

                        journeyType = '';
                        if (tickets?.size() > 0) {
                            if (settings?.Ski__c != null  && (isListContainsOneOfConditions(tickets, 'Non_Eurostar_Destination__c', settings.Ski__c)
                                    || isListContainsOneOfConditions(tickets, 'Non_Eurostar_Origin__c', settings.Ski__c)
                                    || isListContainsOneOfConditions(tickets, 'Destination__c', settings.Ski__c)
                                    || isListContainsOneOfConditions(tickets, 'Origin__c', settings.Ski__c))){
                                journeyType = cu_Utils.CASE_JOURNEY_PRODUCT_SKI_ROUTES;
                            } else if (settings?.Lyon_South_of_France__c != null && (isListContainsOneOfConditions(tickets, 'Non_Eurostar_Destination__c', settings.Lyon_South_of_France__c)
                                    || isListContainsOneOfConditions(tickets, 'Non_Eurostar_Origin__c', settings.Lyon_South_of_France__c)
                                    || isListContainsOneOfConditions(tickets, 'Destination__c', settings.Lyon_South_of_France__c)
                                    || isListContainsOneOfConditions(tickets, 'Origin__c', settings.Lyon_South_of_France__c))) {
                                journeyType = cu_Utils.CASE_JOURNEY_PRODUCT_SUN_ROUTES;
                            } else if (isFieldNotEmpty(tickets, 'Connecting_Destination__c')) {
                                journeyType = cu_Utils.CASE_JOURNEY_PRODUCT_CONNECTIONS;
                            } else if (isListContainsValue(tickets, 'Carrier__c', DLT_CaseConstants.CARRIER_BLUE)) {
                                journeyType = cu_Utils.CASE_JOURNEY_PRODUCT_CROSS_CHANNEL_ROUTES;
                            } else if (isListContainsValue(tickets, 'Carrier__c', DLT_CaseConstants.CARRIER_RED)) {
                                journeyType = cu_Utils.CASE_JOURNEY_PRODUCT_CONTINENTAL_ROUTES;
                            }
                        }
                        caseRecord.Journey_Type_Product__c = journeyType;
                        System.debug(caseRecord.pnr__c + '  ' + caseRecord.Journey_Type_Product__c);
                    } 
                }
            }
        }
    }

    public static void updateJourneyTypeByDLTOriginAndDLTDestination(Case newCase, Case oldCase) {
        String DLT_Origin = '';
        String DLT_Destination = '';

        if (oldCase == null
            || (newCase.DLT_Origin__c != oldCase.DLT_Origin__c)
            || (newCase.DLT_Destination__c != oldCase.DLT_Destination__c)) {
            DLT_Origin = String.isNotBlank(newCase.DLT_Origin__c) ?  newCase.DLT_Origin__c : '';
            DLT_Destination = String.isNotBlank(newCase.DLT_Destination__c) ?  newCase.DLT_Destination__c : '';
        } else {
            return;
        }

        if (MULTI_ROUTES.contains(DLT_Destination.trim().toLowerCase()) || MULTI_ROUTES.contains(DLT_Origin.trim().toLowerCase())) {
            if (CROSS_CHANEL_ROUTES.contains(DLT_Destination.trim().toLowerCase()) || CROSS_CHANEL_ROUTES.contains(DLT_Origin.trim().toLowerCase())) {
                newCase.Journey_Type_Product__c = cu_Utils.CASE_JOURNEY_PRODUCT_CROSS_CHANNEL_ROUTES;
            } else {
                newCase.Journey_Type_Product__c = cu_Utils.CASE_JOURNEY_PRODUCT_CONTINENTAL_ROUTES;
            }
        } else if (SKI_ROUTES.contains(DLT_Destination.trim().toLowerCase()) || SKI_ROUTES.contains(DLT_Origin.trim().toLowerCase())) {
            newCase.Journey_Type_Product__c = cu_Utils.CASE_JOURNEY_PRODUCT_SKI_ROUTES;
        } else if (SUN_ROUTES.contains(DLT_Destination.trim().toLowerCase()) || SUN_ROUTES.contains(DLT_Origin.trim().toLowerCase())) {
            newCase.Journey_Type_Product__c = cu_Utils.CASE_JOURNEY_PRODUCT_SUN_ROUTES;
        } else if (CROSS_CHANEL_ROUTES.contains(DLT_Destination.trim().toLowerCase()) || CROSS_CHANEL_ROUTES.contains(DLT_Origin.trim().toLowerCase())) {
            newCase.Journey_Type_Product__c = cu_Utils.CASE_JOURNEY_PRODUCT_CROSS_CHANNEL_ROUTES;
        } else if (CONTINENTAL_ROUTES.contains(DLT_Destination.trim().toLowerCase()) || CONTINENTAL_ROUTES.contains(DLT_Origin.trim().toLowerCase())) {
            newCase.Journey_Type_Product__c = cu_Utils.CASE_JOURNEY_PRODUCT_CONTINENTAL_ROUTES;
        }
    }

    private static String getBookingValue(List<Ticket__c> tickets) {
        String bookingType = '';
        if (tickets == null || tickets.size() == 0) {
            return bookingType;
        }

        if (isFieldTrueOnceInList(tickets, 'Package_Booking__c') || isListContainsValue(tickets, 'Point_of_Sale__c', 'PACKAGE')) {
            bookingType = cu_Utils.BOOKING_TYPE_PACKAGE;
        } else if (isListContainsOneOfValues(tickets, 'PAX_Type_Description__c', BOOKING_TYPE_ASSISTANCE_PAX_DESCRIPTIONS)
                || isListContainsOneOfValues(tickets, 'Class_of_Service__c', BOOKING_TYPE_ASSISTANCE_CLASS_OF_SERVICE)
                || isListContainsValue(tickets, 'PAX_Type__c', 'DOG')) {
            bookingType = cu_Utils.BOOKING_TYPE_ASSISTANCE;
        } else if (isListContainsValue(tickets, 'PAX_Type_Filter__c', 'Blocked_seat')) {
            bookingType = cu_Utils.BOOKING_TYPE_MUSICAL_INSTRUMENT;
        } else if (isListContainsValue(tickets, 'PAX_Type_Filter__c', 'IRAIL') || isListContainsValue(tickets, 'PAX_Type_Description__c', 'INTER_RAIL')) {
            bookingType = cu_Utils.BOOKING_TYPE_PASSHOLDER_FARE;
        } else if (isListContainsOneOfValues(tickets, 'PAX_Type_Filter__c', BOOKING_TYPE_CONCESSION_FARE_PAX_FILTERS)
                || isListContainsOneOfValues(tickets, 'PAX_Type_Description__c', BOOKING_TYPE_CONCESSION_FARE_PAX_DESCRIPTIONS)) {
            bookingType = cu_Utils.BOOKING_TYPE_CONCESSION_FARE;
        } else if (isListContainsOneOfValues(tickets, 'PAX_Type_Filter__c', BOOKING_TYPE_STAFF_TRAVEL_PAX_FILTERS)
                || isListContainsOneOfValues(tickets, 'PAX_Type_Description__c', BOOKING_TYPE_STAFF_TRAVEL_PAX_DESCRIPTIONS)) {
            bookingType = cu_Utils.BOOKING_TYPE_STAFF_TRAVEL;
        } else if (isListContainsValue(tickets, 'PAX_Type_Filter__c', 'INVIT')
                || isListContainsValue(tickets, 'PAX_Type_Description__c', 'INVIT')) {
            bookingType = cu_Utils.BOOKING_TYPE_GIFT;
        } else if ((isListContainsValue(tickets, 'PAX_Type_Filter__c', 'RIT') || isListContainsValue(tickets, 'PAX_Type_Description__c', 'RIT'))
                && isListContainsOneOfValues(tickets, 'Form_OF_Payment__c', BOOKING_TYPE_TRADE_BOOKING_FOP)
                && !isListContainsOneOfValues(tickets, 'Point_of_Sale__c', BOOKING_TYPE_TRADE_BOOKING_POS)) {
            bookingType = cu_Utils.BOOKING_TYPE_TRADE_BOOKING;
        } else if (!isListContainsOneOfValues(tickets, 'Point_of_Sale__c', BOOKING_TYPE_NON_THIRD_PARTY_BOOKING_POS)) {
            bookingType = cu_Utils.BOOKING_TYPE_THIRD_PARTY_BOOKING;
        } else if (isListContainsValue(tickets, 'PAX_Type_Filter__c', 'LOYAL')) {
            bookingType = cu_Utils.BOOKING_TYPE_POINTS_BOOKING;
        } else if (isListContainsValue(tickets, 'PAX_Type_Filter__c', 'PUB')) {
            bookingType = cu_Utils.BOOKING_TYPE_PUBLIC_BOOKING;
        } else {
            bookingType = cu_Utils.BOOKING_TYPE_GENERAL_QUERY;
        }

        Ticket__c ticket = S3PassengerAPIService.getTicketWithNearestDepartureDateTimeInFuture(tickets);
        Boolean isLastMinuteTicket = ticket != null 
            && ticket.PAX_Type_Filter__c != null 
            && ticket.PAX_Type_Filter__c.containsIgnoreCase(DLT_TicketConstants.TICKET_PAX_TYPE_FILTER_LASTMIN);

        if (isLastMinuteTicket) {
            bookingType = DLT_CaseConstants.BOOKING_TYPE_LAST_MINUTE;
        }

        return bookingType;
    }

    private static Boolean isFieldContainsValue(Ticket__c ticket, String fieldApiName, String value) {
        String fieldValue =  (String) ticket.get(fieldApiName);
        return String.isBlank(fieldValue)
                ? false
                : fieldValue.containsIgnoreCase(value);
    }

    private static Boolean isListContainsValue(List<Ticket__c> tickets, string fieldName, string value) {
        if(tickets!=null){
            for (Ticket__c ticket : tickets) {
                if (isFieldContainsValue(ticket, fieldName, value)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static Boolean isFieldTrueOnceInList(List<Ticket__c> tickets, string fieldName){
        if(tickets!=null){
            for (Ticket__c ticket : tickets) {
                if ((Boolean) ticket.get(fieldName)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static Boolean isListContainsOneOfConditions(List<Ticket__c> tickets, string fieldName, string condition) {
        if (String.isBlank(condition)) { return false;}
        List<String> parts = condition.toLowerCase().split('\\+');
        for (String part : parts) {
            if (isListContainsValue(tickets, fieldName, part)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean isListContainsOneOfValues(List<Ticket__c> tickets, string fieldName, List<String> values) {
        for (String value : values) {
            if (isListContainsValue(tickets, fieldName, value)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean isFieldNotEmpty(List<Ticket__c> tickets, String fieldApiName) {
        if(tickets!=null){
            for (Ticket__c ticket : tickets) {
                if (String.isNotBlank( (String) ticket.get(fieldApiName) )) {
                    return true;
                }
            }
        }
        return false;
    }


}