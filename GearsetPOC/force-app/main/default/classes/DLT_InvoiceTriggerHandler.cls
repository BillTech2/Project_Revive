public without sharing class DLT_InvoiceTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        List<Invoice__c> filteredInvoices;
        if(!System.Trigger.isDelete){
            filteredInvoices = filterRecords((List<Invoice__c>) System.Trigger.new);
        }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                setSubscriptionDependentFields(filteredInvoices);
                assignInvoiceNumber(filteredInvoices);
            }

            if (System.Trigger.isUpdate) {
                setSubscriptionDependentFields(filteredInvoices, (Map<Id, Invoice__c>) System.Trigger.oldMap);
                assignInvoiceNumber(filteredInvoices);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
            }

            if (System.Trigger.isUpdate) {

            }
        }
    }

    private static void assignInvoiceNumber(List<Invoice__c> invoices){

        String numberFormat = System.Today().Year() + DLT_InvoiceConstants.NUMBER_PREFIX;
        String numberFormatSearch = '%' + numberFormat + '%';

        List<Invoice__c> existingInvoices = [
            SELECT Invoice_Number__c 
            FROM Invoice__c 
            WHERE Invoice_Number__c  != null 
                AND Invoice_Number__c LIKE :numberFormatSearch
            ORDER BY Invoice_Number__c DESC 
            LIMIT 1];
            
        Integer biggestNumber = existingInvoices.size() > 0 ?
            Integer.valueOf(existingInvoices[0].Invoice_Number__c.right(4)) :
            0;

        for(Invoice__c invoice : invoices){

            if(!String.isBlank(invoice.Invoice_Number__c) || invoice.Status__c != DLT_InvoiceConstants.STATUS_CONFIRMED) continue;

            biggestNumber++;    
            String currentNumber = ('000' + String.valueOf(biggestNumber)).right(4);

            invoice.Invoice_Number__c = numberFormat + currentNumber;
    
        }
    }

    private static void setSubscriptionDependentFields(List<Invoice__c> invoices){

        Map<Id, Subscription__c> subscriptionMap = getSubscriptionMap(invoices);

        for(Invoice__c invoice : invoices){
            if(invoice.Subscription__c == null) continue;

            fillSubscriptionDependentFields(invoice, subscriptionMap);
        }
    }

    private static void setSubscriptionDependentFields(List<Invoice__c> invoices, Map<Id, Invoice__c> invoiceOldMap){

        Map<Id, Subscription__c> subscriptionMap = getSubscriptionMap(invoices);

        for(Invoice__c invoice : invoices){
            if(invoice.Subscription__c == null || invoiceOldMap.get(invoice.Id).Subscription__c == invoice.Subscription__c) continue;

            fillSubscriptionDependentFields(invoice, subscriptionMap);        
        }
    }

    private static Map<Id, Subscription__c> getSubscriptionMap(List<Invoice__c> invoices){

        List<Id> relatedSubscriptionIds = new List<Id>();

        for(Invoice__c invoice : invoices){
            if(invoice.Subscription__c == null) continue;

            relatedSubscriptionIds.add(invoice.Subscription__c);
        }

        Map<Id, Subscription__c> subscriptionMap = new Map<Id, Subscription__c>([
            SELECT Id, Total_Amount_VAT_excl__c, TECH_VAT__c, Total_Amount__c, VAT_Number__c 
            FROM Subscription__c 
            WHERE Id IN :relatedSubscriptionIds]);

        return subscriptionMap;
    }

    private static void fillSubscriptionDependentFields(Invoice__c invoice, Map<Id, Subscription__c> subscriptionMap){

        invoice.Total_Amount_excl_VAT__c = subscriptionMap.get(invoice.Subscription__c).Total_Amount_VAT_excl__c;
        invoice.VAT__c = subscriptionMap.get(invoice.Subscription__c).TECH_VAT__c;
        invoice.Total_Amount_incl_VAT__c = subscriptionMap.get(invoice.Subscription__c).Total_Amount__c;
        invoice.Subscription_VAT_Number__c = subscriptionMap.get(invoice.Subscription__c).VAT_Number__c;

    }

    private static List<Invoice__c> filterRecords(List<Invoice__c> invoices){

        if(DLT_Constants.IS_LAMBDA_USER) return invoices;

        List<Invoice__c> filteredInvoices = new List<Invoice__c>();

        for(Invoice__c invoice : invoices){
            if(invoice.Invoice_Number__c == null){
                filteredInvoices.add(invoice);
            }
        }

        return filteredInvoices;
    }
}