public inherited sharing class DLT_CaseService {

    private static Map<String,BusinessHours> serviceDeskHoursByName = new Map<String,BusinessHours>();
    private static Map<String,SlaProcess> caseProductivityProcessByName = new Map<String,SlaProcess>();

    public static List<Case> filterCasesE4A(List<Case> cases) {
        List<Case> e4aCases = new List<Case>();

        for (Case c : cases) {
            if (c.RecordTypeId == DLT_CaseConstants.RT_ID_E4A_SUBSCRIBER_REQUEST
                && c.SuppliedEmail != null
            ) {
                e4aCases.add(c);
            }
        }

        return e4aCases;
    }

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

    public static void handleLogicForE4A(List<Case> cases) {
        if (cases == null || cases.isEmpty()) { return; }

        Set<Case> e4aCases = new Set<Case>(filterCasesE4A(cases));
        Set<Case> e4aCasesWithNewCustomers = new Set<Case>();
        Map<String, Case> customerEmailToCase = new Map<String, Case>();
        Map<String, Account> customerEmailToCustomer = new Map<String, Account>();

        if (e4aCases.isEmpty()) { return; }

        // prepare the data
        for (Case c : e4aCases) {
            customerEmailToCase.put(c.SuppliedEmail, c);
        }

        // main logic
        for (String email : customerEmailToCase.keySet()) {
            Case e4aCase = customerEmailToCase.get(email);

            Account customerForUpsert = new Account(
                RecordtypeId = DLT_CustomerConstants.RT_ID_PERSON_ACCOUNT,
                PersonEmail = email,
                Customer_Email__c = email,
                Customer_Email__pc = email,
                FirstName = e4aCase.First_Name__c,
                LastName = e4aCase.Last_Name__c,
                Country_B__c = e4aCase.Country__c,
                Preferred_Language__pc = e4aCase.Preferred_Language__c,
                Company_Registered_Name__c = e4aCase.SuppliedCompany,
                E4A_Customer_Type__c = e4aCase.E4A_Customer_Type__c,
                Other_Customer_Type__c = e4aCase.Other_Customer_Type__c,
                Indirect_Sales_Topics__c = e4aCase.Receive_Communications_on__c
            );

            Boolean isNewCustomer        = e4aCase.New_Customer__c == true;
            Boolean isUnsubscribeRequest = e4aCase.Subject == DLT_CaseConstants.SUBJECT_E4A_UNSUBSCRIBE;

            if (isNewCustomer) {
                customerForUpsert.E4A_Newsletter_Opt_In__c = true;
                customerForUpsert.E4A_Subscriber_Status__c = DLT_CustomerConstants.E4A_SUBSCRIBER_STATUS_APPROVED;

                e4aCasesWithNewCustomers.add(e4aCase);
            } else if (isUnsubscribeRequest) {
                customerForUpsert = new Account(
                    Customer_Email__c = email,
                    E4A_Subscriber_Status__c = DLT_CustomerConstants.E4A_SUBSCRIBER_STATUS_OPTED_OUT,
                    E4A_Opt_Out_Reason__c = e4aCase.E4A_Opt_Out_Reason__c,
                    E4A_Opt_Out_Other_Reason__c = e4aCase.E4A_Opt_Out_Other_Reason__c
                );
            }

            customerEmailToCustomer.put(email, customerForUpsert);
        }

        if (!customerEmailToCustomer.isEmpty()) {
            upsert customerEmailToCustomer.values() Customer_Email__c;
        }

        if (!e4aCasesWithNewCustomers.isEmpty()) {
            sendWelcomeEmailsE4A(e4aCasesWithNewCustomers);
        }

    }

    // HELPERS
    private static void sendWelcomeEmailsE4A(Set<Case> e4aCasesWithNewCustomers) {
        OrgWideEmailAddress owea = new OrgWideEmailAddress();

        Map<String, String> casePrefLangToTemplateDevName = new Map<String, String>{
            DLT_CaseConstants.PREF_LANG_EN => DLT_CaseConstants.EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_EN,
            DLT_CaseConstants.PREF_LANG_DE => DLT_CaseConstants.EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_DE,
            DLT_CaseConstants.PREF_LANG_FR => DLT_CaseConstants.EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_FR,
            DLT_CaseConstants.PREF_LANG_NL => DLT_CaseConstants.EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_NL,
            null => DLT_CaseConstants.EMAIL_TEMPLATE_DEVNAME_E4A_WELCOME_EN
        };

        Map<String, Id> templateDevNameToTemplateId = new Map<String, Id>();

        for (EmailTemplate et : [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName IN :casePrefLangToTemplateDevName.values()
        ]) {
            templateDevNameToTemplateId.put(et.DeveloperName, et.Id);
        }

        if (templateDevNameToTemplateId.isEmpty()) { return; }

        if(!Test.isRunningTest()){
            owea = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = :DLT_Settings__c.getInstance().Eurostar_for_Agents_OrgWideEmail_Name__c
                LIMIT 1
            ];
        }

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for (case c : e4aCasesWithNewCustomers) {
            if (c.ContactId == null) { continue; }

            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();

            emailMessage.setOrgWideEmailAddressId(owea.Id);
            emailMessage.setTargetObjectId(c.ContactId);
            emailMessage.setWhatId(c.Id);
            emailMessage.setTemplateId(
                templateDevNameToTemplateId.get(casePrefLangToTemplateDevName.get(c.Preferred_Language__c))
            );

            emailMessages.add(emailMessage);
        }

        if (!Test.isRunningTest()) { Messaging.sendEmail(emailMessages); }
    }
}