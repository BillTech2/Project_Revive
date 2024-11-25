public without sharing class Eins_CasePriorityHelper {
    private static Map<String, String> casesWithLoyaltyStatus = new Map<String, String>();
    private static Map<String, Boolean> cancelledTicketsByPNR = new Map<String, Boolean>();
    private static Map<String, List<Ticket__c>> ticketsByTrain = new Map<String, List<Ticket__c>>();
    private static Map<String, List<Ticket__c>> ticketsByPNR = new Map<String, List<Ticket__c>>();
    private static Map<String, Train__History> fieldHistoryByTrainId = new Map<String, Train__History>();
    private static List<Ticket__c> ticketsAndTrains = new  List<Ticket__c>();
    private static Map<String, List<Compensation__c>> casesWithCompensations = new Map<String, List<Compensation__c>>();

    public static final String DELTA_LOYALTY_TIER_CLASSIQUE = 'Classique';
    public static final String DELTA_LOYALTY_TIER_AVANTAGE = 'Avantage';
    public static final String DELTA_LOYALTY_TIER_CARTE_BLANCHE = 'Carte Blanche';
    public static final String DELTA_LOYALTY_TIER_ETOILE = 'Etoile';
    public static final String DELTA_LOYALTY_TIER_ELITE = 'Elite';
    public static final String DELTA_LOYALTY_TIER_NO_PROFILE = 'No Profile';

    public static final String CASE_PRIORITY_HIGH = 'High';
    public static final String CASE_PRIORITY_MEDIUM = 'Medium';
    public static final String CASE_PRIORITY_LOW = 'Low';

    private static final String INITIAL_REASON_FOR_CONTACT_DISRUPTION = 'Disruption';

    private static final String CASE_STATUS_CLOSED = 'Closed';

    private static final String CASE_TOPIC_URGENT = 'Urgent';



    public static List<Case> prioritiseAllCases(List<Case> cases) {
        getLoyaltyStatuses(cases);
        getCancelledTrains(cases);
        getCompensations(cases);
        for (Case caseItem : cases) {
            if (caseItem.Status != CASE_STATUS_CLOSED) {
                Date closestDate;
                Date futureDate;
                if (ticketsByPNR.get(caseItem.PNR__c) != null && String.isNotBlank(caseItem.PNR__c)) {
                    closestDate = ticketsByPNR.get(caseItem.PNR__c)[ticketsByPNR.get(caseItem.PNR__c).size() - 1].Departure_Date__c;
                    futureDate = ticketsByPNR.get(caseItem.PNR__c)[0].Departure_Date__c;
                    if (closestDate != null && futureDate != null) {
                        if ((Date.today().daysBetween(closestDate) < 0) && (Date.today().daysBetween(futureDate) < 0)) {
                                setCasePastDatePriority(caseItem);
                        } else if (((0 <= Date.today().daysBetween(closestDate)) && (Date.today().daysBetween(closestDate) < 4)) ||
                                (0 <= Date.today().daysBetween(futureDate) && (Date.today().daysBetween(futureDate) < 4))) {
                                        caseItem.Priority = CASE_PRIORITY_HIGH;
                        } else if (((3 < Date.today().daysBetween(closestDate)) && (Date.today().daysBetween(closestDate) <= 7)) ||
                                (3 < Date.today().daysBetween(futureDate) && (Date.today().daysBetween(futureDate) <= 7))) {
                                        travelMore3Less7(caseItem);
                        } else {
                            travelMore7(caseItem);
                        }
                    } else {
                        setCaseNoDatePriority(caseItem);
                    }
                } else {
                    setCaseNoDatePriority(caseItem);
                }
                highPriority(caseItem, closestDate, futureDate);
            }
        }
        return cases;
    }

    private static void getLoyaltyStatuses(List<Case> cases) {
        Map<String, String> customersWithLoyaltyStatus = new Map<String, String>();
        Set<Id> customersIds = new Set<Id>();
        for (Case caseItem : cases) {
            customersIds.add(caseItem.AccountId);
        }

        customersIds.remove(null);

        if (customersIds.isEmpty()) { return; }

        for (Account customer : [SELECT Id, Delta_Loyalty_Tier__c FROM Account WHERE Id IN :customersIds]) {
            customersWithLoyaltyStatus.put(customer.Id, customer.Delta_Loyalty_Tier__c);
        }
        for (Case caseItem : cases) {
            if (customersWithLoyaltyStatus.containsKey(caseItem.AccountId)) {
                if (String.isNotBlank(customersWithLoyaltyStatus.get(caseItem.AccountId))) {
                    casesWithLoyaltyStatus.put(caseItem.Id, customersWithLoyaltyStatus.get(caseItem.AccountId));
                }
            }
        }
    }

    private static void getCompensations(List<Case> cases) {
        Set<Id> caseIds = new Set<Id>();
        for (Case caseItem : cases) {
            caseIds.add(caseItem.Id);
        }

        caseIds.remove(null);

        if (caseIds.isEmpty()) { return; }

        for (Compensation__c compensationItem : [SELECT Id, Case__c FROM Compensation__c WHERE Case__c IN :caseIds AND CreatedDate = LAST_N_MONTHS:6]) {
            if (casesWithCompensations.get(compensationItem.Case__c) == null) {
                casesWithCompensations.put(compensationItem.Case__c, new List<Compensation__c>());
            }
            casesWithCompensations.get(compensationItem.Case__c).add(compensationItem);
        }
    }

    private static void travelMore3Less7(Case caseItem) {
        caseItem.Priority = CASE_PRIORITY_HIGH;
        if (casesWithLoyaltyStatus.containsKey(caseItem.Id)) {
            if (casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CLASSIQUE) ||
                casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_AVANTAGE) ||
                !casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CARTE_BLANCHE)) {
                    caseItem.Priority = CASE_PRIORITY_MEDIUM;
            }
        } else {
            caseItem.Priority = CASE_PRIORITY_MEDIUM;
        }
        if (cancelledTicketsByPNR.get(caseItem.PNR__c) == true) {
                caseItem.Priority = CASE_PRIORITY_HIGH;
        }

    }

    private static void travelMore7(Case caseItem) {
        caseItem.Priority = CASE_PRIORITY_HIGH;
        if (casesWithLoyaltyStatus.containsKey(caseItem.Id)) {
            if (casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CLASSIQUE) ||
                casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_AVANTAGE) ||
                casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CARTE_BLANCHE)) {
                    caseItem.Priority = CASE_PRIORITY_MEDIUM;
            }
        } else {
            caseItem.Priority = CASE_PRIORITY_LOW;
        }

        if (caseItem.Initial_Reason_For_Contact__c == INITIAL_REASON_FOR_CONTACT_DISRUPTION) {
            if (casesWithCompensations.get(caseItem.Id) != null) {
                if (casesWithCompensations.get(caseItem.Id).size() < 4) {
                    caseItem.Priority = CASE_PRIORITY_MEDIUM;
                }
            }
        }
        if (cancelledTicketsByPNR.get(caseItem.PNR__c) == true) {
                caseItem.Priority = CASE_PRIORITY_HIGH;
        }
    }

    private static void setCaseNoDatePriority(Case caseItem) {
        caseItem.Priority = CASE_PRIORITY_MEDIUM;
        if (casesWithLoyaltyStatus.containsKey(caseItem.Id)) {
            if (casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CLASSIQUE) ||
                casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_AVANTAGE) ||
                !casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CARTE_BLANCHE)) {
                    caseItem.Priority = CASE_PRIORITY_LOW;
            }
        } else {
            caseItem.Priority = CASE_PRIORITY_LOW;
        }
        if (cancelledTicketsByPNR.get(caseItem.PNR__c) == true) {
                caseItem.Priority = CASE_PRIORITY_MEDIUM;
        }
    }

    private static void setCasePastDatePriority(Case caseItem) {
        caseItem.Priority = CASE_PRIORITY_MEDIUM;
        if (casesWithLoyaltyStatus.containsKey(caseItem.Id)) {
            if (casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CLASSIQUE) ||
                casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_AVANTAGE) ||
                !casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_CARTE_BLANCHE)) {
                    caseItem.Priority = CASE_PRIORITY_LOW;
            }
        } else {
            caseItem.Priority = CASE_PRIORITY_LOW;
        }
        if (caseItem.Initial_Reason_For_Contact__c == INITIAL_REASON_FOR_CONTACT_DISRUPTION) {
            if (casesWithCompensations.get(caseItem.Id) != null) {
                if (casesWithCompensations.get(caseItem.Id).size() < 4) {
                    caseItem.Priority = CASE_PRIORITY_LOW;
                }
            }
        }
        if (cancelledTicketsByPNR.get(caseItem.PNR__c) == true) {
                caseItem.Priority = CASE_PRIORITY_MEDIUM;
        }
    }

    private static void highPriority(Case caseItem, Date closestDate, Date futureDate) {
        if (casesWithLoyaltyStatus.containsKey(caseItem.Id)) {
            if (casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_ELITE) ||
                casesWithLoyaltyStatus.get(caseItem.Id).containsIgnoreCase(DELTA_LOYALTY_TIER_ETOILE)) {
                    caseItem.Priority = CASE_PRIORITY_HIGH;
            }
        }

        if (String.isNotBlank(caseItem.Topic__c) && caseItem.Topic__c.containsIgnoreCase(CASE_TOPIC_URGENT)) {
            if (closestDate != null && futureDate != null) {
                caseItem.Priority = CASE_PRIORITY_HIGH;
                if ((Date.today().daysBetween(closestDate) < 0) && (Date.today().daysBetween(futureDate) < 0)) {
                    caseItem.Priority = CASE_PRIORITY_MEDIUM;
                }
            } else {
                caseItem.Priority = CASE_PRIORITY_HIGH;
            }
        }

        if (cancelledTicketsByPNR.get(caseItem.PNR__c) == true) {
                caseItem.Priority = CASE_PRIORITY_HIGH;
        }
    }

    private static void getCancelledTrains(List<Case> cases) {
        String searchPNRString = '\'';
        Set<String> pnrs = new Set<String>();
        for (Integer i = 0; i < cases.size(); i++) {
            pnrs.add(cases[i].PNR__c);
            if (i != cases.size() - 1) {
                searchPNRString += cases[i].PNR__c + ' OR ';
            } else {
                searchPNRString += ' ' + cases[i].PNR__c + '\'';
            }
        }

        pnrs.remove(null);
        pnrs.remove('');
        pnrs.remove('null');

        if (!pnrs.isEmpty()) {
            String searchQuery = 'FIND ' + searchPNRString + ' IN ALL FIELDS RETURNING Ticket__c(Id, Train__c, Ticket_Status__c, Train__r.Cancelled__c, PNR__c, Cancelled_DateTime__c, Cancelled_By_Customer__c, Departure_Date__c ORDER BY Departure_Date__c DESC)'; 
            List<List<SObject>> searchList = search.query(searchQuery);
            ticketsAndTrains = (Ticket__c[]) searchList[0];
            Set<Id> trainIds = new Set<Id>();
            for (Ticket__c ticketItem : ticketsAndTrains) {
                trainIds.add(ticketItem.Train__c);
                if (ticketsByTrain.get(ticketItem.Train__c) == null) {
                    ticketsByTrain.put(ticketItem.Train__c, new List<Ticket__c>());
                }
                ticketsByTrain.get(ticketItem.Train__c).add(ticketItem);
                if (ticketItem.Ticket_Status__c != 'Cancelled') {
                    if (ticketsByPNR.get(ticketItem.PNR__c) == null) {
                        ticketsByPNR.put(ticketItem.PNR__c, new List<Ticket__c>());
                    }
                    ticketsByPNR.get(ticketItem.PNR__c).add(ticketItem);
                }
            }
            List<Train__History> cancelledFieldHistory = [
                SELECT ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate 
                FROM Train__History 
                WHERE Field = 'Cancelled__c' 
                    AND ParentId IN : trainIds
                    AND CreatedDate = LAST_N_MONTHS:6
                ORDER BY CreatedDate DESC
            ];
            for (Train__History fieldHistory : cancelledFieldHistory) {
                if (ticketsByTrain.get(fieldHistory.ParentId) != null) {
                    List<Ticket__c> tickets = ticketsByTrain.get(fieldHistory.ParentId);
    
                    if (fieldHistory.NewValue == 'true') {
                        if (fieldHistoryByTrainId.get(fieldHistory.ParentId) == null) {
                            fieldHistoryByTrainId.put(fieldHistory.ParentId, fieldHistory);
                        }
                        for (Ticket__c ticketItem : tickets) {
                            DateTime cancelledTicketDate = getDateFromCancelledDateTime(ticketItem.Cancelled_DateTime__c);
                            if (cancelledTicketsByPNR.get(ticketItem.PNR__c) == null) {
                                if (cancelledTicketDate < fieldHistory.CreatedDate) {
                                    cancelledTicketsByPNR.put(ticketItem.PNR__c, false);
                                } else {
                                    cancelledTicketsByPNR.put(ticketItem.PNR__c, true);
                                }
                            } else if (cancelledTicketsByPNR.get(ticketItem.PNR__c)) {
                                continue;
                            }
                        }
                    }
                }
            }
        }
    }

    @TestVisible
    private static DateTime getDateFromCancelledDateTime(String cancelledDateTime) {
        DateTime cancelledDateFromField;
        if (cancelledDateTime.contains('/')) {
            String cancelledDate = cancelledDateTime.substringBefore(' ');
            String cancelledTime = cancelledDateTime.substringAfter(' ');
            String departureMonth = cancelledDate.substringBetween('/','/');
            cancelledDate = cancelledDate.replace('/' + departureMonth, '');
            cancelledDate = departureMonth + '/' + cancelledDate;
            String departureYear = cancelledDate.substringAfterLast('/');
            cancelledDate = cancelledDate.replace('/' + departureYear, '');
            cancelledDate = departureYear + '/' + cancelledDate;
            cancelledDate = cancelledDate.replace('/', '-');
            cancelledDateFromField = DateTime.valueOf(cancelledDate + ' ' + cancelledTime);
        }
        return cancelledDateFromField;
    }
}