trigger case_bu on Case (after update) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Case_Automation__c || DLT_CaseTriggerHandler.isDisabled) { return; }

     Id RecordTypeIdBikeBooking = null;
    try{
        RecordTypeIdBikeBooking=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Metafour Bike Booking').getRecordTypeId();
    }
    catch(Exception e){ 
    }
    
 for(Case cse : Trigger.new){

    if(cse.RecordTypeId == RecordTypeIdBikeBooking &&
      cse.Subject  == 'Bike Booking' && cse.Metafour_Send_Email__c == true){
        
            Id caseId = cse.id;
            List<Metafour_Bike_Booking_Details__c> bikeList = new List<Metafour_Bike_Booking_Details__c> ();
            String soql = 'select id,Train_Number__c,Booking_Status__c from Metafour_Bike_Booking_Details__c where Case__c = :caseId';
            bikeList = Database.query(soql);    
            system.debug('Metafour bikeList:: '+bikeList);
          
          for(Metafour_Bike_Booking_Details__c bike : bikeList){
              if(bike.Booking_Status__c == 'Failed'){
                cse.addError('Cannot send Confirmation email if some bookings are failed');
              }
          }
        
    }
 }
    
}