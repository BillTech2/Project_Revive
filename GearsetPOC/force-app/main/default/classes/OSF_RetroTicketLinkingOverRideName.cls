public with sharing class OSF_RetroTicketLinkingOverRideName {
    public class FlowInput {
        @InvocableVariable(required=true) 
        public String membershipNumber;
        @InvocableVariable(required=true) 
        public String pnr;
        @InvocableVariable(required=true)
        public String tcn;
        @InvocableVariable(required=true)
        public String recordId;
        @InvocableVariable(required=true) 
        public String Passenger_First_Name;        
        @InvocableVariable(required=true) 
        public String Passenger_Last_Name;
    }

    public class FlowOutput {
        @InvocableVariable 
        public String resultMessage;
    }

    @InvocableMethod 
    public static List<FlowOutput> retroTicketLinking(List<FlowInput> params) { 
        List<FlowOutput> results = new List<FlowOutput>{new FlowOutput()};
        System.debug('### params: ' + params);
        try {
            results[0].resultMessage = OSF_TicketHandler.retroClaimPointsNameOverRide(params[0].membershipNumber, params[0].pnr, params[0].tcn, params[0].recordId,params[0].Passenger_First_Name,params[0].Passenger_Last_Name);
        } catch(Exception e) { results[0].resultMessage = e.getMessage(); OSF_ErrorLogHandler.logError(e, 'OSF_RetroTicketLining');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
        return results;
    }
   
}