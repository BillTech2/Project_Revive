public without sharing class DLT_CaseTriggerHandler {
    public static Boolean isDisabled = false;

    private static Id brandwatchOwnerId {
        get {
            if (brandwatchOwnerId == null) {
                brandwatchOwnerId = String.isNotBlank(DLT_Automation_Settings__c.getOrgDefaults().Case_Brandwatch_Owner_Id__c)
                    ? DLT_Automation_Settings__c.getOrgDefaults().Case_Brandwatch_Owner_Id__c
                    : UserInfo.getUserId();
            }

            return brandwatchOwnerId;
        }
        set {}
    }


    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                setInitialFieldValues(Trigger.new);
                bookingAmountFieldsInSync_insert(Trigger.New);
                rollupDisruptionsLast6Months(Trigger.new);
                rollupTicketsCarrier((Map<Id, Case>)Trigger.oldMap, Trigger.new);
                assignEntitlementToCase(Trigger.new);
                updateCaseFieldsBasedOnRelatedObjects(Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                bookingAmountFieldsInSync_update((Map<Id, Case>)Trigger.oldMap, (Map<Id, Case>)Trigger.newMap);
                updateCaseSupportEntitlementsFields(Trigger.new, Trigger.oldMap);
                rollupDisruptionsLast6Months(Trigger.new);
                rollupTicketsCarrier((Map<Id, Case>)Trigger.oldMap, Trigger.new);
                assignEntitlementToCase(Trigger.new);
                updateCaseFieldsBasedOnRelatedObjects((List<Case>)Trigger.new, (Map<Id, Case>)Trigger.oldMap);
            }
        }

        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                populateEntitlementStartDate(Trigger.newMap.keySet());
            }

            if (System.Trigger.isUpdate) {

            }
        }
    }


    private static void setInitialFieldValues(List<Case> newRecords){
        for (Case newCase : newRecords) {

            Boolean isBackdoorEmail = newCase.Origin == DLT_CaseConstants.ORIGIN_EMAIL_RED || newCase.Origin == DLT_CaseConstants.ORIGIN_EMAIL_BLUE;

            if (isBackdoorEmail){
                newCase.Initial_Reason_For_Contact__c = DLT_CaseConstants.INITIAL_REASON_FOR_CONTACT_FEEDBACK;
                newCase.Journey_Type_Product__c = DLT_CaseConstants.JOURNEY_TYPE_PRODUCT_GENERAL_QUERY;
            }

            if (newCase.Initial_Reason_For_Contact__c == DLT_CaseConstants.INITIAL_REASON_FOR_CONTACT_ROOM_BOOKING){
                newCase.Carrier__c = DLT_CaseConstants.CARRIER_RED;
            }

            if (newCase.Origin == DLT_CaseConstants.ORIGIN_BRANDWATCH) {
                newCase.OwnerId = brandwatchOwnerId;
                newCase.RecordTypeId = DLT_CaseConstants.RT_ID_NEW_STANDARD_CASE;
                newCase.Status = DLT_CaseConstants.STATUS_NEW;
                newCase.Category__c = DLT_CaseConstants.CATEGORY_SYSTEM;
                newCase.Contact_From__c = DLT_CaseConstants.CONTACT_FROM_SOCIAL_MEDIA;
                newCase.Customer_Struggle__c = DLT_CaseConstants.CUSTOMER_STRUGGLE_SYSTEM;
                newCase.Customer_Type__c = DLT_CaseConstants.CUSTOMER_TYPE_SOCIAL_MEDIA;
                newCase.Initial_Reason_For_Contact__c = DLT_CaseConstants.INITIAL_REASON_FOR_CONTACT_SOCIAL_MEDIA;
                newCase.Journey_Type_Product__c = DLT_CaseConstants.JOURNEY_TYPE_PRODUCT_GENERAL_QUERY;
                newCase.Reason_For_Contact__c = DLT_CaseConstants.REASON_FOR_CONTACT_FEEDBACK;
                newCase.Topic__c = DLT_CaseConstants.TOPIC_TRAVEL_SYSTEM;
                newCase.What_Is_The_Question__c = DLT_CaseConstants.WHAT_IS_THE_QUESTION_SYSTEM;
            }

            if (newCase.Origin == DLT_CaseConstants.ORIGIN_E4A || newCase.Subject == DLT_CaseConstants.SUBJECT_E4A) {
                newCase.RecordTypeId = DLT_CaseConstants.RT_ID_E4A_SUBSCRIBER_REQUEST;
                newCase.Origin = DLT_CaseConstants.ORIGIN_E4A;
            }

            if (newCase.Origin == DLT_CaseConstants.ORIGIN_PRM) {
                newCase.Carrier__c = DLT_CaseConstants.CARRIER_BLUE;
                newCase.Initial_Reason_For_Contact__c = DLT_CaseConstants.INITIAL_REASON_FOR_CONTACT_INFOADVICE;
                newCase.Sundry__c = DLT_CaseConstants.SUNDRY_URGENT_ASSISTANCE;
                newCase.Subject = DLT_CaseConstants.SUBJECT_PRM;
                newCase.Category__c = DLT_CaseConstants.CATEGORY_PRE_TRAVEL;
                newCase.Customer_Struggle__c = null;
                newCase.Topic__c = DLT_CaseConstants.TOPIC_URGENT_ASSISTANCE;
                newCase.What_Is_The_Question__c = DLT_CaseConstants.WHAT_IS_THE_QUESTION_PRM;
            }
        }

    }

    private static void bookingAmountFieldsInSync_insert(List<Case> casesNew) {
        for (Case newCase : casesNew) {
            Boolean isShadowFieldChanged = 
                newCase.Price_Number__c != null ||
                newCase.Deposit_Amount_Number__c != null || newCase.Total_Refund_Number__c != null ||
                newCase.Groups_Exc_Carriage_Sale_Number__c != null || newCase.Groups_Upsell_Number__c != null;

            if (isShadowFieldChanged) {
                newCase.Price__c = newCase.Price_Number__c;
                newCase.Deposit_Amount__c = newCase.Deposit_Amount_Number__c;
                newCase.Total_Refund__c = newCase.Total_Refund_Number__c;
                newCase.Groups_Value_of_Exc_Carriage_Sale__c = newCase.Groups_Exc_Carriage_Sale_Number__c;
                newCase.Groups_Value_of_Upsell__c = newCase.Groups_Upsell_Number__c;
            }
            Boolean isRealFieldChanged = 
                newCase.Price__c != null || newCase.Deposit_Amount__c != null || newCase.Total_Refund__c != null ||
                newCase.Groups_Exc_Carriage_Sale_Number__c != null || newCase.Groups_Upsell_Number__c != null;
            if (isRealFieldChanged) {
                newCase.Price_Number__c = newCase.Price__c;
                newCase.Deposit_Amount_Number__c = newCase.Deposit_Amount__c;
                newCase.Total_Refund_Number__c = newCase.Total_Refund__c;
                newCase.Groups_Exc_Carriage_Sale_Number__c = newCase.Groups_Value_of_Exc_Carriage_Sale__c;
                newCase.Groups_Upsell_Number__c = newCase.Groups_Value_of_Upsell__c;
            }
        }
    }

    private static void bookingAmountFieldsInSync_update(Map<Id, Case> casesOldMap, Map<Id, Case> casesNewMap) {
        for (Case oldCase : casesOldMap.values()) {
            Case newCase = casesNewMap.get(oldCase.Id);
            Boolean isShadowFieldChanged = 
                newCase.Price_Number__c != oldCase.Price_Number__c ||
                newCase.Deposit_Amount_Number__c != oldCase.Deposit_Amount_Number__c || 
                newCase.Total_Refund_Number__c != oldCase.Total_Refund_Number__c ||
                newCase.Groups_Exc_Carriage_Sale_Number__c != oldCase.Groups_Exc_Carriage_Sale_Number__c ||
                newCase.Groups_Upsell_Number__c != oldCase.Groups_Upsell_Number__c;
            if (isShadowFieldChanged) {
                newCase.Price__c = newCase.Price_Number__c;
                newCase.Deposit_Amount__c = newCase.Deposit_Amount_Number__c;
                newCase.Total_Refund__c = newCase.Total_Refund_Number__c;
                newCase.Groups_Value_of_Exc_Carriage_Sale__c = newCase.Groups_Exc_Carriage_Sale_Number__c;
                newCase.Groups_Value_of_Upsell__c = newCase.Groups_Upsell_Number__c;
            }
            Boolean isRealFieldChanged = 
                newCase.Price__c != oldCase.Price__c || newCase.Deposit_Amount__c != oldCase.Deposit_Amount__c ||
                newCase.Total_Refund__c != oldCase.Total_Refund__c || newCase.Groups_Value_of_Exc_Carriage_Sale__c != oldCase.Groups_Value_of_Exc_Carriage_Sale__c ||
                newCase.Groups_Value_of_Upsell__c != oldCase.Groups_Value_of_Upsell__c;
            if (isRealFieldChanged) {
                newCase.Price_Number__c = newCase.Price__c;
                newCase.Deposit_Amount_Number__c = newCase.Deposit_Amount__c;
                newCase.Total_Refund_Number__c = newCase.Total_Refund__c;
                newCase.Groups_Exc_Carriage_Sale_Number__c = newCase.Groups_Value_of_Exc_Carriage_Sale__c;
                newCase.Groups_Upsell_Number__c = newCase.Groups_Value_of_Upsell__c;
            }
        }
    }

    private static void updateCaseSupportEntitlementsFields(List<Case> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id,Case> oldCases = (Map<Id,Case>) oldRecords;

        for (Case newCase: newRecords) {
            if (oldCases.get(newCase.id).Status != newCase.Status) {
                if (newCase.Status == DLT_CaseConstants.STATUS_REOPENED) {
                    newCase.Last_Reopened__c = Datetime.now();
                } else if(newCase.Status == DLT_CaseConstants.STATUS_AWAITING_INTERNAL) {
                    newCase.Last_Awaiting_Internal__c = Datetime.now();
                } else if(newCase.Status == DLT_CaseConstants.STATUS_AWAITING_CUSTOMER){
                    newCase.Last_Awaiting_Customer__c = Datetime.now();
                }
            }
        }
    }

    private static void rollupDisruptionsLast6Months(List<Case> newRecords) {
        if (newRecords == null) { return ; }

        Map<Id, List<Case>> customerIdToCasesMap = getFilteredCustomerIdToCasesMap(newRecords);
        Map<Id, Set<Ticket__c>> customerIdToTicketsMap = getCustomerIdToTicketsMap(
            getDisruptionTickets(customerIdToCasesMap.keySet())
        );

        for (Id customerId : customerIdToCasesMap.keySet()) {
            for (Case newCase : customerIdToCasesMap.get(customerId)) {
                newCase.Disruptions_Last_6_Months__c = customerIdToTicketsMap.get(customerId)?.size();
            }
        }
    }

    private static void rollupTicketsCarrier(Map<Id, Case> oldRecords, List<Case> newRecords) {
        if (newRecords == null) { return ; }

        Set<String> pnrs = new Set<String>();
        Set<Case> cases = new Set<Case>();

        for (Case newCase : newRecords) {
            Boolean isFiltered = String.isBlank(newCase.PNR__c) 
                || newCase.Origin == DLT_CaseConstants.ORIGIN_TACT
                || oldRecords?.get(newCase.Id)?.PNR__c == newCase?.PNR__c;

            if (isFiltered) { continue; }

            pnrs.add(newCase.PNR__c);
            cases.add(newCase);
        }

        if (pnrs.isEmpty()) { return; }

        Map<String, String> pnrToCarrierMap = getPnrToCarrierMap(pnrs);

        for (Case newCase : cases) {
            newCase.Carrier__c = String.isNotBlank(pnrToCarrierMap.get(newCase.PNR__c))
                ? pnrToCarrierMap.get(newCase.PNR__c)
                : DLT_CaseConstants.CARRIER_PURPLE;
        }
    }

    private static void assignEntitlementToCase(List<Case> newRecords) {
        List<Id> customersIds = new List<Id>();
        Map<Id, Case> casesWithoutEntitlement = new Map<Id, Case>();
        Map<Id,Account> selectedCustomers = new Map<Id,Account>();
        List<Entitlement> entitlementToInsert = new List<Entitlement>();
        BusinessHours serviceDeskHours = DLT_CaseService.selectBusinessHoursByName(DLT_CaseConstants.BUSINESS_HOURS_NAME_SERVICE_DESK_HOURS);
        SlaProcess caseProductivityProcess = DLT_CaseService.selectEntitlementProcessByName(DLT_CaseConstants.ENTITLMENT_NAME_CASE_PRODUCTIVITY);

        if (serviceDeskHours == null || caseProductivityProcess == null) { return; }

        for (Case newCase: newRecords) {
            if (newCase.EntitlementId == null && newCase.AccountId != null) {
                customersIds.add(newCase.AccountId);
                casesWithoutEntitlement.put(newCase.Id, newCase);
            }
        }

        if (customersIds.isEmpty()) { return; }

        List<Entitlement> entitlments = DLT_CaseService.selectEntitlementByCustomerIds(customersIds);

        for (Entitlement activeEntitlment : entitlments) {
            for (Case newCase: newRecords) {
                if (newCase.AccountId == activeEntitlment.AccountId) {
                    newCase.EntitlementId = activeEntitlment.Id;
                    casesWithoutEntitlement.remove(newCase.Id);
                }
            }
        }

        selectedCustomers = selectCustomersById(customersIds);

        if (casesWithoutEntitlement.isEmpty()) { return; }

        for (Id newCaseId  : casesWithoutEntitlement.keySet()) {
            Entitlement newEntitlement = new Entitlement();

            newEntitlement.Name = selectedCustomers.get(casesWithoutEntitlement.get(newCaseId).AccountId).Name;
            newEntitlement.AccountId = casesWithoutEntitlement.get(newCaseId).AccountId;
            newEntitlement.Type = DLT_CaseConstants.ENTITLMENT_TYPE_DELTA_SUPPORT;
            newEntitlement.StartDate = Date.valueOf(casesWithoutEntitlement.get(newCaseId).CreatedDate);
            newEntitlement.BusinessHoursId = serviceDeskHours.id;
            newEntitlement.SlaProcessId = caseProductivityProcess.Id;

            entitlementToInsert.add(newEntitlement);
        }

        insert entitlementToInsert;

        for (Entitlement newEntitlement : entitlementToInsert) {
            for (Id newCaseId  : casesWithoutEntitlement.keySet()) {
                if (casesWithoutEntitlement.get(newCaseId).AccountId == newEntitlement.AccountId) {
                    casesWithoutEntitlement.get(newCaseId).EntitlementId = newEntitlement.Id;
                }
            }
        }
    }

    private static void populateEntitlementStartDate (Set<Id> caseRecordsIds) {
        if (!DLT_Utils.isAsyncCtx()) {
            populateEntitlementStartDateInFuture(caseRecordsIds);
            return;
        }
        List<Id> entitlementIds = new List<Id>();
        List<Case> caseRecords = [SELECT ID,EntitlementId,AccountId,CreatedDate FROM CASE WHERE ID IN :caseRecordsIds]; 

        for (Case caseRecord : caseRecords) {
            if (caseRecord.EntitlementId != null && caseRecord.AccountId != null) {
                entitlementIds.add(caseRecord.EntitlementId);
            }
        }

        List<Entitlement> entitlementsToUpdate = DLT_CaseService.selectEntitlementByEntitlementIds(entitlementIds);

        if (entitlementsToUpdate.isEmpty()) { return; }

        for (Entitlement newEntitlement : entitlementsToUpdate) {
            for (Case caseRecord : caseRecords) {
                if (caseRecord.AccountId == newEntitlement.AccountId) {
                    newEntitlement.StartDate = Date.valueOf(caseRecord.CreatedDate);
                }
            }
        }

        update entitlementsToUpdate;
    }

    @future
    private static void populateEntitlementStartDateInFuture(Set<Id> caseRecordsIds) {
        populateEntitlementStartDate(caseRecordsIds);
    }

    private static void updateCaseFieldsBasedOnRelatedObjects(List<Case> newCases){
        Set<Id> trainIds = new Set<Id>();
        Set<Id> ticketIds = new Set<Id>();

        for (Case newCase : newCases) {
            if (newCase.Train__c != null) {
                trainIds.add(newCase.Train__c);
            }
            if (newCase.TCN__c != null) {
                ticketIds.add(newCase.TCN__c);
            }
        }

        updateCaseFieldsBasedOnRelatedObjects(newCases, trainIds, ticketIds);
    }

    private static void updateCaseFieldsBasedOnRelatedObjects(List<Case> newCases, Map<Id, Case> oldCasesMap){

        List<Case> casesToUpdate = new List<Case>();
        Set<Id> trainIds = new Set<Id>();
        Set<Id> ticketIds = new Set<Id>();

        for (Case c : newCases){

            if (oldCasesMap.get(c.Id).Train__c != c.Train__c
                || oldCasesMap.get(c.Id).TCN__c != c.TCN__c){

                casesToUpdate.add(c);
                if (c.Train__c != null) trainIds.add(c.Train__c);
                if (c.TCN__c != null) ticketIds.add(c.TCN__c);

            }
        }

        updateCaseFieldsBasedOnRelatedObjects(casesToUpdate, trainIds, ticketIds);
    }

    private static void updateCaseFieldsBasedOnRelatedObjects(List<Case> newCases, Set<Id> trainIds, Set<Id> ticketIds){

        Map<Id, Train__c> trainsMap = new Map<Id,Train__c>();
        Map<Id, Ticket__c> ticketsMap = new Map<Id,Ticket__c>();

        if (!trainIds.isEmpty()){
            trainsMap = new Map<Id,Train__c>([
                SELECT Id, Global_Delay_Reason__c, Departure_Date__c, Train_Number__c, Delay_in_Minutes__c, 
                    Destination_Voucher__c, From__c, From__r.Name, To__c, To__r.Name, Name
                FROM Train__c 
                WHERE Id IN : trainIds
            ]);
        }

        if (!ticketIds.isEmpty()){
            ticketsMap = new Map<Id,Ticket__c>([
                SELECT Id, Train__r.Global_Delay_Reason__c, Departure_Date__c, Train__r.Train_Number__c, Origin__c, Train__c,
                    UIC_Code__c, Train__r.Delay_in_Minutes__c, Train__r.Destination_Voucher__c, Train__r.To__c, Train__r.To__r.Name, Train__r.Name
                FROM Ticket__c 
                WHERE Id IN : ticketIds
            ]);
        }

        Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints = generateTrainMapWithPassingPoints(ticketsMap.values());

        updateTCNTrainRelatedFields(newCases, ticketsMap, trainsMap, trainWithPassingPoints);
    }

    private static void updateTCNTrainRelatedFields(List<Case> cases, Map<Id,Ticket__c> tickets, Map<Id,Train__c> trains, Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints){

        for (Case c : cases){
            if (c.TCN__c != null && tickets.containsKey(c.TCN__c)){

                Ticket__c t = tickets.get(c.TCN__c);

                c.Delay_Reason__c = t.Train__r.Global_Delay_Reason__c;
                c.Departure_Date__c = t.Departure_Date__c;
                c.Delayed_Train_Number__c = t.Train__r.Train_Number__c;
                c.TCN_Train_Origin__c = t.Origin__c;
                c.Train_Details__c = t.Train__r.Name;
                c.Train__c = c.Train__c == null ? t.Train__c : c.Train__c;

                if (trainWithPassingPoints.containsKey(t.Train__c) && trainWithPassingPoints.get(t.Train__c).containsKey(t.UIC_Code__c)){

                    Passing_Point__c p = trainWithPassingPoints.get(t.Train__c).get(t.UIC_Code__c);

                    try {
                        c.Delay_Duration_Mins__c = String.isNotBlank(p.PassingPoint_Departure_Delay__c)
                            ? Decimal.valueOf(p.PassingPoint_Departure_Delay__c.replaceAll('(?!\\-)(?!\\.)\\D', ''))
                            : null;
                    }
                    catch(TypeException e) {
                        throw new CustomException(System.Label.Passing_Point_Delay_is_not_Decimal);
                    }
                    c.TCN_Train_Percentage__c = String.valueOf(p.PassingPoint_Voucher__c);
                    c.DLT_Destination__c = p.PassingPoint_Station_Name__r.Name;
                }
                else {
                    c.Delay_Duration_Mins__c = t.Train__r.Delay_in_Minutes__c;
                    c.TCN_Train_Percentage__c = String.valueOf(t.Train__r.Destination_Voucher__c);
                    c.DLT_Destination__c = t.Train__r.To__r.Name;
                }
            } else if (c.TCN__c == null && c.Train__c != null && trains.containsKey(c.Train__c)){

                Train__c tr = trains.get(c.Train__c);

                c.Delay_Reason__c = tr.Global_Delay_Reason__c;
                c.Departure_Date__c = tr.Departure_Date__c;
                c.Delayed_Train_Number__c = tr.Train_Number__c;
                c.Delay_Duration_Mins__c = tr.Delay_in_Minutes__c;
                c.TCN_Train_Percentage__c = String.valueOf(tr.Destination_Voucher__c);
                c.TCN_Train_Origin__c = tr.From__r.Name;
                c.DLT_Destination__c = tr.To__r.Name;
                c.Train_Details__c = tr.Name;
                c.Train__c = c.Train__c == null ? tr.Id : c.Train__c;

            } else if (c.TCN__c == null && c.Train__c == null){
                c.Delay_Reason__c = null;
                c.Delayed_Train_Number__c = null;
                c.Delay_Duration_Mins__c = null;
                c.TCN_Train_Percentage__c = null;
                c.TCN_Train_Origin__c = null;
                c.Train_Details__c = null;
            }
        }

    }


    // ========================= HELPERS =========================

    private static Map<String, String> getPnrToCarrierMap(Set<String> pnrs) {
        Map<String, String> pnrToCarrierMap = new Map<String, String>();
        Map<String, Set<String>> pnrToCarriersMap = new Map<String, Set<String>>();

        if (pnrs.isEmpty()) { return pnrToCarrierMap; }

        for (Ticket__c ticket : [
            SELECT PNR__c, Carrier__c
            FROM Ticket__c
            WHERE PNR__c IN :pnrs
                AND Departure_Date__c > :DLT_CaseConstants.DATE_LAST_6_MONTH
        ]) {
            if (!pnrToCarriersMap.containsKey(ticket.PNR__c)) {
                pnrToCarriersMap.put(ticket.PNR__c, new Set<String>());
            }

            pnrToCarriersMap.get(ticket.PNR__c).add(ticket.Carrier__c);
        }

        for (String pnr : pnrToCarriersMap.keySet()) {
            String carrier = pnrToCarriersMap.get(pnr).containsAll(DLT_CaseConstants.BOTH_CARRIERS)
                ? DLT_CaseConstants.CARRIER_PURPLE
                : pnrToCarriersMap.get(pnr).contains(DLT_CaseConstants.CARRIER_BLUE)
                    ? DLT_CaseConstants.CARRIER_BLUE
                    : pnrToCarriersMap.get(pnr).contains(DLT_CaseConstants.CARRIER_RED)
                        ? DLT_CaseConstants.CARRIER_RED
                        : DLT_CaseConstants.CARRIER_PURPLE;

            pnrToCarrierMap.put(pnr, carrier);
        }

        return pnrToCarrierMap;
    }

    private static Map<Id, List<Case>> getFilteredCustomerIdToCasesMap(List<Case> newRecords) {
        Map<Id, List<Case>> customerIdToCasesMap = new Map<Id, List<Case>>();
        for (Case newCase : newRecords) {
            if (newCase.AccountId == null || newCase.Departure_Date__c < DLT_CaseConstants.DATE_LAST_6_MONTH) {
                continue;
            }
            if (customerIdToCasesMap.get(newCase.AccountId) == null) {
                customerIdToCasesMap.put(newCase.AccountId, new List<Case>());
            }
            customerIdToCasesMap.get(newCase.AccountId).add(newCase);
        }
        return customerIdToCasesMap;
    }

    private static Map<Id, Set<Ticket__c>> getCustomerIdToTicketsMap(Set<Ticket__c> disruptionTickets) {
        Map<Id, Set<Ticket__c>> customerIdToTicketsMap = new Map<Id, Set<Ticket__c>>();

        for (Ticket__c disruptionTicket : disruptionTickets) {
            if (customerIdToTicketsMap.get(disruptionTicket.Booker__c) == null) {
                customerIdToTicketsMap.put(disruptionTicket.Booker__c, new Set<Ticket__c>());
            }

            customerIdToTicketsMap.get(disruptionTicket.Booker__c).add(disruptionTicket);
        }

        return customerIdToTicketsMap;
    }

    private static Map<Id,Map<String,Passing_Point__c>> generateTrainMapWithPassingPoints(List<Ticket__c> tickList){
        Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints = new Map<Id,Map<String,Passing_Point__c>>();

        if (tickList.isEmpty()) { return trainWithPassingPoints; }

        Set<String> uicCodeSet = CompApp_Utils.getFieldValueMap2list(tickList, 'UIC_Code__c').keySet();
        Set<String> trainSet = CompApp_Utils.getFieldValueMap2list(tickList, 'Train__c').keySet();

        uicCodeSet.remove(null);
        uicCodeSet.remove('');
        trainSet.remove(null);
        trainSet.remove('');

        if (uicCodeSet.isEmpty() || trainSet.isEmpty()) { return trainWithPassingPoints; }

        for (Passing_Point__c passingPoint : [
            SELECT Id, UIC_Code__c, Train__c, PassingPoint_Station_Name__r.Name, PassingPoint_Departure_Delay__c, PassingPoint_Voucher__c
            FROM Passing_Point__c
            WHERE UIC_Code__c IN :uicCodeSet
                AND Train__c IN :trainSet
                AND UIC_Code__c != null
        ]){
            if (!trainWithPassingPoints.containsKey(passingPoint.Train__c)){
                trainWithPassingPoints.put(passingPoint.Train__c, new Map<String,Passing_Point__c>());
            }

            trainWithPassingPoints.get(passingPoint.Train__c).put(passingPoint.UIC_Code__c,passingPoint);
        }

        return trainWithPassingPoints;
    }

    private static Set<Ticket__c> getDisruptionTickets(Set<Id> customerIds) {
        if (customerIds.isEmpty()) { return new Set<Ticket__c>(); }

        return new Set<Ticket__c>([
            SELECT Id, Booker__c
            FROM Ticket__c
            WHERE Booker__c IN :customerIds
                AND Departure_Date__c = LAST_N_DAYS:180
                AND (Compensation_Ticket__c != NULL
                    OR Train__r.Delay_Actor__c != NULL
                    OR Train__r.Delay_in_Minutes__c > :DLT_TrainConstants.MAX_DELAY_IN_MINUTES
                    OR Train__r.Cancelled__c = true
                )
        ]);
    }


    private static Map<Id,Account> selectCustomersById(List<Id> customerIds) {
        if (customerIds.isEmpty()) { return new Map<Id,Account>(); }

        return new Map<Id,Account>([
            SELECT Id, Name
            FROM Account
            WHERE Id IN: customerIds
        ]);
    }

}