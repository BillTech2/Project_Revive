public  without sharing   class CompApp_AdditionalCompUtils {
    private static List<Additional_Compensation_Rules__c> ruleList;
    public static final String POST_TRAVEL_RULE = 'Post-Travel Rule';
    public static final String PRE_TRAVEL_RULE = 'Pre-Travel Rule';
    private static List<Additional_Compensation_Rules__c> getAdditionalCompensationRules(){
        if (ruleList==null){
            ruleList = [SELECT Id, Date_From__c, Date_to__c, Station_From__c, Station_To__c, Time_From__c, Time_To__c, Trains__c, Additional_Percentage__c, 
                        Additional_PRR_Percentage__c, RecordType.name
                        FROM Additional_Compensation_Rules__c
                        WHERE ( (Date_To__c>=:(Date.Today().addDays(-365)) AND RecordType.name=:POST_TRAVEL_RULE) OR
                               (Date_To__c>=:Date.Today() AND  RecordType.name=:PRE_TRAVEL_RULE))
                        ORDER BY RecordType.Id, Date_From__c] ;
        }
        System.debug('rules : ' + ruleList);
        return ruleList;
    }

    public static void getAdditionalCompensationRule(final List<Train__c> newObjects )  { 
        if (ruleList ==null) 
            getAdditionalCompensationRules();
        for (TRain__c t:newObjects){ 
            System.debug('Checking for a rule !!!');
            for(Additional_Compensation_Rules__c r:ruleList){
                                                            if (isApplicable(r, t)){ //Found an applicable rule
                                                                if (r.RecordType.Name==POST_TRAVEL_RULE){
                                                                    t.Additional_Compensation_Rule__c=r.Id;
                                                                    t.Additional_Compensation_Percentage__c=r.Additional_Percentage__c;
                                                                    t.Additional_PRR_Percentage__c=r.Additional_PRR_Percentage__c;
                                                                }
                                                                else{
                                                                    t.Pre_Travel_Rule__c = r.Id;
                                                                }
                											t.ACR_Reprocess_Count__c++;
                                                            break;
                                                        }
            } 
        }
    }
    public static void getAdditionalCompensationRule(final List<Train__c> newObjects, final Map<Id, Train__c> oldObjectsMap)  {
        Additional_Compensation_Rules__c pretravelrule;
        Additional_Compensation_Rules__c posttravelrule;
        Boolean updateProcessCount=false;
        if (ruleList ==null) 
            getAdditionalCompensationRules();
        for (TRain__c t:newObjects){
            pretravelrule =null;
            posttravelrule =null;
            System.debug('Checking for a rule');
            updateProcessCount=false;
            for(Additional_Compensation_Rules__c r:ruleList){     
                if (pretravelrule !=null && posttravelrule !=null) //Found both type of rules. Hence no need to loop further;
                    break;
                if (pretravelrule==null && r.RecordType.Name==PRE_TRAVEL_RULE){
                    if (isApplicable(r, t)){ //Found an applicable rule
                        pretravelrule = r;
                        continue;
                    }}
                if (posttravelrule==null && r.RecordType.Name==POST_TRAVEL_RULE){
                    if (isApplicable(r, t)){ //Found an applicable rule
                        posttravelrule = r;
                        continue;
                    }}
            }
            if (posttravelrule!=null){
                System.debug('Found a rule'); 
                if (posttravelrule.Id  != oldObjectsMap.get(t.id).Additional_Compensation_Rule__c || 
                    posttravelrule.Additional_Percentage__c!=oldObjectsMap.get(t.id).Additional_Compensation_Percentage__c|| 
                    posttravelrule.Additional_PRR_Percentage__c!=oldObjectsMap.get(t.id).Additional_PRR_Percentage__c){
                        //Od rule is not matching with current
                        //Hence need reprocessing
                        t.Additional_Compensation_Percentage__c = posttravelrule.Additional_Percentage__c;
                        t.Additional_PRR_Percentage__c=posttravelrule.Additional_PRR_Percentage__c;
                        t.Additional_Compensation_Rule__c=posttravelrule.Id;
                        updateProcessCount=true;                            
                    }
                
            } else if(oldObjectsMap.get(t.id).Additional_Compensation_Rule__c !=null){
                // No rule foound, but there is a rule asocaited to old version of the record
                // Remove the rule and reprocess
                // 
                t.Additional_Compensation_Percentage__c = 0;
                t.Additional_Compensation_Rule__c = null;
                t.Additional_PRR_Percentage__c = 0;
                updateProcessCount=true; }
            if (pretravelrule!=null){
                if (pretravelrule.Id  != oldObjectsMap.get(t.id).Pre_Travel_Rule__c){
                    t.Pre_Travel_Rule__c=pretravelrule.Id;
                    updateProcessCount=true;
                }
                
            }else if(oldObjectsMap.get(t.id).Pre_Travel_Rule__c !=null){
                // No rule foound, but there is a rule asocaited to old version of the record
                // Remove the rule and reprocess
                //  NEED TO DEVELOP THIS FUTHER REMOVE ALL COMPENSATIONS.
                //  IF There are no compensations created then the rule can set to null
                //  If there are compensations created and non calimed, then compensations can be deleted and rule set to null
                //  If there are compensations claimed, then the rule need to be de-activated and all unclaimed compensations can be deleted
                //  IF THERE ARE ANY CLAIMED COMPENSATIONS, THEN THIS CANNOT BE DONE
                updateProcessCount=true; } 
            if (updateProcessCount){
                 t.ACR_Reprocess_Count__c=(t.ACR_Reprocess_Count__c==null)?1:++t.ACR_Reprocess_Count__c;
            }
            
        }
    }
    
  private static boolean isApplicable (Additional_Compensation_Rules__c rule, Train__c train){
      String deptime=null;
      Time dtime=null;
      Date dt;
      boolean result=false;
      if (rule!=null && train!=null){
          System.debug('Checkind date range : '+train.Departure_Date_Time__c);
          deptime = train.Departure_Date_Time__c.left(10);
          dt = CompApp_Constructs.parseStringToDate(train.Departure_Date_Time__c.left(10));
           
          if (dt>=rule.date_from__C && dt<=rule.date_to__c){
              result=true;
              System.debug('Checkind date range - met');
              If (rule.station_from__c!=null){ //If Origin station doesn't match, skip
                  if (train.From__c <> rule.station_from__c)
                      result=false;
              }
              If (rule.station_to__c!=null){ //If Destination station doesn't match, skip
                  if (train.to__c <> rule.station_to__c)
                      result=false;
              }
              if (rule.trains__c!=null && rule.trains__c.length()>0 ){ //If train number doesn't match, skip
                  if (!rule.trains__c.contains(train.Train_Number__c)){
                      System.debug('Cant find the train '+ train.Train_Number__c);
                      result=false;
                  }
                  
              }
              //If time is defined then the the trains time must be in the range
              deptime =null;
              if (train.Departure_Date_Time__c.length()==19){
                  deptime = train.Departure_Date_Time__c.right(8).left(5).replace(':','');
                  if (deptime!=null && deptime.length()==4 && deptime.isNumeric()){
                      dtime = Time.newInstance(Integer.valueOf(deptime.left(2)), Integer.valueOf(deptime.right(2)), 0, 0);
                  }
              } 
              if  (rule.time_from__c !=null){ // Need to check only if the from time is defined for this rule 
                  if (dtime==null || dtime<rule.time_from__c ) //Not in the time range, hence skip
                      result=false;
              }
              if (rule.time_to__c !=null){ // Need to check only if the to time is defined for this rule 
                  if (dtime==null || dtime>rule.time_to__c) //Not in the time range, hence skip
                      result=false;
              }                             
              
          }
      }
      return result;
  }
  public static Boolean isAsyncNeeded(Integer recordCount){
        system.debug('recordCount @ compensationCalcHelper_Sync:'+ recordCount);
        system.debug(' MAX_FORCE_SYNC_COMPENSATION_RECORD_COUNT:1'  );
        system.debug('CompApp_Constructs.FUTURE_LIMIT_BUFFER_TRIGGER @ compensationCalcHelper_Sync:'+ CompApp_Constructs.FUTURE_LIMIT_BUFFER_TRIGGER);


        Boolean isAsync = System.isBatch() || System.isFuture() || System.isScheduled(); 
        Boolean isHighRecordCount = recordCount > 1;

        return  (!isAsync) &&  isHighRecordCount;
    }
  
    public static List<Train__c> getTrainsToUpdate(final List<Additional_Compensation_Rules__c>  rules, Map<Id, Additional_Compensation_Rules__c> oldRuleMap){
        List<Train__c> existingtrains=null;
        List<Train__c> newtrains=null;
        List<Train__c> templist=null;
        List<Train__c> trains=null;
        List<Train__c> finalList = new List<Train__c> ();
        existingtrains=[select  id, additional_compensation_rule__c, pre_travel_rule__c, train_number__c, departure_Date__c, departure_Date_time__c, from__c, to__c, ACR_Reprocess_Count__c from Train__C where additional_compensation_rule__c IN :rules OR
                        pre_travel_rule__c IN :rules];
        
        //Create a Map with Ruleid as key and train as value
        Map<Id, List<Train__c>> ruleMap=new Map<Id, List<Train__c>>();
        for (Train__c t:existingtrains){
            templist = ruleMap.get(t.additional_compensation_rule__c);
            if (tempList==null){
                templist = new List<Train__c> ();
                ruleMap.put(t.additional_compensation_rule__c,templist );
            }
            templist.add(t);
            //Checking Pre-Travel Rule
            templist = ruleMap.get(t.pre_travel_rule__c);
            if (tempList==null){
                templist = new List<Train__c> ();
                ruleMap.put(t.pre_travel_rule__c,templist );
            }
            templist.add(t);
        }
        
        //For each updated rule check the following, 
        //Case#1. 
        //	Check whether the currently associated trains are still eligible for this rule. 
        //		if not, remove the relationship and mark the train for reprocessing
        //		if yes, mark it for reprocessing if the rate in the rule is changed
        //Case#2. 
        //	CHeck if there are any new trains to which this rule can be applied.
        //		if found, then set the relatioship for that train
        
            for (Additional_Compensation_Rules__c r : rules){
                if (ruleMap.size()>=1) // If there any trains assocated to any rules
                    if (rulemap.containsKey(r.Id)){
                        //Case#1
                        for (Train__c t: ruleMap.get(r.Id)){
                            if (isApplicable(r,t)){
                                //Rule is still applicable and need re processing only if the rate is changed
                                if (r.Additional_Percentage__c!=oldRuleMap.get(r.Id).Additional_Percentage__c){
                                    t.Additional_Compensation_Percentage__c = r.Additional_Percentage__c;
                                    t.Additional_PRR_Percentage__c = r.Additional_PRR_Percentage__c;
                                    t.ACR_Reprocess_Count__c=(t.ACR_Reprocess_Count__c==null)?1:++t.ACR_Reprocess_Count__c;
                                    finalList.add(t);                        
                                }                    	
                            }
                            else{
                                //Rule is no longer applicable to this train
                                //Hence remove the relationship and mark for processing
                                if (r.RecordType.Name==POST_TRAVEL_RULE){
                                    t.Additional_Compensation_Rule__c =null;
                                    t.Additional_Compensation_Percentage__c = 0;
                                    t.Additional_PRR_Percentage__c = 0;}
                                else{
                                    t.Pre_Travel_Rule__c=null;
                                }
                                t.ACR_Reprocess_Count__c=(t.ACR_Reprocess_Count__c==null)?1:++t.ACR_Reprocess_Count__c;
                                finalList.add(t);   
                            }
                        }
                    }
                //Case#2
                System.debug('r.date_from__c '+'-'+r.date_from__c +'-'+r.date_to__c );
                if (r.RecordType.Name==POST_TRAVEL_RULE)
                trains = [SELECT id, additional_compensation_rule__c, train_number__c, train_departure_date__c, departure_Date_time__c, from__c, to__c, ACR_Reprocess_Count__c from Train__C
                                		where train_departure_date__c >= :r.date_from__c AND train_departure_date__c <=:r.date_to__c];
                else
                     trains = [SELECT id, pre_travel_rule__c, train_number__c, train_departure_date__c, departure_Date_time__c, from__c, to__c, ACR_Reprocess_Count__c from Train__C
                                		where train_departure_date__c>=:Date.Today() AND train_departure_date__c >= :r.date_from__c AND train_departure_date__c <=:r.date_to__c];
                For(Train__c t:trains){
                	if (isApplicable(r,t)){
                        if (r.RecordType.Name==POST_TRAVEL_RULE){
                            t.Additional_Compensation_Rule__c = r.Id;
                            t.Additional_Compensation_Percentage__c = r.Additional_Percentage__c;
                            t.Additional_PRR_Percentage__c = r.Additional_PRR_Percentage__c;
                        }
                        else{
                            t.pre_travel_rule__c = r.Id;
                        }
                        t.ACR_Reprocess_Count__c=(t.ACR_Reprocess_Count__c==null)?1:++t.ACR_Reprocess_Count__c;
                     	finalList.add(t); 
                    }
                    
                }
                System.debug('getTrainsToUpdate- Limits.getCpuTime() :'+Limits.getCpuTime());
            }        
        return finalList;
    }
  public static void updateTrains(List<Train__c> trains){
        System.debug('>>>updateTrain');
        // If async is available 
        if (isAsyncNeeded(trains.size())){
            System.enqueueJob(new CompApp_TrainUpdateJob(trains)); 
        }else{
            for(TRain__c t:trains)
                update t;
        }
    }	 
    
    public static void validateAdditionalCompensationRule(final List<Additional_Compensation_Rules__c> newObjects, final Map<Id, Additional_Compensation_Rules__c> oldObjectsMap){
    	Additional_Compensation_Rules__c oldrec=null;
        Boolean isTrainsOverlapped = false;
        for(Additional_Compensation_Rules__c acr:newObjects){
            oldrec =  oldObjectsMap.get(acr.Id);
            isTrainsOverlapped = ! checkExclusivity(oldrec.Trains__c, acr.Trains__c);
             if ((acr.date_from__c < Date.today().addDays(-1) ) 
                 && ( acr.Station_From__c != oldrec.Station_From__c 
                     || acr.Station_To__c != oldrec.Station_To__c 
                     || acr.Time_From__c != oldrec.Time_From__c 
                     || acr.Time_To__c != oldrec.Time_To__c 
                     || acr.Trains__c != oldrec.Trains__c
                     || isTrainsOverlapped
                    )
                )          
                acr.addError('Cannot modify a Compensation parameters of a past date');
            
            if ((oldrec.date_from__c<= Date.today().addDays(-1) && oldrec.date_from__c!=acr.date_from__c) 
                ||(oldrec.date_to__c<= Date.today().addDays(-1) && oldrec.date_to__c!=acr.date_to__c))
                acr.addError('Only a future date can be changed');
             
        }
    }
    public static void validateAdditionalCompensationRule(final List<Additional_Compensation_Rules__c> newObjects){
        
        Time tfe, tfn, tte, ttn;
        Additional_Compensation_Rules__c oldrec;
        Boolean isTimeOverlapped, isStationOverlapped, isTrainsOverlapped  ;
        List<String> new_trains =null;
        List<String> trains =null;
            for(Additional_Compensation_Rules__c acr:newObjects){
                
                isTimeOverlapped = false;
                isStationOverlapped = false;
                isTrainsOverlapped =  false;
                
                if (acr.Trains__c!=null && acr.Trains__c.length()>0)
                    new_trains =  acr.Trains__c.replace(' ','').split(',');
                else 
                    new_trains=null;
                        
                if (acr.date_from__c > acr.date_to__c )
                    acr.addError('Date From should be a date on or before Date To');
                
                if (acr.time_from__c !=null && acr.time_to__c !=null && acr.time_from__c>acr.time_to__c)
                    acr.addError('Time From should be a time on or before Time To');
                
                if  (acr.Trains__c!=null && !Pattern.matches('(09[0-1]{1}([0-9]{2}),?)+', acr.Trains__c))
                     acr.addError('Invalid Train number format. Train number should be of length 5, starting with 09, then a 0 or a 1 followed by 2 more digits');
                
                if (Trigger.isInsert){
                    if (acr.date_from__c < Date.today().addDays(-1))
                         acr.addError('Cannot define Compensation rules for a past date');
                } 
                
                
                //
                // Selecting all active records which has an overlapping date range with the new one 
                //
                Additional_Compensation_Rules__c[] existing = [SELECT date_from__c, date_to__c, time_from__c, time_to__c, station_from__c, station_to__c, trains__c 
                                                               FROM Additional_Compensation_Rules__c
                                  								WHERE /*active__c = true AND*/ id != :acr.RecordTypeId AND recordTypeID=:acr.RecordTypeId 
                                                               		AND ((date_from__c <= :acr.date_from__c 
                                  											AND date_to__c >= :acr.date_from__c) OR (date_from__c <= :acr.date_to__c AND date_to__c >= :acr.date_to__c) 
                                  											OR (date_from__c >= :acr.date_from__c AND date_to__c <= :acr.date_from__c)) ];
                for (Additional_Compensation_Rules__c acr_existing : existing ){  
                        isTimeOverlapped =False;
                        isStationOverlapped = False;
                         //
                         // Assigning to time varibales for easy comparison
                         //
                         if (acr_existing.time_from__c!=null)
                             tfe = acr_existing.time_from__c;
                         else
                             tfe = Time.newInstance(00, 00, 00, 01);
                         
                         if (acr_existing.time_to__c!=null)
                             tte = acr_existing.time_from__c;
                         else
                             tte = Time.newInstance(11, 59, 59, 00);                  
                         
                         if (acr.time_from__c!=null)
                             tfn = acr.time_from__c;
                         else
                             tfn = Time.newInstance(00, 00, 00, 01);
                         
                         if (acr.time_to__c!=null)
                             ttn = acr.time_from__c;
                         else
                             ttn = Time.newInstance(11, 59, 59, 00); 
                             
                         //
                         //Checking if the time is ovelapping
                         //
                         if ((tfe<=tfn   &&  tte>= tfn) || (tfe <= ttn && tte >=ttn )|| (tfe>=tfn && tte <=tfn ))
                             isTimeOverlapped = True;
                             
                             
                         //
                         //if time is exactly same, then checking if stations are over lapping
                         //
                             if ((acr_existing.station_from__c == null && acr.station_from__c != null) ||
                                 (acr.station_from__c == null && acr_existing.station_from__c != null) ||
                                 (acr_existing.station_to__c == null && acr.station_to__c != null) ||
                                 (acr.station_to__c == null && acr_existing.station_to__c != null) ||
                                 (acr_existing.station_from__c == acr.station_from__c  && acr_existing.station_to__c == acr.station_to__c))
                                 
                                IsStationOverlapped = True; 
                            
                            isTrainsOverlapped = ! checkExclusivity(acr_existing.Trains__c, acr.Trains__c); 
                         
                        if (isTimeOverlapped && isStationOverlapped && isTrainsOverlapped)
                           acr.addError('You can\'t have overlapping date, time, stations and trains'); 
                              
                }
            } 
    }
    public static boolean checkExclusivity( String  list1,  String  list2){
        boolean isExclusive=true;
        List<String> l1=null;
        List<String> l2=null;
        
        if (list1!=null&&list1.length()>0)
            l1 = list1.replace(' ','').split(',');
        
        if (list2!=null&&list2.length()>0)
            l2 = list2.replace(' ','').split(',');
        
        if ((l1==null && l2!=null) 
            || (l1!=null && l2==null)){
                isExclusive = false;
        }
        else if (l1==null && l2==null){
            isExclusive = true;
        }	
        else{
            for(String s:l2){
                if (l1.contains(s)){
                    isExclusive = false;
                    break;
                }
            }  
       }
        return isExclusive;
    }																																											  

}