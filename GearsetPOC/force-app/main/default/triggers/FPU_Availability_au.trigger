trigger FPU_Availability_au on FPU_Availability__c (after insert, after update) {
    
    List<String> availIdList = new List<String>();
    Map<String,String> availDetailsMap = new Map<String,String>();
    Set<String> uniqueTrainId = new Set<String>();
    
    for(FPU_Availability__c avail : Trigger.new){
        
        if( avail.FPU_Avail_Status__c ==true){
        	availIdList.add(avail.FPU_Avail_Train_Id__c); 
        		availDetailsMap.put(avail.FPU_Avail_Train_Id__c,avail.FPU_Avail_FPU_AvailCount__c+'/'+avail.FPU_Avail_FPU_Category__c);        	  
        }
    }

     System.debug('availDetailsMap : '+availDetailsMap+' // availDetailsMap.size()'+availDetailsMap.size());
     System.debug('availIdList : '+availIdList+' // availIdList.size()'+availIdList.size());

    
     List<Train__c> trainList = [select Name,FPU_Availability__c,FPU_Train_Category__c,FPU_Avail_Train_Id__c from Train__c where FPU_Avail_Train_Id__c in :availIdList];
     System.debug('trainList : '+trainList+' // trainList.size()'+trainList.size());
    
    for(Train__c train : trainList){
        uniqueTrainId.add(train.FPU_Avail_Train_Id__c);
    }
     System.debug('uniqueTrainId : '+uniqueTrainId+' // uniqueTrainId.size()'+uniqueTrainId.size());

   if(availIdList.size() != uniqueTrainId.size()){
        System.debug('in if Stetment: ');
       	Trigger.new[0].addError('ERROR : either you are trying to update some data its corresponding train is not available in the Train object or The file contain duplicate entries. Please check the data');
        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'ERROR : either you are trying to update some data its corresponding train is not available in the Train object or The file contain duplicate entries. Please check the data');
        ApexPages.addMessage(errormsg); 
      }
    else{
       
     List<Train__c> trainListtoUpdate = new List<Train__c> ();
     for(Train__c train : trainList){
        System.debug('train : '+train.Name); 
        
        String data = availDetailsMap.get(train.FPU_Avail_Train_Id__c);
        String[] dataArray = data.split('/');
        
        train.FPU_Availability__c = Integer.valueof(dataArray[0]);
        train.FPU_Train_Category__c = dataArray[1];
        trainListtoUpdate.add(train);
    	}
        
        update(trainListtoUpdate);

    }
                 
}