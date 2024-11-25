public with sharing class OSF_RetroTicketLining {
    public class FlowInput {
        @InvocableVariable(required=true) 
        public String membershipNumber;
        @InvocableVariable(required=true) 
        public String pnr;
        @InvocableVariable(required=true)
        public String tcn;
        @InvocableVariable(required=true)
        public String recordId;
        @InvocableVariable 
        public Boolean validateName;
    }

    public class FlowOutput {
        @InvocableVariable 
        public String resultMessage;
    }

    @InvocableMethod 
    public static List<FlowOutput> retroTicketLinking(List<FlowInput> params) { 
        List<FlowOutput> results = new List<FlowOutput>{new FlowOutput()};
        System.debug('### params: ' + params);
        Boolean validateName = params[0].validateName != null ? params[0].validateName : true;
        try {
            Map<String, String> mapSpecialCharToStdChar = new map<String, String>();
            for(Special_Character_Mapping__c scm : [SELECT Id, Special_Character__c, Standard_Character__c FROM Special_Character_Mapping__c]) {
                mapSpecialCharToStdChar.put(scm.Special_Character__c, scm.Standard_Character__c);
            }
            results[0].resultMessage = OSF_TicketHandler.retroClaimPoints(params[0].membershipNumber, params[0].pnr, params[0].tcn, validateName, params[0].recordId, mapSpecialCharToStdChar);
        } catch(Exception e) { results[0].resultMessage = e.getMessage(); OSF_ErrorLogHandler.logError(e, 'OSF_RetroTicketLining');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
        return results;
    }
   
}