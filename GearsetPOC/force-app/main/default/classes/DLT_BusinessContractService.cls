public inherited sharing class DLT_BusinessContractService {
    public static Boolean isContinent(Business_Contract__c contract) {
        return contract?.RecordTypeId == DLT_BusinessContractConstants.CORPORATE_CONTINENT;
    }

    public static Boolean isLondon(Business_Contract__c contract) {
        return contract?.RecordTypeId == DLT_BusinessContractConstants.CORPORATE_LONDON;
    }

    public static Boolean isNCO(Business_Contract__c contract) {
        return contract?.RecordTypeId == DLT_BusinessContractConstants.CORPORATE_NCO;
    }
}