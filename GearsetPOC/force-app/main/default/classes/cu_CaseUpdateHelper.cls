public without sharing class cu_CaseUpdateHelper {

    private static Set<string> cachedStationNames;

    // get ticket for Case by PNR filled
    public static List<Ticket__c> getTicketsByCase(List<string> listOfPNR){
        List<Ticket__c> listTickets = new list<Ticket__c>();
        if(!listOfPNR.isEmpty()){
            listTickets = [SELECT Id, Class_of_Service__c, PNR__c, PAX_Type__c, Train__c, Destination__c, Origin__c ,
                                    Booker__c 
                                FROM Ticket__c where PNR__c in :listOfPNR];
        }

        return listTickets;

    }

    //Destination__c, Origin__c, Booking_DateTime__c, Booking_DateTime_Format__c
    public static Map<string, List<Ticket__c>> getTicketsWithBookingByPNR(list<string> listOfPNR, Date caseDateCreation ){
        Map<string, List<Ticket__c>> mapTickets = new Map<string, List<Ticket__c>>();
        Map<String, Ticket__c> mostRecentTicketbyPnr = new Map<String, Ticket__c>();

        if(!listOfPNR.isEmpty()){
            List<Ticket__c> listTickets = [SELECT Id, Class_of_Service__c, PNR__c, PAX_Type__c, PAX_Type_Description__c, Train__c, 
                                Destination__c, Origin__c, Booking_DateTime_Format__c, Connecting_Destination__c,
                                Non_Eurostar_Origin__c, Non_Eurostar_Destination__c, PAX_Type_Filter__c, Booker__c, Departure_Date_Time_Format__c 
                                FROM Ticket__c where PNR__c in :listOfPNR
                                ];

            for (Ticket__c ticket : listTickets) {
                List<Ticket__c> tickets = new List<Ticket__c>();
                if (mapTickets.containsKey(ticket.PNR__c)){
                    tickets = mapTickets.get(ticket.PNR__c);
                }
                tickets.add(ticket);
                mapTickets.put(ticket.PNR__c, tickets);

                if (mostRecentTicketbyPnr.containsKey(ticket.PNR__c)) {
                    if (mostRecentTicketbyPnr.get(ticket.PNR__c).Departure_Date_Time_Format__c < ticket.Departure_Date_Time_Format__c) {
                        mostRecentTicketbyPnr.put(ticket.PNR__c,ticket);
                    }
                }else {
                    mostRecentTicketbyPnr.put(ticket.PNR__c,ticket);
                }
            }

            for (String pnr : mostRecentTicketbyPnr.keySet()) {
                Ticket__c mostRecentTicket = mostRecentTicketbyPnr.get(pnr);

                List<Ticket__c> filteredTickets = new List<Ticket__c>(); 
                filteredTickets.add(mostRecentTicket);

                for (Ticket__c ticketItem : mapTickets.get(pnr)) {
                    if (mostRecentTicket.Booker__c == ticketItem.Booker__c && mostRecentTicket.Booking_DateTime_Format__c == ticketItem.Booking_DateTime_Format__c) {
                        filteredTickets.add(ticketItem);
                    }
                }

                mapTickets.put(pnr, filteredTickets);
            }
        }

        return mapTickets;
    }

    public static Set<string> getStationNamesBelgiumAndDutch(){
        if (cachedStationNames != null) { return cachedStationNames; }

        cachedStationNames = new Set<string>();

        List<Stations__c> listOfStations = [
            SELECT Id, Name, Dutch_Station_Name__c, nl_Station_Name__c, Active__c, Country__c
            FROM Stations__c
            WHERE country__c in ('DEU', 'BEL')
        ];

        for (Stations__c station : listOfStations) {
            cachedStationNames.add(station.Name);

            if(string.isNotBlank(station.Dutch_Station_Name__c)) {
                cachedStationNames.add(station.Dutch_Station_Name__c);
            }

            if (string.isNotBlank(station.nl_Station_Name__c)) {
                cachedStationNames.add(station.nl_Station_Name__c);
            }

        }

        return cachedStationNames;
    }
}