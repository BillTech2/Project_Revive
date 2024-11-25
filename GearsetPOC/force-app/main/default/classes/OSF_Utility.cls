/*********************************************************************************************************
Class Name      : OSF_Utility
Description     : Class to handle general utility methods
Developer       : Vasile Paraschiv
Date            : 
Version         : 1.0
*********************************************************************************************************
History
*********************************************************************************************************
Date            Developer           Version      Description
*********************************************************************************************************/
public with sharing class OSF_Utility {
    
    /**********************************************************************************************
    * @description  : Checks if a given trigger handler method is active or not
    * @param        : String triggerHandlerName - Name of the trigger handler
    * @param        : String methodName - Name of the method
    * @return       : Boolean - true if active, false otherwise
    ***********************************************************************************************/
    public static Boolean isActive(String triggerName, String methodName){
        List<OSF_Trigger_Management__mdt> lstTriggerManagement = new List<OSF_Trigger_Management__mdt>();
        lstTriggerManagement = [SELECT Is_Active__c FROM OSF_Trigger_Management__mdt WHERE Trigger_Handler_Name__c = :triggerName AND Method_Name__c = :methodName];
        Boolean executeMethod = lstTriggerManagement.size() == 1 ? lstTriggerManagement[0].Is_Active__c : false;
        return executeMethod;
    }

    /**********************************************************************************************
    * @description  : returns batch size based on batch name
    * @param        : String batchName - name of the batch
    * @return       : Integer - batch size
    ***********************************************************************************************/
    public static Integer getBatchSize(String batchName) {
        List<OSF_Batch_Size_Configuration__mdt> lstBatchManagement = new List<OSF_Batch_Size_Configuration__mdt>();
        lstBatchManagement = [SELECT Batch_Size__c FROM OSF_Batch_Size_Configuration__mdt WHERE Batch_Name__c = :batchName];
        Decimal batchSize = lstBatchManagement.size() == 1 ? lstBatchManagement[0].Batch_Size__c : 200;
        return (Integer)batchSize;
    }
    
}