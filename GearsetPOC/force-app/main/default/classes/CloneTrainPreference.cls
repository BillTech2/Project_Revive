public class CloneTrainPreference {
    
	private static final String TRAINS_OPT_IN = 'Trains_opt_in__c';
    private static final String UNSUBSCRIBED_OPT_IN = 'Unsubscribed_all_opt_in__c';
    private static final String NEWTRAINDEALS = '%' + LABEL.New_Train_Deals;
    private static final String SOURCE_PREFERENCE_CENTER = 'preference center';
    
    //Clone Trains Opt Preference
    public static void clone(Map<Id, Preference__c> preferenceMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        for(Preference__c preference : preferenceMap.values()){
            if(preference.Account__c == null) continue;
            accountIdSet.add(preference.Account__c);
        }
        
        Map<Id, Preference__c> accountIdToPreferenceMap = getAccountIdToPreferenceMap(accountIdSet);
        
        List<Preference__c> trainPreferenceList = new List<Preference__c>();
        List<Preference__c> updatedGroupOptPreferenceList = new List<Preference__c>();
        for(Preference__c preference : preferenceMap.values()){
            
            Boolean isUnsubscribedToAll = isUnsubscribedToAll(preference);
            Boolean hasCheckGroupOptPreference = hasCheckGroupOptPreference(accountIdToPreferenceMap.get(preference.Account__c));
            
            //Does not have any existing group opt preference and is Checked Train Opt In OR
            //Does have an existing group opt preference and is Checked Unsubscribed to All
            if(!hasCheckGroupOptPreference && isTrainOpt(preference) || hasCheckGroupOptPreference && isUnsubscribedToAll) {
                //Create Group Opt Preference
                Preference__c groupOptPreference = createGroupOptPreference(preference);
                groupOptPreference.Consent__c = !isUnsubscribedToAll;
                trainPreferenceList.add(groupOptPreference);
                
                if(accountIdToPreferenceMap.containsKey(preference.Account__c)){
                    //Get Latest Group Opt Preference
                    Preference__c previousGroupOptPreference = accountIdToPreferenceMap.get(preference.Account__c);
                    previousGroupOptPreference.DateTimeTo__c = System.now();
                    updatedGroupOptPreferenceList.add(previousGroupOptPreference);
                }
            }
        }
        
        //Skip Update Preference Logic Before cloning
        if(!trainPreferenceList.isEmpty()){
            PreferenceTriggerHandler.skipUpdatePreferences = true;
        	insert trainPreferenceList;
        }
        
        if(!updatedGroupOptPreferenceList.isEmpty()){
            update updatedGroupOptPreferenceList;
        }
    }

    //Check if Preference is Trains Opt and Name ends with Label.New_Train_Deals
    private static Boolean isTrainOpt(Preference__c preference){
        return TRAINS_OPT_IN.equalsIgnoreCase(preference.Preference__c) && !preference.Name.endsWith(Label.New_Train_Deals) && preference.Consent__c;
    }
    
    private static Boolean isUnsubscribedToAll(Preference__c preference){
        return UNSUBSCRIBED_OPT_IN.equalsIgnoreCase(preference.Preference__c) && preference.Consent__c;
    }
    
    private static Boolean hasCheckGroupOptPreference(Preference__c preference){
        return preference != null && preference.Consent__c;
    }
    
    private static Preference__c createGroupOptPreference(Preference__c preference){
        Preference__c trainPreference = preference.clone(false, false, false, false);
        trainPreference.Name = preference.Name.substringBeforeLast('-') + ('-') + Label.New_Train_Deals;
        trainPreference.Source__c = SOURCE_PREFERENCE_CENTER;
        trainPreference.Preference__c = TRAINS_OPT_IN;
        return trainPreference;
    }
    
    private static Map<Id, Preference__c> getAccountIdToPreferenceMap(Set<Id> accountIdSet){
        Map<Id, Preference__c> accountIdToPreferenceMap = new Map<Id, Preference__c>();
        for(Preference__c preference : [SELECT Id, Account__c, Consent__c
                                        FROM Preference__c
                                        WHERE Account__c IN :accountIdSet
                                        AND Preference__c = 'Trains_opt_in__c'
                                        AND NAME LIKE :NEWTRAINDEALS
                                        AND DateTimeTo__c = NULL]){
        	accountIdToPreferenceMap.put(preference.Account__c, preference);
        }

        return accountIdToPreferenceMap;
    }
}