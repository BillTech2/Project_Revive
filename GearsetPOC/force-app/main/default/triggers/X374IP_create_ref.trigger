trigger X374IP_create_ref on X374_Improvement_Plan__c (before insert) {
    // need to get the record type name for the improvement plan object
    Map<ID,Schema.RecordTypeInfo> rt_Map = X374_Improvement_Plan__c.sObjectType.getDescribe().getRecordTypeInfosById();

    for (X374_Improvement_Plan__c curr_IP :Trigger.new){

        try{
            // look for the highest value for Sequence in record of the same record type and primary code
            X374_Improvement_Plan__c IP = [SELECT X374IP_Sequence__c from X374_Improvement_Plan__c WHERE X374IP_Primary_code__c = :curr_IP.X374IP_Primary_code__c and RecordTypeId = :curr_IP.RecordTypeId ORDER BY X374IP_Sequence__c DESC LIMIT 1];
            // increment the sequence number
            if(IP != NULL )
                curr_IP.X374IP_Sequence__c = IP.X374IP_Sequence__c +1;               
        }
        catch(exception e){
            // this is the first record for this record type / primary code combination
                curr_IP.X374IP_Sequence__c = 1;
        }

        // build the reference string as {record type}-374/{primary code}/{sequence} eg RIP-374/A/2
        curr_IP.X374IP_Reference_number__c = rt_map.get(curr_IP.recordTypeID).getName() +'-374/' + curr_IP.X374IP_Primary_code__c.substring(0,1).toUpperCase() + '/' + curr_IP.X374IP_Sequence__c;
    }
}