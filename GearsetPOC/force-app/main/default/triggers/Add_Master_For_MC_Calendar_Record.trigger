trigger Add_Master_For_MC_Calendar_Record on MC_Calendar__c (before insert,after delete) {
    
    Map<String, MC_Calendar_Email_Patterns__c> MCC_categories = MC_Calendar_Email_Patterns__c.getAll();    
    
    if(trigger.isInsert)
    {
             
         /*for(MC_Calendar_Email_Patterns__c pat : MCC_categories.values())				//DISPLAY EVERYTHING IN MAP 
         {System.debug('[MC_Calendar_Email_Patterns] ' + 'Name=' +pat.Name  + ',Channel=' + pat.Channel__c + ',Main_Category=' + pat.Main_Category__c + ',SubCategory=' + pat.Subcategory__c + ',Matching_Pattern=' + pat.Matching_Pattern__c);}*/  
         
        Set<Date> dates_Of_New_Records = new Set<Date>();    							//store dates which need to be searched in soql query used to find master records 
    
        //Assign subcategory and main category for newly created records containing matching pattern   
        for(MC_Calendar__c mccn : Trigger.New)    										//iterate each record in mc calendar
        {
           for(MC_Calendar_Email_Patterns__c category : MCC_categories.values())    	//iterate every item in map
           {          
               //System.debug(category.Subcategory__c+' : '+mccn.Email_Name__c);
               if(mccn.Channel__c=='Email')    											//for Email, Email_name needs to be checked
               { 
                   if(mccn.Email_Name__c.containsIgnoreCase(category.Matching_Pattern__c) && mccn.Channel__c==category.Channel__c)    //check if pattern is present in emailname of record
                   {
                            //System.debug('******matched*******');
                            mccn.Subcategory__c = category.Subcategory__c;     
                            mccn.Main_Category__c = category.Main_Category__c;                                                    
                            dates_Of_New_Records.add((mccn.Date_Sent__c).Date());                                                
                            break;
                   }
               }
               
               if(mccn.Channel__c=='SMS')                								//for SMS, Message_name needs to be checked
               {
                   if(mccn.Message_Name__c.containsIgnoreCase(category.Matching_Pattern__c) && mccn.Channel__c==category.Channel__c)    //check if pattern is present in email name of record
                   {        
                            //System.debug('******matched*******');
                            mccn.Subcategory__c = category.Subcategory__c;    
                            mccn.Main_Category__c = category.Main_Category__c; 
                            dates_Of_New_Records.add((mccn.Date_Sent__c).Date()); 
                            break;
                   }
               } 
           }     
           if(mccn.Subcategory__c==NULL)    											// to handle emails/sms that are not present in any of the subcategories mentioned in the custom settings
           {
               if(mccn.Channel__c=='SMS')
               {
                   //System.debug('******others sms matched*******');
                   mccn.Subcategory__c = 'Other Sms';     
                   mccn.Main_Category__c = 'OTHER'; 
                   dates_Of_New_Records.add((mccn.Date_Sent__c).Date());   
               }   
               if(mccn.Channel__c=='Email')
               {
                   //System.debug('******others email matched*******');
                   mccn.Subcategory__c = 'Other Email';     
                   mccn.Main_Category__c = 'OTHER'; 
                   dates_Of_New_Records.add((mccn.Date_Sent__c).Date());   
               }
           }       
        }
                
        //System.debug('-----DATES OF NEWLY CREATED RECORDS:' + dates_Of_New_Records);				//DISPLAY DATES OF NEWLY CREATED RECORDS
        
        Map<String,MC_Calendar_Master__c> category_Date_Map = new Map<String, MC_Calendar_Master__c>(); 
        List<MC_Calendar_Master__c> mastersList = [Select m.Subcategory__c, m.Main_Category__c, m.Business_Unit__c, m.Child_count__c, m.Channel__c, m.Date_Sent__c, m.Id From MC_Calendar_Master__c m where m.Date_Sent__c in:dates_Of_New_Records];
        List<MC_Calendar_Master__c> mastersListNewAll = new List<MC_Calendar_Master__c>();
        mastersListNewAll.addAll(mastersList);
        
        //-DEBUG - LIST OF MASTERS ALREADY PRESENT IN DB FOR THE SPECIFIC DATES-
        /*System.debug('-----LIST OF MASTERS ALREADY PRESENT:');
        for(MC_Calendar_Master__c master : mastersList){System.debug(master);}*/
        
        for(MC_Calendar_Master__c master : mastersList)
        {   
            if(master.Date_Sent__c!=NULL){                               
                category_Date_Map.put(master.Subcategory__c+':'+String.valueOf((master.Date_Sent__c).Date()), master);
            }
        }                            
        
        //-DEBUG - MAP WITH KEY=SUBCATEGORY:DATE AND VALUE=MASTER RECORD-
        /*System.debug('-----MAP CREATED FOR MASTERS ALREADY PRESENT:');
        for(String key: category_Date_Map.keySet()){System.debug('key: ' + key + '  Value: ' + category_Date_Map.get(key));}*/
        
        //create master records after checking if master is already present or not then assign the correct master            
        Set<String>MCC_master_names_to_add = new Set<String>();//List<String> MCC_master_names_to_add = new List<String>();
        List<MC_Calendar_Master__c> MCC_master = new List<MC_Calendar_Master__c>(); 
        
        
        for(MC_Calendar__c mccn : Trigger.New) 
        {        
            String category_to_check_or_insert = mccn.subcategory__c + ':' + String.valueOf((mccn.Date_Sent__c).Date());
            //System.debug('-----MCC_MASTER_NAMES_TO_ADD LIST:'+MCC_master_names_to_add);// 
            //System.debug('-----CATEGORY_TO_CHECK_OR_INSERT:'+category_to_check_or_insert);//        
            if(category_Date_Map.get(category_to_check_or_insert)==null && MCC_master_names_to_add.contains(category_to_check_or_insert)==false)  //has neither been added nor was initially present
            {
                MCC_master_names_to_add.add(category_to_check_or_insert);
                if(mccn.Main_Category__c!='OTHER')
                    MCC_master.add(new MC_Calendar_Master__c(Subcategory__c = mccn.subcategory__c, Main_Category__c = mccn.Main_Category__c, Business_Unit__c = mccn.Business_Unit__c, Child_count__c=0, Channel__c = mccn.Channel__c, Date_Sent__c = (mccn.Date_Sent__c).Date()));
                else
                    MCC_master.add(new MC_Calendar_Master__c(Subcategory__c = mccn.subcategory__c, Main_Category__c = mccn.Main_Category__c, Business_Unit__c = 'Other', Child_count__c=0, Channel__c = mccn.Channel__c, Date_Sent__c = (mccn.Date_Sent__c).Date()));        	
            }          
        }  
        upsert MCC_master; 
        //-DEBUG - LIST OF MASTER RECORDS THAT NEED TO BE ADDED TO DB-
        /*System.debug('-----MASTERS TO BE ADDED:');
        for(String m : MCC_master_names_to_add){System.debug(m);}*/
                
        mastersListNewAll.addAll(MCC_master);
        
        
        Map<String,MC_Calendar_Master__c> category_Date_Map_All = new Map<String, MC_Calendar_Master__c>(); 
        //List<MC_Calendar_Master__c> mastersList_All = [Select m.Subcategory__c, m.Main_Category__c, m.Business_Unit__c,m.Child_count__c, m.Channel__c, m.Date_Sent__c, m.Id From MC_Calendar_Master__c m where m.Date_Sent__c in:dates_Of_New_Records];    
           
        //-DEBUG - FINAL LIST OF ALL MASTER RECORDS FOR THE SPECIFIC DATES-
        /*System.debug('All master records:' + mastersList_All);*/
        //for(MC_Calendar_Master__c masteroldAll : mastersList_All)
        //{System.debug('[masterList_All]   '+masteroldAll.Subcategory__c+':'+String.valueOf((masteroldAll.Date_Sent__c).Date()));}
                      
        for(MC_Calendar_Master__c master_All : mastersListNewAll)//for(MC_Calendar_Master__c master_All : mastersList_All)
        {   
            //System.debug('[masterListNewAll]   '+master_All.Subcategory__c+':'+String.valueOf((master_All.Date_Sent__c).Date()));
            if(master_All.Date_Sent__c!=NULL){               
                category_Date_Map_All.put(master_All.Subcategory__c+':'+String.valueOf((master_All.Date_Sent__c).Date()), master_All);
            }
        }
        
        //-DEBUG - FINAL MAP WITH KEY=SUBCATEGORY:DATE AND VALUE=MASTER RECORD CONTAINING ALL MASTERS FOR THE SPECIFIC DATES-
        /*System.debug('-----MAP CREATED FOR ALL MASTERS RECORDS:');
        for(String key: category_Date_Map_All.keySet()){System.debug('key: ' + key + '  Value: ' + category_Date_Map_All.get(key));}*/
           
        //Link master records to mc calendar new records
        List<MC_Calendar_Master__c> mastertoMapList = new List<MC_Calendar_Master__c>();
        List<String> mastertoMapListNames = new List<String>();
        for(MC_Calendar__c mccn : Trigger.New) 
        {
            String category_to_check_or_insert =mccn.subcategory__c + ':' + String.valueOf((mccn.Date_Sent__c).Date());
        	MC_Calendar_Master__c masterToMap = new MC_Calendar_Master__c();
            masterToMap = category_Date_Map_All.get(category_to_check_or_insert);
            mccn.MC_Calendar_Master__c = masterToMap.Id; 
            masterToMap.Child_count__c = masterToMap.Child_count__c+1;            
            if(mastertoMapListNames.contains(category_to_check_or_insert)==false)
            {
                mastertoMapListNames.add(category_to_check_or_insert);
                mastertoMapList.add(masterToMap);
            }
        }
        update mastertoMapList;
    }
    
    if(trigger.isDelete)
    {
        Set<Id> masterToReduceIdList = new Set<Id>();
        //get list of all masters whose child count will have to be reduced
        for(MC_Calendar__c mccn : Trigger.Old) 
        {
            masterToReduceIdList.add(mccn.MC_Calendar_Master__c);   
        }
                       
        Map<ID, MC_Calendar_Master__c> masterToReduceMap = new Map<ID, MC_Calendar_Master__c>([Select Id, Child_count__c, Name from MC_Calendar_Master__c where id in :masterToReduceIdList]);
        List<MC_Calendar_Master__c> mastertoReduceList = new List<MC_Calendar_Master__c>();
        List<String> mastertoReduceListNames = new List<String>();
        for(MC_Calendar__c mccn : Trigger.Old) 
        {
            MC_Calendar_Master__c masterToReduce = new MC_Calendar_Master__c();
            masterToReduce = masterToReduceMap.get(mccn.MC_Calendar_Master__c);            
            masterToReduce.Child_count__c = masterToReduce.Child_count__c-1;            
       		if(mastertoReduceListNames.contains(masterToReduce.Name)==false)
            {
                mastertoReduceListNames.add(masterToReduce.Name);
                mastertoReduceList.add(masterToReduce);
            }
        }
        update mastertoReduceList;
        
    }
}