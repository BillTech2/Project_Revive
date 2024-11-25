public without sharing class cu_Utils {

    public static String ST_PANCRAS_INTERNATIONAL = 'St Pancras International';
    public static String ASHFORD_INTERNATIONAL = 'Ashford International';
    public static String EBBSFLEET_INTERNATIONAL = 'Ebbsfleet International';
    public static String PARIS_GARE_DU_NORD = 'Paris Gare du Nord';
    public static String BRUSSELS_MIDI_ZUID = 'Brussels Midi/Zuid';
    public static String AMSTERDAM_CENTRAAL = 'Amsterdam Centraal';
    public static String LILLE_EUROPE = 'Lille Europe';
    public static String ROTTERDAM_CENTRAAL = 'Rotterdam Centraal';
    public static String DISNEYLAND_PARIS = 'Disneyland Paris';
    public static String LYON_PART_DIEU = 'Lyon Part-Dieu';
    public static String CALAS_FRETHUN = 'Calas-Frethun';
    public static String CALAIS_FRETHUN = 'Calais-Fréthun';
    public static String ALBERTVILLE = 'Albertville';
    public static String AIME_LA_PLAGNE = 'Aime-La-Plagne';
    public static String AIX_EN_PROVENCE = 'Aix-en-Provence';
    public static String AVIGNON = 'Avignon';
    public static String BOURG_SAINT_MAURICE = 'Bourg-Saint-Maurice';
    public static String BOURG_ST_MAURICE = 'Bourg St Maurice';
    public static String CHAMBERY = 'Chambery';
    public static String LANDRY = 'Landry';
    public static String MARSEILLES = 'Marseilles';
    public static String MOUTIERS = 'Moûtiers';
    public static String PARIS_CHARLES_DE_GAULLE_AIRPORT = 'Paris-Charles-de-Gaulle Airport';
    public static String PARIS_CHARLES_DE_GAULLE_AIRPORT_WITHOUT_DASH = 'Paris Charles de Gaulle Airport';
    public static String VALENCE = 'Valence';
    public static String ANTWERP = 'Antwerp';
    public static String LIEGE = 'Liege';
    public static String AACHEN = 'Aachen';
    public static String COLOGNE = 'Cologne';
    public static String DUISBURG = 'Duisburg';
    public static String DORTMUND = 'Dortmund';
    public static String DUSSELDORF = 'Düsseldorf';
    public static String DUSSELDORF_AIRPORT = 'Düsseldorf Airport';
    public static String ESSEN = 'Essen';
    public static String SCHIPHOL_AIRPORT = 'Schiphol Airport';
    public static String STATION_INFORMATION = 'Station Information';
    public static String GENERIC = 'GENERIC';

    public static final String CASE_JOURNEY_PRODUCT_CROSS_CHANNEL_ROUTES = 'Cross channel routes';
    public static final String CASE_JOURNEY_PRODUCT_SKI_ROUTES = 'Ski routes';
    public static final String CASE_JOURNEY_PRODUCT_SUN_ROUTES = 'Sun routes';
    public static final String CASE_JOURNEY_PRODUCT_CONTINENTAL_ROUTES = 'Continental routes';
    public static final String CASE_JOURNEY_PRODUCT_CONNECTIONS = 'Connections';
    public static final String CASE_JOURNEY_PRODUCT_LUGGAGE = 'Luggage';
    public static final String CASE_CLASS_OF_SERVICE_COMBINATION = 'Combination';

    public static final String BOOKING_TYPE_PACKAGE = 'Package';
    public static final String BOOKING_TYPE_MUSICAL_INSTRUMENT = 'Musical Instrument';
    public static final String BOOKING_TYPE_PASSHOLDER_FARE = 'Passholder fare';
    public static final String BOOKING_TYPE_CONCESSION_FARE = 'Concession fare';
    public static final String BOOKING_TYPE_THIRD_PARTY_BOOKING = '3rd party booking';
    public static final String BOOKING_TYPE_STAFF_TRAVEL = 'Staff travel';
    public static final String BOOKING_TYPE_GIFT = 'Gift certificate/Prizewinner';
    public static final String BOOKING_TYPE_TRADE_BOOKING = 'Trade booking';
    public static final String BOOKING_TYPE_ASSISTANCE = 'Assistance';
    public static final String BOOKING_TYPE_POINTS_BOOKING = 'Points Booking';
    public static final String BOOKING_TYPE_PUBLIC_BOOKING = 'Public Booking';
    public static final String BOOKING_TYPE_GENERAL_QUERY = 'General Query';

    public static final String TYPE_OF_ASSISTANCE_TRAVEL_WITH_ANIMAL = 'Assisted traveller with assistance animal';
    public static final String TYPE_OF_ASSISTANCE_WHEELCHAIR_WITH_ANIMAL = 'Wheelchair traveller with assistance animal';
    public static final String TYPE_OF_ASSISTANCE_WHEELCHAIR_TRAVELLER = 'Wheelchair traveller with or without companion';
    public static final String TYPE_OF_ASSISTANCE_ASSISTANCE_ANIMAL = 'Assistance animal';

    public static Map<String, String> STATION_TO_TEMPLATE = new Map<String, String> {
        GENERIC => 'Generic_station_1',
        ST_PANCRAS_INTERNATIONAL => 'St_Pancras_1',
        PARIS_GARE_DU_NORD => 'Paris_1',
        BRUSSELS_MIDI_ZUID => 'Brussels_1',
        LILLE_EUROPE => 'Lille_1',
        CALAS_FRETHUN => 'Calais_1',
        LYON_PART_DIEU => 'South_of_France_1',
        DISNEYLAND_PARIS => 'Disney_1',
        AMSTERDAM_CENTRAAL => 'Holland_1',
        ROTTERDAM_CENTRAAL => 'Holland_1',
        ASHFORD_INTERNATIONAL => 'Kent_Stations_1',
        EBBSFLEET_INTERNATIONAL => 'Kent_Stations_1',
        AACHEN => 'Aachen_1',
        AIME_LA_PLAGNE => 'Aime_La_Plagne_1',
        AIX_EN_PROVENCE => 'Aix_en_Provence_1',
        ALBERTVILLE => 'Albertville_1',
        ANTWERP => 'Antwerp_1',
        AVIGNON => 'Avignon_1',
        BOURG_SAINT_MAURICE => 'Bourg_Saint_Maurice_1',
        CHAMBERY => 'Chambery_1',
        COLOGNE => 'Cologne_1',
        DORTMUND => 'Dortmund_1',
        DUISBURG => 'Duisburg_1',
        DUSSELDORF => 'Dusseldorf_1',
        DUSSELDORF_AIRPORT => 'Dusseldorf_Airport_1',
        ESSEN => 'Essen_1',
        LANDRY => 'Landry_1',
        LIEGE => 'Liege_1',
        MARSEILLES => 'Marseilles_1',
        MOUTIERS => 'Moutiers_1',
        PARIS_CHARLES_DE_GAULLE_AIRPORT => 'Paris_Charles_de_Gaulle_Airport_1',
        SCHIPHOL_AIRPORT => 'Schiphol_Airport_1',
        VALENCE => 'Valence_1'
    };

    public static Map<String, String> STATION_TO_TEMPLATE_DISRUPTION = new Map<String, String> {
        GENERIC => 'Generic_station_1',
        ST_PANCRAS_INTERNATIONAL => 'London_disruption_1',
        PARIS_GARE_DU_NORD => 'Paris_disruption_1',
        BRUSSELS_MIDI_ZUID => 'Brussels_disruption_1',
        LILLE_EUROPE => 'Lille_disruption_1',
        CALAS_FRETHUN => 'Calais_disruption_1',
        LYON_PART_DIEU => 'South_of_France_disruption_1',
        DISNEYLAND_PARIS => 'Disney_disruption_1',
        AMSTERDAM_CENTRAAL => 'Amsterdam_and_Rotterdam_disruption_1',
        ROTTERDAM_CENTRAAL => 'Amsterdam_and_Rotterdam_disruption_1',
        ASHFORD_INTERNATIONAL => 'Kent_disruption_1',
        EBBSFLEET_INTERNATIONAL => 'Kent_disruption_1',
        AACHEN => 'Aachen_disruption_1',
        AIME_LA_PLAGNE => 'Aime_La_Plagne_disruption_1	',
        AIX_EN_PROVENCE => 'Aix_en_Provence_disruption_1',
        ALBERTVILLE => 'Albertville_disruption_1',
        ANTWERP => 'Antwerp_disruption_1',
        AVIGNON => 'Avignon_disruption_1',
        BOURG_SAINT_MAURICE => 'Bourg_Saint_Maurice_disruption_1',
        CHAMBERY => 'Chambery_disruption_1',
        COLOGNE => 'Cologne_disruption_1	',
        DORTMUND => 'Dortmund_disruption_1	',
        DUISBURG => 'Duisburg_disruption_1',
        DUSSELDORF => 'Dusseldorf_disruption_1',
        DUSSELDORF_AIRPORT => 'Dusseldorf_Airport_disruption_1',
        ESSEN => 'Essen_disruption_1',
        LANDRY => 'Landry_disruption_1',
        LIEGE => 'Liege_disruption_1',
        MARSEILLES => 'Marseilles_disruption_1',
        MOUTIERS => 'Moutiers_disruption_1',
        PARIS_CHARLES_DE_GAULLE_AIRPORT => 'Paris_Charles_de_Gaulle_Airport_disruption_1',
        SCHIPHOL_AIRPORT => 'Schiphol_Airport_disruption_1',
        VALENCE => 'Valence_disruption_1'
    };

    public static Map<String, String> allowedLanguagesByCodes = new Map<String, String> { 'EN' => 'English',
    'FR' => 'Français',
    'NL' => 'Nederlands',
    'DE' => 'Deutsch'  };

    public static Map<String, String> allowedCodesByLanguages = new Map<String, String> { 'English (UK)' => 'EN' ,
    'English' => 'EN' ,
    'French' => 'FR',
    'Nederlands' => 'NL',
    'Flemish' => 'EN',
    'Deutsch' => 'DE' };

    public static Map<String, String> LANGUAGE_CODE_TO_HOME_PAGE_URL = new Map<String, String> {
        'EN' => 'https://www.eurostar.com/uk-en',
        'FR' => 'https://www.eurostar.com/fr-fr',
        'NL' => 'https://www.eurostar.com/nl-nl',
        'DE' => 'https://www.eurostar.com/de-de',
        'en_US' => 'https://www.eurostar.com/uk-en',
        'nl_NL' => 'https://www.eurostar.com/nl-nl',
        'fr' => 'https://www.eurostar.com/fr-fr',
        'de' => 'https://www.eurostar.com/de-de'
    };

    public static Map<String, String> LANGUAGE_CODE_TO_FAQ_PAGE_URL = new Map<String, String> {
        'EN' => 'https://help.eurostar.com/?language=rw-en',
        'FR' => 'https://help.eurostar.com/?language=fr-fr',
        'NL' => 'https://help.eurostar.com/?language=nl-nl',
        'DE' => 'https://help.eurostar.com/?language=de-de',
        'en_US' => 'https://help.eurostar.com/?language=rw-en',
        'nl_NL' => 'https://help.eurostar.com/?language=nl-nl',
        'fr' => 'https://help.eurostar.com/?language=fr-fr',
        'de' => 'https://help.eurostar.com/?language=de-de'
    };

    public static Map<String, String> LANGUAGE_CODE_TO_HELP_CENTRE_LABEL = new Map<String, String> {
        'EN' => System.Label.HelpCentreHeader,
        'FR' => System.Label.HelpCentreHeader_fr,
        'NL' => System.Label.HelpCentreHeader_nl,
        'DE' => System.Label.HelpCentreHeader_de
    };

    // variables for dynamic Stations__c retrieving
    /*private static final String CU_STRING_QUERY_TEMPLATE = 'SELECT Id,{0} FROM {1} WHERE Is_Contact_Us_Station__c = TRUE';*/
    /*private static final Map<String,Map<String,String>> OBJECT_TO_LANG_TO_FIELDS_MAP = new Map<String,Map<String,String>>{
        'Stations__c' => new Map<String,String>{'English' => 'en_Station_Name__c', 'French' => 'French_Station_Name__c', 'Dutch' => 'Dutch_Station_Name__c'}
    };*/

    public static String translateLanguageToCode(String language) {
        String result = 'en_US';
        if (language != null && allowedCodesByLanguages.keySet().contains(language)) {
            result = allowedCodesByLanguages.get(language);
        }
        return result;
    }

    /* The logic for dynamic stations retrieving */
   /* @AuraEnabled
    public static List<ContUsWrapper> getRecordsList(String objectName, String lang) {
        try {
            List<ContUsWrapper> cuWrappers = new List<ContUsWrapper>();
            List<sObject> records = Database.query(
                String.format(
                    CU_STRING_QUERY_TEMPLATE,
                    new List<Object>{
                        OBJECT_TO_LANG_TO_FIELDS_MAP.get(objectName).get(lang),
                        objectName
                    }
                )
            );
            if (!records.isEmpty()) {
                for (sObject rec : records) {
                    cuWrappers.add(
                        new ContUsWrapper(String.valueOf(rec.get(OBJECT_TO_LANG_TO_FIELDS_MAP.get(objectName).get(lang))))
                    );
                }
            }
            return cuWrappers;
        } catch (Exception e) {
            System.debug('getStationsListError' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    */

    @AuraEnabled
    public static PnrDetails checkPNR(String pnr) {
        try {
            PnrDetails response = S3PassengerAPIService.getAOPByPNR(pnr);
            return response;
        } catch (Exception e) {
           return null;
        }
    }

    @AuraEnabled
    public static Boolean checkDepartureDate(String pnr, String departureDate) {
        return [SELECT COUNT() FROM Ticket__c WHERE PNR__c = :pnr AND DAY_ONLY(Departure_Date_Time_Format__c) = :Date.valueOf(departureDate)] > 0;
    }

    @AuraEnabled
    public static Boolean checkTCN(String tcn) {
        return [SELECT COUNT() FROM Ticket__c WHERE Name = :tcn] > 0;
    }

    @AuraEnabled
    public static MembershipDetails checkMembership(String mNumber) {
        MembershipDetails member = new MembershipDetails(mNumber, null, '');
        try {
            if (String.isNotEmpty(mNumber)) {
                List<LoyaltyProgramMember> loyaltyMember = [
                    SELECT Id, MembershipNumber, Contact.Account.PersonBirthdate
                    FROM LoyaltyProgramMember
                    WHERE MembershipNumber =: mNumber
                    LIMIT 1
                ];
                if (!loyaltyMember.isEmpty()) {
                    member.membershipNumber = String.isNotEmpty(loyaltyMember.get(0).MembershipNumber) ? loyaltyMember.get(0).MembershipNumber : '';
                    member.birthDate = loyaltyMember.get(0).Contact.Account.PersonBirthdate;
                } else {
                    member.error = 'cu_CannotSubmitQueryWithoutNumber';
                }
                return member;
            } else {
                member.error = 'cu_CannotSubmitQueryWithoutNumber';
                return member;
            }
        } catch (Exception e) {
           return null;
        }
    }

    // Wrapper to return stations labels
   /* public class ContUsWrapper {
        @AuraEnabled
        public String label;
        public ContUsWrapper(String label) {
            this.label = label;
        }
        public ContUsWrapper() {}
    }*/

    public class PnrDetails {
        @AuraEnabled
        public String pnr;
        @AuraEnabled
        public Boolean isDisrupted;
        @AuraEnabled
        public String bookingType;
        @AuraEnabled
        public Boolean isFree;
        @AuraEnabled
        public Boolean isRefundable;
        @AuraEnabled
        public Boolean isExchangable;
        @AuraEnabled
        public Boolean isChangeableOnline;
        @AuraEnabled
        public Boolean addInfo;
        @AuraEnabled
        public String cancelOption;
        @AuraEnabled
        public String error;
        @AuraEnabled
        public Boolean isDelayed;
        @AuraEnabled
        public Boolean isCancelled;
        @AuraEnabled
        public Boolean isLastMinuteTicket;
        @AuraEnabled
        public String departureDate;

        public PnrDetails(
            String pnr,
            Boolean isDisrupted,
            String bookingType,
            Boolean isFree,
            Boolean isExchangable,
            Boolean isRefundable,
            Boolean isChangeableOnline,
            Boolean addInfo,
            String cancelOption,
            String error,
            Boolean isDelayed
        ) {
            this.pnr = pnr;
            this.isDisrupted = isDisrupted;
            this.bookingType = bookingType;
            this.error = error;
            this.isFree = isFree;
            this.isRefundable = isRefundable;
            this.isExchangable = isExchangable;
            this.isChangeableOnline = isChangeableOnline;
            this.addInfo = addInfo;
            this.cancelOption = cancelOption;
            this.isDelayed = isDelayed;
        }

        public PnrDetails(
            String pnr,
            Boolean isDisrupted,
            String bookingType,
            Boolean isFree,
            Boolean isExchangable,
            Boolean isRefundable,
            Boolean isChangeableOnline,
            Boolean addInfo,
            String cancelOption,
            String error,
            Boolean isDelayed,
            Boolean isCancelled
        ) {
            this(
                pnr, 
                isDisrupted, 
                bookingType,
                isFree, 
                isExchangable, 
                isRefundable,
                isChangeableOnline, 
                addInfo, 
                cancelOption, 
                error, 
                isDelayed
            );
            this.isCancelled = isCancelled;
        }

        public PnrDetails() {}
    }

    public class MembershipDetails {
        @AuraEnabled
        public String membershipNumber;
        @AuraEnabled
        public Date birthDate;
        @AuraEnabled
        public String error;

        public MembershipDetails(String membershipNumber, Date birthDate, String error) {
            this.membershipNumber = membershipNumber;
            this.birthDate = birthDate;
            this.error = error;
        }
    }

    public static void setTemplateId(Case newCase, String station) {
        String templateName = STATION_TO_TEMPLATE.get(station);
        newCase.TemplateId__c = templateName != null ? templateName : STATION_TO_TEMPLATE.get(GENERIC);
    }

    public static void setDisruptionTemplateId(Case newCase, String station) {
        String templateName = STATION_TO_TEMPLATE_DISRUPTION.get(station);
        newCase.TemplateId__c = templateName != null ? templateName : STATION_TO_TEMPLATE_DISRUPTION.get(GENERIC);
    }

}