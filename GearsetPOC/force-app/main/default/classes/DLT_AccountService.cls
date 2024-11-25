public inherited sharing class DLT_AccountService {

    public static Loyalty_Integration__e createLoyaltyEventInstance(Account acc) {
        return new Loyalty_Integration__e(
            AccountRecordId__c = acc.Id,
            FirstName__c = acc.FirstName,
            LastName__c = acc.LastName,
            DeltaLoyaltyTier__c = acc.Delta_Loyalty_Tier__c,
            MembershipNumber__c = acc.DELTA_Loyalty_Member__r.MembershipNumber,
            MemberStatus__c = acc.DELTA_Loyalty_Member__r.MemberStatus,
            EnrollmentDate__c = acc.DELTA_Loyalty_Member__r.EnrollmentDate
        );
    }

    public static void fireLoyaltyEvents(List<Account> newAccounts) {
        if (newAccounts == null || newAccounts.isEmpty()) { return; }

        fireLoyaltyEvents(new Map<Id, Account>(newAccounts).keySet());
    }


    public static void fireLoyaltyEvents(List<Account> newAccounts, Map<Id,Account> oldAccountMap) {
        if(newAccounts == null || oldAccountMap == null || newAccounts.isEmpty() || oldAccountMap.isEmpty()) { return; }

        Set<Id> changedCustomerIds = new Set<Id>();
        List<Schema.FieldSetMember> TACTfieldSet = DLT_Utils.getFieldSetMembers(
            DLT_CustomerConstants.OBJECT_NAME,
            DLT_CustomerConstants.TACT_FIELD_SET_NAME
        );

        for (Account acc : newAccounts) {
            if (acc.RecordTypeId != DLT_CustomerConstants.RT_ID_PERSON_ACCOUNT) { continue; }

            for (Schema.FieldSetMember field : TACTfieldSet) {
                if (acc.get(field.getSObjectField()) != oldAccountMap.get(acc.Id).get(field.getSObjectField())) {
                    changedCustomerIds.add(acc.Id);
                    break;
                }
            }
        }

        fireLoyaltyEvents(changedCustomerIds);
    }

    public static void fireLoyaltyEvents(Set<Id> customerIds) {
        if (customerIds == null || customerIds.isEmpty()) { return; }

        List<Loyalty_Integration__e> events = new List<Loyalty_Integration__e>();

        for (Account acc : [
            SELECT Id,
                FirstName,
                LastName,
                Delta_Loyalty_Tier__c,
                DELTA_Loyalty_Member__r.MembershipNumber,
                DELTA_Loyalty_Member__r.MemberStatus,
                DELTA_Loyalty_Member__r.EnrollmentDate
            FROM Account
            WHERE Id IN :customerIds
                AND RecordTypeId = :DLT_CustomerConstants.RT_ID_PERSON_ACCOUNT
        ]) {
            events.add(createLoyaltyEventInstance(acc));
        }

        if (!events.isEmpty()) {
            EventBus.publish(events);
        }
    }
}