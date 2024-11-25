public without sharing class Eins_CaseIntentHandler {

    private static Eins_EinsteinServiceController controller = new Eins_EinsteinServiceController();

    public static void intentProcessing(Map<ID, Case> caseMap) {
        if (controller == null) {
            controller = new Eins_EinsteinServiceController();
        }
        Set<Id> caseIds = new Set<Id>();

        for (Case caseItem : caseMap.values()) {
            if (string.isBlank(caseItem.Einstein_Master_Label__c)) {
                caseIds.add(caseItem.Id);
            }
        }
        Eins_CaseIntentHandler.processIntents(caseIds);
    }


    public static string getTopLabel(Eins_IntentModel.ProbabilityItem[] probabilities) {
        Eins_IntentModel.ProbabilityItem topProbability = probabilities.size()>0 ?  probabilities[0] 
                                                        : new Eins_IntentModel.ProbabilityItem() ;
        for (Eins_IntentModel.ProbabilityItem item : probabilities) {
            if (topProbability.probability < item.probability) {
                topProbability = item;
            }
        }
        return topProbability.label;
    }
    
    @future (callout = True) 
    private static void processIntents(Set<Id> caseIds ) {
        if (caseIds != null && caseIds.size() > 0) {

            Eins_EinsteinSettings settings =  Eins_EinsteinServiceController.getPlatformSettings();
        
            string sqlBody = 'SELECT Id, Language_Code__c, Description, Einstein_Template_Id__c, Einstein_Master_Label__c';
            Map<string, Map<string, string>> fieldMap = CaseMasterLabelHelper.getFiledsMap();
            string fieldsToUpdate = '';
            for (string label : fieldMap.keySet()){
                        Map<string, string> items = fieldMap.get(label);
                        for (string key: items.keySet()) {
                            fieldsToUpdate = ', '+ key;
                        }
            }
            sqlBody += fieldsToUpdate;
            List<Case> caseList = (List<Case>)Database.query(sqlBody + '  FROM Case where id in :caseIds');

            List<Eins_IntentModel.ProbabilityItem> probabilities = new list<Eins_IntentModel.ProbabilityItem>();
            Map<ID, string> labels = new Map<ID, string>();
            for (Case caseItem : caseList) {
                List<string> modelIdsToCall = new List<String>();
                if (string.isNotEmpty(caseItem.Language_Code__c) && settings.models.containsKey(caseItem.Language_Code__c)) {
                    modelIdsToCall.add( settings.models.get(caseItem.Language_Code__c));
                    
                
                } else {
                    modelIdsToCall = settings.models.values();
                }
                for (string modelId : modelIdsToCall) {
                    Eins_IntentModel result = controller.getIntent(caseItem.Description, modelId);
                    if (result != null && result.probabilities != null && result.probabilities.size() > 0) {
                        probabilities.addAll(result.probabilities);
                    }
                }
                if (probabilities.size() > 0) {
                    string label = getTopLabel(probabilities);
                    labels.put(caseItem.Id, label);
                }
                
                if (labels.size() > 0) {
                    CaseMasterLabelHelper.updateMasterLabels(caseList, labels);
                }   
                
            }
        }

                                
        
    }
}