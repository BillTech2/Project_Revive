public with sharing class LeadTriggerHandler {
    public static LeadTriggerHandler instance;

    public static LeadTriggerHandler getInstance() {
        if (instance == null) {
            instance = new LeadTriggerHandler();
        }
        return instance;
    }

    public void onBeforeInsert (List<Lead> newLeads) {
        System.debug('count of leads: ' + newLeads.size());

        generateMiceSpecialRateCode(newLeads);
    }

    public void onAfterUpdate (List<Lead> oldLeads, List<Lead> newLeads, Map<Id,Lead> newLeadMap) {
        List<Lead> leadsForUpdate = new List<Lead>();

        for (Integer i = 0; i < oldLeads.size(); i++) {
            if (oldLeads[i].LeadSource == 'MICE Special Rate Form' &&
                oldLeads[i].Approved__c == false &&
                newLeads[i].LeadSource == 'MICE Special Rate Form' &&
                newLeads[i].Approved__c == true) {

                leadsForUpdate.add(new Lead(Id = newLeads[i].Id, LeadSource = newLeads[i].LeadSource, Approved__c = newLeads[i].Approved__c));
            }
        }

        generateMiceSpecialRateCode(leadsForUpdate);

        for (Integer i = 0; i < oldLeads.size(); i++) {
            if (oldLeads[i].LeadSource == 'MICE Special Rate Form' &&
                    oldLeads[i].Approved__c == false &&
                    newLeads[i].LeadSource == 'MICE Special Rate Form' &&
                    newLeads[i].Approved__c == true) {

                newLeads[i].Special_Rate_Code__c = leadsForUpdate[i].Special_Rate_Code__c;
                newLeads[i].Status = 'Qualified';
            }
        }
//        update leadsForUpdate;
    }

    private void generateMiceSpecialRateCode (List<Lead> newLeads) {
        Integer countOfLeads = 0;
        Set<String> miceCodes = new Set<String>();
        List<Integer> indexList = new List<Integer>();

        for (Integer i = 0 ; i < newLeads.size(); i++) {
            if (newLeads[i].LeadSource == 'MICE Special Rate Form' && newLeads[i].Approved__c) {
                indexList.Add(i);
            }
        }

        countOfLeads = indexList.size();
        System.debug('Count of suitable leads: ' + countOfLeads);

        if (countOfLeads == 0) return;

        while (miceCodes.size() != countOfLeads) {
            System.debug('1 check for duplicates of generated code');
            miceCodes.clear();

            for (Integer i = 0; i < countOfLeads ; i++) {
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                String guid = h.SubString(0,17);

                miceCodes.add(guid);
            }
        }

        for (Integer i = 0; i < 10 ; i ++) {
            System.debug('check for duplicates');

            List<Lead> leadsForCheck = [
                    SELECT Id FROM Lead
                    WHERE LeadSource = 'MICE Special Rate Form'
                    AND Special_Rate_Code__c IN :miceCodes
            ];

            if (leadsForCheck.size() == 0) {
                break;
            }

            while (miceCodes.size() != countOfLeads) {
                System.debug('2 check for duplicates of generated code');
                miceCodes.clear();

                for (Integer x = 0; x < countOfLeads ; x++) {
                    Blob b = Crypto.GenerateAESKey(128);
                    String h = EncodingUtil.ConvertTohex(b);
                    String guid = h.SubString(0,17);


                    miceCodes.add(guid);
                }
            }
        }

        List<String> codeList = new List<String>(miceCodes);
        System.debug('Count of codes: ' + codeList.size());
        for (Integer i : indexList) {
            newLeads[i].Special_Rate_Code__c = codeList[i];
        }
    }

}