public without sharing class DLT_EVoucherTriggerHandler {
    
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                updateCarrierValues((List<eVoucher__c>)Trigger.new);
            }

            if (System.Trigger.isUpdate) {
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
            }

            if (System.Trigger.isUpdate) {
            }
        }
    }

    private static void updateCarrierValues(List<eVoucher__c> eVoucherList){

        Set<Id> compensationIds = new Set<Id>();

        for(eVoucher__c eV : eVoucherList){
            compensationIds.add(eV.Compensation__c);
        }

        Map<Id, Compensation__c> compensationMap = new Map<Id,Compensation__c>([
            SELECT Id, Carrier__c, Carrier_was_defaulted__c, Handled_by_Mass_Compensation__c
            FROM Compensation__c 
            WHERE Id IN :compensationIds]);

        for(eVoucher__c eVoucher : eVoucherList){

            if(eVoucher.recordTypeId != Schema.SObjectType.EVoucher__c.getRecordTypeInfosByName().get(DLT_EVoucherConstants.RECORDTYPE_SERVICE_RECOVERY).getRecordTypeId()) continue;

            eVoucher.Carrier_was_defaulted__c =
                compensationMap.containsKey(eVoucher.Compensation__c) 
                ? compensationMap.get(eVoucher.Compensation__c).Carrier_was_defaulted__c
                : false;

            eVoucher.Carrier__c = (
                compensationMap.containsKey(eVoucher.Compensation__c) 
                && (compensationMap.get(eVoucher.Compensation__c).Carrier__c == DLT_CompensationConstants.CARRIER_RED
                    || compensationMap.get(eVoucher.Compensation__c).Carrier__c == DLT_CompensationConstants.CARRIER_BLUE)) 
                ? compensationMap.get(eVoucher.Compensation__c).Carrier__c
                : DLT_CompensationConstants.CARRIER_BLUE;
            
            eVoucher.Handled_by_Mass_Compensation__c = 
                compensationMap.containsKey(eVoucher.Compensation__c) 
                ? compensationMap.get(eVoucher.Compensation__c).Handled_by_Mass_Compensation__c 
                : false;

        }
        
    }

}