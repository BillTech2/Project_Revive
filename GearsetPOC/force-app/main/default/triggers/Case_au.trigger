trigger Case_au on Case (after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Case_Automation__c || DLT_CaseTriggerHandler.isDisabled) { return; }

    /***
    *Triger to Update Log and Log detail object when a booking Cancelled in Metafour and Updated the case Status as Cancelled.
    */
      Id RecordTypeIdBikeBooking = null;
    try{
        RecordTypeIdBikeBooking=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Metafour Bike Booking').getRecordTypeId();
    }
    catch(Exception e){ 
    }
   List<Case> caseObject = new List<Case>();
    for(Case newItem : trigger.new) {
        Case oldCase = Trigger.oldMap.get(newItem.ID);
        if(newItem.RecordTypeId == RecordTypeIdBikeBooking && newItem.Case_Status__c =='Cancelled' && oldCase.Case_Status__c !='Cancelled' ) {
        caseObject.add(newItem);
        }else if(oldCase.Case_Status__c =='Cancelled' && newItem.Case_Status__c !='Cancelled'){
            newItem.addError('You cannot change the status of Cancelled Case');
        }
    system.debug('Metafour caseObject::'+caseObject);
    
    }
    
    if(caseObject != null){
        for(Case caseObj : caseObject){
            
            Id caseId = caseObj.id;
            system.debug('caseId:: '+caseId);
            List<Metafour_Bike_Booking_Details__c> bikeList = new List<Metafour_Bike_Booking_Details__c> ();
            String soql = 'select id,Train_Number__c,Train_Date__c,From_Station__c,To_Station__c,No_Of_Pieces__c,Luggage_Type__c,Is_Intermediate_Station__c,Booking_Status__c from Metafour_Bike_Booking_Details__c where Case__c = :caseId';
            bikeList = Database.query(soql);    
            system.debug('Metafour bikeList:: '+bikeList);
            Metafour_Bike_Availability_Log_Details__c logDetails;
            Metafour_Bike_Availability_Logs__c summaryLog ;
            Metafour_Bike_Availability_Log_Details__c logDetails2;
            Metafour_Bike_Availability_Logs__c summaryLog2;
            
            if(bikeList.size() > 0){
                
                for(Metafour_Bike_Booking_Details__c bike : bikeList){
                    if(bike.Booking_Status__c == 'Success'){
                        
                            String[] strDate = bike.Train_Date__c.split('-');
                            Integer myIntDate = integer.valueOf(strDate[0]);
                            Integer myIntMonth = integer.valueOf(strDate[1]);
                            Integer myIntYear = integer.valueOf(strDate[2]);

                            Date dt = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                        system.debug('Metafour Date:: '+dt);
                            
                        summaryLog = [select id,Booked_Assembled_Tickets__c,Booked_Boxed_Tickets__c from Metafour_Bike_Availability_Logs__c where Train_Number__c = :bike.Train_Number__c and Date__c = :dt and From_Station__c = :bike.From_Station__c and To_Station__c = :bike.To_Station__c limit 1];
                        
                        system.debug('Metafour summaryLog:: '+summaryLog);
                        
                        if(bike.Luggage_Type__c =='Boxed'){
                            summaryLog.Booked_Boxed_Tickets__c = summaryLog.Booked_Boxed_Tickets__c-bike.No_Of_Pieces__c;
                            
                        }else if(bike.Luggage_Type__c =='Assembled'){
                            summaryLog.Booked_Assembled_Tickets__c = summaryLog.Booked_Assembled_Tickets__c-bike.No_Of_Pieces__c;
                        }

                        system.debug('Metafour summaryLog::'+summaryLog);
                        
                        logDetails = [select id,Booking_Status__c from Metafour_Bike_Availability_Log_Details__c where Train_Number__c=:bike.Train_Number__c and Train_Date__c= :dt and From_Station__c = :bike.From_Station__c and To_Station__c = :bike.To_Station__c and Luggauge_Type__c = :bike.Luggage_Type__c and Number_of_Spaces__c = :bike.No_Of_Pieces__c and Booking_Status__c = 'Booked'  limit 1];
                        if(logDetails!= null){
                            logDetails.Booking_Status__c = 'Cancelled';
                          system.debug(' MetafourlogDetails::'+logDetails);
                        }
                        
                    
                    update summaryLog;
                    update logDetails;
                    
                    /*Checking if the to station is an intermediate station*/
                    if(bike.Is_Intermediate_Station__c == true){
                        
                        /*Fetching the full jouney train detail corresponding to this entry*/
                        Metafour_Bike_Capacity__c trainCapacity  = [Select From_Station__c,To_Station__c,Train_Number__c,Intermediate_stop__c  from Metafour_Bike_Capacity__c where From_Station__c = :bike.From_Station__c and Train_Number__c =:bike.Train_Number__c and  Intermediate_stop__c = false  limit 1];
                        /*Fetching the full jouney train detail from Log table*/
                            summaryLog2 = [select id,Booked_Assembled_Tickets__c,Booked_Boxed_Tickets__c from Metafour_Bike_Availability_Logs__c where Train_Number__c = :bike.Train_Number__c and Date__c = :dt and From_Station__c = :bike.From_Station__c and To_Station__c = :trainCapacity.To_Station__c limit 1];

                        system.debug('in trigger summaryLog2::'+summaryLog2);
                        
                        

                       if(bike.Luggage_Type__c =='Boxed'){
                            summaryLog2.Booked_Boxed_Tickets__c = summaryLog2.Booked_Boxed_Tickets__c-bike.No_Of_Pieces__c;
                            
                        }else if(bike.Luggage_Type__c =='Assembled'){
                            summaryLog2.Booked_Assembled_Tickets__c = summaryLog2.Booked_Assembled_Tickets__c-bike.No_Of_Pieces__c;
                        }                       
                        
                         logDetails2 = [select id,Booking_Status__c from Metafour_Bike_Availability_Log_Details__c where Train_Number__c=:bike.Train_Number__c and Train_Date__c= :dt and From_Station__c = :bike.From_Station__c and To_Station__c = :trainCapacity.To_Station__c and Luggauge_Type__c = :bike.Luggage_Type__c and Number_of_Spaces__c = :bike.No_Of_Pieces__c and Booking_Status__c = 'Booked' limit 1];
                        if(logDetails2!= null){
                            logDetails2.Booking_Status__c = 'Cancelled';
                          system.debug(' MetafourlogDetails::'+logDetails2);
                        }
                    update summaryLog2;
                    update logDetails2;
                    }
                }
                }
            }
        }
        
    }  

}