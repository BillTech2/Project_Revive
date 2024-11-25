public without sharing class CompApp_IncidentCompUtils {	
    private static Map<Id, Compensation_Incident_Rules__c> incidentCompRules;
    
    public static Compensation_Incident_Rules__c getIncidentCompensationRule(Id ruleid){ 
        if (incidentCompRules==null){
            incidentCompRules = new Map<Id, Compensation_Incident_Rules__c>();
           
            For(Compensation_Incident_Rules__c rule:   [ SELECT class_of_service__c,   delay_minutes_from__c, delay_minutes_to__c, Compensation_Percentage__c 
                                                        from Compensation_Incident_Rules__c ]){
                                                            incidentCompRules.put(rule.Id, rule);
			}
            
        } 
        return incidentCompRules.get(ruleid);
         
    }

    public static void getIncidentCompensationRule(final List<Incidents__c> newObjects){
        List<ID> trainids = new List<ID>();
        Train__c train;
        Map<Id, Train__c> trainMap = new Map<Id, Train__c>();
        for(Incidents__c i: newObjects){
            trainids.add(i.Train__c);
        }
        for(Train__c t:[SELECT id, train_departure_date__c, departure_date__c, Delay_in_Minutes__c , train_number__c FROM Train__c where Id IN :trainids]){
            trainMap.put(t.id, t);
        }
        List<Compensation_Incident_Rules__c> ruleList = [SELECT name, travel_date_from__c, travel_date_to__c, class_of_service__c, 
                                                   					incident_type__c, delay_minutes_from__c, delay_minutes_to__c, Compensation_Percentage__c 
                                                   			FROM Compensation_Incident_Rules__c 
                                                            /*WHERE travel_date_from__c<=:train.train_departure_date__c 
                                                             		AND travel_date_to__c>=:train.train_departure_date__c
                                                         			AND incident_type__c= :i.Incident_Type__c*/
                                                 			ORDER BY travel_date_from__c, delay_minutes_from__c];
        for(Incidents__c i: newObjects){ 
            i.Compensation_Rule_Id__c = null;
            train = trainMap.get(i.train__c);
             if (ruleList!=null && ruleList.size()>0)
                 for(Compensation_Incident_Rules__c r:ruleList){
                     if(!(r.travel_date_from__c<=train.train_departure_date__c && 
                          r.travel_date_to__c>=train.train_departure_date__c   && 
                          r.incident_type__c== i.Incident_Type__c)){
                           //Rule not matching
                           //Move to next rule
                           continue;   
                          }
                         
                     System.debug('Found Rule:' + r.name+'Train :'+train.train_number__c+',Delay:'+train.Delay_in_Minutes__c);
                     if (r.delay_minutes_from__c!=null){
                         if (train.Delay_in_Minutes__c==null){
                             i.Compensation_Rule_Id__c = r.Id;
                             break;
                         }
                         else{
                             if (train.Delay_in_Minutes__c>=r.delay_minutes_from__c && train.Delay_in_Minutes__c<=r.delay_minutes_to__c ){
                                i.Compensation_Rule_Id__c = r.Id;
                                break;                             
                             }
                         }
                            
                     }
                     else{
                          i.Compensation_Rule_Id__c = r.Id;
                           break;
                     }
                 }  
        }
    }
    
}