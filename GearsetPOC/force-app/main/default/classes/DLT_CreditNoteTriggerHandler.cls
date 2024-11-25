public without sharing class DLT_CreditNoteTriggerHandler {
    public static Boolean isDisabled = false;

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        List<Credit_Note__c> filteredCreditNotes;
        if(!System.Trigger.isDelete){
            filteredCreditNotes = filterRecords((List<Credit_Note__c>) System.Trigger.new);
        }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                assignCreditNoteNumber(filteredCreditNotes);
            }

            if (System.Trigger.isUpdate) {
                assignCreditNoteNumber(filteredCreditNotes);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
            }

            if (System.Trigger.isUpdate) {

            }
        }
    }

    private static void assignCreditNoteNumber(List<Credit_Note__c> creditNotes){

        String numberFormat = System.Today().Year() + DLT_CreditNoteConstants.NUMBER_PREFIX;
        String numberFormatSearch = '%' + numberFormat + '%';

        List<Credit_Note__c> existingCreditNotes = [
            SELECT Credit_Note_Number__c  
            FROM Credit_Note__c  
            WHERE Credit_Note_Number__c  != null 
                AND Credit_Note_Number__c LIKE :numberFormatSearch
            ORDER BY Credit_Note_Number__c DESC 
            LIMIT 1];

        Integer biggestNumber = existingCreditNotes.size() > 0 ?
            Integer.valueOf(existingCreditNotes[0].Credit_Note_Number__c.right(4)) :
            0;

        for(Credit_Note__c creditNote : creditNotes){

            if(!String.isBlank(creditNote.Credit_Note_Number__c) || creditNote.Status__c != DLT_CreditNoteConstants.STATUS_CONFIRMED) continue;

            biggestNumber++;    
            String currentNumber = ('000' + String.valueOf(biggestNumber)).right(4);

            creditNote.Credit_Note_Number__c = numberFormat + currentNumber;
    
        }
    }

    private static List<Credit_Note__c> filterRecords(List<Credit_Note__c> creditNotes){

        if(DLT_Constants.IS_LAMBDA_USER) return creditNotes;

        List<Credit_Note__c> filteredCreditNotes = new List<Credit_Note__c>();

        for(Credit_Note__c creditNote : creditNotes){
            if(creditNote.Credit_Note_Number__c == null){
                filteredCreditNotes.add(creditNote);
            }
        }

        return filteredCreditNotes;
    }
}