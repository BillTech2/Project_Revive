trigger X374IP_calc_forecast_benefit on X374_Improvement_Plan__c (before insert, before update) {
    Map<ID,Schema.RecordTypeInfo> rt_Map = X374_Improvement_Plan__c.sObjectType.getDescribe().getRecordTypeInfosById();

 
    for (X374_Improvement_Plan__c curr_IP :Trigger.new){
        // only interested in RIP record types that have implementation start dates
        if (rt_map.get(curr_IP.recordTypeID).getName() == 'RIP' && curr_IP.X374IP_Planned_start__c != NULL){    
            // calculate the date 12 months before the implementation start date for this record
            Date min_days = curr_IP.X374IP_Planned_start__c.addDays(-365);
            Date max_days = curr_IP.X374IP_Planned_start__c;
          
            // count the number of records of the same record type, primary code and title in the last 12 months
            Integer ip_count = [SELECT count() from X374_Improvement_Plan__c WHERE RecordTypeId = :curr_IP.RecordTypeId and X374IP_Primary_code__c = :curr_IP.X374IP_Primary_code__c and X374IP_Title__c = :curr_IP.X374IP_Title__c and X374IP_Planned_start__c >= :min_days and X374IP_Planned_start__c <= :max_days];
            
            // calculate the forecast benefit -must divide by decimal to get decimal result
            if(ip_count != 0)
                curr_IP.X374IP_Forecast_benefit__c = ip_count/12.00;
            else
                curr_IP.X374IP_Forecast_benefit__c = 0;
        }
    }
}