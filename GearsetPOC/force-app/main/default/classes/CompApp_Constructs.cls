Global class  CompApp_Constructs { 
   																		 
    public enum CompensationType {POINT , VOUCHER}
    public enum CompensationRejectionReason {
                                                NO_APPLICABLE_COMPENSATION, COMPENSATION_ALREADY_CLAIMED, COMPENSATION_NON_QUALIFIED_TRAVEL_DATE
                                            }
    public enum CompensationReason{
        Delay, Incident, Train, DelayAndIncident, DelayAndTrain, DelayAndTrainAndIncident
    }
    public ENUM LOYALTY_TIER{
        CC, CB, CBE
    }
    public enum CompansationExclusionRuleType {
        NON_ZERO_PRICE_TICKET, ZERO_PRICE_TICKET
    }
    public class CompApp_DataIssueException extends Exception{}
    public class CompApp_BadDateFormatException extends Exception{}
    public class CompApp_CaptchaSecurityException extends Exception{}

    public class CompensationFlatFeeRulesWrapper{
        public String currencyCode {get; private set;}
        public String incidentType {get; private set;}
        public String travelerClass {get; private set;}
        public Decimal voucherAmount {get; private set;}

        public CompensationFlatFeeRulesWrapper(Compensation_Flat_Fee_Rules__c compFlatFeeRule){
            this.currencyCode = compFlatFeeRule.Currency_Code__c;
            this.incidentType = compFlatFeeRule.Incident_Type__c;
            this.travelerClass = compFlatFeeRule.Traveler_Class__c;
            this.voucherAmount = compFlatFeeRule.Voucher_Amount__c;
        }
    }
    public class CompensationRuleWrapper implements Comparable{
        public Boolean isValidRule {get; private set;}
        public String type {get; private set;}
        public Decimal delayStart {get; private set;}
        public Decimal delayEnd {get; private set;}
        public Decimal pointsConversionRate {get; private set;}
        public Decimal eligibleBaseCompensationCB {get; private set;}
        public Decimal eligibleBaseCompensationCBE {get; private set;}
        public Decimal eligibleBaseCompensationCC {get; private set;}
        public Decimal eligibleCompensation {get; private set;}
		public Decimal eligiblePRRCompensation {get; private set;}														  
        public String fbc {get; private set;}
        public String originalCurrency {get; private set;}
        public Decimal points {get; private set;}
        public Decimal voucher {get; private set;}
        public Decimal pointConversion {get; private set;}
        public Map<String, Decimal> currencyRates {get; private set;}



        private Sobject compRule;
        
        public CompensationRuleWrapper (Sobject customSettingCommon){
            if (customSettingCommon.getSobjectType().getDescribe().getName() == 'Compensation_Rules__c'){
                populateAsCompRule((Compensation_Rules__c) customSettingCommon);
            }
            else if (customSettingCommon.getSobjectType().getDescribe().getName() == 'Comp_App_Zero_Price_Compensation__c'){
                populateAsZeroPriceComp((Comp_App_Zero_Price_Compensation__c) customSettingCommon);
            }

        }
        private Decimal getWellBehavedDecValue (Object o){
            try{
                return Decimal.valueOf((Double) o);
            }catch (Exception e){
                CompApp_Utils.log('eligibleBaseCompensation is empty in Compensation_Rules__c Custom Setting');
                return 0.0;
            }
        }
        private void populateAsCompRule(Compensation_Rules__c compRule){
            this.compRule = compRule;
            this.pointsConversionRate = getWellBehavedDecValue(compRule.Point_Conversion__c);
            this.eligibleBaseCompensationCB = getWellBehavedDecValue(compRule.Eligible_Base_Compensation_CB__c);
            this.eligibleBaseCompensationCBE = getWellBehavedDecValue(compRule.Eligible_Base_Compensation_CBE__c);
            this.eligibleBaseCompensationCC = getWellBehavedDecValue(compRule.Eligible_Base_Compensation_CC__c);
            this.eligibleCompensation = getWellBehavedDecValue(compRule.Eligible_Compensation__c);
            this.eligiblePRRCompensation = getWellBehavedDecValue(compRule.Eligible_PRR_Compensation__c);
            this.pointConversion = getWellBehavedDecValue(compRule.Point_Conversion__c);
            this.currencyRates = new Map<String,Decimal>();
            this.currencyRates.put('USD', getWellBehavedDecValue(compRule.USD_Rate__c));
            this.currencyRates.put('GBP', getWellBehavedDecValue(compRule.GBP_Rate__c));
            this.currencyRates.put('EUR', getWellBehavedDecValue(compRule.EUR_Rate__c));

            populateGeneric(compRule);
        }
        
        private void populateAsZeroPriceComp(Comp_App_Zero_Price_Compensation__c  zeroPriceComp){
            this.compRule = zeroPriceComp;
            this.originalCurrency = zeroPriceComp.currency__c;
            this.fbc = zeroPriceComp.FBC__c;
            this.points = zeroPriceComp.Points__c !=null ? zeroPriceComp.Points__c : 0;
            this.voucher = zeroPriceComp.Voucher__c !=null? zeroPriceComp.Voucher__c : 0;
            populateGeneric(zeroPriceComp);
        }
        public void populateGeneric(Sobject customSettingCommon){
            this.isValidRule = (Boolean) customSettingCommon.get('isValidRule__c');
            this.type = (String) customSettingCommon.get('type__c');
            this.delayStart = (Decimal) customSettingCommon.get('Delay_Start__c');
            this.delayEnd = (Decimal) customSettingCommon.get('Delay_End__c');

        }


        public Boolean isInMaxRange(Decimal inputDelay){
            return delayStart <= inputDelay && delayEnd ==null;
        }

        public Boolean isInRange(Decimal inputDelay){
            return delayStart <= inputDelay && delayEnd >=inputDelay;
        }

        public Integer compareTo(Object compareTo) {
            return this.delayStart > ((CompensationRuleWrapper) compareTo ).delayStart? 1:-1;
        }
    }

    public class EligibilityResponse{
        public Boolean captchaSuccess = false;
        public String userIp ='';
        public String systemErrorMessage = '';
        public String membershipNumber='';

        public Boolean isVaucher = false;
        public Boolean isPoints = false;
        public String sumPoints = '0';
        public String sumVoucher = '0';
        public String compensationCurrency ='';
        public CompensationReason compensationReason;

        public CompensationRejectionReason deniedReason;
        public String softErrorBody ='';
        public String softErrorHeader ='';

        public String dateOfTravel ='';
        public String ticketPrice = '';
        public String trainNum ='';
        public String ticketNum ='';
        public String PNR ='';
        public Integer delayInMinutes = 0;

        public EligibilityResponse(){}

        public EligibilityResponse(String userIp){
            this.userIp = userIp;
        }
    }

    public class NewCaseHolderResponse{
        public Id      caseHolderId                  = Null;
        public String  softErrorBody                 = '';
        public String  softErrorHeader               = '';
        public Boolean isCaptchaSuccess              = true;
        public Boolean isTicketExists                = true;
        public Boolean isInvalidPNR                  = false;
        public Boolean isDuplicateRequest            = false;
        public Boolean isNotEligible                 = false;
        public Boolean isNoTicketsInScope            = false;
        public Boolean isNoDisneyTicketsInScope      = false;
        public Boolean isNoTicketsIn60DaysScope      = false;
        public Boolean isClaimedPastThresholdDate    = false;
        public Boolean isCancelledTrainsPastTheScope = false;
        public Boolean isPackageBookingPastTheScope  = false;
        public Boolean isRedirectionToMYBRequired    = false;
        public Boolean isClaimEmailMismatch          = false;
        public Boolean isIdentityNotConfirmed         = false;
    }

    public class NewCaseWrapper{
        public Case newCase;
        public Id holderId;

        public NewCaseWrapper(Case inputCase, Id inputHolderId){
            this.newCase = inputCase;
            this.holderId = inputHolderId;
        }
    }

    public class CompensationHistoryTracking {
        public String Ticket_Price ='';
        public Boolean Flat_Fee = false;
        public Boolean isCancelled = false;
        public String Total_Online_Points ='';
        public List<String> Compensation_Percentage;
		public String PRR_Amount ='';
        public String Base_Compensation ='';
		public String Additional_Compensation ='';										  
        public String Delay_Minutes_Rule ='';
        public String Actual_Delay ='';
        public String Train_Compensation ='';
        public String Compensation_Reason ='';
        public String Total_Incident_Comp ='';
    }
        
    public Static Decimal EUR_2_POINT_CONVERSION_RATE{get{
                                                if (EUR_2_POINT_CONVERSION_RATE == null){
                                                    try{
                                                        EUR_2_POINT_CONVERSION_RATE =  Decimal.valueOf(Compensation_App_Metadata__c.getValues('EUR_2_Points').Data__c);
                                                    }catch(Exception e){
                                                        system.debug(Logginglevel.ERROR, 'No EUR_2_Points Defined, Please verify "Compensation_App_Metadata__c" configurations');
                                                        EUR_2_POINT_CONVERSION_RATE =  0.15;
                                                    }
                                                }

                                                return EUR_2_POINT_CONVERSION_RATE;

                                            }}
    
    public Static Decimal GBP_2_POINT_CONVERSION_RATE{get{
                                                if (GBP_2_POINT_CONVERSION_RATE == null){
                                                    try{
                                                        GBP_2_POINT_CONVERSION_RATE =  Decimal.valueOf(Compensation_App_Metadata__c.getValues('GBP_2_Points').Data__c);
                                                    }catch(Exception e){
                                                        system.debug(Logginglevel.ERROR, 'No GBP_2_Points Defined, Please verify "Compensation_App_Metadata__c" configurations');
                                                        GBP_2_POINT_CONVERSION_RATE =  0.20;
                                                    }
                                                }

                                                return GBP_2_POINT_CONVERSION_RATE;
                                            }}

    public Static Integer VOUCHER_EXPIRATION_DELTA {get{
                                            if (VOUCHER_EXPIRATION_DELTA == null){
                                                try{
                                                    VOUCHER_EXPIRATION_DELTA =  Integer.valueOf(Compensation_App_Metadata__c.getValues('Voucher Expiration Interval Months').Data__c);
                                                }catch(Exception e){
                                                    system.debug(Logginglevel.ERROR, 'No Voucher Expiry Defined, Please verify "Compensation_App_Metadata__c" configurations');
                                                    VOUCHER_EXPIRATION_DELTA =  12;
                                                }
                                            }
                                            return VOUCHER_EXPIRATION_DELTA;
                                        }}

    public Static Integer GOOGLE_CAPTCHA_LIVIDITY_TIME {get{
                                            try{
                                                return Integer.valueOf(Compensation_App_Metadata__c.getValues('google_captcha_live_time_minutes').Data__c);
                                            }catch(Exception e){
                                                system.debug(Logginglevel.ERROR, 'No Google Captcha secret life time found in Custom setting. Please verify "Compensation_App_Metadata__c" configurations');
                                                return 5;
                                            }
                                        }}

    public Static String GOOGLE_CAPTCHA_SITE_KEY {get{
                                            try{
                                                return Compensation_App_Metadata__c.getValues('google_captcha_site_key').Data__c;
                                            }catch(Exception e){
                                                throw new CompApp_DataIssueException ('No Google Captcha secret found in Custom setting. Please verify "Compensation_App_Metadata__c" configurations');
                                            }
                                        }}

    public Static String COMPENSATION_POLICY_CHANGE_DATE {get{
                                            try{
                                                return Compensation_App_Metadata__c.getValues('Compensation Policy Change Date').Data__c;
                                            }catch(Exception e){
                                                throw new CompApp_DataIssueException ('No Compensation Policy Change Date found in Custom setting. Please verify "Compensation_App_Metadata__c" configurations');
                                            }
                                        }}

    public Static Map<String,String> CURRENCY_CODE_TO_HTML = new Map<String, String> {'EUR' => '&#8364;', 'USD'=>'&#36;', 'GBP'=>'&pound;'};

    public Static Integer MAX_FORCE_SYNC_COMPENSATION_RECORD_COUNT {get{
                                                                        if(MAX_FORCE_SYNC_COMPENSATION_RECORD_COUNT == null){
                                                                            try{
                                                                                MAX_FORCE_SYNC_COMPENSATION_RECORD_COUNT = Integer.valueOf(Compensation_App_Metadata__c.getValues('force_async_record_count').Data__c);
                                                                            }catch(Exception e){
                                                                                MAX_FORCE_SYNC_COMPENSATION_RECORD_COUNT = 6;
                                                                            }
                                                                        }
                                                                        return MAX_FORCE_SYNC_COMPENSATION_RECORD_COUNT;
                                                                        }set;}
    
    public Static Integer FUTURE_LIMIT_BUFFER_TRIGGER {get{
                                                            return 8;
                                                            }}

    public Static Date parseStringToDate(String dateString){
        try{
            String[] partsOfDates = dateString.split('/');
            system.debug('partsOfDates[2] '+partsOfDates[2].substringBefore(' '));
            Integer yearOnDate =  integer.valueOf(partsOfDates[2].substringBefore(' ')) < 100 ? (integer.valueOf(partsOfDates[2].substringBefore(' ')) + 2000) : integer.valueOf(partsOfDates[2].substringBefore(' '));
            Date dateAfterParse = Date.newInstance(yearOnDate, integer.valueOf(partsOfDates[1]), integer.valueOf(partsOfDates[0]));
            return dateAfterParse;
        }catch(Exception e){
            throw new CompApp_BadDateFormatException ('The Date of Travel or the Compensation Policy Change Date are in a wrong format. Please verify "Date_of_Travel__c" and "Compensation_App_Metadata__c" configurations');
        }
    }


    
    private static compOfSingleTicket compOfSingleTicketInstance;
    public static compOfSingleTicket getCompOfSingleTicket(
                                                    String userRemoteIp, String languageCode, 
                                                    String ticketNumber, String userInputPNR,
                                                    String dateOfTravel){

        if(compOfSingleTicketInstance == null){
            compOfSingleTicketInstance = new compOfSingleTicket(
                                                                userRemoteIp, languageCode, 
                                                                ticketNumber ,userInputPNR,
                                                                dateOfTravel);
        }
        return compOfSingleTicketInstance;
    }

    public class compOfSingleTicket{
        public Boolean hasOnlineClaimedComp {get;set;}
        public Compensation__c unclaimedOnlineComp {get;set;}
        public Ticket__c ticket {get;set;}
        public Boolean isValidDate {get;set;}
        public Boolean isCaptchVerified {get;set;}

        public compOfSingleTicket(String userRemoteIp, String languageCode, 
                                        String ticketNumber, String userInputPNR,
                                        String dateOfTravel){
        
            if(!CompApp_Utils.isUserCaptchaVerified(userRemoteIp)){
                throw new CompApp_CaptchaSecurityException('IP is not Autherized for requested resources.');        
            }else{
                isCaptchVerified = true;
            }

            this.unclaimedOnlineComp = null;
            this.hasOnlineClaimedComp = false;      
            Date policyChangeDate = parseStringToDate(COMPENSATION_POLICY_CHANGE_DATE);
            
            this.isValidDate = true;
            
            List<Compensation_Ticket__c> compTicketJunctionList = [
                SELECT
                    Compensation__c,
                    Ticket__r.Id,
                    Ticket__r.Ticket_Price__c,
                    Ticket__r.Name,
                    Ticket__r.Delay_mins__c,
                    Ticket__r.PNR__c,
                    Ticket__r.Booking_Sales_Channel__c,
                    Ticket__r.Train__r.Train_Number__c,
                    Ticket__r.Train__r.Name,
                    Compensation__r.Claim_Status__c
                FROM
                    Compensation_Ticket__c
                WHERE
                    Ticket__r.PNR__c = :userInputPNR
                    AND Ticket__r.Name =:CompApp_Utils.remove2LeadingAlpha(ticketNumber)
                    AND (
                        Ticket__r.Cancelled__c = True
                        OR (
                            Ticket__r.Cancelled_By_Customer__c = False
                            AND Ticket__r.Ticket_Status__c = :DLT_TicketConstants.TICKET_STATUS_ACTIVE
                            AND (
                                Ticket__r.Checked_In__c = True 
                                OR (
                                    Ticket__r.Train__r.Carrier__c = :DLT_TrainConstants.CARRIER_RED
                                )
                            )
                        )
                    )
            ];

            if(CompApp_Utils.isWellBehaved(compTicketJunctionList)){
                if (compTicketJunctionList.size() > 1 && compTicketJunctionList[0].Compensation__r.Claim_Status__c == 'Claimed') {
                    this.ticket = compTicketJunctionList[1].Ticket__r;
                } else {
                    this.ticket = compTicketJunctionList[0].Ticket__r;
                }
                
                Set<Id> compIdSet = CompApp_Utils.getSobjectIdMap('Compensation__c', compTicketJunctionList).keySet();                                                       
                List<Compensation__c> compList = [SELECT 
                                                        Id,Payment_Currency__c, Claim_Status__c,Is_Eligible_Points__c, Date_of_Travel__c,Membership_Number__c,
                                                        Is_Excluded_From_Delay_Compensation__c,Total_Online_Compensation__c, Total_Online_Points__c,Base_Compensation__c,
                                                        Total_Incident_Compensation__c, Train_Compensation__c,Delay_Duration_Mins__c, Train_Cancelled__c, Train__r.Name,
                                                        Manually_Processed_CC__c, Manually_Processed_BSP_ONLY__c, CustomerC__c
                                                    FROM 
                                                        Compensation__c  
                                                    WHERE
                                                            Id IN: compIdSet
                                                        AND
                                                            RecordTypeId =: CompApp_Utils.compensationOnlineRecTypeID
                                                        AND
                                                  			Train__r.Name =: this.ticket.Train__r.Name
                                                  		AND
                                                            (Total_Online_Compensation__c != 0 OR Total_Online_Points__c != 0)
                                                        AND
                                                            Payment_Currency__c != null
                                                        AND
                                                            ( 
                                                                Voucher_Expiry_Date__c = NULL
                                                            OR
                                                                Voucher_Expiry_Date__c >= : Date.today()
                                                            )
                                                    LIMIT
                                                        1
                                                    FOR UPDATE
                                                ];
                system.debug('compList: '+compList);                                
                CompApp_Utils.log('compList @ checkUserEligibility: ' +compList );
                if(CompApp_Utils.isWellBehaved(compList)){
                    for(Compensation__c comp : compList){
                        if(comp.Date_of_Travel__c.length() > 9){
                            Date quariedTravelDate = parseStringToDate(comp.Date_of_Travel__c.substring(0,10));
                            if (policyChangeDate.addDays(-1) > quariedTravelDate){
                                this.ticket = null;
                                this.isValidDate = false;
                            }
                        }
                        if(comp.Claim_Status__c != 'Claimed'){
                            this.unclaimedOnlineComp = comp;
                        }
                        else{
                            this.hasOnlineClaimedComp = true;
                        }
                    }
                }                          
            }
            
            CompApp_Utils.log('compList @ hasOnlineClaimedComp: ' +this.hasOnlineClaimedComp );
            CompApp_Utils.log('compList @ unclaimedOnlineComp: ' +this.unclaimedOnlineComp );
        }
        
    }

    public class CompensationCreationDataWrapper{
        public List<Ticket__c> tickList;
        public List<Incidents__c> incList;
        public Set<Train__c> trainList = new Set<Train__c>();
        public List<List<Ticket__c>> chunkedTicketList;
        public Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints = new Map<Id,Map<String,Passing_Point__c>>();

        public CompensationCreationDataWrapper(List<Ticket__c> tickList, List<Incidents__c> incList){

            Integer MAX_NUM_OF_TICKET_PER_TRANSACTION = 200;
            
            this.tickList = tickList;
            this.incList = incList;

            // mark Train as handled by auto compensation
            for (Ticket__c t : tickList){
                this.trainList.add(new Train__c(Id = t.Train__c));
            }
            
            this.trainWithPassingPoints = generateTrainMapWithPassingPoints(tickList, trainList);
            
            this.tickList = replaceTrainDelayWithPassingPointDelay(this.tickList, this.trainWithPassingPoints);

            chunkedTicketList = new List<List<Ticket__c>>();

            Integer NUM_OF_TICKETS = tickList.size();
            if (NUM_OF_TICKETS > MAX_NUM_OF_TICKET_PER_TRANSACTION){
                Integer i,j;
               Integer NUM_OF_REQUIRED_ITERATIONS = divideIntegersRoundUp(NUM_OF_TICKETS, MAX_NUM_OF_TICKET_PER_TRANSACTION);
                //== 6
                

                for (i=0; i<NUM_OF_REQUIRED_ITERATIONS; i++){
                    chunkedTicketList.add(new List<Ticket__c>());
                    if (MAX_NUM_OF_TICKET_PER_TRANSACTION * (i+1) <= NUM_OF_TICKETS ){
                        for (j=0; j<MAX_NUM_OF_TICKET_PER_TRANSACTION; j++){
                            chunkedTicketList[i].add(tickList[i * MAX_NUM_OF_TICKET_PER_TRANSACTION + j]);
                        }
                    }else{
                        Integer doneTickets = i * MAX_NUM_OF_TICKET_PER_TRANSACTION;
                        for (j=0;  doneTickets + j < NUM_OF_TICKETS; j++){
                            chunkedTicketList[i].add(tickList[i * MAX_NUM_OF_TICKET_PER_TRANSACTION + j]);
                        }   
                    }
                }
            }else{
                chunkedTicketList.add(tickList);
            }

        }

        private Integer divideIntegersRoundUp(Integer num, Integer divisor){
             return (num + divisor - 1) / divisor;
        }

        private Map<Id,Map<String,Passing_Point__c>> generateTrainMapWithPassingPoints(List<Ticket__c> tickList, Set<Train__c> trainList){
            Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints = new Map<Id,Map<String,Passing_Point__c>>();

            Set<String> uicCodeSet = CompApp_Utils.getFieldValueMap2list(tickList, 'UIC_Code__c').keySet();

            for(Passing_Point__c passingPoint : [ SELECT Id, PassingPoint_Arrival_Delay__c, Passing_Point_Cash__c, PassingPoint_Voucher__c, UIC_Code__c, Train__c,
                                                        Unacceptable_Travel_Conditions__c, No_Catering__c
                                                        FROM Passing_Point__c
                                                        WHERE UIC_Code__c IN :uicCodeSet
                                                            AND Train__c IN :trainList
                                                            AND UIC_Code__c != null]){
                if(trainWithPassingPoints.containsKey(passingPoint.Train__c)){
                    trainWithPassingPoints.get(passingPoint.Train__c).put(passingPoint.UIC_Code__c,passingPoint);
                }
                else{
                    Map<String,Passing_Point__c> tempMap = new Map<String,Passing_Point__c>();
                    tempMap.put(passingPoint.UIC_Code__c,passingPoint);
                    trainWithPassingPoints.put(passingPoint.Train__c, tempMap);
                }

            }
            return trainWithPassingPoints;
        }

        private List<Ticket__c> replaceTrainDelayWithPassingPointDelay(List<Ticket__c> tickList, Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints){

            for(Ticket__c ticket : tickList){
                Decimal ppArivalDelay = trainWithPassingPoints?.get(ticket.Train__c)?.get(ticket.UIC_Code__c)?.PassingPoint_Arrival_Delay__c != null
                    ? Decimal.valueOf(trainWithPassingPoints.get(ticket.Train__c).get(ticket.UIC_Code__c).PassingPoint_Arrival_Delay__c)
                    : 0.0;

                if( trainWithPassingPoints.containsKey(ticket.Train__c)
                    && trainWithPassingPoints.get(ticket.Train__c).containsKey(ticket.UIC_Code__c)
                    && ppArivalDelay > 0
                ){

                    ticket.Delay_mins__c = Decimal.valueOf(trainWithPassingPoints.get(ticket.Train__c).get(ticket.UIC_Code__c).PassingPoint_Arrival_Delay__c);
                }
            }

            return tickList;
        }
    }
   
	public class CompensationDataWrapper{
        public List<Compensation__c> compensationList; 
        
        public List<List<Compensation__c>> chunkedCompensationList;

        public CompensationDataWrapper(List<Compensation__c> compensationList ){
            Integer MAX_NUM_OF_COMPENSATION_PER_TRANSACTION = 200;
            
            this.compensationList = compensationList; 
            this.chunkedCompensationList = new List<List<Compensation__c>>();

            Integer NUM_OF_COMPENSATIONS = compensationList.size();
            if (NUM_OF_COMPENSATIONS > MAX_NUM_OF_COMPENSATION_PER_TRANSACTION){
                Integer i,j;
               Integer NUM_OF_REQUIRED_ITERATIONS = divideIntegersRoundUp(NUM_OF_COMPENSATIONS, MAX_NUM_OF_COMPENSATION_PER_TRANSACTION);
                //== 6
                

                for (i=0; i<NUM_OF_REQUIRED_ITERATIONS; i++){
                    chunkedCompensationList.add(new List<Compensation__c>());
                    if (MAX_NUM_OF_COMPENSATION_PER_TRANSACTION * (i+1) <= NUM_OF_COMPENSATIONS ){
                        for (j=0; j<MAX_NUM_OF_COMPENSATION_PER_TRANSACTION; j++){
                            chunkedCompensationList[i].add(compensationList[i * MAX_NUM_OF_COMPENSATION_PER_TRANSACTION + j]);
                        }
                    }else{
                        Integer doneCompensations = i * MAX_NUM_OF_COMPENSATION_PER_TRANSACTION;
                        for (j=0;  doneCompensations + j < NUM_OF_COMPENSATIONS; j++){
                            chunkedCompensationList[i].add(compensationList[i * MAX_NUM_OF_COMPENSATION_PER_TRANSACTION + j]);
                        }   
                    }
                }
            }else{
                chunkedCompensationList.add(compensationList);
            }
        }

        private Integer divideIntegersRoundUp(Integer num, Integer divisor){
             return (num + divisor - 1) / divisor;
        }
    } 
    public class CompensationTicketTuple{
        public Compensation__c comp;
        public Id tickId;
        public Id passingPointId;

        public CompensationTicketTuple(Compensation__c comp, Id tickId){
            this.comp = comp;
            this.tickId = tickId;
        }

        public CompensationTicketTuple(Compensation__c comp, Id tickId, Id passingPointId){
            this.comp = comp;
            this.tickId = tickId;
            this.passingPointId = passingPointId;
        }
    }



}