trigger FPU_Eligibility_Criteria_bi on FPU_Availability_Criteria__c (before insert,before update) {
    
    for(FPU_Availability_Criteria__c criteria : Trigger.new){
        
        try{
            
            FPU_Availability_Criteria__c cr = [select id,Name,FPU_AvailCrit_TravelPeriod_FromDate__c,FPU_AvailCrit_TravelPeriod_ToDate__c from FPU_Availability_Criteria__c 
                                               where FPU_AvailCrit_Status__c = true and id != :criteria.id limit 1]; 
     
        if(cr != null){
            criteria.addError('Two records cannot be Active at a time');
        }
        }catch(Exception e){
            
        }
		
    }

}