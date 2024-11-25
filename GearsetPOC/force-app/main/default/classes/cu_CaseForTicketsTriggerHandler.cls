public with sharing class cu_CaseForTicketsTriggerHandler {


    private static final string CASE_TYPE = 'New Standard Case';

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

            Map <string, Case> mapCasesToUpdate = getCasesForCheck(cases);
            List <Ticket__c> listTickets = cu_CaseUpdateHelper.getTicketsByCase(new list<string>(mapCasesToUpdate.keySet()));



            //check case owner
            Map <string, List<Ticket__C>> ticketsByPnr = new Map<string, List<Ticket__C>>();
            for (Ticket__C ticket : listTickets) {
                List<Ticket__C> ticketList = ticketsByPnr.containsKey(ticket.PNR__c)?  ticketsByPnr.get(ticket.PNR__c) : new List<Ticket__C>();
                ticketList.add(ticket);
                ticketsByPnr.put(ticket.PNR__c, ticketList);
            }
            listTickets = new List<Ticket__C>();
            for(Case caseRecord: cases) {
                List<Ticket__c> tickets = ticketsByPnr.get(caseRecord.PNR__c)==null ? new List<Ticket__C>() : ticketsByPnr.get(caseRecord.PNR__c);
                listTickets.addAll(checkAccountOwner(caseRecord, tickets));

            }

            for (Ticket__c ticket : listTickets){
                Case caseRecord = mapCasesToUpdate.get(ticket.PNR__c);
                caseRecord.Train_LInked_With_TCN__c = ticket.Train__c;
                caseRecord.Class_of_Service__c = ticket.Class_of_Service__c;

            }
        }
    }

    private static integer getNumberOfItemsByField(List<Ticket__c> tickets, string fieldName, string value) {
        integer valuesCount = 0;
        if(tickets!=null){
            for (Ticket__c ticket : tickets) {

                valuesCount = checkFieldValue(ticket, fieldName, value)? valuesCount + 1: valuesCount;
            }
        }
        return valuesCount;
    }

    private static Boolean checkFieldValue(Ticket__c ticket, string fieldName, string value) {
        string fieldValue =  (String) ticket.get(fieldName);
        return fieldValue==null?false:fieldValue.toLowerCase().contains(value.toLowerCase());
    }

    private static List<Ticket__C> checkAccountOwner(Case caseRecord, List<Ticket__C> tickets) {
        List<Ticket__C> checkedTickets = new List<Ticket__C>();
        for (Ticket__C ticket : tickets) {
            /*if (ticket.Booker__c == caseRecord.AccountId) {
                checkedTickets.add(ticket);
            }*/
            checkedTickets.add(ticket);
        }
        System.debug(caseRecord.PNR__c + ' ' + checkedTickets.size());
        return checkedTickets;
    }

    public static void BookingTypeField_update(list <Case> cases){
        system.debug('BookingTypeField_update');
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            Map <string, Case> mapCasesToUpdate = getCasesForCheck(cases);
            Map<string, List<Ticket__c>> mapTickets =
                    cu_CaseUpdateHelper.getTicketsWithBookingByPNR(new list<string>(mapCasesToUpdate.keySet()), Date.today());
            for (string pnr : mapCasesToUpdate.keySet()) {
                Case caseRecord = mapCasesToUpdate.get(pnr);
                List<Ticket__c> tickets = mapTickets.get(pnr)==null ? new List<Ticket__C>() : mapTickets.get(pnr);
                string bookingType = string.isNotBlank(caseRecord.Booking_Type__c)? caseRecord.Booking_Type__c : '';

                //check case owner
                tickets = checkAccountOwner(caseRecord, tickets);


                // Wheelchair
                if (string.isBlank(bookingType) && getNumberOfItemsByField(tickets, 'PAX_Type_Description__c', 'Wheelchair')> 0) {
                    bookingType = 'Wheelchair traveller with or without Companion';
                }
                // Dog
                integer numberOfItemsByValue =  getNumberOfItemsByField(tickets, 'PAX_Type__c', 'DOG');
                if (string.isBlank(bookingType) && numberOfItemsByValue> 0) {
                    bookingType = (numberOfItemsByValue == tickets.size())?  'Standalone guide dog'
                            : 'Assisted traveller with Guide dog';
                }
                // Blocked_seat (loyal disregarded)
                bookingType = (string.isBlank(bookingType) && getNumberOfItemsByField(tickets, 'PAX_Type_Filter__c', 'Blocked_seat')> 0)?
                        'Musical Instrument' : bookingType;
                // LOYAL
                for (Ticket__c ticket : tickets) {
                    if (string.isBlank(bookingType) && checkFieldValue(ticket, 'PAX_Type_Filter__c',  'LOYAL')
                            && (string.isBlank(ticket.Non_Eurostar_Destination__c) && (string.isBlank(ticket.Non_Eurostar_Origin__c)))) {
                        bookingType = 'Points Booking (core/direct)';
                    }
                    if (string.isBlank(bookingType) && checkFieldValue(ticket, 'PAX_Type_Filter__c',  'LOYAL')
                            && (string.isNotBlank(ticket.Non_Eurostar_Destination__c) || string.isNotBlank(ticket.Non_Eurostar_Origin__c)) ) {
                        bookingType = 'Indirect route with points';
                    }
                }
                // PUB
                bookingType = (string.isBlank(bookingType) && getNumberOfItemsByField(tickets, 'PAX_Type_Filter__c', 'PUB')> 0) ?
                        'Public booking (no points used)': bookingType;

                caseRecord.Booking_Type__c  = bookingType;
            }

        }
    }

    private static string isIntraShengen(Ticket__c ticket, string condition, string value){
        string journeyType = '';
        if(string.isNotBlank(ticket.Origin__c) &&  string.isNotBlank(ticket.Destination__c)){
            List<string> parts = condition.toLowerCase().split('\\+');
            if (parts.size() == 2 && string.isBlank(journeyType)) {
                if((ticket.Origin__c.toLowerCase().contains(parts[0]) && ticket.Destination__c.toLowerCase().contains(parts[1]))
                        || (ticket.Origin__c.toLowerCase().contains(parts[1]) && ticket.Destination__c.toLowerCase().contains(parts[0]))) {
                    journeyType = value;
                }
            }
        }
        return journeyType;
    }

    private static string isAmsterdam(Ticket__c ticket, string condition,string value ){
        string journeyType = '';
        List<string> parts = condition.toLowerCase().split('\\+');
        if (parts.size()>0 && string.isBlank(journeyType)) {
            for (string part : parts){
                if((string.isNotBlank(ticket.Origin__c) && ticket.Origin__c.toLowerCase().contains(part) && ticket.Origin__c != 'Amsterdam Central')
                        || (string.isNotBlank(  ticket.Destination__c) && ticket.Destination__c.toLowerCase().contains(part) && ticket.Destination__c != 'Amsterdam Central')) {
                    journeyType = 'Amsterdam/Rotterdam';
                }
            }
        }
        return journeyType;
    }

    private static Boolean isFieldRuleValid(Ticket__c ticket, string fieldName, string condition){
        Boolean isValid  = false;
        List<string> parts = condition.toLowerCase().split('\\+');
        string fieldValue =  (String) ticket.get(fieldName);
        if (parts.size()>0 && string.isNotBlank(fieldValue)) {
            for (string value : parts) {

                if(fieldValue.tolowerCase().contains(value) ) {
                    isValid = true;
                }
            }
        }
        return isValid;
    }

    public static void jorneyTypeField_update(list <Case> cases){
        system.debug('jorneyTypeField_update');
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            list< Case> listCasesToCheck = new List <Case>();
            System.debug(listCasesToCheck.size());
            for (Case caseRecord : cases){
                if (string.isBlank(caseRecord.DLT_Destination__c)&&string.isBlank(caseRecord.PNR__c)&&caseRecord.RecordTypeId == getRecordTypeId()&&String.isBlank(caseRecord.Journey_Type_Product__c)){
                    caseRecord.Journey_Type_Product__c = 'General Query';

                }
                listCasesToCheck.add(caseRecord);
            }
            Map <string, Case> mapCasesToUpdate = getCasesForCheck(listCasesToCheck);
            Map <string, List<Ticket__c>> mapTickets = cu_CaseUpdateHelper.getTicketsWithBookingByPNR(new list<string>(mapCasesToUpdate.keySet()), Date.today());
            Journey_Type_By_PNR__c settings = Journey_Type_By_PNR__c.getInstance('Default');
            Set<string> listStationNamesOfCheck = cu_CaseUpdateHelper.getStationNamesBelgiumAndDutch();

            for (Case caseRecord : cases) {
                if(mapTickets.get(caseRecord.PNR__c)!=null){
                    List<Ticket__c> tickets = mapTickets.get(caseRecord.PNR__c);
                    string journeyType =  string.isNotBlank(caseRecord.Journey_Type_Product__c) ? caseRecord.Journey_Type_Product__c : '';
                    if (String.isNotBlank(caseRecord.PNR__c) && String.isNotBlank(caseRecord.Journey_Type_Product__c)) {
                        if (caseRecord.Journey_Type_Product__c == 'General Query') {
                            journeyType = '';
                        }
                    }
                    Integer counter = 0;

                    // check account owner
                    tickets = checkAccountOwner(caseRecord, tickets);

                    List<string> parts = new List<string>();
                    while (string.isBlank(journeyType) && counter != tickets.size() && settings != null) {
                        string condition = '';
                        Ticket__c ticket = tickets[counter];
                        //Amsterdam/Rotterdam

                        condition = settings.Amsterdam_Roterdam__c;

                        journeyType = string.isBlank(journeyType)? isAmsterdam(ticket, condition, 'Amsterdam/Rotterdam') : journeyType;

                        //Any Belgian and Any Dutch
                        condition = settings.Belgian_and_Dutch__c;
                        parts = condition.split('\\+');
                        if (string.isNotBlank(ticket.Non_Eurostar_Destination__c)
                                && listStationNamesOfCheck.contains(ticket.Non_Eurostar_Destination__c)) {
                            journeyType = '	Any Belgian and Any Dutch';
                        }

                        //Intra-schengen (LIU-BXS)
                        condition = settings.Intra_schengen_LIU__c;
                        journeyType = string.isBlank(journeyType)? isIntraShengen(ticket, condition, 'Intra-schengen (LIU-BXS)') : journeyType;

                        //Intra-schengen (BXS-ROT/AMS)
                        condition = settings.Intra_schengen_ROT_and_AMS__c;
                        journeyType  = string.isBlank(journeyType)? isIntraShengen(ticket, condition, 'Intra-schengen (BXS-ROT/AMS)') : journeyType;
                        //Disney
                        condition = settings.Disney__c;
                        parts = condition.tolowerCase().split('\\+');
                        if (parts.size() > 0 && string.isBlank(journeyType)) {
                            for (string part : parts){
                                if ((string.isNotBlank(ticket.Non_Eurostar_Destination__c)
                                        && ticket.Non_Eurostar_Destination__c.contains(part))
                                        ||(string.isNotBlank(ticket.Destination__c) && ticket.Destination__c.contains(part))){
                                    journeyType = 'Disney';
                                }
                            }
                        }


                        //Inter caps 
                        condition = settings.Inter_caps__c;
                        parts = condition.tolowerCase().split('\\+');
                        if (parts.size() > 0 && string.isBlank(journeyType)) {
                            for (string part : parts){
                                if (string.isBlank(ticket.Non_Eurostar_Destination__c)
                                        && string.isBlank(ticket.Connecting_Destination__c)
                                        && ((string.isNotBlank(ticket.Origin__c) &&ticket.Origin__c.tolowerCase().contains(part))
                                        ||  (string.isNotBlank(ticket.Destination__c) &&ticket.Destination__c.tolowerCase().contains(part)))){
                                    journeyType = 'Inter caps';
                                }
                            }
                        }
                        //Interlinning/Domestic rail
                        condition = settings.Interlinning_Domestic_rail__c;
                        parts = condition.split('\\+');

                        //Lyon South of France
                        condition = settings.Lyon_South_of_France__c;
                        if (string.isBlank(journeyType) &&  isFieldRuleValid(ticket, 'Destination__c', condition .toLowerCase())){
                            journeyType = 'Lyon South of France';
                        }

                        //Passholder
                        condition = settings.Passholder__c;
                        if (string.isBlank(journeyType) &&  isFieldRuleValid(ticket, 'PAX_Type_Filter__c', condition.tolowerCase() )){
                            journeyType = 'Passholder';
                        }
                        //Ski
                        condition = settings.Ski__c;
                        if (string.isBlank(journeyType) &&  isFieldRuleValid(ticket, 'PAX_Type_Description__c', condition.tolowerCase() )){
                            journeyType = 'Ski';
                        }

                        //Snap
                        condition = settings.Snap__c;
                        parts = condition.split('\\+');
                        //Child fare
                        condition = settings.Child_fare__c;
                        if (string.isBlank(journeyType) &&  isFieldRuleValid(ticket, 'PAX_Type__c', condition.tolowerCase() )){
                            journeyType = 'Child fare';
                        }

                        //Sundry

                        //Thalys Through Fare
                        condition = settings.Thalys_Through_Fare__c;
                        if (string.isBlank(journeyType) &&  isFieldRuleValid(ticket, 'Non_Eurostar_Destination__c', condition.tolowerCase() )){
                            journeyType = 'Thalys Through Fare';
                        }

                        //Concession (Core) or  Concession (Other)
                        condition = settings.Concession_Core__c;
                        parts = condition.split('\\+');
                        if (parts.size()>0 && string.isBlank(journeyType)&&ticket.PAX_Type_Filter__c!=null) {

                            if((ticket.PAX_Type_Filter__c.toLowerCase().contains(parts[0].tolowerCase()) ||
                                    ticket.PAX_Type_Filter__c.toLowerCase().contains(parts[1].tolowerCase())
                                    || ticket.PAX_Type_Filter__c.toLowerCase().contains(parts[2].tolowerCase()) )
                                    ) {
                                journeyType = string.isBlank(ticket.Non_Eurostar_Destination__c)||ticket.Non_Eurostar_Destination__c==null ? 'Concession (Core)': 'Concession (Other)' ;
                            }
                        }


                        //French provinces (connections)
                        condition = settings.French_provinces__c;
                        parts = condition.split('\\+');
                        Set<string> setExcludeForFrance = new Set <string> (parts);
                        if (string.isBlank(journeyType)) {
                            if (string.isNotBlank(ticket.Non_Eurostar_Destination__c)
                                    && !setExcludeForFrance.contains(ticket.Non_Eurostar_Destination__c)
                                    && !listStationNamesOfCheck.contains(ticket.Non_Eurostar_Destination__c)) {
                                journeyType = 'French provinces (connections)';
                            }
                        }
                        counter +=  1;
                    }

                    caseRecord.Journey_Type_Product__c = String.isNotBlank(journeyType)?journeyType:'General Query';
                    System.debug(caseRecord.pnr__c + '  ' + caseRecord.Journey_Type_Product__c);


                }

            }
        }
    }
}