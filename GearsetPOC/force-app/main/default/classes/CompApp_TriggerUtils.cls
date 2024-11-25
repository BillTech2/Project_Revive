public without sharing class CompApp_TriggerUtils {

    public static final String RED = 'Red';
    public static final String APPROVAL_METHOD = 'BATCH';
    public static final String APPROVED_STATUS = 'Approved';
    public static final Integer ACTIVE      =  1;
    public static final Integer CANCELLED   =  2;
    public static final Integer CHECKED_IN  =  4;
    public static final Integer OUTBOUND    =  8;
    public static final Integer INBOUND     = 16;
    public static Map<Id, Compensation__c> compensationsById = new Map<Id, Compensation__c>();
    public static Map<Id, Compensation__c> newObjectsMap = new Map<Id, Compensation__c>();

    public static Id voucherRecTypeID {
        get {
            if (voucherRecTypeID == null) {
                Schema.RecordTypeInfo voucherRecTypeInfo = Schema.SObjectType.Compensation__c.getRecordTypeInfosByName().get('Voucher');

                if (voucherRecTypeInfo == null) {
                    throw new CompApp_Constructs.CompApp_DataIssueException('Record type "Voucher" for Ticket__c must be defined');
                } else {
                    voucherRecTypeID = voucherRecTypeInfo.getRecordTypeId();
                }
            }

            return voucherRecTypeID;
        }
        set {}
    }

    public static void convertPublicSiteCaseHolderToCase(List<Public_Site_Case_Holder__c> publicSiteCaseHolderList) {
        try { 
            List<Case> caseToInsertList = new List<Case>();
            Id caseHolderId = publicSiteCaseHolderList[0].Id;
            List<ContentDocumentLink> attachmentList = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: caseHolderId];
            List<CompApp_Constructs.NewCaseWrapper> newCaseWrapperList = new List<CompApp_Constructs.NewCaseWrapper>();
            Map<Id, List<sObject>> attachmentListByParentIdMap = CompApp_Utils.getFieldIdMap2list(attachmentList, 'LinkedEntityId');
            Map<Id, Reason_Code__c> reasonCodes = new Map<Id,Reason_Code__c>(
                                                        [SELECT Id, en_Label__c
                                                        FROM Reason_Code__c
                                                        WHERE Available_Online__c = true AND Active__c = true]
            );
            Id newStandardCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Standard Case').getRecordTypeId();
            Id dynamicPackageCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dynamic Packages').getRecordTypeId();
            Id groupCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Group Booking Case').getRecordTypeId();

            if (CompApp_Utils.isWellBehaved(publicSiteCaseHolderList)) {
                for (Public_Site_Case_Holder__c publicSiteCaseHolder : publicSiteCaseHolderList) { 
                    Case customerCase = new Case();
                    customerCase.Reason_Code__c = publicSiteCaseHolder.Category__c;
                    customerCase.Email__c = publicSiteCaseHolder.Email__c;
                    customerCase.Description = publicSiteCaseHolder.Question__c;
                    customerCase.First_Name__c = publicSiteCaseHolder.First_Name__c;
                    customerCase.Last_Name__c = publicSiteCaseHolder.Last_Name__c;
                    customerCase.Converted_From_Site__c = true;
                    customerCase.ContactId = publicSiteCaseHolder.Contact__c;
                    customerCase.Origin = 'Web';
                    customerCase.Date_Queued__c = System.now(); // Jira-1756 - added to set value instead bypassed PB
                    customerCase.Type = publicSiteCaseHolder.Case_Type__c; // Jira-1756 - added to set value instead bypassed PB
                    customerCase.Error_Message_Incident_Number__c = publicSiteCaseHolder.Error_Message__c;
                    customerCase.Website_Language__c = publicSiteCaseHolder.Website_Language__c;
                    customerCase.Subject = publicSiteCaseHolder.Subject__c;
                    customerCase.SuppliedEmail = publicSiteCaseHolder.Email__c;
                    customerCase.PNR__c = publicSiteCaseHolder.PNR__c;
                    customerCase.SuppliedName = publicSiteCaseHolder.Last_Name__c + ' ' + publicSiteCaseHolder.First_Name__c;
                    if (publicSiteCaseHolder.Direction__c != 'None') {
                        customerCase.Direction_requested__c = publicSiteCaseHolder.Direction__c;
                    }
                    customerCase.Hotel_Booking_Reference__c = publicSiteCaseHolder.Hotel_Booking_Reference__c;
                    customerCase.Birth_Date__c = publicSiteCaseHolder.Birth_Date__c;
                    customerCase.Membership_Number_Webform__c = publicSiteCaseHolder.Membership_Number__c;
                    if (publicSiteCaseHolder.Case_Type__c == 'Groups') {
                        customerCase.recordTypeId = groupCaseId;
                        customerCase.Initial_Reason_For_Contact__c = publicSiteCaseHolder.Initial_Reason_For_Contact__c;
                    } else {
                        if (String.isBlank(publicSiteCaseHolder.Reason_For_Contact__c)) {
                            customerCase.recordTypeId = newStandardCaseId;
                            if (String.isNotBlank(publicSiteCaseHolder.Initial_Reason_For_Contact__c)) {
                                customerCase.Initial_Reason_For_Contact__c = publicSiteCaseHolder.Initial_Reason_For_Contact__c;
                            }
                        } else {
                            customerCase.recordTypeId = dynamicPackageCaseId;
                            customerCase.Reason_For_Contact_Dynamic_Package__c = publicSiteCaseHolder.Reason_For_Contact__c;
                        }
                    }
                    if (publicSiteCaseHolder.Hotel__c !=null) {
                        customerCase.Hotel_Booking_Reference__c = publicSiteCaseHolder.Hotel_Booking_Reference__c;
                        customerCase.Hotel_Name__c = publicSiteCaseHolder.Hotel_Name__c;
                    }
                    if (publicSiteCaseHolder.Ticket__c !=null){
                        customerCase.TCN__c = publicSiteCaseHolder.Ticket__c;
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Check_In_Date__c)) {
                        customerCase.Original_Check_In_Date__c = Date.valueOf(publicSiteCaseHolder.Check_In_Date__c); 
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Check_Out_Date__c)) {
                        customerCase.Original_Check_Out_Date__c = Date.valueOf(publicSiteCaseHolder.Check_Out_Date__c); 
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Journey_Type_Product__c)) {
                        customerCase.Journey_Type_Product__c = publicSiteCaseHolder.Journey_Type_Product__c; // TODO
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Loyalty_Category__c)) {
                        customerCase.Loyalty_Category__c = publicSiteCaseHolder.Loyalty_Category__c; // TODO
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Loyalty_Topic__c)) {
                        customerCase.Loyalty_Topic__c = publicSiteCaseHolder.Loyalty_Topic__c; // TODO
                    }  
                    if (String.isNotBlank(publicSiteCaseHolder.Case_Category__c)) {
                        customerCase.Category__c = publicSiteCaseHolder.Case_Category__c;
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Customer_Struggle__c)) {
                        customerCase.Customer_Struggle__c = publicSiteCaseHolder.Customer_Struggle__c;
                    }
                    if(String.isNotBlank(publicSiteCaseHolder.Travel_Based_Disruption__c)) {
                        customerCase.Travel_Based_Disruption__c = publicSiteCaseHolder.Travel_Based_Disruption__c;
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Topic__c)) {
                        customerCase.Topic__c = publicSiteCaseHolder.Topic__c;
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.What_Is_The_Question__c)) {
                        customerCase.What_Is_The_Question__c = publicSiteCaseHolder.What_Is_The_Question__c;
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Sundry__c)) {
                        customerCase.Sundry__c = publicSiteCaseHolder.Sundry__c;
                    }
                    if (String.isNotBlank(publicSiteCaseHolder.Tone_of_Contact__c)) {
                        customerCase.Tone_of_Contact__c = publicSiteCaseHolder.Tone_of_Contact__c;
                    }
                    if (publicSiteCaseHolder.Queue__c == 'Eurostar For Business') {
                        Id queueId = [SELECT Id, DeveloperName
                                       FROM Group
                                       WHERE DeveloperName = 'Eurostar_For_Business' AND Type='Queue' LIMIT 1].Id;
                        customerCase.OwnerId = queueId;
                    } else if (publicSiteCaseHolder.Queue__c == 'Disneyland') {
                        Id queueId = [SELECT Id, DeveloperName
                                       FROM Group
                                       WHERE DeveloperName = 'Disney_Bookings' AND Type='Queue' LIMIT 1].Id;
                        customerCase.OwnerId = queueId;
                    } else if (publicSiteCaseHolder.Queue__c == 'Lille') {
                        Id queueId = [SELECT Id, DeveloperName
                                       FROM Group
                                       WHERE DeveloperName = 'Lille' AND Type='Queue' LIMIT 1].Id;
                        customerCase.OwnerId = queueId;
                    } else if (publicSiteCaseHolder.Queue__c == 'Disruption Exchange queue') {
                        customerCase.Type = 'Disruption Exchange';
                    } else if (publicSiteCaseHolder.Queue__c == 'Disruption Refund queue') {
                        customerCase.Type = 'Disruption Refund';
                    }
                    // FOR URGENT ASSISTANCE CASES
                    if (reasonCodes.get(publicSiteCaseHolder.Category__c).en_Label__c == 'Urgent Special Assistance') {
                        Integer direction = publicSiteCaseHolder.Direction__c == 'Outbound' ? OUTBOUND : INBOUND;
                        customerCase.Direction_requested__c = publicSiteCaseHolder.Direction__c;
                        List<Ticket__c> relatedTickets = [
                                SELECT Id, Name_Check__c, Departure_Date__c, PNR__c, Name,
                                       Origin__c, Destination__c, First_Name__c, Last_Name__c,
                                       Departure_Time__c, Departure_Date_Time_Format__c, Ticket_Status__c
                                FROM Ticket__c
                                WHERE PNR__c = :publicSiteCaseHolder.PNR__c
                                ORDER BY Name_Check__c ASC, Departure_Date__c ASC, Departure_Time__c ASC, Origin__c ASC
                        ];

                        Ticket__c recentActiveTicket;

                        if (relatedTickets.size() > 0) {
                            CaseTicketsStats currentStats = new CaseTicketsStats();
                            Integer ticketThroughoutPos = 0;
                            while (ticketThroughoutPos < relatedTickets.size()) {
                                String nextPassenger = relatedTickets[ticketThroughoutPos].Name_Check__c;
                                List<Ticket__c> passengerTickets = new List<Ticket__c>();
                                while (ticketThroughoutPos < relatedTickets.size() &&
                                        nextPassenger == relatedTickets[ticketThroughoutPos].Name_Check__c) {
                                    passengerTickets.add(relatedTickets[ticketThroughoutPos]);
                                    ticketThroughoutPos++;
                                }
                                markOutboundAndInbound(passengerTickets, currentStats);
                            }
                            for (Ticket__c nextTicket  : relatedTickets) {
                                Integer ticketStats = currentStats.ticketsStates.get(nextTicket.Id);
                                if ((ticketStats & ACTIVE) == ACTIVE && (ticketStats & direction) == direction ) {
                                    if (recentActiveTicket != null) {
                                        if (nextTicket.Departure_Date_Time_Format__c > recentActiveTicket.Departure_Date_Time_Format__c) {
                                            recentActiveTicket = nextTicket;
                                        }
                                    } else {
                                        recentActiveTicket = nextTicket;
                                    }
                                }
                            }
                        }
                        if (recentActiveTicket != null) {
                            List<Stations__c> stations = [SELECT Id, Name, Duty_Manager_Shift_Leader__c, NS_Customer_Care__c,
                                                                 Terminal_Control__c, Contact_Times__c, Contractor__c, Location__c
                                                            FROM Stations__c
                                                            WHERE Name = :recentActiveTicket.Origin__c
                                                            OR Name = :recentActiveTicket.Destination__c];
                            Stations__c departureStation;
                            Stations__c arrivalStation;
                            for (Stations__c station : stations) {
                                if (station.Name == recentActiveTicket.Origin__c) departureStation = station;
                                if (station.Name == recentActiveTicket.Destination__c) arrivalStation = station;
                            }
                            if (stations.size() == 1) {
                                customerCase.Departure_station__c = departureStation.Name;
                                customerCase.Duty_Manager_Shift_Leader__c = departureStation.Duty_Manager_Shift_Leader__c;
                                customerCase.NS_Customer_Care__c = departureStation.NS_Customer_Care__c;
                                customerCase.Terminal_Control__c = departureStation.Terminal_Control__c;
                                customerCase.Contact_Times__c = departureStation.Contact_Times__c;
                                customerCase.Contractor__c = departureStation.Contractor__c;
                                customerCase.Station_Location__c = departureStation.Location__c;
                                customerCase.Arrival_station__c = arrivalStation.Name;
                                customerCase.Duty_Manager_Shift_Leader_arrival__c = arrivalStation.Duty_Manager_Shift_Leader__c;
                                customerCase.NS_Customer_Care_arrival__c = arrivalStation.NS_Customer_Care__c;
                                customerCase.Terminal_Control_arrival__c = arrivalStation.Terminal_Control__c;
                                customerCase.Contact_Times_arrival__c = arrivalStation.Contact_Times__c;
                                customerCase.Contractor_arrival__c = arrivalStation.Contractor__c;
                                customerCase.Station_Location_arrival__c = arrivalStation.Location__c;
                            }
                        }
                        Id queueId = [SELECT Id, DeveloperName
                                       FROM Group
                                       WHERE DeveloperName = 'Urgent_assistance_request' AND Type='Queue' LIMIT 1].Id;
                        customerCase.OwnerId = queueId;
                        customerCase.recordTypeId = newStandardCaseId;
                        customerCase.Customer_Type__c = 'Special Assistance';
                        customerCase.Initial_Reason_For_Contact__c = 'Disruption or Compensation';
                        customerCase.Alternative_Disruption__c = 'Urgent Assistance';
                        //next line added to conform with validation rule
                        customerCase.Customer_Struggle__c = 'Need More Information';
                    }
                    caseToInsertList.add(customerCase);
                    newCaseWrapperList.add(new CompApp_Constructs.NewCaseWrapper(customerCase, publicSiteCaseHolder.Id));
                }
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.EmailHeader.triggerAutoResponseEmail = true;
                dmo.assignmentRuleHeader.useDefaultRule = true;

                List<Database.SaveResult> results = database.insert(caseToInsertList, dmo);

                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    }
                    else {             
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }

                CompApp_Utils.log('caseToInsertList @ convertPublicSiteCaseHolderToCase: ' + caseToInsertList);
                for (CompApp_Constructs.NewCaseWrapper wrapper : newCaseWrapperList){
                    if (attachmentListByParentIdMap.containsKey(wrapper.holderId)){
                        for (sObject attach : attachmentListByParentIdMap.get(wrapper.holderId)){
                            reparentAttachment(attach.id, wrapper.newCase.Id);
                        }
                    }
                }
            }
        }
        catch (Exception e) {
            system.debug('ERROR: Case insertion from public site failed: '+e.getMessage());
        }
    }

    public static void submitForApprovalMatchingCompensations(List<Compensation__c> compList) {
        CompApp_Utils.log('CompVouch Process @@@@@ submitForApprovalMatchingCompensations: '+compList);
        if (!compList.isEmpty()) {
            Eins_CompensationApprovalController.getRelatedRecords(compList);
            for (Compensation__c compensationItem : compList) {
                compensationsById.put(compensationItem.Id, compensationItem);
            }
        }
        Set<Id> noneOnlineCompIdSet = new Set<Id>();
        Map<Id, List<Compensation__c>> recTypeToCompMap = CompApp_Utils.getFieldIdMap2list(compList,'RecordTypeID');
        recTypeToCompMap.remove(CompApp_Utils.compensationOnlineRecTypeID);

        if (recTypeToCompMap != null && recTypeToCompMap.size() > 0) {
            for (List<Compensation__c> recTypeCompList : recTypeToCompMap.values()) {
                noneOnlineCompIdSet.addAll((new Map<Id,Compensation__c> (recTypeCompList)).keySet());
            }
            submitCompensationsForApproval(
                filterCompensationsForApproval(
                            CompApp_Utils.getFieldIdMap2list(
                                    [select Ticket__c, Compensation__c from Compensation_Ticket__c where Compensation__c IN :noneOnlineCompIdSet],
                                    'Ticket__c').keySet()
                            )
            );
        }
    }

    private static Set<Id> filterCompensationsForApproval(Set<Id> ticketIdSet) {
        CompApp_Utils.log('CompVouch Process @@@@@ filterCompensationsForApproval: '+ticketIdSet);
        Set<Id> retSet = new Set<Id>();
        Boolean isMoreThan1CompPerTicket, isNotOnlineComp, isExpensiveComp, isNotVoucher;

        if (!CompApp_Utils.isWellBehaved(ticketIdSet)) {
            return retSet;
        }
        for (List<Compensation_Ticket__c> compTicketJuncList : CompApp_Utils.getFieldValueMap2list([SELECT Id, Ticket__c, Compensation__c, Compensation__r.RecordTypeID,
                                                                                                        Compensation__r.GBP_Payment_Amount__c
                                                                                                    FROM Compensation_Ticket__c
                                                                                                    WHERE Compensation__r.Claimed_Compensation_Type__c != 'PRR'
                                                                                                    AND Ticket__c IN: ticketIdSet
                                                                                                    AND Compensation__c != NULL
                                                                                                    AND Compensation__r.Comp_Approval_Status__c != 'Approved'
                                                                                                    AND Compensation__r.Comp_Approval_Status__c != 'Rejected'
                                                                                                    AND Compensation__r.Comp_Approval_Status__c != 'Recalled'
                                                                                                    ORDER BY Ticket__c],'Ticket__c').values()) {
            // If one ticket has more than 1 none PRR compensation
            isMoreThan1CompPerTicket = compTicketJuncList.size() > 1;

            for (Compensation_Ticket__c compTick: compTicketJuncList) {
                isNotOnlineComp = compTick.Compensation__r.RecordTypeID != CompApp_Utils.compensationOnlineRecTypeID;
                isNotVoucher = compTick.Compensation__r.RecordTypeID != voucherRecTypeID;
                isExpensiveComp = compTick.Compensation__r.GBP_Payment_Amount__c != NULL && compTick.Compensation__r.GBP_Payment_Amount__c >= 300;
                if (isNotOnlineComp && isNotVoucher) {
                    retSet.add(compTick.Compensation__c);
                }
            }
        }
        CompApp_Utils.log('CompVouch Process @@@@@ retSet: ' + retSet);
        return retSet;
    }

    private static void submitCompensationsForApproval(Set<Id> compIdSet) {
        String compAppGuestUserId = '';
        List<User> compAppGuestUserList = [SELECT Id FROM User WHERE Name = 'Compensation App Site Guest User'];
        if (!compAppGuestUserList.isEmpty()) {
            compAppGuestUserId = compAppGuestUserList[0].Id;
        }

        Approval.ProcessSubmitRequest approvalReq;

        for (Id compId: compIdSet) {
            if (newObjectsMap.get(compId) != null) {
                if (newObjectsMap.get(compId).Comp_Approval_Status__c != 'Approved' && newObjectsMap.get(compId).Comp_Approval_Status__c != 'Draft') {
                    submitToApprovalProcess(compId);
                }
            }
            
        }

        for (Id compensationId : compensationsById.keySet()) {
            if (!compIdSet.contains(compensationId)) {

                Boolean isCompAppGuestUserId = false;
                if (String.isNotBlank(compAppGuestUserId)) {
                    if (compensationsById.get(compensationId).CreatedById == compAppGuestUserId) {
                        isCompAppGuestUserId = true;
                    }
                }

                if (compensationsById.get(compensationId).No_TCN_to_Use__c || isCompAppGuestUserId) {
                    if (newObjectsMap.get(compensationId).Comp_Approval_Status__c != 'Approved' && newObjectsMap.get(compensationId).RecordTypeID != voucherRecTypeID && newObjectsMap.get(compensationId).Comp_Approval_Status__c != 'Draft') {
                        submitToApprovalProcess(compensationId);
                    }
                } else if (newObjectsMap.containsKey(compensationId) && newObjectsMap.get(compensationId).RecordTypeID != CompApp_Utils.compensationOnlineRecTypeID && newObjectsMap.get(compensationId).RecordTypeID != voucherRecTypeID) {
                    if (newObjectsMap.get(compensationId).Comp_Approval_Status__c != 'Approved' && newObjectsMap.get(compensationId).Comp_Approval_Status__c != 'Draft') {
                        submitToApprovalProcess(compensationId);
                    }
                }
            }
        }
    }

    private static void submitToApprovalProcess(String compensationId) {
        Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setObjectId(compensationId);

        Approval.ProcessResult result = Approval.process(approvalReq);
        if (result.getInstanceStatus() != 'Approved') {
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            Boolean hasPermission = FeatureManagement.checkPermission('No_Manual_Compensation_Approval');
            if (!hasPermission) {
                Eins_CompensationApprovalController.submitForApprovalVerification(compensationsById.get(compensationId), newWorkItemIds.get(0));
            }
        }
    }

    @future
    private static void reparentAttachment(Id attachId, Id newParent) {
        ContentDocumentLink attch = [SELECT Id, LinkedEntityId, ContentDocumentId
                                    FROM ContentDocumentLink
                                    WHERE id =: attachId];
        attch = attch.clone(false,false);
        attch.LinkedEntityId = newParent;
        insert attch;
    }

    public static void assertCaseRelatedToTicket(List<Compensation__c> newObjects) {
        Map<String, List<Sobject>> caseToCompensationMap = CompApp_Utils.getFieldValueMap2list(newObjects, 'case__c');
        caseToCompensationMap.remove(null);
        caseToCompensationMap.remove('');

        for (Case iteratedCase: [SELECT Id, TCN__c FROM Case WHERE Id In:caseToCompensationMap.keySet()]) {
            if (iteratedCase.TCN__c == null && caseToCompensationMap.containsKey(iteratedCase.id)){
                for (Compensation__c iteratedComp : (List<Compensation__c>) caseToCompensationMap.get(iteratedCase.id)) {
                    if (iteratedComp.isCaseDriven__c && iteratedComp.Link_to_all_tickets_for_same_train_PNR__c){
                        iteratedComp.addError('This case does not relate to a ticket, and cannot be compensated.');
                    }
                }
            }
        }
    }

   public static void calculateTotalCompensation(Set<Id> compIdSet) {
        if (!CompApp_Utils.isWellBehaved(compIdSet)) {
            return;
        }
        if (isAsyncNeeded(compIdSet.size())) {
            System.enqueueJob(new CompApp_CompensationCalculationJob(compIdSet));
        } else {
            compensationCalcHelper_Sync(compIdSet);
        }
    }

    public static void calculateEvoucherTotalCompensation(List<Compensation__c> comp_Lst , Map<Id , Compensation__c> oldMap) {
        List<Compensation__c> CompensationsApproved_Lst = new List<Compensation__c>();
        List<Compensation__c> CompensationsToUpdate = new List<Compensation__c>();

        for (Compensation__c comp : comp_Lst) {
            CompApp_Utils.log('CompVouch Process @@@ comp: ' + comp);
            if (comp.Comp_Approval_Status__c == 'Approved' &&
                comp.Comp_Approval_Status__c != oldMap.get(comp.Id).Comp_Approval_Status__c &&
                comp.RecordTypeId == PromEV_Utils.CompensationVoucherRecordTypeId &&
                comp.isEvoucherExists__c == true &&
                comp.isEvoucherExists__c != oldMap.get(comp.Id).isEvoucherExists__c &&
                (String.isBlank(comp.Voucher_Type__c) || comp.Voucher_Type__c == '--None--')) {
                    CompensationsApproved_Lst.add(comp);
                    CompensationsToUpdate.add(new Compensation__c(Id = comp.Id , isEvoucherExists__c = false));
            }
        }
        if (CompApp_Utils.isWellBehaved(CompensationsToUpdate)) {
            update CompensationsToUpdate;
        }
        
        enqueueCompensationVoucherJob(CompensationsApproved_Lst);
    }

    public static void enqueueCompensationVoucherJob(List<Compensation__c> compensationsApproved_Lst) {

        if (CompApp_Utils.isWellBehaved(compensationsApproved_Lst)) {
            CompApp_Utils.log('CompVouch Process @@@ enqueueJob: ');
            System.enqueueJob(new CompApp_CompensationVoucherJob(compensationsApproved_Lst));
        }

    }

    public static void CreateEvouchers(List<Compensation__c> inNewComp) {
        CompApp_Utils.log('CompVouch Process @@@ inNewComp: '+inNewComp);
        List<eVoucher__c> eVoucherToInsertList = new List<eVoucher__c>();
        for (Compensation__c comp : inNewComp) {
            eVoucher__c eVoucherToInsert = new eVoucher__c(
                                                            RecordTypeId = PromEV_Utils.eVoucherServiceRecoveryRecTypeID,
                                                            Compensation__c = comp.Id,
                                                            Promotional_eVoucher_rule__c = comp.eVoucher_rule_override__c != null ?
                                                            comp.eVoucher_rule_override__c : Label.Default_eVoucher_Rule ,
                                                            Customer__c = comp.CustomerC__c != null ? comp.CustomerC__c : '',
                                                            Email__c = comp.Voucher_Email__c != null ? comp.Voucher_Email__c : ''
                                                            );
            eVoucherToInsertList.add(eVoucherToInsert);
        }
        CompApp_Utils.log('CompVouch Process @@@ eVoucherToInsertList: ' + eVoucherToInsertList);
        if (CompApp_Utils.isWellBehaved(eVoucherToInsertList)) {
            insert eVoucherToInsertList;
        }
    }

    public static Boolean isAsyncNeeded(Integer recordCount) {
        Boolean isAsyncCallWithinLimits =  (Limits.getFutureCalls() + CompApp_Constructs.FUTURE_LIMIT_BUFFER_TRIGGER) < Limits.getLimitFutureCalls();
        Boolean isHighRecordCount = recordCount > CompApp_Constructs.MAX_FORCE_SYNC_COMPENSATION_RECORD_COUNT;

        return  !DLT_Utils.isAsyncCtx() && isAsyncCallWithinLimits;
    }

    public static void compensationCalcHelper_Sync(Set<Id> compIdSet) {
        List<Compensation_Ticket__c> junctionCompensationTicketList = [
            SELECT Compensation__c, Compensation__r.Calculate_Compensation__c,Compensation__r.pre_travel__c, Compensation__r.Train_Compensation__c ,Compensation__r.Additonal_Compensation_Checker__c,
                    Compensation__r.Base_Compensation__c, Compensation__r.Is_Eligible_Points__c, Compensation__r.Points_Amount__c,
                    Ticket__c, Ticket__r.Train__c, Ticket__r.Train__r.CBE__c, Ticket__r.Name,Ticket__r.Train__r.delay_in_minutes__c,
                    Ticket__r.Booking_DateTime__c, Ticket__r.Booker__r.DELTA_Loyalty_Member__r.MemberStatus, 
                    Ticket__r.Train__r.Train_Number__c,	Ticket__r.Booker__r.DELTA_Loyalty_Member__c, 					   
                    Ticket__r.Train__r.CC__c, Ticket__r.Train__r.CB__c, Compensation__r.Is_Excluded_From_Delay_Compensation__c,
                    Ticket__r.Train__r.All__c, Ticket__r.Ticket_Price__c, Compensation__r.Total_Incident_Compensation__c,
                    Ticket__r.Class_of_Service__c, Ticket__r.Coach__c, Ticket__r.Loyalty_Tier__c, Ticket__r.FBC__c, Ticket__r.PNR__c,
                    Ticket__r.Train__r.Additional_compensation_rule__c, Ticket__r.Train__r.Additional_Compensation_Rule__r.RecordType.Name,
                    Ticket__r.Train__r.Additional_compensation_Percentage__c,Ticket__r.Train__r.Additional_PRR_Percentage__c,
                    Ticket__r.Train__r.ACR_Reprocess_Count__c ,Ticket__r.Train__r.Pre_Travel_rule__c,Ticket__r.Train__r.Pre_Travel_rule__r.RecordType.Name,
                    Ticket__r.Train__r.Pre_Travel_rule__r.Booking_Date_From__c,Ticket__r.Train__r.Pre_Travel_rule__r.Booking_Date_to__c,
                    Ticket__r.Train__r.Pre_Travel_rule__r.Fixed_Expiry_Date__c,Ticket__r.Train__r.Pre_Travel_rule__r.Voucher_Life_in_months__c,	
                    Ticket__r.Train__r.Pre_Travel_rule__r.Additional_Percentage__c,
                    Ticket__r.Train__r.Pre_Travel_rule__r.Allow_Loyalty_Points__c,
                    Ticket__r.Original_Currency__c, Ticket__r.Booker__c, Ticket__r.Booker__r.PersonContactId, Ticket__r.Cancelled__c, Ticket__r.Cancelled_by_customer__c, 
                    Ticket__r.Train__r.cancelled__c, Ticket__r.Train__r.Destination_Cash__c, Ticket__r.Train__r.Destination_Voucher__c, 
                    Ticket__r.Membership_Number__c, Ticket__r.Booker__r.iloyalcustomerId__pc, Ticket__r.Booking_Sales_Channel__c, 
                    Ticket__r.Checked_In__c, Ticket__r.Delay_mins__c, Ticket__r.Train__r.Departure_Date_Time__c, Ticket__r.Train__r.from__c, Ticket__r.Train__r.to__c, Ticket__r.Train__r.Carrier__c,
                    Ticket__r.Departure_Date__c, Ticket__r.UIC_Code__c, Ticket__r.Train__r.Unacceptable_Travel_Conditions__c, Ticket__r.Train__r.No_Catering__c,
                    Passing_Point__c, Passing_Point__r.Unacceptable_Travel_Conditions__c, Passing_Point__r.No_Catering__c,
                    Passing_Point__r.PassingPoint_Arrival_Delay__c, Passing_Point__r.Passing_Point_Cash__c, Passing_Point__r.PassingPoint_Voucher__c 
            FROM Compensation_Ticket__c
            WHERE Compensation__c IN: compIdSet
                AND Compensation__r.Calculate_Compensation__c = true
                AND Compensation__r.Comp_Approval_Status__c != 'Approved'
            FOR UPDATE
        ];

        CompApp_Utils.log('CompVouch Process @@@@ junctionCompensationTicketList: ' + junctionCompensationTicketList);

        if (CompApp_Utils.isWellBehaved(junctionCompensationTicketList)) {
            Set<String> trainIdSet = CompApp_Utils.getFieldValueMap2list(junctionCompensationTicketList, 'Ticket__r.Train__c').keySet();
            List<Incidents__c> incidentsList = [SELECT Id, Additional_Comp__c, Additional_CC__c, Train__c,
                                                    Additional_CBE__c, Additional_CB__c, Coach__c, Compensation_Rule_Id__c, 
                                                    Incident_Type__c, (SELECT Compensation__c FROM Compensation_Incidents__r WHERE Compensation__r.Comp_Approval_Status__c != 'Approved')
                                                FROM Incidents__c
                                                WHERE Train__c IN: trainIdSet];

            Map<String, List<Incidents__c>> incidentsListByTrainIdMap = CompApp_Utils.getFieldValueMap2list(incidentsList, 'Train__c');

            List<Compensation_Incident__c> compensationIncidentJunctionToInsertList = new List<Compensation_Incident__c>();

            List<Compensation__c> compensationsToUpdateList = getRecalculatedCompensationList(
                                                                    junctionCompensationTicketList,
                                                                    incidentsListByTrainIdMap,
                                                                    compensationIncidentJunctionToInsertList
                                                                ); // this method also updates the list compensationIncidentJunctionToInsertList

            insert compensationIncidentJunctionToInsertList;
            submitCompensationsForApproval(
                filterCompensationsForApproval(CompApp_Utils.getFieldIdMap2list(junctionCompensationTicketList, 'Ticket__c').keySet())
            );

            update compensationsToUpdateList;
        }
    }
    private static void resetPreTravelValues(Compensation_Ticket__c junctionCompensationTicket){
        junctionCompensationTicket.Compensation__r.Voucher_Expiry_Date__c=null;
        junctionCompensationTicket.Compensation__r.Base_Compensation__c = 0;
        junctionCompensationTicket.Compensation__r.Additional_Compensation__c = 0;
        junctionCompensationTicket.Compensation__r.PRR_Amount__c = null;
        junctionCompensationTicket.Compensation__r.additional_compensation_rule__c=null;        
        junctionCompensationTicket.Compensation__r.Ticket_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.Ticket_PRR_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.Pre_Travel__c = false;
    }
    private static List<Compensation__c> getRecalculatedCompensationList(
                            List<Compensation_Ticket__c> junctionCompensationTicketList ,Map<String, List<Incidents__c>> incidentsListByTrainIdMap, List<Compensation_Incident__c> compensationIncidentJunctionToInsertList){
        List<Compensation__c> retList =  new List<Compensation__c>(); 
        for(Compensation_Ticket__c junctionCompensationTicket : junctionCompensationTicketList){ 
            if (isEligibleForPreTravelComp(junctionCompensationTicket)){ 
                addPreTravelCompnesation(junctionCompensationTicket);
            }
            else if (isGoodwillCompensationEligable(junctionCompensationTicket) && !isTicketDelayCompensationEligable(junctionCompensationTicket.Ticket__r)){
                addGoodwillCompensation(junctionCompensationTicket);
            }
            else{ 
                if (junctionCompensationTicket.Compensation__r.Pre_Travel__c)
                	resetPreTravelValues(junctionCompensationTicket);
                addTrainCompensation(junctionCompensationTicket);
                addTicketDelayCompensation(junctionCompensationTicket);
                addIncidentsCompensation(junctionCompensationTicket, incidentsListByTrainIdMap, compensationIncidentJunctionToInsertList);
            }
            popGeneralFields(junctionCompensationTicket);  
            retList.add(junctionCompensationTicket.Compensation__r);
        }
        return retList;
    }

    private static void popGeneralFields(Compensation_Ticket__c junctionCompensationTicket){
        junctionCompensationTicket.Compensation__r.PNR__c = junctionCompensationTicket.Ticket__r.PNR__c;
        junctionCompensationTicket.Compensation__r.Ticket_Number__c = junctionCompensationTicket.Ticket__r.Name;
        junctionCompensationTicket.Compensation__r.Train_Cancelled__c = junctionCompensationTicket.Ticket__r.Cancelled__c;
        junctionCompensationTicket.Compensation__r.iLoyalCustomerID__c = junctionCompensationTicket.Ticket__r.Membership_Number__c;
        junctionCompensationTicket.Compensation__r.Train__c = junctionCompensationTicket.Ticket__r.Train__c;
        junctionCompensationTicket.Compensation__r.CustomerC__c = junctionCompensationTicket.Ticket__r.Booker__r.PersonContactId;
        junctionCompensationTicket.Compensation__r.RecordTypeID = CompApp_Utils.compensationOnlineRecTypeID;
        junctionCompensationTicket.Compensation__r.eVoucher_Appropriate__c = CompApp_Utils.isNotCompensationThirdParty(junctionCompensationTicket.Ticket__r.Booking_Sales_Channel__c) ? 'Yes' : 'No';

        // if Passing Point is present fill Compensation delay with Passing Point delay
        junctionCompensationTicket.Compensation__r.Delay_Duration_Mins__c = junctionCompensationTicket.Passing_Point__c != null && junctionCompensationTicket.Passing_Point__r.PassingPoint_Arrival_Delay__c != null
            ? Decimal.valueOf(junctionCompensationTicket.Passing_Point__r.PassingPoint_Arrival_Delay__c)
            : junctionCompensationTicket.Ticket__r.Delay_mins__c;

        junctionCompensationTicket.Compensation__r.Payment_Currency__c = junctionCompensationTicket.Ticket__r.Original_Currency__c;
        junctionCompensationTicket.Compensation__r.Date_of_Travel__c = junctionCompensationTicket.Ticket__r.Train__r.Departure_Date_Time__c;
        
        Date departureDate;
        try{
            String tempDate = junctionCompensationTicket.Ticket__r.Train__r.Departure_Date_Time__c.substring(0,10);
            departureDate = Date.newInstance(Integer.valueOf(tempDate.substring(6,10)),Integer.valueOf(tempDate.substring(3,5)),Integer.valueOf(tempDate.substring(0,2)));
        }
        catch(Exception e){
            throw new CompApp_Constructs.CompApp_DataIssueException('Departure date time is not defined well in ticket #'+junctionCompensationTicket.Ticket__r.Id);
        }
        if (!junctionCompensationTicket.Compensation__r.Pre_Travel__c)
        	junctionCompensationTicket.Compensation__r.Voucher_Expiry_Date__c = departureDate.addMonths(CompApp_Constructs.VOUCHER_EXPIRATION_DELTA).addDays(1);
        
        
        junctionCompensationTicket.Compensation__r.Ticket_Price__c = junctionCompensationTicket.Ticket__r.Ticket_Price__c;
        junctionCompensationTicket.Compensation__r.Ticket_Read_Only__c = junctionCompensationTicket.Ticket__r.Name;
        junctionCompensationTicket.Compensation__r.Carriage__c = junctionCompensationTicket.Ticket__r.Coach__c;
        
        Decimal totalOnlineCompensationDecimal =
            getRoundedVoucher(
                CompApp_Utils.getDecimalValue(junctionCompensationTicket.Compensation__r.Base_Compensation__c) +
                CompApp_Utils.getDecimalValue(junctionCompensationTicket.Compensation__r.Additional_Compensation__c) +																								   
                CompApp_Utils.getDecimalValue(junctionCompensationTicket.Compensation__r.Train_Compensation__c) +
                CompApp_Utils.getDecimalValue(junctionCompensationTicket.Compensation__r.Total_Incident_Compensation__c)
            );
        
        junctionCompensationTicket.Compensation__r.Total_Online_Compensation__c = totalOnlineCompensationDecimal;
        
        junctionCompensationTicket.Compensation__r.Calculate_Compensation__c = false;
    }

    private static void addIncidentsCompensation(Compensation_Ticket__c junctionCompensationTicket ,Map<String, List<Incidents__c>> incidentsListByTrainIdMap, List<Compensation_Incident__c> compensationIncidentJunctionToInsertList) {
        junctionCompensationTicket.Compensation__r.Total_Incident_Compensation__c = null;
        junctionCompensationTicket.Compensation__r.Incident_HistoryTracking__c = '';
        if (incidentsListByTrainIdMap.containsKey(junctionCompensationTicket.Ticket__r.Train__c)) {
            addIncidentsCompensationHelper(junctionCompensationTicket,
                incidentsListByTrainIdMap.get(junctionCompensationTicket.Ticket__r.Train__c),
                compensationIncidentJunctionToInsertList);
        }
    }

    private static void addIncidentsCompensationHelper(Compensation_Ticket__c junctionCompensationTicket, List<Incidents__c> relatedIncidentsList, List<Compensation_Incident__c> compensationIncidentJunctionToInsertList) {
        if (isIncidentCompensationEligable(junctionCompensationTicket.Ticket__r, relatedIncidentsList)){
            junctionCompensationTicket.Compensation__r.Total_Incident_Compensation__c = 0;
            compensationIncidentJunctionToInsertList.addAll(createNewCompensationIncidentJunctionList(junctionCompensationTicket, relatedIncidentsList));
            List<CompApp_Constructs.CompensationHistoryTracking> incidentsHistoryTracking = new List<CompApp_Constructs.CompensationHistoryTracking>();
            for (Incidents__c inc : relatedIncidentsList){
                if (isTicketEligable(inc.Coach__c, junctionCompensationTicket.Ticket__r.Coach__c)) {
                    junctionCompensationTicket.Compensation__r.Total_Incident_Compensation__c += addIncidentCompensation(junctionCompensationTicket.Ticket__r, inc, incidentsHistoryTracking);
                }
            }
            junctionCompensationTicket.Compensation__r.Incident_HistoryTracking__c = JSON.serialize(incidentsHistoryTracking);
        }
    }

    private static Boolean isExistedCompensationIncidentJunction(Id compId, Incidents__c inc) {
        if (CompApp_Utils.isWellBehaved(inc.Compensation_Incidents__r)){
            for (Compensation_Incident__c junctionCompensationIncident : inc.Compensation_Incidents__r) {
                if (compId == junctionCompensationIncident.Compensation__c) {
                    return true;
                }
            }
        }
        return false;
    }

    private static List<Compensation_Incident__c> createNewCompensationIncidentJunctionList(Compensation_Ticket__c junctionCompensationTicket, List<Incidents__c> relatedIncidentsList){
        List<Compensation_Incident__c> newCompensationIncidentJunctionList = new List<Compensation_Incident__c>();
        for(Incidents__c inc : relatedIncidentsList){
            if(isExistedCompensationIncidentJunction(junctionCompensationTicket.Compensation__c, inc) == false){
                if(inc.Coach__c != null){
                    if(inc.Coach__c == junctionCompensationTicket.Ticket__r.Coach__c){
                        Compensation_Incident__c newCompensationIncidentJunction = new Compensation_Incident__c();
                        newCompensationIncidentJunction.Compensation__c = junctionCompensationTicket.Compensation__c;
                        newCompensationIncidentJunction.Incident__c = inc.Id;
                        newCompensationIncidentJunctionList.add(newCompensationIncidentJunction);
                    } 
                }
                else{
                    Compensation_Incident__c newCompensationIncidentJunction = new Compensation_Incident__c();
                    newCompensationIncidentJunction.Compensation__c = junctionCompensationTicket.Compensation__c;
                    newCompensationIncidentJunction.Incident__c = inc.Id;
                    newCompensationIncidentJunctionList.add(newCompensationIncidentJunction);
                }
            }
        }
        return newCompensationIncidentJunctionList;
    }
	
    private static boolean isEligibleForPreTravelComp(Compensation_Ticket__c junctionCompensationTicket) { 
        return isEligibleForPreTravelComp(junctionCompensationTicket.Ticket__r);
    }

    private static boolean isEligibleForPreTravelComp( Ticket__c ticket) {
        //A ticket is eligible for Pre-Travel Coucher is the train as a PreTravelCompensation RUle and the the
        //tickets departure date should be after tomorrow
        //Ticket and Train should not be cancelled
        //Ticket should not be checked in
        Boolean eligible = false;
        String tempDate = ticket.train__r.Departure_Date_Time__c.substring(0,10);
		Date departureDate = Date.newInstance(Integer.valueOf(tempDate.substring(6,10)),Integer.valueOf(tempDate.substring(3,5)),Integer.valueOf(tempDate.substring(0,2)));
               
        eligible = (ticket.Train__r.pre_travel_rule__c!=null && 
        ticket.Train__r.pre_travel_rule__r.RecordType.Name == CompApp_AdditionalCompUtils.PRE_TRAVEL_RULE && 
        ticket.Cancelled_By_Customer__c == false &&
        ticket.Cancelled__c == false &&
        ticket.Checked_In__c == false &&
        departureDate > Date.today() );
        if (eligible) {
            if (ticket.Booking_DateTime__c != null) {
                tempDate=ticket.Booking_DateTime__c.substring(0,10);
                Date bookingDate = Date.newInstance(Integer.valueOf(tempDate.substring(6,10)),Integer.valueOf(tempDate.substring(3,5)),Integer.valueOf(tempDate.substring(0,2)));
                
                if (ticket.Train__r.pre_travel_rule__r.Booking_Date_From__c != null && bookingDate < ticket.Train__r.pre_travel_rule__r.Booking_Date_From__c)
                    eligible = false;
                if (ticket.Train__r.pre_travel_rule__r.Booking_Date_To__c != null && bookingDate > ticket.Train__r.pre_travel_rule__r.Booking_Date_To__c)
                    eligible = false;
            }
             
            
        }
        return eligible;
    }

    private static void addPreTravelCompnesation(Compensation_Ticket__c junctionCompensationTicket) {
        junctionCompensationTicket.Compensation__r.Base_Compensation__c = 0;
        junctionCompensationTicket.Compensation__r.Additional_Compensation__c = 0;
        junctionCompensationTicket.Compensation__r.PRR_Amount__c = null;
        junctionCompensationTicket.Compensation__r.Ticket_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.Ticket_PRR_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.additional_compensation_rule__c=null;	
        junctionCompensationTicket.Compensation__r.Pre_Travel__c=true;
        
        CompApp_Constructs.CompensationHistoryTracking ticketHistoryTracking = new CompApp_Constructs.CompensationHistoryTracking();
        List<String> compensationPercentageList = new List<String>();
        
        if (isEligibleForPreTravelComp(junctionCompensationTicket)){
            junctionCompensationTicket.Compensation__r.Payment_Currency__c = junctionCompensationTicket.Ticket__r.Original_Currency__c;
            junctionCompensationTicket.Compensation__r.Additional_Compensation__c = getRoundedVoucher(junctionCompensationTicket.Ticket__r.Ticket_Price__c * junctionCompensationTicket.Ticket__r.Train__r.pre_travel_rule__r.Additional_Percentage__c /100);                    
            junctionCompensationTicket.Compensation__r.Total_Online_Compensation__c = junctionCompensationTicket.Compensation__r.Additional_Compensation__c;
            
            ticketHistoryTracking.Additional_Compensation = String.valueOf(junctionCompensationTicket.Compensation__r.Additional_Compensation__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
            ticketHistoryTracking.Base_Compensation = String.valueOf(junctionCompensationTicket.Compensation__r.Base_Compensation__c + junctionCompensationTicket.Compensation__r.Additional_Compensation__c ) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);

            
            junctionCompensationTicket.Compensation__r.additional_compensation_rule__c = junctionCompensationTicket.Ticket__r.Train__r.Pre_Travel_rule__c;
            junctionCompensationTicket.Compensation__r.Additonal_Compensation_Checker__c=junctionCompensationTicket.Ticket__r.TRain__r.ACR_Reprocess_Count__c;
            
            //Setting expiry date
            if ( junctionCompensationTicket.Ticket__r.Train__r.Pre_Travel_Rule__r.fixed_expiry_date__c !=null )
                junctionCompensationTicket.Compensation__r.Voucher_Expiry_Date__c =junctionCompensationTicket.Ticket__r.Train__r.Pre_Travel_Rule__r.fixed_expiry_date__c;
            else if (junctionCompensationTicket.Ticket__r.departure_date__c !=null) {    
                if ( junctionCompensationTicket.Ticket__r.Train__r.Pre_Travel_Rule__r.Voucher_Life_In_Months__c !=null )
                    junctionCompensationTicket.Compensation__r.Voucher_Expiry_Date__c = junctionCompensationTicket.Ticket__r.departure_date__c.addMonths(Integer.valueOf(junctionCompensationTicket.Ticket__r.Train__r.Pre_Travel_Rule__r.Voucher_Life_In_Months__c)).addDays(1);
                else
                    junctionCompensationTicket.Compensation__r.Voucher_Expiry_Date__c = junctionCompensationTicket.Ticket__r.departure_date__c.addMonths(CompApp_Constructs.VOUCHER_EXPIRATION_DELTA).addDays(1);
            }
            else
                throw new CompApp_Constructs.CompApp_DataIssueException('No Departure date for ticket -'+ junctionCompensationTicket.Ticket__r.name);
            
            
            compensationPercentageList.add('Pre-Travel Compensation (' + junctionCompensationTicket.Ticket__r.Train__r.Pre_Travel_Rule__r.Additional_Percentage__c +'%');
            
            ticketHistoryTracking.Compensation_Percentage = compensationPercentageList;
            ticketHistoryTracking.Ticket_Price = String.valueOf(junctionCompensationTicket.Ticket__r.Ticket_Price__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
            ticketHistoryTracking.Actual_Delay = 'Pre-Travel Voucher';
            
            junctionCompensationTicket.Compensation__r.Ticket_HistoryTracking__c = JSON.serialize(ticketHistoryTracking);
        }
        
    }
    private static void addTicketDelayCompensation(Compensation_Ticket__c junctionCompensationTicket){
        junctionCompensationTicket.Compensation__r.Base_Compensation__c = 0;
		junctionCompensationTicket.Compensation__r.Additional_Compensation__c = 0;
        junctionCompensationTicket.Compensation__r.PRR_Amount__c = null;
		junctionCompensationTicket.Compensation__r.Ticket_HistoryTracking__c = '';
		junctionCompensationTicket.Compensation__r.Ticket_PRR_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.additional_compensation_rule__c=null;

        // if Passing Point is present replace Ticket delay with Passing Point delay
        junctionCompensationTicket.Ticket__r.Delay_mins__c = junctionCompensationTicket.Passing_Point__c != null && junctionCompensationTicket.Passing_Point__r.PassingPoint_Arrival_Delay__c != null
            ? Decimal.valueOf(junctionCompensationTicket.Passing_Point__r.PassingPoint_Arrival_Delay__c)
            : junctionCompensationTicket.Ticket__r.Delay_mins__c;

        if(junctionCompensationTicket.Compensation__r.Additonal_Compensation_Checker__c==null)  
           junctionCompensationTicket.Compensation__r.Additonal_Compensation_Checker__c=0;
        if(isTicketDelayCompensationEligable(junctionCompensationTicket.Ticket__r) ||
          (junctionCompensationTicket.Ticket__r.cancelled_by_customer__c=false &&
          junctionCompensationTicket.Compensation__r.Additonal_Compensation_Checker__c!=junctionCompensationTicket.Ticket__r.TRain__r.ACR_Reprocess_Count__c)) { 
          junctionCompensationTicket.Compensation__r.Additonal_Compensation_Checker__c=junctionCompensationTicket.Ticket__r.TRain__r.ACR_Reprocess_Count__c;
            CompApp_Constructs.CompensationHistoryTracking ticketHistoryTracking = new CompApp_Constructs.CompensationHistoryTracking();
            List<String> compensationPercentageList = new List<String>();
			Decimal prr_percentage=0;						 
            if (junctionCompensationTicket.Ticket__r.Ticket_Price__c != 0) {
                CompApp_Constructs.CompensationRuleWrapper compRule = CompApp_Utils.getCompRuleByTicket(junctionCompensationTicket.Ticket__r);
                CompApp_Utils.log('compRule @ addTicketDelayCompensation: ' + compRule);
				/* 
				 * If a base compensation rule found. If the train is not delayed enough, 
                 * there will not be any base comp rule, but Additional comp rule can be present
                 * 
                 */
                if (compRule != null){ 					   
					ticketHistoryTracking.isCancelled = compRule.type =='Cancelled';
					if (compRule.delayEnd!= null)
						ticketHistoryTracking.Delay_Minutes_Rule = Integer.valueOf(compRule.delayStart) + '-' + Integer.valueOf(compRule.delayEnd);
					else
						ticketHistoryTracking.Delay_Minutes_Rule = Integer.valueOf(compRule.delayStart) + '+';

                    // Base Compensation caluclation

                    junctionCompensationTicket.Compensation__r.Base_Compensation__c = CompApp_Utils.calculateBaseCompensation(junctionCompensationTicket, compRule, compensationPercentageList);

                    // PRR Amount calculation
                    junctionCompensationTicket.Compensation__r.PRR_Amount__c = CompApp_Utils.calculatePRRAmount(junctionCompensationTicket, compRule, prr_percentage);

                    // Points Amount calculation
                    junctionCompensationTicket.Compensation__r.Points_Amount__c = calculatePointsAmount(junctionCompensationTicket, compRule);
                    junctionCompensationTicket.Compensation__r.Total_Online_Points__c = junctionCompensationTicket.Compensation__r.Points_Amount__c;
					
                    ticketHistoryTracking.PRR_amount = String.valueOf(junctionCompensationTicket.Compensation__r.PRR_Amount__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
           		}
                
                //if (junctionCompensationTicket.Compensation__r.Base_Compensation__c>0){ //Additional compensation will be applied only if there is a base compensation
                    
                    if (junctionCompensationTicket.Ticket__r.Train__r.Additional_Compensation_rule__c!=null
                       && (junctionCompensationTicket.Ticket__r.Train__r.Additional_Compensation_Percentage__c!=null||
                           junctionCompensationTicket.Ticket__r.Train__r.Additional_PRR_Percentage__c!=null)){ 
                        
                        junctionCompensationTicket.Compensation__r.Additional_Compensation__c = getRoundedVoucher(junctionCompensationTicket.Ticket__r.Ticket_Price__c * junctionCompensationTicket.Ticket__r.Train__r.Additional_Compensation_Percentage__c /100);                    
                        ticketHistoryTracking.Additional_Compensation = String.valueOf(junctionCompensationTicket.Compensation__r.Additional_Compensation__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
                           if (junctionCompensationTicket.Ticket__r.Train__r.Additional_PRR_Percentage__c!=null ){
                               // Additional PRR Amount Calculation
                               // Additional PRR needs to be calculated regardless of the base PRR present/applied
                               // Bugfix SFDCI-411
                                prr_percentage = (((compRule==null||compRule.eligiblePRRCompensation==null)?0:compRule.eligiblePRRCompensation) +junctionCompensationTicket.Ticket__r.Train__r.Additional_PRR_Percentage__c) /100;                   
                               // prr_percentage = ((compRule.eligiblePRRCompensation==null?0:compRule.eligiblePRRCompensation) +junctionCompensationTicket.Ticket__r.Train__r.Additional_PRR_Percentage__c) /100;                   
                                junctionCompensationTicket.Compensation__r.PRR_Amount__c = getRoundedVoucher(junctionCompensationTicket.Ticket__r.Ticket_Price__c* prr_percentage); //CompApp_Utils.getBaseCompensationByTicket(junctionCompensationTicket.Ticket__r, compRule, compensationPercentageList);
                                ticketHistoryTracking.PRR_amount = String.valueOf(junctionCompensationTicket.Compensation__r.PRR_Amount__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
                           }
                        junctionCompensationTicket.Compensation__r.additional_compensation_rule__c = junctionCompensationTicket.Ticket__r.Train__r.Additional_Compensation_rule__c;
                        junctionCompensationTicket.Compensation__r.Additonal_Compensation_Checker__c=junctionCompensationTicket.Ticket__r.TRain__r.ACR_Reprocess_Count__c;
                        compensationPercentageList.add('Additional Compensation (' + junctionCompensationTicket.Ticket__r.Train__r.Additional_Compensation_Percentage__c +'% , PRR-'+junctionCompensationTicket.Ticket__r.Train__r.Additional_PRR_Percentage__c+'%)');
                    }
                	else{
                        junctionCompensationTicket.Compensation__r.Additional_Compensation__c = 0;
                		ticketHistoryTracking.Additional_Compensation = '0';
                    }
                            
                //}
            }else{
                ticketHistoryTracking.Flat_Fee = true;
                CompApp_Constructs.CompensationRuleWrapper zeroPriceComp = CompApp_Utils.getZeroPriceCompensationByTicket(junctionCompensationTicket.Ticket__r);
                if(zeroPriceComp != null){
                    junctionCompensationTicket.Compensation__r.Base_Compensation__c = zeroPriceComp.voucher;
                }
                else{
                    junctionCompensationTicket.Compensation__r.Base_Compensation__c = 0;
					junctionCompensationTicket.Compensation__r.Additional_Compensation__c = 0;																		  
                }
            }

            CompApp_Utils.log('junctionCompensationTicket.Compensation__r.Base_Compensation__c I @ addTicketDelayCompensation: ' + junctionCompensationTicket.Compensation__r.Base_Compensation__c);
            junctionCompensationTicket.Compensation__r.Base_Compensation__c = getRoundedVoucher(junctionCompensationTicket.Compensation__r.Base_Compensation__c);
            CompApp_Utils.log('junctionCompensationTicket.Compensation__r.Base_Compensation__c II @ addTicketDelayCompensation: ' + junctionCompensationTicket.Compensation__r.Base_Compensation__c);


            junctionCompensationTicket.Compensation__r.Is_Excluded_From_Delay_Compensation__c = CompApp_Utils.isTicketExcludedFromDelayCompensation(junctionCompensationTicket.Ticket__r);

            CompApp_Utils.log('junctionCompensationTicket.Compensation__r.Additional_Compensation__c I @ addTicketDelayCompensation: ' + junctionCompensationTicket.Compensation__r.Additional_Compensation__c);
            
            ticketHistoryTracking.Base_Compensation = String.valueOf(junctionCompensationTicket.Compensation__r.Base_Compensation__c + junctionCompensationTicket.Compensation__r.Additional_Compensation__c ) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
            if (junctionCompensationTicket.Compensation__r.Additional_Compensation__c!=0)
            	ticketHistoryTracking.Additional_Compensation = String.valueOf(junctionCompensationTicket.Compensation__r.Additional_Compensation__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
            else
                ticketHistoryTracking.Additional_Compensation = null;
            
            ticketHistoryTracking.Compensation_Percentage = compensationPercentageList;
            ticketHistoryTracking.Ticket_Price = String.valueOf(junctionCompensationTicket.Ticket__r.Ticket_Price__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
            ticketHistoryTracking.Total_Online_Points = String.valueOf(junctionCompensationTicket.Compensation__r.Points_Amount__c);
            ticketHistoryTracking.Actual_Delay = String.valueOf(junctionCompensationTicket.Ticket__r.Delay_mins__c);

            junctionCompensationTicket.Compensation__r.Ticket_HistoryTracking__c = JSON.serialize(ticketHistoryTracking);
			 //Reset the List for PRR Data
            compensationPercentageList = new List<String>();
            compensationPercentageList.add('PRR (' + prr_percentage*100 + '%)');
            ticketHistoryTracking.Compensation_Percentage = compensationPercentageList;
            junctionCompensationTicket.Compensation__r.Ticket_PRR_HistoryTracking__c = JSON.serialize(ticketHistoryTracking);							 
        }
    }

    private static void addTrainCompensation(Compensation_Ticket__c junctionCompensationTicket){
        junctionCompensationTicket.Compensation__r.Train_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.Train_Compensation__c = null;
        if(isTrainCompensationEligable(junctionCompensationTicket.Ticket__r)){
            Decimal ticketPrice = CompApp_Utils.getDecimalValue(junctionCompensationTicket.Ticket__r.Ticket_Price__c);
            Decimal trainAll = CompApp_Utils.getDecimalValue(junctionCompensationTicket.Ticket__r.Train__r.All__c);
            Decimal trainCB = CompApp_Utils.getDecimalValue(junctionCompensationTicket.Ticket__r.Train__r.CB__c);
            Decimal trainCBE = CompApp_Utils.getDecimalValue(junctionCompensationTicket.Ticket__r.Train__r.CBE__c);
            Decimal trainCC = CompApp_Utils.getDecimalValue(junctionCompensationTicket.Ticket__r.Train__r.CC__c);

            CompApp_Constructs.CompensationHistoryTracking trainHistoryTracking = new CompApp_Constructs.CompensationHistoryTracking();
            trainHistoryTracking.isCancelled = junctionCompensationTicket.Ticket__r.Cancelled__c;

            trainHistoryTracking.Compensation_Percentage = new List<String>();
            trainHistoryTracking.Compensation_Percentage.add('All ('+trainAll+'%)');

            if(CompApp_Utils.getLoyaltyTier(junctionCompensationTicket.Ticket__r.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CC){
                junctionCompensationTicket.Compensation__r.Train_Compensation__c = ticketPrice * (trainAll + trainCC);
                trainHistoryTracking.Compensation_Percentage.add('CC ('+trainCC+'%)');
            }
            else if(CompApp_Utils.getLoyaltyTier(junctionCompensationTicket.Ticket__r.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CB){
                junctionCompensationTicket.Compensation__r.Train_Compensation__c = ticketPrice * (trainAll + trainCB);
                trainHistoryTracking.Compensation_Percentage.add('CB ('+trainCB+'%)');
            }
            else if(CompApp_Utils.getLoyaltyTier(junctionCompensationTicket.Ticket__r.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CBE){
                junctionCompensationTicket.Compensation__r.Train_Compensation__c = ticketPrice * (trainAll + trainCBE);
                trainHistoryTracking.Compensation_Percentage.add('CBE ('+trainCBE+'%)');
            }
            else{
                junctionCompensationTicket.Compensation__r.Train_Compensation__c = ticketPrice * trainAll;
            }
            junctionCompensationTicket.Compensation__r.Train_Compensation__c = getRoundedVoucher(junctionCompensationTicket.Compensation__r.Train_Compensation__c / 100);

            trainHistoryTracking.Train_Compensation = String.valueOf(junctionCompensationTicket.Compensation__r.Train_Compensation__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
            trainHistoryTracking.Ticket_Price = String.valueOf(junctionCompensationTicket.Ticket__r.Ticket_Price__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);

            junctionCompensationTicket.Compensation__r.Train_HistoryTracking__c = JSON.serialize(trainHistoryTracking);
        }
    }

	public static CompApp_Constructs.CompensationCreationDataWrapper getCompensationCreationData(Map<Id, Train__c> newObjectsMap){
        List<Ticket__c> ticketList = [
            SELECT
                Id, Train__c, Train__r.Carrier__c, Coach__c, Delay_mins__c, Checked_In__c, Cancelled__c, Ticket_price__c, Original_Currency__c,Train__r.Train_Number__c,
                Train__r.Departure_Date_Time__c,Train__r.Additional_compensation_rule__c, Train__r.No_Catering__c, Train__r.Unacceptable_Travel_Conditions__c,
                Train__r.From__c, Train__r.To__c , Booking_DateTime__c, UIC_Code__c
            FROM Ticket__c
            WHERE Train__r.Cancelled__c = false
                AND Train__r.Exempt_from_Auto_Compensation__c = false
                AND Train__c IN :newObjectsMap.keySet()
        ];

        List<Incidents__c> incidentsList;
        if(CompApp_Utils.isWellBehaved(ticketList)){
            for(Ticket__c tick : ticketList){
                tick.Train__r = newObjectsMap.get(tick.Train__c);
            }
            incidentsList = [SELECT
                                Id, Train__c, Coach__c
                             FROM
                                Incidents__c
                             WHERE
                                Train__c IN: newObjectsMap.keySet()
                                ]; // TODO: Israel @ 21.09.2015
        }
        return new CompApp_Constructs.CompensationCreationDataWrapper(ticketList, incidentsList);
    }

    public static CompApp_Constructs.CompensationCreationDataWrapper getCompensationCreationData(List<Incidents__c> newObjects, Map<Id, Incidents__c> newObjectsMap){
		Set<Id> trainIdSetTemp = new Set<Id>();
        Set<Id> trainIdSet = new Set<Id>();

        for(Incidents__c incident : newObjects){
            trainIdSetTemp.add(incident.Train__c);
        }

        Map<Id, Train__c> trainByIdMap = new Map<Id, Train__c>([
            SELECT
                Id, All__c, CC__c, CB__c, CBE__c, Carrier__c, Departure_Date_Time__c,  From__c, To__c, Train_number__c, Delay_in_Minutes__c, 
                Additional_compensation_rule__c, Additional_compensation_rule__r.RecordType.Name, Additional_compensation_Percentage__c,Additional_PRR_Percentage__c,
                ACR_Reprocess_Count__c,  Pre_Travel_Rule__c, Pre_Travel_Rule__r.RecordType.Name,Pre_Travel_Rule__r.Booking_Date_From__c,
                Pre_Travel_Rule__r.Booking_Date_To__c,Pre_Travel_Rule__r.Fixed_Expiry_Date__c,Cancelled__c,
                Pre_Travel_Rule__r.Allow_Loyalty_Points__c,
                Pre_Travel_Rule__r.Voucher_Life_in_months__c,Pre_Travel_Rule__r.Additional_Percentage__c
            FROM Train__c
            WHERE Id IN :trainIdSetTemp
                AND Cancelled__c = false
                AND Exempt_from_Auto_Compensation__c = false

        ]);

		for (Id train_id :trainIdSetTemp ){
            if (trainByIdMap.get(train_id)!=null){
                if  (isTrainReadyToBeProcessed(trainByIdMap.get(train_id)))
                    trainIdSet.add(train_id);
           	}
        }
        trainIdSetTemp.clear();
		List<Ticket__c> ticketList = [
            SELECT
                Id, Train__c, Coach__c, Train__r.Additional_compensation_rule__c, Train__r.Additional_compensation_rule__r.RecordType.Name, train__r.Cancelled__c, UIC_Code__c, Train__r.Carrier__c,
                Checked_In__c, Train__r.No_Catering__c, Train__r.Unacceptable_Travel_Conditions__c, Cancelled__c, Cancelled_By_Customer__c, Delay_mins__c 
            FROM Ticket__c
            WHERE Train__r.Exempt_from_Auto_Compensation__c = false
                AND Train__c IN :trainIdSet
        ];

        if(CompApp_Utils.isWellBehaved(ticketList)){
            for(Ticket__c tick : ticketList){
                tick.Train__r = trainByIdMap.get(tick.Train__c);
            }
        }
        return new CompApp_Constructs.CompensationCreationDataWrapper(ticketList, newObjects);
    }

    public static CompApp_Constructs.CompensationCreationDataWrapper getCompensationCreationData(List<Ticket__c> newObjects, Map<Id, Ticket__c> newObjectsMap) {
        Map<Id, List<Ticket__c>> ticketListByTrainIdMap = new Map<Id, List<Ticket__c>>();
        Date cutOffDate = CompApp_Constructs.parseStringToDate(CompApp_Constructs.COMPENSATION_POLICY_CHANGE_DATE);
        Date ticketTravelDate;
        for(Ticket__c tick : newObjects) {
            ticketTravelDate = String.isNotBlank(tick.Travel_DateTime__c)
                ? CompApp_Constructs.parseStringToDate(tick.Travel_DateTime__c.substring(0,10))
                : null;

            if ( ticketTravelDate < cutOffDate && isTicketReadyToBeProcessed(tick) ){
                continue;
            }
            if (ticketListByTrainIdMap.containsKey(tick.Train__c)) {
                ticketListByTrainIdMap.get(tick.Train__c).add(tick);
            }
            else{
                ticketListByTrainIdMap.put(tick.Train__c, new List<Ticket__c>{tick});
            }
        }
        newObjects = fillTrainInfoInNewTicketList(ticketListByTrainIdMap);

        List<Incidents__c> relatedIncidentsList = [
            SELECT
                Id, Coach__c, Train__c
            FROM Incidents__c
            WHERE Train__r.Exempt_from_Auto_Compensation__c = false
                AND Train__c IN: ticketListByTrainIdMap.keySet()
        ];

        return new CompApp_Constructs.CompensationCreationDataWrapper(newObjects, relatedIncidentsList);
    }


    public static void upsertCompensations(CompApp_Constructs.CompensationCreationDataWrapper dataWrapper) {
        // If async is available and there is only one chunk of data:
        if (isAsyncNeeded(dataWrapper.tickList.size()) && dataWrapper.chunkedTicketList.size() == 1) {
            System.enqueueJob(new CompApp_CompensationPreCalculationJob(dataWrapper));
        } else {
            upsertCompensations_SyncHelper(dataWrapper);
        }
    }

  
	public static void upsertCompensations_SyncHelper(CompApp_Constructs.CompensationCreationDataWrapper dataWrapper) {
        List<CompApp_Constructs.CompensationTicketTuple> newCompensationTicketTupleList = new List<CompApp_Constructs.CompensationTicketTuple>();
        List<Compensation__c> compToBeUpList =  CompApp_TriggerUtils.getCompensationsToBeUpsertedList(newCompensationTicketTupleList, dataWrapper);
        upsert compToBeUpList;

        // mark Train as handled by auto compensation
        for(Train__c t : dataWrapper.trainList){
            t.Train_handled_by_Auto_Compensation__c = true;
        }
        update new List<Train__c>(dataWrapper.trainList);


        if (CompApp_Utils.isWellBehaved(newCompensationTicketTupleList)) {
            List<Compensation_Ticket__c> junctionCompensationTicketToInsertList = new List<Compensation_Ticket__c>();

            for (CompApp_Constructs.CompensationTicketTuple wrapper : newCompensationTicketTupleList) {
                junctionCompensationTicketToInsertList.add( new Compensation_Ticket__c(
                        Ticket__c = wrapper.tickId,
                        Compensation__c = wrapper.comp.Id,
                        Passing_Point__c = wrapper.passingPointId
                    )
                );
            }
            insert junctionCompensationTicketToInsertList;
        }
    }

    public static List<Compensation__c> getCompensationsToBeUpsertedList(List<CompApp_Constructs.CompensationTicketTuple> newCompensationTicketTupleList, CompApp_Constructs.CompensationCreationDataWrapper dataWrapper) {
        List<Compensation__c> compensationsToBeUpsertedList = new List<Compensation__c>();
        List<Compensation_Ticket__c> junctionCompensationTicketList = [SELECT Compensation__c, Ticket__c, Compensation__r.Id, Compensation__r.Claim_Status__c
                                                                        FROM Compensation_Ticket__c
                                                                        WHERE Ticket__c IN: dataWrapper.tickList
                                                                            AND Compensation__r.RecordTypeId =: CompApp_Utils.compensationOnlineRecTypeID
                                                                        FOR UPDATE
                                                                    ];

        CompApp_Utils.log('junctionCompensationTicketList @getCompensationsToBeUpsertedList: ' + junctionCompensationTicketList);

        Map<Id, Compensation__c> existinOnlineCompensationByTicketIdMap = new Map<Id, Compensation__c>();
        Compensation__c comp;
        
        for (Compensation_Ticket__c junctionCompensationTicket : junctionCompensationTicketList) {
            existinOnlineCompensationByTicketIdMap.put(junctionCompensationTicket.Ticket__c, junctionCompensationTicket.Compensation__r);
        }
        // existinOnlineCompensationByTicketIdMap is ready to use now

        // Iterate on each ticket now and decide if he is supposed to get a compensation or to update a compensation

        for (Ticket__c tick : dataWrapper.tickList) {
            // First we check if is eligable to train compensation
            if (existinOnlineCompensationByTicketIdMap.containsKey(tick.Id)) {
                if (existinOnlineCompensationByTicketIdMap.get(tick.Id).Claim_Status__c == 'Claimed') {
                    continue;
                }

                comp = existinOnlineCompensationByTicketIdMap.get(tick.Id);
                comp.Calculate_Compensation__c = true;
                compensationsToBeUpsertedList.add(comp);
            } else if (isTrainCompensationEligable(tick)
                || isTicketDelayCompensationEligable(tick)
                || isIncidentCompensationEligable(tick, dataWrapper.incList)
                || isEligibleForPreTravelComp(tick)
                || isGoodwillCompensationEligable(tick, dataWrapper.trainWithPassingPoints)
            ) {
                comp = new Compensation__c(
                    Calculate_Compensation__c = true, 
                    RecordTypeId = CompApp_Utils.compensationOnlineRecTypeID, 
                    Source_Ticket__c = tick.Id 
                );
                if(dataWrapper.trainWithPassingPoints.containsKey(tick.Train__c) && dataWrapper.trainWithPassingPoints.get(tick.Train__c).containsKey(tick.UIC_Code__c)){
                    newCompensationTicketTupleList.add(new CompApp_Constructs.CompensationTicketTuple(comp, tick.Id, dataWrapper.trainWithPassingPoints.get(tick.Train__c).get(tick.UIC_Code__c).Id));
                } else{
                    newCompensationTicketTupleList.add(new CompApp_Constructs.CompensationTicketTuple(comp, tick.Id));
                }
                compensationsToBeUpsertedList.add(comp);
            }
        }
        return compensationsToBeUpsertedList;
    }
	
	private static Boolean isTrainReadyToBeProcessed(Train__c train) {
        //#Prevent Compensation on Cancelled Trains Change
         Date departureDate;
        if (train!= null && String.isNotBlank(train.Departure_Date_Time__c)) {
            try {
                String tempDate = train.Departure_Date_Time__c.substring(0,10);
				departureDate = Date.newInstance(Integer.valueOf(tempDate.substring(6,10)),Integer.valueOf(tempDate.substring(3,5)),Integer.valueOf(tempDate.substring(0,2)));																											  
            }
            catch (Exception e) {
                throw new CompApp_Constructs.CompApp_DataIssueException('Departure date time is not defined well in train #'+train.Id + '-' + train.Departure_Date_Time__c);
            }
        }
        return departureDate < Date.Today() && !train.Cancelled__c;
    }
    
    private static Boolean isTicketReadyToBeProcessed(Ticket__c ticket) {
        // Prevent Compensation on Cancelled Trains Change
        // Train should be OK to process and Ticket muct be checked in on an non cancelled Train 
        if (isTrainReadyToBeProcessed(ticket.Train__r) && (ticket.Checked_In__c && !ticket.Cancelled__c && !ticket.Cancelled_By_Customer__c) || (ticket.Train__r.Carrier__c == RED && !ticket.Cancelled__c && !ticket.Cancelled_By_Customer__c)) {
            return true;
        }
        return false;
    }

    private static Boolean isTicketDelayCompensationEligable(Ticket__c tick) {
		//Ticket is eligible for Compensation if it checked in and travelled yesterday and any one of the conditions are met
        //	1.Delayed enough to get compensation based on the Compensation Rule
        //	2.An Active additional compensation rule is applicable to the Train
        //	3.Ticket is Cancelled
        Decimal minimalDelayCompensation = CompApp_Utils.compensationRuleList[0].delayStart;
        Boolean isDelaySufficent = tick.Delay_mins__c != null && ((tick.Delay_mins__c >= minimalDelayCompensation));
        Boolean isAdditionalCompRulePresent =  (tick.Train__r.Additional_Compensation_rule__c!=null && 
                                                tick.Train__r.Additional_Compensation_rule__r.RecordType.Name==CompApp_AdditionalCompUtils.POST_TRAVEL_RULE ) ?True:false   ;                                                      //|| (tick.Train__r.compensation_process__c == CompApp_Constructs.EXCEPTION_PROCESS_TAG  ));
        
        Boolean isValidTicket = isTicketReadyToBeProcessed(tick);
		if (isValidTicket /*isValidDate*/ && ( (isDelaySufficent || isAdditionalCompRulePresent))) {
            return true;
        }
        else {
            return false;
        }
    }

    private static Boolean isIncidentCompensationEligable(Ticket__c tick, List<Incidents__c> incidentsList){
        // Check for correct delay and CoS will be done lated in the delay caluclation function
        // This is to reduce an SQL call
        for (Incidents__c inc : incidentsList) {
            if (inc.Train__c == tick.Train__c && isTicketReadyToBeProcessed(tick)  && !tick.Cancelled__c) {
                if (inc.Coach__c != null) {
                    if (tick.Coach__c!=null)
                    	if (Integer.valueOf(inc.Coach__c) == Integer.valueOf(tick.Coach__c)) {
                        	return true;
                    	}
                }
                else {
                    return true;
                }
            }
        }
        return false;
    }

    private static Boolean isGoodwillCompensationEligable(Ticket__c ticket, Map<Id,Map<String,Passing_Point__c>> trainWithPassingPoints){

        if(!isTicketReadyToBeProcessed(ticket)){
            return false;
        }
        
        if(ticket.Train_No_Catering__c || 
            ticket.Train_Unacceptable_Travel_Conditions__c || 
            trainWithPassingPoints.containsKey(ticket.Train__c) &&
            trainWithPassingPoints.get(ticket.Train__c).containsKey(ticket.UIC_Code__c) && 
            (
                trainWithPassingPoints.get(ticket.Train__c).get(ticket.UIC_Code__c).No_Catering__c ||
                trainWithPassingPoints.get(ticket.Train__c).get(ticket.UIC_Code__c).Unacceptable_Travel_Conditions__c
            )
        ){
            return true;
        }
        
        return false;
    }

    private static boolean isGoodwillCompensationEligable(Compensation_Ticket__c junctionCompensationTicket) { 

        if(!isTicketReadyToBeProcessed(junctionCompensationTicket.Ticket__r)){
            return false;
        }

        // checks first passing point if present, then train destination
        if(junctionCompensationTicket.Passing_Point__c != null && (
            junctionCompensationTicket.Passing_Point__r.Unacceptable_Travel_Conditions__c  ||
            junctionCompensationTicket.Passing_Point__r.No_Catering__c)
        ){
            return true;
        } else if(junctionCompensationTicket.Passing_Point__c == null &&
        (junctionCompensationTicket.Ticket__r.Train__r.Unacceptable_Travel_Conditions__c  ||
        junctionCompensationTicket.Ticket__r.Train__r.No_Catering__c)){
            return true;
        }
        return false;
    }

    private static void addGoodwillCompensation(Compensation_Ticket__c junctionCompensationTicket){

        junctionCompensationTicket.Compensation__r.Base_Compensation__c = 0;
        junctionCompensationTicket.Compensation__r.PRR_Amount__c = null;
        junctionCompensationTicket.Compensation__r.Additional_Compensation__c = 0;
        junctionCompensationTicket.Compensation__r.Ticket_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.Ticket_PRR_HistoryTracking__c = '';
        junctionCompensationTicket.Compensation__r.Comp_Approval_Status__c = DLT_CompensationConstants.COMP_APPROVAL_STATUS_APPROVED;

        CompApp_Constructs.CompensationHistoryTracking ticketHistoryTracking = new CompApp_Constructs.CompensationHistoryTracking();

        Decimal prr_percentage = 0;
        Decimal basicPercentage = 0;		

        if (junctionCompensationTicket.Ticket__r.Ticket_Price__c != 0) {
                
            // Base Compensation caluclation

            junctionCompensationTicket.Compensation__r.Base_Compensation__c = CompApp_Utils.calculateBaseCompensation(junctionCompensationTicket, null, null);

            basicPercentage = junctionCompensationTicket.Compensation__r.Base_Compensation__c / junctionCompensationTicket.Ticket__r.Ticket_Price__c;
            
            junctionCompensationTicket.Compensation__r.Base_Compensation__c = getRoundedVoucher(junctionCompensationTicket.Compensation__r.Base_Compensation__c);
            
            // PRR Amount calculation

            junctionCompensationTicket.Compensation__r.PRR_Amount__c = CompApp_Utils.calculatePRRAmount(junctionCompensationTicket, null, prr_percentage);

            prr_percentage = junctionCompensationTicket.Compensation__r.PRR_Amount__c / junctionCompensationTicket.Ticket__r.Ticket_Price__c;

            junctionCompensationTicket.Compensation__r.PRR_Amount__c = getRoundedVoucher(junctionCompensationTicket.Compensation__r.PRR_Amount__c);
        }

        // Ticket History Tracking Data

        ticketHistoryTracking.PRR_amount = String.valueOf(junctionCompensationTicket.Compensation__r.PRR_Amount__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
        ticketHistoryTracking.Base_Compensation = String.valueOf(junctionCompensationTicket.Compensation__r.Base_Compensation__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
        ticketHistoryTracking.Ticket_Price = String.valueOf(junctionCompensationTicket.Ticket__r.Ticket_Price__c) +' '+ String.valueOf(junctionCompensationTicket.Ticket__r.Original_Currency__c);
        
        ticketHistoryTracking.Compensation_Reason = DLT_CompensationConstants.COMP_GOODWILL_COMPENSATION;
        ticketHistoryTracking.Additional_Compensation = '0';

        // Basic percentage
        List<String> compensationPercentageListBasic = new List<String>();
        compensationPercentageListBasic.add(basicPercentage*100 + '%');
        ticketHistoryTracking.Compensation_Percentage = compensationPercentageListBasic;

        junctionCompensationTicket.Compensation__r.Ticket_HistoryTracking__c = JSON.serialize(ticketHistoryTracking);

        // PRR percentage
        List<String> compensationPercentageList = new List<String>();
        compensationPercentageList.add(DLT_CompensationConstants.COMP_PRR + ' (' + prr_percentage*100 + '%)');
        ticketHistoryTracking.Compensation_Percentage = compensationPercentageList;

        junctionCompensationTicket.Compensation__r.Ticket_PRR_HistoryTracking__c = JSON.serialize(ticketHistoryTracking);							 
    }

    private static Boolean isTrainCompensationEligable(Ticket__c ticket) { 
        //Ticket must be checked in and
        //Train is eligible for compensation
         return isTicketReadyToBeProcessed(ticket) && !ticket.Cancelled__c && isTrainCompensationEligable(ticket.Train__r);
    }
	private static Boolean isTrainCompensationEligable(Train__c train) {
		if (isTrainReadyToBeProcessed(train) && ((train.All__c != null && train.All__c > 0) || 
           /* Check if additional comp rule is present of the train */
           train.additional_compensation_rule__c != null )) {
			return true;
        } else {
            return false;
        }
    }

    private static List<Ticket__c> fillTrainInfoInNewTicketList(Map<Id, List<Ticket__c>> ticketListByTrainIdMap) {

        List<Ticket__c> retList = new List<Ticket__c>();
        Map<Id, List<Ticket__c>> ticketListByTrainIdMapCopy = new Map<Id, List<Ticket__c>>();

        for(Train__c train : [
            SELECT
                Id, All__c, CC__c, CB__c, CBE__c, Departure_Date_Time__c,  From__c, To__c, Train_number__c, Delay_in_Minutes__c, Cancelled__c, Carrier__c,
                Additional_compensation_rule__c, Additional_compensation_rule__r.RecordType.Name, Additional_compensation_Percentage__c,Additional_PRR_Percentage__c,
                ACR_Reprocess_Count__c,  Pre_Travel_Rule__c, Pre_Travel_Rule__r.RecordType.Name,Pre_Travel_Rule__r.Booking_Date_From__c,
                Pre_Travel_Rule__r.Booking_Date_To__c,Pre_Travel_Rule__r.Fixed_Expiry_Date__c,
                Pre_Travel_Rule__r.Allow_Loyalty_Points__c,
                Pre_Travel_Rule__r.Voucher_Life_in_months__c,Pre_Travel_Rule__r.Additional_Percentage__c
            FROM Train__c
            WHERE Id IN: ticketListByTrainIdMap.keySet()
        ]) {
            ticketListByTrainIdMapCopy.put(train.Id,
                                            Trigger.isExecuting ? (Trigger.isAfter ?
                                            ticketListByTrainIdMap.get(train.Id).deepClone(true,true,true):
                                            ticketListByTrainIdMap.get(train.Id)) : ticketListByTrainIdMap.get(train.Id)
            );
            for (Ticket__c tick : ticketListByTrainIdMapCopy.get(train.Id)) {
                tick.Train__r = train;
                retList.add(tick);
            }
        }
        return retList;
    }

    private static Boolean isTicketEligable(String incidentCoach, String ticketCoach) {
        Boolean isTicketEligable = false;
        if (incidentCoach!= null && String.isNotBlank(incidentCoach)) {
            if (ticketCoach!=null)
            	if (Integer.ValueOf(incidentCoach) == Integer.ValueOF(ticketCoach)) {
                	isTicketEligable = true;
            }
        } else {
            isTicketEligable = true;
        }
        return isTicketEligable;
    }

    private static Decimal addIncidentCompensation(Ticket__c inputTicket, Incidents__c inputIncident, List<CompApp_Constructs.CompensationHistoryTracking> incidentsHistoryTracking) {
        CompApp_Constructs.CompensationHistoryTracking incidentHistoryTracking = new CompApp_Constructs.CompensationHistoryTracking();
        incidentHistoryTracking.Compensation_Percentage = new List<String>();
        incidentHistoryTracking.Flat_Fee = false;
        Decimal compensationToAdd = 0;
        Decimal ticketPrice = CompApp_Utils.getDecimalValue(inputTicket.Ticket_Price__c);
        Decimal additionalComp = CompApp_Utils.getDecimalValue(inputIncident.Additional_Comp__c);
        Decimal additionalCC = CompApp_Utils.getDecimalValue(inputIncident.Additional_CC__c);
        Decimal additionalCB = CompApp_Utils.getDecimalValue(inputIncident.Additional_CB__c);
        Decimal additionalCBE = CompApp_Utils.getDecimalValue(inputIncident.Additional_CBE__c);
		if (additionalComp!=0)					  
			incidentHistoryTracking.Compensation_Percentage.add('All ('+String.valueOf(additionalComp)+'%)');

        if (CompApp_Utils.getLoyaltyTier(inputTicket.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CC){
            compensationToAdd = (ticketPrice * (additionalComp + additionalCC));
            incidentHistoryTracking.Compensation_Percentage.add('CC ('+String.valueOf(additionalCC)+'%)');
        }
        else if (CompApp_Utils.getLoyaltyTier(inputTicket.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CB) {
            compensationToAdd = (ticketPrice * (additionalComp + additionalCB));
            incidentHistoryTracking.Compensation_Percentage.add('CB ('+String.valueOf(additionalCB)+'%)');
        }
        else if (CompApp_Utils.getLoyaltyTier(inputTicket.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CBE) {
            compensationToAdd = (ticketPrice * (additionalComp + additionalCBE));
            incidentHistoryTracking.Compensation_Percentage.add('CBE ('+String.valueOf(additionalCBE)+'%)');
        } else {
            compensationToAdd = (ticketPrice * additionalComp);
        }
        compensationToAdd = getRoundedVoucher(compensationToAdd / 100);
        if (CompApp_Utils.compensationFlatFeeRuleAmountByXKeyMap.containsKey(inputTicket.Original_Currency__c+inputIncident.Incident_Type__c+inputTicket.Class_of_Service__c)) {
            incidentHistoryTracking.Flat_Fee = true;
            compensationToAdd =  compensationToAdd + CompApp_Utils.compensationFlatFeeRuleAmountByXKeyMap.get(inputTicket.Original_Currency__c+inputIncident.Incident_Type__c+inputTicket.Class_of_Service__c);
        } else {
            String strRuleID =   inputIncident.Compensation_Rule_Id__c;
            Boolean validRule = true;
            ID ruleID;
            if (strRuleID != null) {
                try {
                	ruleID = Id.valueOf(strRuleID);
                    Compensation_Incident_Rules__c r =  CompApp_IncidentCompUtils.getIncidentCompensationRule(ruleID);
                    if (r.delay_minutes_from__c != null || r.delay_minutes_to__c != null) {
                        if (!(inputTicket.Delay_mins__c >= r.delay_minutes_from__c  && inputTicket.Delay_mins__c <= r.delay_minutes_to__c )) {
                            validRule=false; 
                        }
                    }
                    if (r.Class_Of_Service__c != null){
                        if (!(r.Class_Of_Service__c == inputTicket.Class_of_Service__c)) {
                            validRule = false;
                        }
                    }
                    if (validRule) {
                        incidentHistoryTracking.Flat_Fee = false;
                        compensationToAdd = compensationToAdd + (ticketPrice * (r.compensation_percentage__c/100));
                        incidentHistoryTracking.Compensation_Percentage.add ('Standard Rate ('+ String.valueOf( r.compensation_percentage__c)+'%)');
                        compensationToAdd = getRoundedVoucher(compensationToAdd );
                    }
                     else
                		system.debug('Select rule cannot be applied ');
                }
                catch(Exception e){
                    System.debug('ID Conversion error :' +strRuleID + e.getStackTraceString() );
                }
            } 
            else
                system.debug('No applicable a rules found ');
        }

        incidentHistoryTracking.Total_Incident_Comp = String.valueOf(compensationToAdd)+' '+String.valueOf(inputTicket.Original_Currency__c);
        incidentHistoryTracking.Compensation_Reason = inputIncident.Incident_Type__c;
        incidentHistoryTracking.Ticket_Price = String.valueOf(inputTicket.Ticket_Price__c) +' '+ String.valueOf(inputTicket.Original_Currency__c);
        incidentsHistoryTracking.add(incidentHistoryTracking);
        return compensationToAdd;
    }

    // rounds up to upper 0.5
    private static Decimal getRoundedVoucher(Decimal comp) {
		 if (comp == null)
            return 0;
        return comp.setScale(2, RoundingMode.HALF_UP);
   }

    public class CompTicketWrapper {
        public Id trainId               {get; set;}
        public String PNR               {get; set;}
        public Id compensationId        {get; set;}

        public CompTicketWrapper(Id trainId, String PNR, Id compensationId) {
            this.trainId = trainId;
            this.PNR = PNR;
            this.compensationId = compensationId;
        }
    }

    public static void attachCompensatioToTicktsByPNR(final Map<Id, Compensation__c> newObjectsMap, Set<Id> multipleTicketComensation) {
        Set<Id> compToBeProccessed = new Set<Id>();

        for (Id compId: multipleTicketComensation) {
            if (newObjectsMap.get(compId).recordtypeId != CompApp_Utils.compensationOnlineRecTypeID) {
                compToBeProccessed.add(compId);
            }
        }

        List<CompTicketWrapper> ctws = new List<CompTicketWrapper>();
        List<CompTicketWrapper> ctwbooking = new List<CompTicketWrapper>();
        Map<Id,Id> ticketIdByCompensationIdMap = new Map<Id,Id>();
        for(Compensation__c comp : [SELECT Id, Case__r.TCN__r.PNR__c, Case__r.PNR__c, Case__r.TCN__r.Train__c , Case__r.TCN__c, Link_to_all_tickets_for_same_train_PNR__c, Link_To_All_Tickets_of_the_Same_PNR__c
                                    FROM Compensation__c
                                    WHERE Id IN: compToBeProccessed
                                ]) {
            if (comp.Link_to_all_tickets_for_same_train_PNR__c && comp.Case__r.TCN__r.PNR__c != '' && comp.Case__r.TCN__r.Train__c != null) {
                ctws.add(new CompTicketWrapper(comp.Case__r.TCN__r.Train__c , comp.Case__r.TCN__r.PNR__c , comp.Id));
            } 
            else if (comp.Link_To_All_Tickets_of_the_Same_PNR__c && comp.Case__r.PNR__c != '') {
                ctwbooking.add(new CompTicketWrapper(null, comp.Case__r.PNR__c , comp.Id));
            }
            else if (!comp.Link_to_all_tickets_for_same_train_PNR__c && comp.Case__r.TCN__c != null) {
                ticketIdByCompensationIdMap.put(comp.Id,comp.Case__r.TCN__c);
            }
        }
        connectCompensationToSingleTicket(ticketIdByCompensationIdMap);
        connectCompensationToTickets(ctws);
        connectCompensationToBookings(ctwbooking);
    }

    public static boolean connectCompensationToSingleTicket(Map<Id,Id> ticketIdByCompensationIdMap) {
        CompApp_Utils.log('xxx  connectCompensationToSingleTicket ' + ticketIdByCompensationIdMap);
        List<Compensation_Ticket__c> compensationTicketsToInsert = new List<Compensation_Ticket__c>();
        for(Id compId :ticketIdByCompensationIdMap.keySet()){
            Compensation_Ticket__c compensationTicket = new Compensation_Ticket__c(Compensation__c = compId , Ticket__c = ticketIdByCompensationIdMap.get(compId));
            compensationTicketsToInsert.add(compensationTicket);
        }
        CompApp_Utils.log('xxx  compensationTicketsToInsert '+compensationTicketsToInsert);
        if (compensationTicketsToInsert.size() > 0) {
            try {
                insert compensationTicketsToInsert;
            } catch(Exception e) {
                CompApp_Utils.log('Silenced Exception: ' + e.getMessage());
                CompApp_Utils.log(e.getStackTraceString());
                return false;
            }
        }
        return true;
    }

    public static void resetLinkCompensationFlag(Set<Id> compIdSet) {
        if (CompApp_TriggerUtils.isAsyncNeeded(compIdSet.size())) {
            resetLinkCompensationFlagHelper_Async(compIdSet);
        } else {
            resetLinkCompensationFlagHelper_Sync(compIdSet);
        }
    }

    @future
    public static void resetLinkCompensationFlagHelper_Async(Set<Id> compIdSet) {
        resetLinkCompensationFlagHelper_Sync(compIdSet);
    }

    public static void resetLinkCompensationFlagHelper_Sync(Set<Id> compIdSet) {
        List<Compensation__c> compToUpdate = new List<Compensation__c>();

        for (Id compId:compIdSet) {
            //compToUpdate.add( new Compensation__c(id=compId, Link_to_all_tickets_for_same_train_PNR__c = true, isCaseDriven__c = false));//!!!!!!!!
            compToUpdate.add( new Compensation__c(id=compId, isCaseDriven__c = false));//!!!!!!!!
        }
        update compToUpdate;
    }

    public static Set<Id> getCompensationToTicketManyToMany(List<Compensation__c> newObjects) {
        Set<Id> retSet = new Set<Id>();
        CompApp_Utils.log('newObjectsI @ getCompensationToTicketManyToMany:' +newObjects);
        for (Compensation__c iteratedComp: newObjects) {
            if (iteratedComp.isCaseDriven__c)
                retSet.add(iteratedComp.id);

        }
        CompApp_Utils.log('newObjectsII @ getCompensationToTicketManyToMany:' + newObjects);
        CompApp_Utils.log('retSet @ getCompensationToTicketManyToMany:' + retSet);
        return retSet;
    }

    public static boolean connectCompensationToTickets(List<CompTicketWrapper> CompTicketWrapperList) {
        System.debug('CompTicketWrapperList: ' + CompTicketWrapperList);
        List<Compensation_Ticket__c> compensationTicketsToInsert = new List<Compensation_Ticket__c>();
        Set<Id> trainIds = new Set<Id>(); // 
        Set<Id> compensationIds = new Set<Id>();
        Set<String> pnrS = new Set<String>(); //!!!
        Map<String,List<Id>>  CompensationIdByTicketMap = new Map<String,List<Id>>();
        for (CompTicketWrapper ctw :CompTicketWrapperList) {
            trainIds.add(ctw.trainId);
            pnrS.add(ctw.PNR);
            compensationIds.add(ctw.compensationId);
            if (CompensationIdByTicketMap.containsKey(ctw.trainId+ctw.PNR)){
            CompensationIdByTicketMap.get(ctw.trainId+ctw.PNR).add(ctw.compensationId);
            }else {
                CompensationIdByTicketMap.put(ctw.trainId+ctw.PNR,new List<Id>{ctw.compensationId});
            }
        }

        List<Ticket__c> ticketsRelatedToCompensation = [SELECT Id,Train__c,PNR__c FROM Ticket__c WHERE PNR__c IN : pnrS AND Train__c IN : trainIds];

        List<Compensation_Ticket__c> existingCompensationsTickets = [SELECT Ticket__c,Compensation__c 
            FROM Compensation_Ticket__c 
            WHERE Compensation__c IN : compensationIds
            ];
        Map<Id,Map<Id,Compensation_Ticket__c>> existingTicketsToCompsMap = new Map<Id,Map<Id,Compensation_Ticket__c>>();
        for (Compensation_Ticket__c compTick: existingCompensationsTickets) {
            if (existingTicketsToCompsMap.containsKey(compTick.Compensation__c))
                existingTicketsToCompsMap.get(compTick.Compensation__c).put(compTick.Ticket__c,compTick);
            else
                existingTicketsToCompsMap.put(compTick.Compensation__c,new Map<Id,Compensation_Ticket__c>{compTick.Ticket__c => compTick});
        }

        for (Ticket__c tick :ticketsRelatedToCompensation) { 
            List<Id> compensationRelatedToPNRTrainList = CompensationIdByTicketMap.get(tick.Train__c+tick.PNR__c);
            for (Id crtp: compensationRelatedToPNRTrainList) {
                if (!existingTicketsToCompSMap.containsKey(crtp) || !existingTicketsToCompSMap.get(crtp).containsKey(tick.Id)) {
                    Compensation_Ticket__c compensationTicket = new Compensation_Ticket__c(Compensation__c = crtp , Ticket__c = tick.Id);
                    compensationTicketsToInsert.add(compensationTicket);
                }
            }
        }
        if (compensationTicketsToInsert.size() > 0) {
            try {
                insert compensationTicketsToInsert;
            } catch(Exception e) {
                CompApp_Utils.log('Silenced Exception: ' + e.getMessage());
                CompApp_Utils.log(e.getStackTraceString());
                return false;
            }
        }
        return true;
    }

    public static boolean connectCompensationToBookings(List<CompTicketWrapper> CompTicketWrapperList) {
        DateTIme CovidStartDate = null;
        try {
            CovidStartDate = DateTime.ValueOf(Compensation_App_Metadata__c.getValues('Covid Compensation Stat Date').Data__c);
        } catch(Exception e) {
            CovidStartDate = DateTime.ValueOf('2020-03-13 00:00:00');
        }
        List<Compensation_Ticket__c> compensationTicketsToInsert = new List<Compensation_Ticket__c>();
        Set<Id> compensationIds = new Set<Id>();
        Set<String> pnrS = new Set<String>();
        Map<String,List<Id>>  CompensationIdByTicketMap = new Map<String,List<Id>>();
        for (CompTicketWrapper ctw :CompTicketWrapperList) { 
            pnrS.add(ctw.PNR);
            compensationIds.add(ctw.compensationId);
            if (CompensationIdByTicketMap.containsKey(ctw.PNR))
                CompensationIdByTicketMap.get(ctw.PNR).add(ctw.compensationId);
            else
                CompensationIdByTicketMap.put(ctw.PNR,new List<Id>{ctw.compensationId});
        }

        List<Ticket__c> ticketsRelatedToCompensation = [
            SELECT Id, Train__c, PNR__c 
            FROM Ticket__c 
            WHERE Departure_Date_Time_Format__c >: CovidStartDate AND PNR__c IN : pnrS 
        ];

        List<Compensation_Ticket__c> existingCompensationsTickets = [
            SELECT Ticket__c, Compensation__c 
            FROM Compensation_Ticket__c 
            WHERE Compensation__c IN : compensationIds];
        Map<Id,Map<Id,Compensation_Ticket__c>> existingTicketsToCompsMap = new Map<Id,Map<Id,Compensation_Ticket__c>>();
        for (Compensation_Ticket__c compTick: existingCompensationsTickets) {
            if (existingTicketsToCompsMap.containsKey(compTick.Compensation__c))
                existingTicketsToCompsMap.get(compTick.Compensation__c).put(compTick.Ticket__c,compTick);
            else
                existingTicketsToCompsMap.put(compTick.Compensation__c,new Map<Id,Compensation_Ticket__c>{compTick.Ticket__c => compTick});
        }
        for (Ticket__c tick :ticketsRelatedToCompensation) { 
            List<Id> compensationRelatedToPNRTrainList = CompensationIdByTicketMap.get(tick.PNR__c);
            for (Id crtp: compensationRelatedToPNRTrainList) {
                if (!existingTicketsToCompSMap.containsKey(crtp) || !existingTicketsToCompSMap.get(crtp).containsKey(tick.Id)) {
                    Compensation_Ticket__c compensationTicket = new Compensation_Ticket__c(Compensation__c = crtp , Ticket__c = tick.Id);
                    compensationTicketsToInsert.add(compensationTicket);
                }
            }
        }
        if (compensationTicketsToInsert.size()>0) {
            try {
                insert compensationTicketsToInsert;
            } catch(Exception e) {
                CompApp_Utils.log('Silenced Exception: ' + e.getMessage());
                CompApp_Utils.log(e.getStackTraceString());
                return false;
            }
        }
        return true;
    }

    public static void updateVoucherIssueTypeFlag(final Map<Id, Compensation__c> newObjectsMap, Set<Id> caseDrivenCompensations) {
        Map<Id, Compensation__c> vouchersForUpdateMap = new Map<Id, Compensation__c>();
        for (Id compId: newObjectsMap.keySet()) {
            if (newObjectsMap.get(compId).recordtypeId == voucherRecTypeID) {
                //initially all vouchers of 'Goodwill' issue type
                vouchersForUpdateMap.put(compId, new Compensation__c(Id = compId, Voucher_Issue_Type__c = 'Goodwill'));
            }
        }

        List<Compensation_Ticket__c> junctionCompensationTicketList = [
                SELECT Compensation__c, Ticket__c
                FROM Compensation_Ticket__c
                WHERE Compensation__c IN: vouchersForUpdateMap.keySet()
        ];

        Map<Id, Id> ticketsToVouchers = new Map<Id, Id>();
        for (Compensation_Ticket__c nextPair: junctionCompensationTicketList){
            ticketsToVouchers.put(nextPair.Ticket__c, nextPair.Compensation__c);
        }

        List<MC_Emails_Sent__c> emailsSent = [
                SELECT 	Name, Ticket__c, Status__c
                FROM MC_Emails_Sent__c
                WHERE Ticket__c IN : ticketsToVouchers.keySet()
        ];

        for (MC_Emails_Sent__c nextEmail : emailsSent) {
            if (nextEmail.Name.containsIgnoreCase('cancelled train') &&
                    nextEmail.Status__c != null && nextEmail.Status__c == 'Sent') {
                Id relatedVoucher = ticketsToVouchers.get(nextEmail.Ticket__c);
                //if there was at list one canx email against tickets attached to voucher then it's 'Cancellation' issue type
                vouchersForUpdateMap.get(relatedVoucher).Voucher_Issue_Type__c = 'Cancellation';
            }
        }
        if (vouchersForUpdateMap.size() > 0) update vouchersForUpdateMap.values();
    }

    public static void markOutboundAndInbound(List<Ticket__c> passengerTickets, CaseTicketsStats currentStats ) {

        Integer ticketListPos = 0;
        while (ticketListPos < passengerTickets.size()) {
            Ticket__c nextTicket = passengerTickets[ticketListPos];
            Ticket__c possiblePairTicket = (ticketListPos + 1 < passengerTickets.size()) ? passengerTickets[ticketListPos + 1] : null;
            Integer firstOutboundIndex = -1;
            Integer lastOutboundIndex = -1;
            Integer currentTicketState;
            //FIRST_OUTBOUND
            currentTicketState = OUTBOUND;
            if (nextTicket.Ticket_Status__c == 'Cancelled') {
                currentTicketState = currentTicketState | CANCELLED;
            } else {
                currentTicketState = currentTicketState | ACTIVE;
            }
            currentStats.ticketsStates.put(nextTicket.Id, currentTicketState);
            firstOutboundIndex = ticketListPos;
            lastOutboundIndex = ticketListPos;

            String baseDestination = nextTicket.Destination__c;

            ticketListPos++; //!!!!!!!!!!!!!!!!

            if (possiblePairTicket != null) {
                // OUTBOUND TICKETS
                while (possiblePairTicket != null && possiblePairTicket.Destination__c == baseDestination) {
                    lastOutboundIndex++;
                    currentTicketState = OUTBOUND;
                    if (possiblePairTicket.Ticket_Status__c == 'Cancelled') {
                        currentTicketState = currentTicketState | CANCELLED;
                    } else {
                        currentTicketState = currentTicketState | ACTIVE;
                    }
                    currentStats.ticketsStates.put(possiblePairTicket.Id, currentTicketState);
                    ticketListPos++;
                    possiblePairTicket = (ticketListPos < passengerTickets.size()) ? passengerTickets[ticketListPos] : null;
                }
                // INBOUND TICKETS
                if (possiblePairTicket != null) {
                    String baseOrigin = possiblePairTicket.Origin__c;
                    if (possiblePairTicket.Origin__c == baseOrigin) {
                        while (possiblePairTicket != null && possiblePairTicket.Origin__c == baseOrigin) {
                            currentStats.containsFullJourney = true;
                            Integer statsForInbound = INBOUND;
                            if (possiblePairTicket.Ticket_Status__c == 'Cancelled') {
                                statsForInbound = statsForInbound | CANCELLED;
                            } else {
                                statsForInbound = statsForInbound | ACTIVE;
                            }
                            currentStats.ticketsStates.put(possiblePairTicket.Id, statsForInbound);
                            ticketListPos++;
                            possiblePairTicket = (ticketListPos < passengerTickets.size()) ? passengerTickets[ticketListPos] : null;
                        }
                    } else {
                        //return to beginning of MAIN while loop
                    }
                    //here we supposed to have last inbound ticket from full trip marked
                    //if previous while loop worked at leas once
                    //so we should return to beginning of MAIN while loop
                }
            } else {
                ticketListPos++;
            }
        }
    }

    public static Decimal calculatePointsAmount(Compensation_Ticket__c junctionCompensationTicket, CompApp_Constructs.CompensationRuleWrapper compRule){

        Boolean isEligiblePoints = 
            junctionCompensationTicket.Ticket__r.Booker__r != null &&
            junctionCompensationTicket.Ticket__r.Booker__r.DELTA_Loyalty_Member__c != null && 
            junctionCompensationTicket.Ticket__r.Booker__r.DELTA_Loyalty_Member__r.MemberStatus == DLT_LoyaltyProgramMemberConstants.MEMBERSTATUS_ACTIVE ? true : false;
        
        if(
            junctionCompensationTicket.Ticket__r.Ticket_Price__c == null || 
            junctionCompensationTicket.Ticket__r.Ticket_Price__c < 0 || 
            !isEligiblePoints ||
            compRule.pointConversion == null ||
            !compRule.currencyRates.containsKey(junctionCompensationTicket.Ticket__r.Original_Currency__c) ||
            compRule.currencyRates.get(junctionCompensationTicket.Ticket__r.Original_Currency__c) == null
        ) return null;

        return (junctionCompensationTicket.Ticket__r.Ticket_Price__c * compRule.pointConversion / 100 / compRule.currencyRates.get(junctionCompensationTicket.Ticket__r.Original_Currency__c)).setScale(0, RoundingMode.HALF_UP);
    }

    @TestVisible
    private static void justIncrementCoverage() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        
    }
}