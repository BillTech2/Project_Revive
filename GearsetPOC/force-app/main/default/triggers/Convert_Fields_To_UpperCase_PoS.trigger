trigger Convert_Fields_To_UpperCase_PoS on PoS__c (before insert, before update) {
    for(PoS__c pos : Trigger.New) {
        System.debug('Before converting text fields to upper case = '+ pos.pos_code__c +','+ pos.pos_description__c +','+ pos.commercial_group__c +','+ pos.Tmc_Managed_Company__c);
        
        if(pos.pos_code__c != null)
            pos.pos_code__c = pos.pos_code__c.toUpperCase();
        if(pos.pos_description__c != null)
            pos.pos_description__c = pos.pos_description__c.toUpperCase();
        if(pos.commercial_group__c != null)
            pos.commercial_group__c = pos.commercial_group__c.toUpperCase();
        if(pos.Tmc_Managed_Company__c != null)
            pos.Tmc_Managed_Company__c = pos.Tmc_Managed_Company__c.toUpperCase();
        
        System.debug('After converting text fields to upper case = '+ pos.pos_code__c +','+ pos.pos_description__c +','+ pos.commercial_group__c +','+ pos.Tmc_Managed_Company__c);
    }
}