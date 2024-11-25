public inherited sharing class DLT_CaseService {

    
    private static Map<String,BusinessHours> serviceDeskHoursByName = new Map<String,BusinessHours>();
    private static Map<String,SlaProcess> caseProductivityProcessByName = new Map<String,SlaProcess>();

    public static SlaProcess selectEntitlementProcessByName(String name) {
        if (String.isBlank(name)) { return null; }

        if (!caseProductivityProcessByName.containsKey(name)) {
            List<SlaProcess> slas = [
                SELECT Id, Name
                FROM SlaProcess
                WHERE Name = :name
                    AND IsActive = true
                ORDER BY CreatedDate, VersionNumber DESC
                LIMIT 1
            ];
            caseProductivityProcessByName.put(name, !slas.isEmpty() ? slas[0] : null);
        }

        return caseProductivityProcessByName.get(name);
    }

    public static BusinessHours selectBusinessHoursByName(String name) {
        if (String.isBlank(name)) { return null; }

        if (!serviceDeskHoursByName.containsKey(name)) {
            List<BusinessHours> bhs =  [
                SELECT Id, Name
                FROM BusinessHours
                WHERE Name =: name
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            serviceDeskHoursByName.put(name, !bhs.isEmpty() ? bhs[0] : null);
        }

        return serviceDeskHoursByName.get(name);
    }

    public static List<Entitlement> selectEntitlementByCustomerIds(List<Id> customerIds) {
        if (customerIds.isEmpty()) { return new List<Entitlement>(); }

        return [
            SELECT Id, AccountId
            FROM Entitlement
            WHERE AccountId IN: customerIds
                AND Status = :DLT_CaseConstants.ENTITLMENT_STATUS_ACTIVE
        ];
    }

    public static List<Entitlement> selectEntitlementByEntitlementIds(List<Id> entitlementIds) {
        if (entitlementIds.isEmpty()) { return new List<Entitlement>(); }

        return [
            SELECT Id, StartDate, AccountId
            FROM Entitlement
            WHERE Id IN: entitlementIds
        ];
    }
}