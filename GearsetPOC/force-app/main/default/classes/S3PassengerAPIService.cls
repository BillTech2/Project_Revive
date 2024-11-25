public without sharing class S3PassengerAPIService {

    public static final S3Settings__c s3Settings = S3Settings__c.getInstance();

    // public static final String authEndpoint = 'https://api.eurostar-prod.cloud.sqills.com/oauth/v2/token';
    // public static final String authBody= '{"grant_type": "https://com.sqills.s3.oauth.agent","username": "sf.contactus","password": "ConTACTuS@2024"}';
    // public static final String authHeaders = '{"Content-Type": "application/json","Authorization": "Basic MTJzMzM1ejBrZWU2aG44a2MxdjQyb2xpYjMzMWM5MGFucW4wNDFtYjNmdDlyNXZ0MWc6Z2ZseGE1dHIyeGw1eDNwMzduNGI1OTA4dHJyNDg1dDN3bjVqM2ppam0yYTZnczc4bHM="}';
    // public static final String authMethod = 'POST';
    // public static final String profilesEndpoint = 'https://api.eurostar-prod.cloud.sqills.com/api/v3/fare/management/aftersales-override-profiles?page_size=100';
    // public static final String profileHeaders = '{"Content-Type": "application/json","Authorization": "Bearer {token}"}';
    // public static final String profileAuthTokenPlaceholder = '{token}';
    // public static final String profileMethod = 'GET';

    public static final String HOTEL_ONLY = 'HOTEL_ONLY';
    public static final String TRAIN_ONLY = 'TRAIN_ONLY';
    public static final String TRAIN_AND_HOTEL = 'TRAIN_AND_HOTEL';

    public static final String NO_REFUND = 'NO_REFUND';
    public static final String REFUND_TO_VOUCHER = 'REFUND_TO_VOUCHER';
    public static final String FULL_REFUND = 'FULL_REFUND';

    public static List<Object> aops;
    public static Map<String, Map<String, Object>> aopsById = new Map<String, Map<String, Object>>();

    private static String getAccessToken() {
        String token = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(s3Settings.authEndpoint__c);
        request.setMethod(s3Settings.authMethod__c);
        Map<String, String> headers = (Map<String,String>) JSON.deserialize(s3Settings.authHeaders__c, Map<String,String>.class);
        for (String headerName : headers.keySet()) {
            System.debug(headerName);
            System.debug(headers.get(headerName));
            request.setHeader(headerName, headers.get(headerName));
        }
        request.setBody(s3Settings.authBody__c);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            token = (String) results.get('access_token');
        } else {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
        }
        return token;
    }

    public static HttpResponse getAOP() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(s3Settings.profilesEndpoint__c);
        request.setMethod(s3Settings.profileMethod__c);

        String token = getAccessToken();

        Map<String, String> headers = (Map<String,String>) JSON.deserialize(s3Settings.profileHeaders__c.replace(s3Settings.profileAuthTokenPlaceholder__c, token), Map<String,String>.class);
        for (String headerName : headers.keySet()) {
            request.setHeader(headerName, headers.get(headerName));
        }
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            aops = (List<Object>) results.get('aftersales_override_profiles');
            if (String.isNotBlank((String) results.get('next_page'))) {
                getNextAOPs(token, (String) results.get('next_page'));
            }
            for (Object aop: aops) {
                Map<String, Object> aopWithFields = (Map<String, Object>) aop;
                aopsById.put((String) aopWithFields.get('id'), aopWithFields);
            }
        } else {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
        }
        return response;
    }

    private static void getNextAOPs(String token, String nextUrl) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(nextUrl);
        request.setMethod(s3Settings.profileMethod__c);
        Map<String, String> headers = (Map<String,String>) JSON.deserialize(s3Settings.profileHeaders__c.replace(s3Settings.profileAuthTokenPlaceholder__c, token), Map<String,String>.class);
        for (String headerName : headers.keySet()) {
            request.setHeader(headerName, headers.get(headerName));
        }
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            aops.addAll((List<Object>) results.get('aftersales_override_profiles'));
            if (String.isNotBlank((String) results.get('next_page')) && !Test.isRunningTest()) {
                getNextAOPs(token, (String) results.get('next_page'));
            }
        } else {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
        }
    }

    public static cu_Utils.PnrDetails getAOPByPNR(String pnr) {
        cu_Utils.PnrDetails pnrItem = new cu_Utils.PnrDetails();
        pnrItem.pnr = pnr;
        pnrItem.isDisrupted = false;
        pnrItem.bookingType = '';
        pnrItem.isFree = false;
        pnrItem.isExchangable = false;
        pnrItem.isRefundable = false;
        pnrItem.isChangeableOnline = false;
        pnrItem.addInfo = false;
        pnrItem.cancelOption = '';
        pnrItem.error = '';
        pnrItem.isDelayed = false;
        pnrItem.isCancelled = false;
        pnrItem.isLastMinuteTicket = false;
        
        if (String.isBlank(pnr)) {
            pnrItem.error = 'cu_ErrorPNR';
            return pnrItem;
        }

        List<Booking__c> bookings = getBookingsByPnr(pnr);
        List<Ticket__c> tickets = getTicketsByPnr(pnr);

        Map<String, Object> aop = new Map<String, Object>();

        if (!tickets.isEmpty()) {
            getAOP();
        }
        
        for (Ticket__c ticket : tickets) {
            if (!aop.containsKey('reason')) {
                for (Map<String, Object> aopWithFields : aopsById.values()) {
                    String serviceNames = '';
                    List<Object> aopWithFieldsList = new List<Object>();
                    if (aopWithFields.containsKey('services')) {
                        aopWithFieldsList = (List<Object>) aopWithFields.get('services');
                    }
                    if (!aopWithFieldsList.isEmpty()) {
                        String startDate = (String) aopWithFields.get('start_date');
                        if (startDate.equalsIgnoreCase(ticket.Train__r.Name.substringBetween(' '))) {
                            for (Object service : aopWithFieldsList) {
                                Map<String, Object> serviceItem = (Map<String, Object>) service;
                                for (Object serviceName : serviceItem.values()) {
                                    serviceNames = serviceNames + ' ' + (String) serviceName;
                                }
                            }
                            if (serviceNames.containsIgnoreCase(ticket.Train_Number__c)) {
                                aop = aopWithFields;
                                break;
                            }
                        }
                    }
                }
            }
        }

        if (bookings.isEmpty() && tickets.isEmpty()) {
            pnrItem.error = 'cu_ErrorPNR';
            return pnrItem;
        }

        List<Case> openCases = CaseService.getExistingCasesByPNR(pnr);
        if (!openCases.isEmpty()) {
            pnrItem.error = 'cu_ErrorCaseExists';
        }

        // only train tickets have AOP
        if (!bookings.isEmpty() && tickets.isEmpty()) {
            pnrItem.bookingType = HOTEL_ONLY;
        }
        if (bookings.isEmpty() && !tickets.isEmpty()) {
            pnrItem.bookingType = TRAIN_ONLY;
        }
        if (!bookings.isEmpty() && !tickets.isEmpty()) {
            pnrItem.bookingType = TRAIN_AND_HOTEL;
        }
        if (aop != null) {
            if (aop.containsKey('reason')) {
                pnrItem.isDisrupted = true;
                String reason = (String) aop.get('reason');
                if (reason.containsIgnoreCase('FREE')) {
                    pnrItem.cancelOption = NO_REFUND;
                }
                if (reason.containsIgnoreCase('VOUCHER')) {
                    pnrItem.cancelOption = REFUND_TO_VOUCHER;
                    pnrItem.isRefundable = true;
                }
                if (reason.containsIgnoreCase('PRR')) {
                    pnrItem.cancelOption = FULL_REFUND;
                    pnrItem.isRefundable = true;
                }
                if (reason.containsIgnoreCase('EXCHANGE')) {
                    pnrItem.isExchangable = true;
                }
            }

            if (aop.containsKey('description')) {
                pnrItem.isDisrupted = true;
                String description = (String) aop.get('description');
                if (
                    description.containsIgnoreCase('FEE') || 
                    description.containsIgnoreCase('FFE') || 
                    description.containsIgnoreCase('FREE')
                ) {
                    pnrItem.isFree = true;
                }
            }

            Boolean isDelayed = false;
            if (!aop.containsKey('description') && !aop.containsKey('reason')) {
                if (!tickets.isEmpty()) {
                    for (Ticket__c ticket : tickets) {
                        if (ticket.Cancelled__c) {
                            pnrItem.isCancelled = true;
                        }
                        if ((ticket.Train__r.Delay_in_Minutes__c > 60) && !isDelayed) {
                            pnrItem.isDelayed = true;
                            pnrItem.isDisrupted = true;
                            isDelayed = true;
                        }
                    }
                }
            }
        }

        Ticket__c ticket = getTicketWithNearestDepartureDateTimeInFuture(tickets);
        pnrItem.isLastMinuteTicket = ticket != null 
            && ticket.PAX_Type_Filter__c != null 
            && ticket.PAX_Type_Filter__c.containsIgnoreCase(DLT_TicketConstants.TICKET_PAX_TYPE_FILTER_LASTMIN);

        return pnrItem;
    }

    private static List<Booking__c> getBookingsByPnr(String pnr) {
        return [
            SELECT Id, Booker__c, PNR__c
            FROM Booking__c
            WHERE PNR__c =: pnr.trim()
                OR JAC_Travel_Ref__c =: pnr.trim()
        ];
    }

    private static List<Ticket__c> getTicketsByPnr(String pnr) {
        return [
            SELECT Id, 
                PNR__c, 
                PNR_Ticket__c, 
                Booker__c, 
                Retimed__c, 
                Train__r.Name,
                Departure_Date_Time_Format__c, 
                Train_Number__c, 
                Travel_DateTime__c,
                Train__r.Delay_in_Minutes__c, 
                Checked_In__c, 
                Cancelled__c,
                PAX_Type_Filter__c
            FROM Ticket__c
            WHERE PNR__c =: pnr.trim()
            ORDER BY CreatedDate DESC
        ];
    }

    public static Ticket__c getTicketWithNearestDepartureDateTimeInFuture(List<Ticket__c> tickets) {
        if (tickets.isEmpty()) {
            return null;
        }

        List<Ticket__c> sortedTickets = sortTicketsByDepartureDateTime(tickets);
        Ticket__c ticket = findTicketWithNearestDepartureDateTimeInFuture(sortedTickets);

        return ticket;
    }

    private static List<Ticket__c> sortTicketsByDepartureDateTime(List<Ticket__c> tickets) {
        List<TicketWrapper> ticketWrappers = new List<TicketWrapper>();
        for (Ticket__c ticket : tickets) {
            TicketWrappers.add(new TicketWrapper(ticket));
        }
        
        ticketWrappers.sort();

        List<Ticket__c> ticketsAfterSort = new List<Ticket__c>();
        for (TicketWrapper ticketWrapper : ticketWrappers) {
            ticketsAfterSort.add(ticketWrapper.record);
        }

        return ticketsAfterSort;
    }

    private static Ticket__c findTicketWithNearestDepartureDateTimeInFuture(List<Ticket__c> sortedTickets) {
        DateTime dateTimeNow = Datetime.now();

        for (Ticket__c ticket : sortedTickets) {
            if (ticket.Departure_Date_Time_Format__c != null && ticket.Departure_Date_Time_Format__c > dateTimeNow) {
                return ticket;
            }
        }

        return null;
    }

    public class TicketWrapper implements Comparable {
        public Ticket__c record;

        public TicketWrapper(Ticket__c record) {
            this.record = record;
        }

        public Integer compareTo(Object compareTo) {
            TicketWrapper ticketWrapperToCompare = (TicketWrapper) compareTo;

            DateTime thisValue = this.record.Departure_Date_Time_Format__c;
            DateTime thatValue = ticketWrapperToCompare.record.Departure_Date_Time_Format__c;

            if (thisValue < thatValue) {
                return -1;
            } else if (thisValue > thatValue) { 
                return 1; 
            } else {
                return 0;
            }
        }
    }
}