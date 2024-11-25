public without sharing class DLT_TicketTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                setDefaultFieldValues(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                setDefaultFieldValues(Trigger.new);
                preventDelayOverride((List<Ticket__c>) System.Trigger.new, (Map<Id, Ticket__c>) System.Trigger.oldMap);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {

            }

            if (System.Trigger.isUpdate) {

            }
        }
    }

    private static void setDefaultFieldValues(List<Ticket__c> tickets) {
        for (Ticket__c ticket : tickets) {
            if (String.isNotBlank(ticket.Point_of_Sale_original__c)) { continue; }

            if (DLT_TicketConstants.POS_AGENT_USERNAME_BSC_VALUES.contains(ticket.Booking_Sales_Channel__c)) {
                ticket.Point_of_Sale_original__c = ticket.Agent_Username__c;

            } else if (DLT_TicketConstants.POS_CITY_CODE_BSC_VALUES.contains(ticket.Booking_Sales_Channel__c)) {
                ticket.Point_of_Sale_original__c = ticket.city_code__c;

            } else if (DLT_TicketConstants.POS_IATA_CODE_BSC_VALUES.contains(ticket.Booking_Sales_Channel__c)) {
                ticket.Point_of_Sale_original__c = ticket.IATA_code__c;

            } else if (DLT_TicketConstants.POS_OFFICE_CODE_BSC_VALUES.contains(ticket.Booking_Sales_Channel__c)) {
                ticket.Point_of_Sale_original__c = ticket.office_code__c;
            }
        }
    }

    private static void preventDelayOverride(List<Ticket__c> newList, Map<Id, Ticket__c> oldMap){
        if (DLT_Constants.IS_TRAIN_EXPERT) { return; }

        for (Ticket__c ticket : newList) {

            if(ticket.Delay_mins__c != oldMap.get(ticket.Id).Delay_mins__c 
                && ticket.Delay_Mins_Train_Expert__c != null){

                ticket.Delay_mins__c = ticket.Delay_Mins_Train_Expert__c;
            }
        }
    }
}