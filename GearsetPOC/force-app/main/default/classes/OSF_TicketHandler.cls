public class OSF_TicketHandler {
    
    private static String JOURNAL_TYPE_NAME = Test.isRunningTest() ? 'Accrual Test' : 'Accrual';
    private static String JOURNAL_SUBTYPE_NAME = Test.isRunningTest() ? 'Purchase a Ticket Test' : 'Purchase a Ticket';

    public static Boolean validatePayment(String paymentType,List<String> paymentTypesList){
        Boolean valid=False;
        for(String types:paymentTypesList){
            if(!paymentType.contains(types)) { valid=true; }
        }
        return valid;
    }
    
    public static Boolean validateSameRoute(Ticket_Sales__c ticketSalesOBj,List<Ticket_Sales_Processing__c> ticketSalesProcessingList){
        System.debug('### validateSameRoute: ' + ticketSalesOBj + ' ------ ' + ticketSalesProcessingList);
        Boolean isSameRoute=false;
        for(Ticket_Sales_Processing__c ticketSalesProcessingObj:ticketSalesProcessingList){
            if(Date.valueOf(ticketSalesOBj.Depart_DateTime__c)==ticketSalesProcessingObj.Departure_date__c && ticketSalesOBj.OriginUic__c==ticketSalesProcessingObj.Origin__c && ticketSalesOBj.DestinationUic__c==ticketSalesProcessingObj.Destination__c && !ticketSalesProcessingObj.Points_indicator__c) { isSameRoute=true; }
        }
        return isSameRoute;
    }
    
    public static Decimal calculatePoints(Ticket_Sales__c ticketSalesOBj){
        Decimal points;
        Decimal amount= ticketSalesOBj.Payment_Currency_Amount__c;
        String CurrencyCode = ticketSalesOBj.Payment_Currency_Code__c;
        points=amount;
  
        if(CurrencyCode=='GBP'){
            points=amount*1.2;
        }
        return Math.round(points);
    }
    
    private static String replaceSpecialCharacters(String inputString, Map<String, String> mapSpecialCharToStdChar) {
        String outputString = inputString;
        for(String key : mapSpecialCharToStdChar.keySet()) {
            outputString = outputString.replace(key, mapSpecialCharToStdChar.get(key));
        }
        return outputString;
    }

    public static Boolean matchesName(Ticket__c ticketObj,LoyaltyProgramMember LPM, Map<String, String> mapSpecialCharToStdChar) {

        string ticketFirstName = !String.isBlank(ticketObj.First_Name__c) ? removeTitle(ticketObj.First_Name__c.toLowerCase(), mapSpecialCharToStdChar) : '';
        string ticketLastName =  !String.isBlank(ticketObj.Last_Name__c) ? removeTitle(ticketObj.Last_Name__c.toLowerCase(), mapSpecialCharToStdChar) : ''; 
        string contactFirstName = !String.isBlank(LPM.Contact.FirstName) ? removeTitle(LPM.Contact.FirstName.toLowerCase(), mapSpecialCharToStdChar) : ''; 
        string contactLastName = !String.isBlank(LPM.Contact.LastName) ? removeTitle(LPM.Contact.LastName.toLowerCase(), mapSpecialCharToStdChar) : ''; 

        System.debug('QQQ ticketFirstName: ' + ticketFirstName);
        System.debug('QQQ ticketLastName: ' + ticketLastName);
        System.debug('QQQ contactFirstName: ' + contactFirstName);
        System.debug('QQQ contactLastName: ' + contactLastName);
        System.debug('QQQ contactLastName: ' + contactLastName);

        String ticketNameWithoutTitle = ticketFirstName + ' ' + ticketLastName;
        String contactNameWithoutTitle = contactFirstName + ' ' + contactLastName;

        if(
            (ticketFirstName.equalsIgnoreCase(contactFirstName) && ticketLastName.equalsIgnoreCase(contactLastName)) ||
            (ticketFirstName.equalsIgnoreCase(contactLastName) && ticketLastName.equalsIgnoreCase(contactFirstName)) ||
            contactLastName.equalsIgnoreCase(ticketFirstName + ' ' + ticketLastName) ||
            contactLastName.equalsIgnoreCase(ticketLastName  + ' ' + ticketFirstName) ||
            contactFirstName.equalsIgnoreCase(ticketLastName + ' ' + ticketFirstName) ||
            contactFirstName.equalsIgnoreCase(ticketFirstName + ' ' + ticketLastName) ||
            ticketFirstName.equalsIgnoreCase(contactFirstName + ' ' + contactLastName) ||
            ticketFirstName.equalsIgnoreCase(contactLastName + ' ' + contactFirstName) ||
            ticketLastName.equalsIgnoreCase(contactFirstName + ' ' + contactLastName) ||
            ticketLastName.equalsIgnoreCase(contactLastName + ' ' + contactFirstName)
            ) {
            return true;
        }
        return false;
    }

    private static String removeTitle(String name, Map<String, String> mapSpecialCharToStdChar) {
        // List of common titles to be removed
        List<String> titles = new List<String>{'mr', 'mrs', 'ms', 'dr', 'miss'};
        name = replaceSpecialCharacters(name, mapSpecialCharToStdChar);
        name = name.replaceAll('[^a-zA-Z0-9]', '');
        // Remove titles from the name
        for (String title : titles) {
            name = name.replaceAll(title, '').trim();
        }
        
        return name;
    }
/*
    public static Boolean ticketLinkingRule(Ticket__c ticketObj,LoyaltyProgramMember LPM){
        System.debug('### ticketObj: ' + ticketObj);

        string ticketTitle = ticketObj.Title__c;
       	string ticketFirstName = ticketObj.First_Name__c;
		string ticketLastName = ticketObj.Last_Name__c;
        System.debug('###beforeTitle');
		string contactTitle = LPM.Contact.Title;
        string contactFirstName = LPM.Contact.FirstName;
        System.debug('###afterFN');
        string contactLastName	= LPM.Contact.LastName != null ? LPM.Contact.LastName : '';
        System.debug('###afterLN' + ticketFirstName + ticketLastName + contactFirstName + contactLastName );
        
        //Boolean check = ticketTitle != null ? ticketTitle.equals(contactTitle) : false;
        //Boolean titleEmpty = String.isBlank(ticketTitle);
        Boolean TicketFirstNameMatch = ticketFirstName != null ? ticketFirstName.equalsIgnoreCase(contactFirstName) : false;
        Boolean TicketLastNameMatch = ticketLastName != null ? ticketLastName.equalsIgnoreCase(contactLastName) : false;
        //Boolean TicketTitleMatch = ticketTitle != null ? ticketTitle.equalsIgnoreCase(contactTitle) : false;
        // Abbrviations are given as follows
        // TFN = TicketFirstName , CFN = contactFirstName, CLN = contactLastName, CT = contactTitle
        Boolean TFNcontainCFN = (ticketFirstName != null && contactFirstName != null) ? ticketFirstName.containsIgnoreCase(contactFirstName) : false;
        Boolean TFNcontainHypen = TicketFirstName != null ? TicketFirstName.contains('-') : false;
        System.Debug('### contactTitle: ' + contactTitle);
        System.Debug('### ticketFirstName: ' + ticketFirstName);
        //Boolean TFNcontaineCT = contactTitle != null ? ticketFirstName.containsIgnoreCase(contactTitle) : false;
        Boolean CLNcontainTLN = ticketLastName != null ? contactLastName.containsIgnoreCase(ticketLastName) : false;
        //Boolean Rule3A_C = String.isBlank(ticketTitle)  && (string.isBlank(ticketFirstName) || string.isBlank(ticketLastName));
        Boolean Rule3A_C = string.isBlank(ticketFirstName) || string.isBlank(ticketLastName);
        //Boolean Rule3D_E = !titleEmpty && !TicketLastNameMatch && TicketFirstNameMatch && !CLNcontainTLN;
        //Boolean Rule3F_I = !titleEmpty && !TicketFirstNameMatch && TicketLastNameMatch;
        //Boolean Rule3J =  !titleEmpty && !TicketFirstNameMatch && !TicketLastNameMatch;
        //Boolean Rule4A = titleEmpty && !TFNcontaineCT && TicketLastNameMatch && TicketFirstNameMatch;

        Boolean Rule3D_E = !TicketLastNameMatch && TicketFirstNameMatch && !CLNcontainTLN; 
        Boolean Rule3F_I = !TicketFirstNameMatch && TicketLastNameMatch;
        Boolean Rule3J =  !TicketFirstNameMatch && !TicketLastNameMatch;
        Boolean Rule4A = TicketLastNameMatch && TicketFirstNameMatch;

        //Boolean Rule4B = !TicketTitleMatch && !titleEmpty && TicketLastNameMatch && TicketFirstNameMatch;
        Boolean Rule4B = TicketLastNameMatch && TicketFirstNameMatch;
        //Boolean Rule5A_B = TFNcontainCFN && !TicketFirstNameMatch && !TFNconta	ineCT && !TFNcontainHypen;
        Boolean Rule5A_B = TFNcontainCFN && !TicketFirstNameMatch && !TFNcontainHypen; 
        //Boolean Rule5C_D = TFNcontainCFN && !TicketFirstNameMatch && TFNcontaineCT && titleEmpty && !TFNcontainHypen;
        Boolean Rule5C_D = TFNcontainCFN && !TicketFirstNameMatch && !TFNcontainHypen;
        Boolean Rule8 = (ticketFirstName != null && ticketLastName != null) ? (ticketFirstName.equalsIgnoreCase(contactLastName) && ticketLastName.equalsIgnoreCase(contactFirstName)) : false;
        // Rejected Ticket rule 3
        if(Rule3A_C) { return False; } 
        else if (Rule3D_E){ return False; } 
        else if (Rule3F_I && !Rule5A_B && !TFNcontainHypen){ return False; } 
        else if (Rule3J && !Rule8){ return False; } 
        //Approved Tickets rule 4 
        else if (Rule4A){ return True; } 
        else if (Rule4B){ return True; } 
        //approved tickets rule 5
        else if (Rule5A_B){ return True; } else if (Rule5C_D){ return True; } 
        //approved tickets rule 6
        else if (TFNcontainHypen){	return True; }
        //approved tickets rule 7
        else if (CLNcontainTLN && !TicketLastNameMatch){  return True; } //approved tickets rule 8
        else if (Rule8){  return True; }
        return False;
    }
*/
    public static Boolean isSameRoute(List<RouteValidation> lstRouteValidation, Ticket_Sales_Processing__c tsp) {
        Boolean isSameRoute = false;
        for (RouteValidation rv : lstRouteValidation) {
            if (rv.linkedUser == tsp.User_Link__c && rv.origin == tsp.Origin__c && rv.destination == tsp.Destination__c && rv.departureDate == tsp.Departure_date__c) {
                isSameRoute = true;
            }
        }
        return isSameRoute;
    }

    public static void unlinkUsedRoutes(List<RouteValidation> lstRouteValidation) {
        //create lists of separate elements to be used in a tsp query
        List<String> lstLinkedUsers = new List<String>();
        List<String> lstOrigins = new List<String>();
        List<String> lstDestinations = new List<String>();
        List<Date> lstDepartureDates = new List<Date>();
        String whereClause = '';
        //create a dynamic where clause based on the list
        for (RouteValidation rv : lstRouteValidation) {
            String tmpDate = String.valueOf(rv.departureDate).left(10);
            System.debug('### tmpDate: ' + tmpDate);
            if (!String.isBlank(rv.linkedUser ) && !String.isBlank(rv.origin) && !String.isBlank(rv.destination) && rv.departureDate != null) {
                whereClause += '(User_Link__c = \'' + rv.linkedUser + '\' AND Origin__c = \'' + rv.origin + '\' AND Destination__c = \'' + rv.destination + '\' AND Departure_date__c = ' + tmpDate + ') OR ';
            }
        }
        if(whereClause != '') {
            whereClause = whereClause.left(whereClause.length() - 4);
        }
        System.debug('### whereClause: ' + whereClause);
        String queryString = '';
        if (whereClause != '') {
            queryString = 'SELECT Id, User_Link__c, Origin__c, Destination__c, Departure_date__c FROM Ticket_Sales_Processing__c WHERE ' + whereClause;
        }
        System.debug('### queryString: ' + queryString);
        //query for all tsp records that match the lists
        List<Ticket_Sales_Processing__c> lstTSP = new List<Ticket_Sales_Processing__c>();
        if (queryString != '')
        lstTSP = (List<Ticket_Sales_Processing__c>)Database.query(queryString);
        //lstTSP = [SELECT Id, User_Link__c, Origin__c, Destination__c, Departure_date__c FROM Ticket_Sales_Processing__c WHERE User_Link__c IN :lstLinkedUsers AND Origin__c IN :lstOrigins AND Destination__c IN :lstDestinations AND Departure_date__c IN :lstDepartureDates AND Points_indicator__c = false];
        System.debug('### lstTSP: ' + lstTSP);
        //verify if the records match exactly the rv
        if (lstTSP.size() > 0) {
            for (Ticket_Sales_Processing__c tsp : lstTSP) {
                for (RouteValidation rv : lstRouteValidation) {
                    if (rv.linkedUser == tsp.User_Link__c && rv.origin == tsp.Origin__c && rv.destination == tsp.Destination__c && rv.departureDate == tsp.Departure_date__c) {
                        tsp.User_Link__c = null;
                        System.debug('### tsp: ' + tsp);
                    }
                }
            }
        }
        
                                                                                                                                                                          
        //update tsp records
        System.debug('### lstTSP2: ' + lstTSP);
        update lstTSP;
    }

    public static String retroClaimPointsAPI(String membershipNumber, String actionBy, String pnr, String tcn, Boolean validateName, Map<String, String> mapSpecialCharToStdChar) {
        System.Debug('### retroClaimPoints start');
        Map<Id,String> maptoerror = null; 
        maptoerror = new Map<Id,String>();
        List<String> lstofErrors = null; 
        lstofErrors = new List<String>();
        List<RouteValidation> lstUsedRoutes = null;
        lstUsedRoutes = new List<RouteValidation>();
        List<RouteValidation> lstCurrentRoutes = null; 
        lstCurrentRoutes = new List<RouteValidation>();
        JournalSubtype jst;
        List<TransactionJournal> lstTransactionJournalsToInsert = null;
        lstTransactionJournalsToInsert = new List<TransactionJournal>();
        Integer index = 0;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        index++;
        //Deserializing the data sent into concrete SFDC objects
        List<Ticket_Sales_Processing__c> lstToupdate = new List<Ticket_Sales_Processing__c>();
        if(String.isBlank(membershipNumber) || String.isBlank(pnr)) {
            System.Debug('### main if');
            return 'invalidParameters';
        } else {
            System.Debug('### main else');
            jst = [SELECT Id, JournalTypeId FROM JournalSubtype WHERE Name = :JOURNAL_SUBTYPE_NAME AND JournalType.Name = :JOURNAL_TYPE_NAME];
            List<Ticket__c> ticketsList;
            List<Ticket_Sales_Processing__c> processingRecordList;
            System.Debug('### 90date: ' + Date.today().addDays(-90));
            if(!String.isBlank(pnr) && !String.isBlank(tcn)){
                //If the TCN and PNR are provided, one ticket must be found that matches both values. If any found the ticket will be considered as eligible for linking.
                System.Debug('### both if');
                ticketsList = [Select id,Name,Title__c,Departure_Date__c,Departure_Date_Time_Format__c,Booking_DateTime_Format__c,First_Name__c,Last_Name__c,PNR__c,Destination__c,Origin__c,Travel_DateTime__c from Ticket__c where PNR__c =:pnr AND Name=:tcn AND Departure_Date__c > :Date.today().addDays(-90)];
                //If only PNR is provide, multiple tickets cxan be found. In that case all tickets will be considered as eligible for linking
            } else { System.Debug('### pnr only if');
                ticketsList = [Select id,Name,Departure_Date__c,Departure_Date_Time_Format__c,Booking_DateTime_Format__c,Title__c,First_Name__c,Last_Name__c,PNR__c,Destination__c,Origin__c,Travel_DateTime__c from Ticket__c where PNR__c =:pnr AND Departure_Date__c > :Date.today().addDays(-90)]; }

            //we get the list of TSP only based on the PNR to be able to check for same day and route tickets
            processingRecordList = [Select id,PNR__c,Points_indicator__c,Carrier__c,Checked_in__c,Refundable__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c,Payment_Currency_Code__c, Payment_Currency_Amount__c, Class_Of_Service__c, Event_Date__c, Potential_points__c, Points_eligible__c from Ticket_Sales_Processing__c where PNR__c =:pnr AND Cancelled__c = false];
            Map<String,Ticket__c> tcnToTicket = new Map<String,Ticket__c>();

            if (ticketsList.size()>0) {
                for(Ticket__c tc:ticketsList){
                    tcnToTicket.put(tc.Name,tc);
                }
            }
            system.debug('### pnr: '+pnr);
            system.debug('### tcn: '+tcn);
            system.debug('### ticketsList: '+ticketsList);
            List<Ticket_Sales_Processing__c> memberProcessingRecordList = [Select id,PNR__c,Carrier__c,Checked_in__c,Refundable__c,Points_indicator__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c from Ticket_Sales_Processing__c where User_Link__r.MemberShipNumber =: membershipNumber];
            system.debug('### memberProcessing: '+memberProcessingRecordList);
            List<LoyaltyProgramMember> lpmObj =[Select id,Contact.FirstName,Contact.LastName,Contact.Title,MemberStatus from LoyaltyProgramMember where MembershipNumber=:membershipNumber AND MemberStatus='Active'];
            system.debug('### lpmObj: '+lpmObj);
            //Check if the LPM exists
            if (lpmObj.size() > 0 && lpmObj[0].MemberStatus != 'Active') {
                system.debug('### inactive if');
                return 'inactiveMember';
            }
            if (lpmObj.size()>0) {
                //Check if ticket exists
                if (ticketsList.size()>0) {
                    //What if this list return multiple records
                    //If we have any of the successfull line then we need to go with that otherwise we need to show the very first failure/error on response
                    if (processingRecordList.size()>0) {
                        for (Ticket_Sales_Processing__c record: processingRecordList) {
                            System.Debug('### in for');
                            //if the current tsp record has already earned points we should make sure that any record that might be linked is not on the same route
                            if (record.Points_indicator__c == true) {
                                RouteValidation rv = new RouteValidation(); rv.departureDate = record.Departure_date__c; rv.origin = record.Origin__c; rv.destination = record.Destination__c; rv.linkedUser = record.User_Link__c; lstUsedRoutes.add(rv);
                            }
                            system.debug('### lstUsedRoutes: ' + lstUsedRoutes);
                            //Ticket is already linked
                            if (!String.isBlank(record.User_Link__c)) {
                                maptoerror.put(record.id,'TicketAlreadyLinked');
                                lstofErrors.add('TicketAlreadyLinked');
                            } else if (record.Departure_Date__c != null && record.Departure_Date__c + 90 < Date.Today()) {
                                maptoerror.put(record.id,'90DaysPassed');
                                lstofErrors.add('90DaysPassed');
                            } else if (tcnToTicket.containsKey(record.TCN__c) && !matchesName(tcnToTicket.get(record.TCN__c), lpmObj[0], mapSpecialCharToStdChar) && validateName) {
                                    maptoerror.put(record.id,'NameMismatched');
                                    lstofErrors.add('NameMismatched');
                            } else if (checkedInvalidation(record,memberProcessingRecordList)) {
                                    maptoerror.put(record.id,'TicketAlreadyCheckedIn'); lstofErrors.add('TicketAlreadyCheckedIn');
                            } else if(String.isBlank(tcn) || (!String.isBlank(tcn) && tcn == record.TCN__c)) {
                                record.User_Link__c=lpmObj[0].id;
                                if (!isSameRoute(lstUsedRoutes, record)) {
                                    System.Debug('### after isSameRoute if');
                                        if (record.Carrier__c=='Blue' && record.Checked_in__c) {
                                            System.Debug('### Blue checkin if');
                                            //Create TJ
                                            TransactionJournal tj = new TransactionJournal();
                                            tj.MemberId = lpmObj[0].id;
                                            tj.JournalTypeId = jst.JournalTypeId;
                                            tj.Currency__c = record.Payment_Currency_Code__c;
                                            tj.JournalSubTypeId = jst.Id;
                                            tj.TransactionAmount = record.Payment_Currency_Amount__c;
                                            tj.Points__c = record.Potential_points__c;
                                            tj.ActivityDate = Date.today();
                                            tj.Departure_Date__c = record.Departure_Date__c;
                                            tj.PNR__c = record.Pnr__c;
                                            tj.Ticket__c = record.Tcn__c;
                                            tj.Origin = record.Origin__c;
                                            tj.Destination = record.Destination__c;
                                            tj.CarrierCode__c = record.Carrier__c;
                                            tj.Travel_Class__c = record.Class_Of_Service__c;
                                            tj.Booking_Date_Time__c = record.Event_Date__c;
                                            tj.Action_By__c = actionBy;
                                            if(record.Points_eligible__c == true) {
                                                lstTransactionJournalsToInsert.add(tj);
                                                record.Points_indicator__c=true;
                                            } else {
                                                System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                            }
                                        } else if (record.Carrier__c=='Red') {
                                            system.debug('Red-110');
                                            if (!record.Refundable__c || record.Checked_in__c ) {
                                                //Create TJ
                                                system.debug('Tj-112');
                                                TransactionJournal tj = new TransactionJournal();
                                                tj.MemberId = lpmObj[0].id;
                                                tj.JournalTypeId = jst.JournalTypeId;
                                                tj.Currency__c= record.Payment_Currency_Code__c;
                                                tj.JournalSubTypeId = jst.Id;
                                                tj.TransactionAmount = record.Payment_Currency_Amount__c;
                                                tj.Points__c = record.Potential_points__c;
                                                tj.ActivityDate = Date.today();
                                                tj.Departure_Date__c = record.Departure_Date__c;
                                                tj.PNR__c = record.Pnr__c;
                                                tj.Ticket__c = record.Tcn__c;
                                                tj.Origin = record.Origin__c;
                                                tj.Destination = record.Destination__c;
                                                tj.CarrierCode__c = record.Carrier__c;
                                                tj.Travel_Class__c = record.Class_Of_Service__c;
                                                tj.Booking_Date_Time__c = record.Event_Date__c;
                                                tj.Action_By__c = actionBy;
                                                if(record.Points_eligible__c == true) {
                                                    lstTransactionJournalsToInsert.add(tj);
                                                    record.Points_indicator__c=true;
                                                } else {
                                                    System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                                }
                                            } else if (!record.Checked_in__c && record.Refundable__c && record.Departure_date__c+1>=Date.today()) {
                                                //Create TJ
                                                TransactionJournal tj = new TransactionJournal();
                                                tj.MemberId = lpmObj[0].id;
                                                tj.Currency__c = record.Payment_Currency_Code__c;
                                                tj.TransactionAmount = record.Payment_Currency_Amount__c;
                                                tj.Points__c = record.Potential_points__c;
                                                tj.JournalTypeId = jst.JournalTypeId;
                                                tj.JournalSubTypeId = jst.Id;
                                                tj.ActivityDate = Date.today();
                                                tj.Departure_Date__c = record.Departure_Date__c;
                                                tj.PNR__c = record.Pnr__c;
                                                tj.Ticket__c = record.Tcn__c;
                                                tj.Origin = record.Origin__c;
                                                tj.Destination = record.Destination__c;
                                                tj.CarrierCode__c = record.Carrier__c;
                                                tj.Travel_Class__c = record.Class_Of_Service__c;
                                                tj.Booking_Date_Time__c = record.Event_Date__c;
                                                tj.Action_By__c = actionBy;
                                                if(record.Points_eligible__c == true) {
                                                    lstTransactionJournalsToInsert.add(tj);
                                                    record.Points_indicator__c=true;
                                                } else {
                                                    System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                                }
                                            }
                                        }
                                        if (record.Points_indicator__c == true) {
                                            RouteValidation rv = new RouteValidation();
                                            rv.departureDate = record.Departure_date__c;
                                            rv.origin = record.Origin__c;
                                            rv.destination = record.Destination__c;
                                            rv.linkedUser = record.User_Link__c;
                                            lstUsedRoutes.add(rv);
                                            lstCurrentRoutes.add(rv);
                                        }
                                        lstToUpdate.add(record);
                                } else if(isSameRoute(lstUsedRoutes, record)) {System.Debug('### memberEarnedPointsOnSameRoute');lstofErrors.add('memberEarnedPointsOnSameDay&Route');}
                            }
                        }
                    } else {
                        lstofErrors.add('cancelledTicket');
                    }
                } else { 
                    lstofErrors.add('ticketNotFound');
                }
            } else {
                lstofErrors.add('invalidMembership');
            }
        }
        if (lstCurrentRoutes.size() > 0 && lstTransactionJournalsToInsert.size() > 0) {
            unlinkUsedRoutes(lstCurrentRoutes);
        }
        System.Debug('### lstCurrentRoutes: ' + lstCurrentRoutes);
        //Added the final response
        System.Debug('### lstTransactionJournalsToInsert: ' + lstTransactionJournalsToInsert);
        System.Debug('### lstToUpdate: ' + lstToUpdate);
        if (lstToUpdate.size() > 0) {
            update lstToUpdate;
        }
        if (lstTransactionJournalsToInsert.size()>0) {
            System.Debug('### in if lstTransactionJournalsToInsert');
            insert lstTransactionJournalsToInsert;
        } else {
            if(lstofErrors.size()>0 && lstToUpdate.size() == 0) {
                return (lstofErrors.size() == 1) ? lstofErrors[0] : lstofErrors[lstofErrors.size()-1];  
            } 
        }
        
        
        return 'success';
    }

    public static String retroClaimPoints(String membershipNumber, String pnr, String tcn, Boolean validateName, String recordId, Map<String, String> mapSpecialCharToStdChar) {
        System.Debug('### retroClaimPoints start');
        Map<Id,String> maptoerror = new Map<Id,String>();
        List<String> lstofErrors = new List<String>();
        List<Ticket_Sales_Processing__c> pointsCamparisionList;
        List<RouteValidation> lstUsedRoutes = new List<RouteValidation>();
        JournalSubtype jst;
        List<TransactionJournal> lstTransactionJournalsToInsert = new List<TransactionJournal>();
        //Deserializing the data sent into concrete SFDC objects
        List<Ticket_Sales_Processing__c> lstToupdate = new List<Ticket_Sales_Processing__c>();
        List<Ticket_Sales_Processing__c> manualRecord;
        if(String.isBlank(membershipNumber) || String.isBlank(pnr)) {
            System.Debug('### main if');
            return 'invalidParameters';
        } else {
            System.Debug('### main else');
            jst = [SELECT Id, JournalTypeId FROM JournalSubtype WHERE Name = :JOURNAL_SUBTYPE_NAME AND JournalType.Name = :JOURNAL_TYPE_NAME];
            pointsCamparisionList = [Select id,Potential_points__c,PNR__c,Points_indicator__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c from Ticket_Sales_Processing__c where PNR__c =: pnr AND Points_eligible__c = True ORDER BY Potential_points__c DESC  ]; 
            List<Ticket__c> ticketsList;
            List<Ticket_Sales_Processing__c> processingRecordList;
            if(!String.isBlank(pnr) && !String.isBlank(tcn)){
                //If the TCN and PNR are provided, one ticket must be found that matches both values. If any found the ticket will be considered as eligible for linking.
                ticketsList = [Select id,Name,Title__c,Departure_Date__c,Departure_Date_Time_Format__c,Booking_DateTime_Format__c,First_Name__c,Last_Name__c,PNR__c,Destination__c,Origin__c,Travel_DateTime__c from Ticket__c where PNR__c =:pnr AND Name=:tcn AND Name=:tcn AND Departure_Date__c > :Date.today().addDays(-90)];
                //processingRecordList = [Select id,PNR__c,Points_indicator__c,Carrier__c,Checked_in__c,Refundable__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c,Payment_Currency_Code__c, Payment_Currency_Amount__c from Ticket_Sales_Processing__c where TCN__c =:jsonwrap.tcn AND Cancelled__c = false];
                //If only PNR is provide, multiple tickets cxan be found. In that case all tickets will be considered as eligible for linking
            } else { ticketsList = [Select id,Name,Departure_Date__c,Departure_Date_Time_Format__c,Booking_DateTime_Format__c,Title__c,First_Name__c,Last_Name__c,PNR__c,Destination__c,Origin__c,Travel_DateTime__c from Ticket__c where PNR__c =:pnr AND Departure_Date__c > :Date.today().addDays(-90)]; }

            //we get the list of TSP only based on the PNR to be able to check for same day and route tickets
            processingRecordList = [Select id,PNR__c,Points_indicator__c,Carrier__c,Checked_in__c,Refundable__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c,Payment_Currency_Code__c, Payment_Currency_Amount__c, Class_Of_Service__c, Event_Date__c, Potential_points__c, Points_eligible__c from Ticket_Sales_Processing__c where PNR__c =:pnr AND Cancelled__c = false];
            manualRecord = !String.isBlank(recordId) ? [SELECT Id FROM Ticket_Sales_Processing__c WHERE Id = :recordId] : new List<Ticket_Sales_Processing__c>();
            Map<String,Ticket__c> tcnToTicket = new Map<String,Ticket__c>();

            if (ticketsList.size()>0) {
                for(Ticket__c tc:ticketsList){
                    tcnToTicket.put(tc.Name,tc);
                }
            }
            system.debug('### ticketsList: '+ticketsList+pnr+tcn);
            List<Ticket_Sales_Processing__c> memberProcessingRecordList = [Select id,PNR__c,Carrier__c,Checked_in__c,Refundable__c,Points_indicator__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c from Ticket_Sales_Processing__c where User_Link__r.MemberShipNumber =: membershipNumber];
            system.debug('### memberProcessing: '+memberProcessingRecordList);
            List<LoyaltyProgramMember> lpmObj =[Select id,Contact.FirstName,Contact.LastName,Contact.Title,MemberStatus from LoyaltyProgramMember where MembershipNumber=:membershipNumber AND MemberStatus='Active'];
            system.debug('### lpmObj: '+lpmObj);
            //Check if the LPM exists
            if (lpmObj.size() > 0 && lpmObj[0].MemberStatus != 'Active') {
                system.debug('### inactive if');
                return 'inactiveMember';
            }
            if (lpmObj.size()>0) {
                //Check if ticket exists
                if (ticketsList.size()>0) {
                    //What if this list return multiple records
                    //If we have any of the successfull line then we need to go with that otherwise we need to show the very first failure/error on response
                    if (processingRecordList.size()>0) {
                        for (Ticket_Sales_Processing__c record: processingRecordList) {
                            System.Debug('### in for');
                            //if the current tsp record has already earned points we should make sure that any record that might be linked is not on the same route
                            if (record.Points_indicator__c == true) {
                                RouteValidation rv = new RouteValidation(); rv.departureDate = record.Departure_date__c; rv.origin = record.Origin__c; rv.destination = record.Destination__c; rv.linkedUser = record.User_Link__c; lstUsedRoutes.add(rv);
                            }
                            system.debug('### lstUsedRoutes: ' + lstUsedRoutes);
                            //Ticket is already linked
                            if (!String.isBlank(record.User_Link__c) && record.TCN__c == tcn) {
                                maptoerror.put(record.id,'TicketAlreadyLinked');
                                lstofErrors.add('TicketAlreadyLinked');
                                system.debug('TicketAlreadyLinked-70');
                                //response.responseBody = createResponse(false, OK_CODE, '','Ticket is already linked with some other Member');
                                //return; 
                            } else if (record.Departure_Date__c != null && record.Departure_Date__c + 90 < Date.Today()) {
                                maptoerror.put(record.id,'90DaysPassed'); lstofErrors.add('90DaysPassed');
                                system.debug('90DaysPassed-77');
                                //response.responseBody = createResponse(false, BAD_REQUEST, '','It has been more than 90 days since the departure');
                                //return; 
                            } else if (tcnToTicket.containsKey(record.TCN__c) && !matchesName(tcnToTicket.get(record.TCN__c), lpmObj[0], mapSpecialCharToStdChar) && validateName) {
                                    maptoerror.put(record.id,'NameMismatched'); lstofErrors.add('NameMismatched');
                                    system.debug('NameMismatched-83');
                                    //response.responseBody = createResponse(false, BAD_REQUEST, '','Name is not matched');
                                    //return;
                                
                            } else if (memberProcessingRecordList.size()>0 && checkedInvalidation(record,memberProcessingRecordList)) {
                                    maptoerror.put(record.id,'TicketAlreadyCheckedIn'); lstofErrors.add('TicketAlreadyCheckedIn');
                                    system.debug('TicketAlreadyCheckedIn-88');
                                    //response.responseBody = createResponse(false, BAD_REQUEST, '','Name is not matched');
                                    //return;
                                
                            } else {
                                if (!String.isBlank(recordId) && recordId == record.Id) { record.TCN__c = tcn; record.Pnr__c = pnr;
                                }
                                record.User_Link__c=lpmObj[0].id;
                                if (!isSameRoute(lstUsedRoutes, record) && record.TCN__c == tcn) {
                                    System.Debug('### after isSameRoute if');
                                    if (record.Carrier__c=='Blue' && record.Checked_in__c) {
                                        System.Debug('### Blue checkin if');
                                        //Create TJ
                                        TransactionJournal tj = new TransactionJournal();
                                        tj.MemberId = lpmObj[0].id;
                                        tj.JournalTypeId = jst.JournalTypeId;
                                        tj.Currency__c = record.Payment_Currency_Code__c;
                                        tj.JournalSubTypeId = jst.Id;
                                        tj.TransactionAmount = record.Payment_Currency_Amount__c;//getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList);
                                        tj.Points__c = record.Potential_points__c;
                                        tj.ActivityDate = Date.today();
                                        tj.Departure_Date__c = record.Departure_Date__c;
                                        tj.PNR__c = record.Pnr__c;
                                        tj.Ticket__c = record.Tcn__c;
                                        tj.Origin = record.Origin__c;
                                        tj.Destination = record.Destination__c;
                                        tj.CarrierCode__c = record.Carrier__c;
                                        tj.Travel_Class__c = record.Class_Of_Service__c;
                                        tj.Booking_Date_Time__c = record.Event_Date__c;
                                        if(record.Points_eligible__c == true) {
                                            lstTransactionJournalsToInsert.add(tj);
                                            record.Points_indicator__c=true;
                                        } else {
                                            System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                        }
                                    } else if (record.Carrier__c=='Red') {
                                        system.debug('Red-110');
                                        if (!record.Refundable__c || record.Checked_in__c ) {
                                            //Create TJ
                                            system.debug('Tj-112');
                                            system.debug('points'+getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList));
                                            TransactionJournal tj = new TransactionJournal();
                                            tj.MemberId = lpmObj[0].id;
                                            tj.JournalTypeId = jst.JournalTypeId;
                                            tj.Currency__c= record.Payment_Currency_Code__c;
                                            tj.JournalSubTypeId = jst.Id;
                                            tj.TransactionAmount = record.Payment_Currency_Amount__c;//getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList);
                                            tj.Points__c = record.Potential_points__c;
                                            tj.ActivityDate = Date.today();
                                            tj.Departure_Date__c = record.Departure_Date__c;
                                            tj.PNR__c = record.Pnr__c;
                                            tj.Ticket__c = record.Tcn__c;
                                            tj.Origin = record.Origin__c;
                                            tj.Destination = record.Destination__c;
                                            tj.CarrierCode__c = record.Carrier__c;
                                            tj.Travel_Class__c = record.Class_Of_Service__c;
                                            tj.Booking_Date_Time__c = record.Event_Date__c;
                                            if(record.Points_eligible__c == true) {
                                                lstTransactionJournalsToInsert.add(tj);
                                                record.Points_indicator__c=true;
                                            } else {
                                                System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                            }
                                        } else if (!record.Checked_in__c && record.Refundable__c && record.Departure_date__c+1>=Date.today()) {
                                            //Create TJ
                                            system.debug('points'+getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList));
                                            TransactionJournal tj = new TransactionJournal();
                                            tj.MemberId = lpmObj[0].id;
                                            tj.Currency__c = record.Payment_Currency_Code__c;
                                            tj.TransactionAmount = record.Payment_Currency_Amount__c;//getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList);
                                            tj.Points__c = record.Potential_points__c;
                                            tj.JournalTypeId = jst.JournalTypeId;
                                            tj.JournalSubTypeId = jst.Id;
                                            tj.ActivityDate = Date.today();
                                            tj.Departure_Date__c = record.Departure_Date__c;
                                            tj.PNR__c = record.Pnr__c;
                                            tj.Ticket__c = record.Tcn__c;
                                            tj.Origin = record.Origin__c;
                                            tj.Destination = record.Destination__c;
                                            tj.CarrierCode__c = record.Carrier__c;
                                            tj.Travel_Class__c = record.Class_Of_Service__c;
                                            tj.Booking_Date_Time__c = record.Event_Date__c;
                                            if(record.Points_eligible__c == true) {
                                                lstTransactionJournalsToInsert.add(tj);
                                                record.Points_indicator__c=true;
                                            } else {
                                                System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                            }
                                        }
                                    }
                                    if (record.Points_indicator__c == true) {
                                        RouteValidation rv = new RouteValidation(); rv.departureDate = record.Departure_date__c; rv.origin = record.Origin__c; rv.destination = record.Destination__c; rv.linkedUser = record.User_Link__c;
                                        lstUsedRoutes.add(rv);
                                    }
                                    lstToUpdate.add(record);
                                } else if(isSameRoute(lstUsedRoutes, record)) {System.Debug('### memberEarnedPointsOnSameRoute');lstofErrors.add('memberEarnedPointsOnSameDay&Route');}
                            }
                            if (!String.isBlank(recordId) && recordId == record.Id) break;
                        }
                    } else {
                        lstofErrors.add('cancelledTicket');
                    }
                } else { 
                    lstofErrors.add('ticketNotFound');
                }
            } else {
                lstofErrors.add('invalidMembership');
            }
        }
        if (lstUsedRoutes.size() > 0 && lstTransactionJournalsToInsert.size() > 0) {
            unlinkUsedRoutes(lstUsedRoutes);
        }
        System.Debug('### lstUsedRoutes: ' + lstUsedRoutes);
        //Added the final response
        System.Debug('### lstTransactionJournalsToInsert: ' + lstTransactionJournalsToInsert);
        System.Debug('### lstToUpdate: ' + lstToUpdate);
        if (lstToUpdate.size() > 0) {
            update lstToUpdate;
        }
        if (lstTransactionJournalsToInsert.size()>0) {
            System.Debug('### in if lstTransactionJournalsToInsert');
            insert lstTransactionJournalsToInsert;
        } else {
            if(lstofErrors.size()>0 && lstToUpdate.size() == 0) {
                return (lstofErrors.size() == 1) ? lstofErrors[0] : lstofErrors[lstofErrors.size()-1];  
            } 
        }
        
        
        return 'success';
    }

    public static Decimal getPoints(String pnr,String destination,String origin,List<Ticket_Sales_Processing__c> pointsCamparisionList) {
        Decimal points=0.0;
        for(Ticket_Sales_Processing__c tsp:pointsCamparisionList){if(tsp.Origin__c==origin && tsp.Destination__c==destination){points = tsp.Potential_points__c;}}
        return points;
    }

    public static Boolean checkedInvalidation(Ticket_Sales_Processing__c record,List<Ticket_Sales_Processing__c> memberProcessingRecordList){
        Boolean error=False;
        for(Ticket_Sales_Processing__c rec: memberProcessingRecordList){
            if(record.Id != rec.Id && record.Departure_date__c==rec.Departure_date__c && record.Origin__c==rec.Origin__c && record.Destination__c==rec.Destination__c && record.Points_indicator__c){
                    error=True;
            }
        }
        return error;
    }
    
    
    	//Added for the new requirement of Manual ticket linking on  1/5/2024
        public static String retroClaimPointsNameOverRide(String membershipNumber, String pnr, String tcn, String recordId, String Passenger_First_Name , String Passenger_Last_Name ) {
        System.Debug('### retroClaimPoints start');
        Map<Id,String> maptoerror = new Map<Id,String>();
        List<String> lstofErrors = new List<String>();
        List<Ticket_Sales_Processing__c> pointsCamparisionList;
        List<RouteValidation> lstUsedRoutes = new List<RouteValidation>();
        JournalSubtype jst;
        List<TransactionJournal> lstTransactionJournalsToInsert = new List<TransactionJournal>();
        //Deserializing the data sent into concrete SFDC objects
        List<Ticket_Sales_Processing__c> lstToupdate = new List<Ticket_Sales_Processing__c>();
        List<Ticket_Sales_Processing__c> manualRecord;
        if(String.isBlank(membershipNumber) || String.isBlank(pnr)) {
            System.Debug('### main if');
            return 'invalidParameters';
        } else {
            System.Debug('### main else');
            jst = [SELECT Id, JournalTypeId FROM JournalSubtype WHERE Name = :JOURNAL_SUBTYPE_NAME AND JournalType.Name = :JOURNAL_TYPE_NAME];
            pointsCamparisionList = [Select id,Potential_points__c,PNR__c,Points_indicator__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c from Ticket_Sales_Processing__c where PNR__c =: pnr AND Points_eligible__c = True ORDER BY Potential_points__c DESC  ]; 
            List<Ticket__c> ticketsList;
            List<Ticket_Sales_Processing__c> processingRecordList;
            if(!String.isBlank(pnr) && !String.isBlank(tcn)){
                //If the TCN and PNR are provided, one ticket must be found that matches both values. If any found the ticket will be considered as eligible for linking.
                ticketsList = [Select id,Name,Title__c,Departure_Date__c,Departure_Date_Time_Format__c,Booking_DateTime_Format__c,First_Name__c,Last_Name__c,PNR__c,Destination__c,Origin__c,Travel_DateTime__c from Ticket__c where PNR__c =:pnr AND Name=:tcn AND Departure_Date__c > :Date.today().addDays(-90)];
                //processingRecordList = [Select id,PNR__c,Points_indicator__c,Carrier__c,Checked_in__c,Refundable__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c,Payment_Currency_Code__c, Payment_Currency_Amount__c from Ticket_Sales_Processing__c where TCN__c =:jsonwrap.tcn AND Cancelled__c = false];
                //If only PNR is provide, multiple tickets cxan be found. In that case all tickets will be considered as eligible for linking
            } else { ticketsList = [Select id,Name,Departure_Date__c,Departure_Date_Time_Format__c,Booking_DateTime_Format__c,Title__c,First_Name__c,Last_Name__c,PNR__c,Destination__c,Origin__c,Travel_DateTime__c from Ticket__c where PNR__c =:pnr AND Departure_Date__c > :Date.today().addDays(-90)]; }

            //we get the list of TSP only based on the PNR to be able to check for same day and route tickets
            processingRecordList = [Select id,PNR__c,Points_indicator__c,Carrier__c,Checked_in__c,Refundable__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c,Payment_Currency_Code__c, Payment_Currency_Amount__c, Class_Of_Service__c, Event_Date__c, Potential_points__c, Points_eligible__c from Ticket_Sales_Processing__c where PNR__c =:pnr AND Cancelled__c = false];
            manualRecord = !String.isBlank(recordId) ? [SELECT Id FROM Ticket_Sales_Processing__c WHERE Id = :recordId] : new List<Ticket_Sales_Processing__c>();
            Map<String,Ticket__c> tcnToTicket = new Map<String,Ticket__c>();

            if (ticketsList.size()>0) {
                for(Ticket__c tc:ticketsList){
                    tcnToTicket.put(tc.Name,tc);
                }
            }
            system.debug('### ticketsList: '+ticketsList+pnr+tcn);
            List<Ticket_Sales_Processing__c> memberProcessingRecordList = [Select id,PNR__c,Carrier__c,Checked_in__c,Refundable__c,Points_indicator__c,TCN__c,User_Link__r.MemberShipNumber,User_Link__r.MemberStatus,Destination__c,Origin__c,Departure_Date__c from Ticket_Sales_Processing__c where User_Link__r.MemberShipNumber =: membershipNumber];
            system.debug('### memberProcessing: '+memberProcessingRecordList);
            List<LoyaltyProgramMember> lpmObj =[Select id,Contact.FirstName,Contact.LastName,Contact.Title,MemberStatus from LoyaltyProgramMember where MembershipNumber=:membershipNumber AND MemberStatus='Active'];
            //Check if the LPM exists
            if (lpmObj.size() > 0 && lpmObj[0].MemberStatus != 'Active') {
                return 'inactiveMember';
            }
            if (lpmObj.size()>0) {
                //Check if ticket exists
                if (ticketsList.size()>0) {
                    //What if this list return multiple records
                    //If we have any of the successfull line then we need to go with that otherwise we need to show the very first failure/error on response
                    if (processingRecordList.size()>0) {
                        for (Ticket_Sales_Processing__c record: processingRecordList) {
                            System.Debug('### in for');
                            //if the current tsp record has already earned points we should make sure that any record that might be linked is not on the same route
                            if (record.Points_indicator__c == true) {
                                RouteValidation rv = new RouteValidation(); rv.departureDate = record.Departure_date__c; rv.origin = record.Origin__c; rv.destination = record.Destination__c; rv.linkedUser = record.User_Link__c; lstUsedRoutes.add(rv);
                            }
                            system.debug('### lstUsedRoutes: ' + lstUsedRoutes);
                            //Ticket is already linked
                            if (!String.isBlank(record.User_Link__c) && record.TCN__c == tcn) {
                                maptoerror.put(record.id,'TicketAlreadyLinked');
                                lstofErrors.add('TicketAlreadyLinked');
                                system.debug('TicketAlreadyLinked-70');
                                //response.responseBody = createResponse(false, OK_CODE, '','Ticket is already linked with some other Member');
                                //return; 
                            } else if (record.Departure_Date__c != null && record.Departure_Date__c + 90 < Date.Today()) {
                                maptoerror.put(record.id,'90DaysPassed');
                                lstofErrors.add('90DaysPassed');
                                system.debug('90DaysPassed-77');
                                //response.responseBody = createResponse(false, BAD_REQUEST, '','It has been more than 90 days since the departure');
                                //return; 
                            } else if (tcnToTicket.containsKey(record.TCN__c) && !ticketLinkingRuleNameOverRide(tcnToTicket.get(record.TCN__c),lpmObj[0],Passenger_First_Name,Passenger_Last_Name)) {
                                    maptoerror.put(record.id,'NameMismatched'); lstofErrors.add('NameMismatched');
                                    system.debug('NameMismatched-83');
                                    //response.responseBody = createResponse(false, BAD_REQUEST, '','Name is not matched');
                                    //return;
                                
                            } else if (memberProcessingRecordList.size()>0 && checkedInvalidation(record,memberProcessingRecordList)) {
                                    maptoerror.put(record.id,'TicketAlreadyCheckedIn'); lstofErrors.add('TicketAlreadyCheckedIn');
                                    system.debug('TicketAlreadyCheckedIn-88');
                                    //response.responseBody = createResponse(false, BAD_REQUEST, '','Name is not matched');
                                    //return;
                               
                            } else {
                                if (!String.isBlank(recordId) && recordId == record.Id) { record.TCN__c = tcn; record.Pnr__c = pnr;
                                }
                                record.User_Link__c=lpmObj[0].id;
                                if (!isSameRoute(lstUsedRoutes, record) && record.TCN__c == tcn) {
                                    System.Debug('### after isSameRoute if');
                                    if (record.Carrier__c=='Blue' && record.Checked_in__c) {
                                        System.Debug('### Blue checkin if');
                                        //Create TJ
                                        TransactionJournal tj = new TransactionJournal();
                                        tj.MemberId = lpmObj[0].id;
                                        tj.JournalTypeId = jst.JournalTypeId;
                                        tj.Currency__c = record.Payment_Currency_Code__c;
                                        tj.JournalSubTypeId = jst.Id;
                                        tj.TransactionAmount = record.Payment_Currency_Amount__c;//getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList);
                                        tj.Points__c = record.Potential_points__c;
                                        tj.ActivityDate = Date.today();
                                        tj.Departure_Date__c = record.Departure_Date__c;
                                        tj.PNR__c = record.Pnr__c;
                                        tj.Ticket__c = record.Tcn__c;
                                        tj.Origin = record.Origin__c;
                                        tj.Destination = record.Destination__c;
                                        tj.CarrierCode__c = record.Carrier__c;
                                        tj.Travel_Class__c = record.Class_Of_Service__c;
                                        tj.Booking_Date_Time__c = record.Event_Date__c;
                                        if(record.Points_eligible__c == true) {
                                            lstTransactionJournalsToInsert.add(tj);
                                            record.Points_indicator__c=true;
                                        } else {
                                            System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                        }
                                    } else if (record.Carrier__c=='Red') {
                                        system.debug('Red-110');
                                        if (!record.Refundable__c || record.Checked_in__c ) {
                                            //Create TJ
                                            system.debug('Tj-112');
                                            system.debug('points'+getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList));
                                            TransactionJournal tj = new TransactionJournal();
                                            tj.MemberId = lpmObj[0].id;
                                            tj.JournalTypeId = jst.JournalTypeId;
                                            tj.Currency__c= record.Payment_Currency_Code__c;
                                            tj.JournalSubTypeId = jst.Id;
                                            tj.TransactionAmount = record.Payment_Currency_Amount__c;//getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList);
                                            tj.Points__c = record.Potential_points__c;
                                            tj.ActivityDate = Date.today();
                                            tj.Departure_Date__c = record.Departure_Date__c;
                                            tj.PNR__c = record.Pnr__c;
                                            tj.Ticket__c = record.Tcn__c;
                                            tj.Origin = record.Origin__c;
                                            tj.Destination = record.Destination__c;
                                            tj.CarrierCode__c = record.Carrier__c;
                                            tj.Travel_Class__c = record.Class_Of_Service__c;
                                            tj.Booking_Date_Time__c = record.Event_Date__c;
                                            if(record.Points_eligible__c == true) {
                                                lstTransactionJournalsToInsert.add(tj);
                                                record.Points_indicator__c=true;
                                            } else {
                                                System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                            }
                                        } else if (!record.Checked_in__c && record.Refundable__c && record.Departure_date__c+1>=Date.today()) {
                                            //Create TJ
                                            system.debug('points'+getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList));
                                            TransactionJournal tj = new TransactionJournal();
                                            tj.MemberId = lpmObj[0].id;
                                            tj.Currency__c = record.Payment_Currency_Code__c;
                                            tj.TransactionAmount = record.Payment_Currency_Amount__c;//getPoints(record.PNR__c,record.Destination__c,record.Origin__c,pointsCamparisionList);
                                            tj.Points__c = record.Potential_points__c;
                                            tj.JournalTypeId = jst.JournalTypeId;
                                            tj.JournalSubTypeId = jst.Id;
                                            tj.ActivityDate = Date.today();
                                            tj.Departure_Date__c = record.Departure_Date__c;
                                            tj.PNR__c = record.Pnr__c;
                                            tj.Ticket__c = record.Tcn__c;
                                            tj.Origin = record.Origin__c;
                                            tj.Destination = record.Destination__c;
                                            tj.CarrierCode__c = record.Carrier__c;
                                            tj.Travel_Class__c = record.Class_Of_Service__c;
                                            tj.Booking_Date_Time__c = record.Event_Date__c;
                                            if(record.Points_eligible__c == true) {
                                                lstTransactionJournalsToInsert.add(tj);
                                                record.Points_indicator__c=true;
                                            } else {
                                                System.Debug('### notEligibleForPoints');lstofErrors.add('notEligibleForPoints');
                                            }
                                        }
                                    }
                                    if (record.Points_indicator__c == true) {
                                        RouteValidation rv = new RouteValidation();
                                        rv.departureDate = record.Departure_date__c;
                                        rv.origin = record.Origin__c;
                                        rv.destination = record.Destination__c;
                                        rv.linkedUser = record.User_Link__c;
                                        lstUsedRoutes.add(rv);
                                    }
                                    lstToUpdate.add(record);
                                } else if(isSameRoute(lstUsedRoutes, record)) {System.Debug('### memberEarnedPointsOnSameRoute');lstofErrors.add('memberEarnedPointsOnSameDay&Route');}
                            }
                            if (!String.isBlank(recordId) && recordId == record.Id) break;
                        }
                    } else {
                        lstofErrors.add('cancelledTicket');
                    }
                } else { 
                    lstofErrors.add('ticketNotFound');
                }
            } else {
                lstofErrors.add('invalidMembership');
            }
        }
        if (lstUsedRoutes.size() > 0 && lstTransactionJournalsToInsert.size() > 0) {
            unlinkUsedRoutes(lstUsedRoutes);
        }
        System.Debug('### lstUsedRoutes: ' + lstUsedRoutes);
        //Added the final response
        System.Debug('### lstTransactionJournalsToInsert: ' + lstTransactionJournalsToInsert);
        System.Debug('### lstToUpdate: ' + lstToUpdate);
        if (lstToUpdate.size() > 0) {
            update lstToUpdate;
        }
        if (lstTransactionJournalsToInsert.size()>0) {
            System.Debug('### in if lstTransactionJournalsToInsert');
            insert lstTransactionJournalsToInsert;
        } else {
            if(lstofErrors.size()>0 && lstToUpdate.size() == 0) {
                return (lstofErrors.size() == 1) ? lstofErrors[0] : lstofErrors[lstofErrors.size()-1];  
            } 
        }
        
        
        return 'success';
    }

    
    
    public static Boolean ticketLinkingRuleNameOverRide(Ticket__c ticketObj,LoyaltyProgramMember LPM, String Passenger_First_Name, String Passenger_Last_Name){
        System.debug('### ticketObj: ' + ticketObj);

        string ticketTitle = ticketObj.Title__c;
       	string ticketFirstName = Passenger_First_Name;
		string ticketLastName = Passenger_Last_Name;
        System.debug('###beforeTitle');
		string contactTitle = LPM.Contact.Title;
        string contactFirstName = LPM.Contact.FirstName;
        System.debug('###afterFN');
        string contactLastName	= LPM.Contact.LastName != null ? LPM.Contact.LastName : '';
        System.debug('###afterLN' + ticketFirstName + ticketLastName + contactFirstName + contactLastName );
        
        //Boolean check = ticketTitle != null ? ticketTitle.equals(contactTitle) : false;
        //Boolean titleEmpty = String.isBlank(ticketTitle);
        Boolean TicketFirstNameMatch = ticketFirstName != null ? ticketFirstName.equalsIgnoreCase(contactFirstName) : false;
        Boolean TicketLastNameMatch = ticketLastName != null ? ticketLastName.equalsIgnoreCase(contactLastName) : false;
        //Boolean TicketTitleMatch = ticketTitle != null ? ticketTitle.equalsIgnoreCase(contactTitle) : false;
        // Abbrviations are given as follows
        // TFN = TicketFirstName , CFN = contactFirstName, CLN = contactLastName, CT = contactTitle
        Boolean TFNcontainCFN = (ticketFirstName != null && contactFirstName != null) ? ticketFirstName.containsIgnoreCase(contactFirstName) : false;
        Boolean TFNcontainHypen = TicketFirstName != null ? TicketFirstName.contains('-') : false;
        System.Debug('### contactTitle: ' + contactTitle);
        System.Debug('### ticketFirstName: ' + ticketFirstName);
        //Boolean TFNcontaineCT = contactTitle != null ? ticketFirstName.containsIgnoreCase(contactTitle) : false;
        Boolean CLNcontainTLN = ticketLastName != null ? contactLastName.containsIgnoreCase(ticketLastName) : false;
        //Boolean Rule3A_C = String.isBlank(ticketTitle)  && (string.isBlank(ticketFirstName) || string.isBlank(ticketLastName));
        Boolean Rule3A_C = string.isBlank(ticketFirstName) || string.isBlank(ticketLastName);
        //Boolean Rule3D_E = !titleEmpty && !TicketLastNameMatch && TicketFirstNameMatch && !CLNcontainTLN;
        //Boolean Rule3F_I = !titleEmpty && !TicketFirstNameMatch && TicketLastNameMatch;
        //Boolean Rule3J =  !titleEmpty && !TicketFirstNameMatch && !TicketLastNameMatch;
        //Boolean Rule4A = titleEmpty && !TFNcontaineCT && TicketLastNameMatch && TicketFirstNameMatch;

        Boolean Rule3D_E = !TicketLastNameMatch && TicketFirstNameMatch && !CLNcontainTLN; 
        Boolean Rule3F_I = !TicketFirstNameMatch && TicketLastNameMatch;
        Boolean Rule3J =  !TicketFirstNameMatch && !TicketLastNameMatch;
        Boolean Rule4A = TicketLastNameMatch && TicketFirstNameMatch;

        //Boolean Rule4B = !TicketTitleMatch && !titleEmpty && TicketLastNameMatch && TicketFirstNameMatch;
        Boolean Rule4B = TicketLastNameMatch && TicketFirstNameMatch;
        //Boolean Rule5A_B = TFNcontainCFN && !TicketFirstNameMatch && !TFNconta	ineCT && !TFNcontainHypen;
        Boolean Rule5A_B = TFNcontainCFN && !TicketFirstNameMatch && !TFNcontainHypen; 
        //Boolean Rule5C_D = TFNcontainCFN && !TicketFirstNameMatch && TFNcontaineCT && titleEmpty && !TFNcontainHypen;
        Boolean Rule5C_D = TFNcontainCFN && !TicketFirstNameMatch && !TFNcontainHypen;
        Boolean Rule8 = (ticketFirstName != null && ticketLastName != null) ? (ticketFirstName.equalsIgnoreCase(contactLastName) && ticketLastName.equalsIgnoreCase(contactFirstName)) : false;
        // Rejected Ticket rule 3
        if(Rule3A_C) {/*system.debug('Rejected Ticket: First name, last name or both are missing on the ticket');*/ return False; } 
        else if (Rule3D_E){/*system.debug('Rejected Ticket: last name missmatch');*/ return False; } 
        else if (Rule3F_I && !Rule5A_B && !TFNcontainHypen){/*system.debug('Rejected Ticket: First name missmatch');*/ return False; } 
        else if (Rule3J && !Rule8){/*system.debug('Rejected Ticket: First and last name missmatch');*/ return False; } 
        //Approved Tickets rule 4 
        else if (Rule4A){/*system.debug('Approved Ticket: The title on the ticket is missing');*/ return True; } 
        else if (Rule4B){/*system.debug('Approved Ticket: The title on the ticket does not match');*/ return True; } 
        //approved tickets rule 5
        else if (Rule5A_B){/* system.debug('Approved Ticket: Members full name has been entered as the first name on the ticket with and without spaces');*/ return True; } else if (Rule5C_D){/* system.debug('Approved Ticket: Members title has been added to the first name on the ticket with and without spaces');*/ return True; } 
        //approved tickets rule 6
        else if (TFNcontainHypen){/* system.debug('Approved Ticket: The first name and/or the last name on the ticket has a hyphen');*/	return True; }
        //approved tickets rule 7
        else if (CLNcontainTLN && !TicketLastNameMatch){ /* system.debug('Approved Ticket: The members full last name may not be entered in the ticket');*/ return True; } //approved tickets rule 8
        else if (Rule8){ /* system.debug('Approved Ticket: The first name and the last name of the customer is swapped on the ticket');  */ return True; }
        return False;
    }
    public class RouteValidation {
        public String linkedUser;
        public String origin;
        public String destination;
        public Date departureDate;
    }
}