public without sharing class S3PassengerAPIService {

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
        request.setEndpoint('https://api.eurostar-uat-acc.cloud.sqills.com/oauth/v2/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        request.setBody('{' +
            '"grant_type": "https://com.sqills.s3.oauth.agent",' +
            '"username": "sf.contactus",' +
            '"password": "ConTACTuS@2022",' +
            '"client_id": "4lsgn8x9ozr939ow3422mb0qubk789cj31wzk93227xiuyga99"' +
        '}');
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
        request.setEndpoint('https://api.eurostar-uat-acc.cloud.sqills.com/api/v3/fare/management/aftersales-override-profiles' + '?page_size=100');
        request.setMethod('GET');

        String token = getAccessToken();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
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
        request.setMethod('GET');

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
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
        cu_Utils.PnrDetails pnrItem = new cu_Utils.PnrDetails(pnr, false, '', false, false, false, false, false, '', '', false, false);
        if (String.isBlank(pnr)) {
            pnrItem.error = 'cu_ErrorPNR';
            return pnrItem;
        }
        List<Booking__c> booking = [
            SELECT Id, Booker__c, PNR__c
            FROM Booking__c
            WHERE PNR__c =: pnrItem.pnr.trim()
                OR JAC_Travel_Ref__c =: pnrItem.pnr.trim()
        ];
        List<Ticket__c> ticket = [
            SELECT Id, PNR__c, PNR_Ticket__c, Booker__c, Retimed__c, Train__r.Name,
                Departure_Date_Time_Format__c, Train_Number__c, Travel_DateTime__c,
                Train__r.Delay_in_Minutes__c, Checked_In__c, Cancelled__c
            FROM Ticket__c
            WHERE PNR__c =: pnrItem.pnr.trim()
            ORDER BY CreatedDate DESC
        ];

        Map<String, Object> aop = new Map<String, Object>();
        if (!ticket.isEmpty()) {
            getAOP();
            for (Ticket__c ticketItem : ticket) {
                if (!aop.containsKey('reason')) {
                    for (Map<String, Object> aopWithFields : aopsById.values()) {
                        String serviceNames = '';
                        List<Object> aopWithFieldsList = new List<Object>();
                        if (aopWithFields.containsKey('services')) {
                            aopWithFieldsList = (List<Object>) aopWithFields.get('services');
                        }
                        if (!aopWithFieldsList.isEmpty()) {
                            String startDate = (String) aopWithFields.get('start_date');
                            if (startDate.equalsIgnoreCase(ticketItem.Train__r.Name.substringBetween(' '))) {
                                for (Object service : aopWithFieldsList) {
                                    Map<String, Object> serviceItem = (Map<String, Object>) service;
                                    for (Object serviceName : serviceItem.values()) {
                                        serviceNames = serviceNames + ' ' + (String) serviceName;
                                    }
                                }
                                if (serviceNames.containsIgnoreCase(ticketItem.Train_Number__c)) {
                                    aop = aopWithFields;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }

        if (booking.isEmpty() && ticket.isEmpty()) {
            pnrItem.error = 'cu_ErrorPNR';
            return pnrItem;
        }

        List<Case> openCases = CaseService.getExistingCasesByPNR(pnr);
        if (!openCases.isEmpty()) {
            pnrItem.error = 'cu_ErrorCaseExists';
        }

        // only train tickets have AOP
        if (!booking.isEmpty() && ticket.isEmpty()) {
            pnrItem.bookingType = HOTEL_ONLY;
        }
        if (booking.isEmpty() && !ticket.isEmpty()) {
            pnrItem.bookingType = TRAIN_ONLY;
        }
        if (!booking.isEmpty() && !ticket.isEmpty()) {
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
                if (description.containsIgnoreCase('FEE') || description.containsIgnoreCase('FFE') || description.containsIgnoreCase('FREE')) {
                    pnrItem.isFree = true;
                }
            }

            Boolean isDelayed = false;
            if (!aop.containsKey('description') && !aop.containsKey('reason')) {
                if (!ticket.isEmpty()) {
                    for (Ticket__c ticketItem : ticket) {
                        if (ticketItem.Cancelled__c) {
                            pnrItem.isCancelled = true;
                        }
                        if ((ticketItem.Train__r.Delay_in_Minutes__c > 60) && !isDelayed) {
                            pnrItem.isDelayed = true;
                            pnrItem.isDisrupted = true;
                            isDelayed = true;
                        }
                    }
                }
            }
        }
        return pnrItem;
    }
}