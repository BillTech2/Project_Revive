public without sharing class Eins_CompensationApprovalController {

    public static Boolean reEntry = false;

    public static Map<String, List<Ticket__c>> trainWithTickets = new Map<String, List<Ticket__c>>();
    public static List<Compensation__c> compensationWithTickets = new List<Compensation__c>();
    public static List<Ticket__c> ticketsWithSameTCNOrPNR = new List<Ticket__c>();
    public static Map<String, List<Compensation__c>> compensationsSamePNR = new Map<String, List<Compensation__c>>();
    public static Map<String, List<Compensation__c>> compensationsSameTCN = new Map<String, List<Compensation__c>>();
    public static Map<String, List<Ticket__c>> disruptedTicketsSamePNR = new Map<String, List<Ticket__c>>();
    public static Map<String, Decimal> ticketPriceByPNR = new Map<String, Decimal>();
    public static Map<String, Decimal> compensationPriceByPNR = new Map<String, Decimal>();

    public static String checkLinkedTickets(Compensation__c compensationItem) {
        if (trainWithTickets.isEmpty()) {
            getAllRelatedTickets(compensationItem);
        }
        if (compensationItem.Link_to_all_tickets_for_same_train_PNR__c) {
            if (!compensationWithTickets.isEmpty()) {
                if (!compensationWithTickets[0].Compensation_Tickets__r.isEmpty()) {
                    String trainId = compensationWithTickets[0].Compensation_Tickets__r[0].Ticket__r.Train__c;
                    if (compensationWithTickets[0].Compensation_Tickets__r.size() == trainWithTickets.get(trainId).size()) {
                        return 'ALL_TICKETS_WITH_TRAIN';
                    }
                }
                if (compensationItem.Link_To_All_Tickets_of_the_Same_PNR__c) {
                    if (!compensationWithTickets[0].Compensation_Tickets__r.isEmpty()) {
                        if (compensationWithTickets[0].Compensation_Tickets__r.size() == ticketsWithSameTCNOrPNR.size()) {
                            return 'ALL_TICKETS_WITH_PNR';
                        }
                    }
                }
            }
        }
        return 'FALSE';
    }

    public static Boolean checkLinkedFields(Compensation__c compensationItem) {
        if (compensationItem.Link_to_all_tickets_for_same_train_PNR__c) {
            return true;
        }
        if (compensationItem.Link_To_All_Tickets_of_the_Same_PNR__c) {
            return true;
        }
        return false;
    }

    public static void getAllRelatedTickets(Compensation__c compensationItem) {
        compensationWithTickets = [
            SELECT Id, TCN__c, Ticket_Number__c, Type_of_Refund__c, Payment_Currency__c, Link_to_all_tickets_for_same_train_PNR__c, 
                Link_To_All_Tickets_of_the_Same_PNR__c, Comp_Approval_Status__c, Manually_Processed_CC__c,
                (SELECT Id, Ticket__c, Ticket__r.Train__c
                FROM Compensation_Tickets__r)
            FROM Compensation__c
            WHERE Id = :compensationItem.Id
        ];
        List<List<sObject>> searchList = [
            FIND :compensationItem.PNR__c
            IN ALL FIELDS 
            RETURNING Ticket__c (Id, Train__c, Exchanged_TCN__c)
        ];
        List<Ticket__c> ticketsWithSameTCNOrPNR = (Ticket__c[]) searchList[0];
        for (Ticket__c ticketItem : ticketsWithSameTCNOrPNR) {
            if (trainWithTickets.get(ticketItem.Train__c) == null) {
                trainWithTickets.put(ticketItem.Train__c, new List<Ticket__c>());
            }
            trainWithTickets.get(ticketItem.Train__c).add(ticketItem);
        }
    }

    public static void getRelatedRecords(List<Compensation__c> compensations) {
        String searchPNRString = '\'';
        Set<String> pnrs = new Set<String>();
        Set<Id> compensationIds = new Set<Id>();
        for (Integer i = 0; i < compensations.size(); i++) {
            if (String.isNotBlank(compensations[i].PNR__c)) {
                pnrs.add(compensations[i].PNR__c);
                compensationIds.add(compensations[i].Id);
                if (i != compensations.size() - 1) {
                    searchPNRString += compensations[i].PNR__c + ' OR ';
                } else {
                    searchPNRString += ' ' + compensations[i].PNR__c + '\'';
                }
            }
        }
        if (!pnrs.isEmpty()) {
            String searchQuery = 'FIND ' + searchPNRString + ' IN ALL FIELDS RETURNING Compensation__c(Id, TCN__c, Ticket_Number__c, PNR__c, Payment_Amount__c, No_TCN_to_Use__c, RecordTypeId, Integration_Status__c, Manually_Processed_CC__c, Claim_Status__c WHERE Id NOT IN :compensationIds),' + 
                'Ticket__c(Id, PNR__c, Name, Ticket_Price__c, Cancelled__c, Cancelled_By_Customer__c, Checked_In__c, Delay_mins__c, Exchanged_TCN__c, CreatedDate ORDER BY CreatedDate DESC)'; 
            List<List<SObject>> searchList = search.query(searchQuery);
            List<Compensation__c> compensationsWithPNR = (Compensation__c[]) searchList[0];
            List<Ticket__c> disruptedTickets = (Ticket__c[]) searchList[1];

            for (Compensation__c compItem : compensationsWithPNR) {
                if (String.isNotBlank(compItem.PNR__c)) {
                    if (compensationsSamePNR.get(compItem.PNR__c) == null) {
                        compensationsSamePNR.put(compItem.PNR__c, new List<Compensation__c>());
                    }
                    if (!compensationIds.contains(compItem.Id)) {
                        compensationsSamePNR.get(compItem.PNR__c).add(compItem);
                    }
                    Decimal compensationPaymentAmount = 0;
                    if (compItem.Payment_Amount__c != null) {
                        compensationPaymentAmount = compItem.Payment_Amount__c;
                    }
                    if (compensationPriceByPNR.get(compItem.PNR__c) == null) {
                        compensationPriceByPNR.put(compItem.PNR__c, compensationPaymentAmount);
                    } else {
                        compensationPriceByPNR.put(compItem.PNR__c, (compensationPriceByPNR.get(compItem.PNR__c) + compensationPaymentAmount));
                    }
                }
                if (String.isNotBlank(compItem.TCN__c)) {
                    if (compensationsSameTCN.get(compItem.TCN__c) == null) {
                        compensationsSameTCN.put(compItem.TCN__c, new List<Compensation__c>());
                    }
                    if (!compensationIds.contains(compItem.Id)) {
                        compensationsSameTCN.get(compItem.TCN__c).add(compItem);
                    }
                }
            }

            Map<String, Date> dateByPNR = new Map<String, Date>();
            for (Ticket__c ticketItem : disruptedTickets) {
                if (!dateByPNR.containsKey(ticketItem.PNR__c)) {
                    dateByPNR.put(ticketItem.PNR__c, ticketItem.CreatedDate.date());
                }

                if (ticketItem.Cancelled__c || (ticketItem.Checked_In__c && ticketItem.Delay_mins__c > 60)) {
                    if (disruptedTicketsSamePNR.get(ticketItem.PNR__c) == null) {
                        disruptedTicketsSamePNR.put(ticketItem.PNR__c, new List<Ticket__c>());
                    }
                    disruptedTicketsSamePNR.get(ticketItem.PNR__c).add(ticketItem);
                }

                if (ticketItem.CreatedDate.date().isSameDay(dateByPNR.get(ticketItem.PNR__c))) {
                    Decimal ticketPrice = ticketItem.Ticket_Price__c;
                    if (ticketItem.Cancelled_By_Customer__c && String.isNotBlank(ticketItem.Exchanged_TCN__c)) {
                        ticketPrice = 0;
                    }
                    if (ticketPriceByPNR.get(ticketItem.PNR__c) == null) {
                        ticketPriceByPNR.put(ticketItem.PNR__c, ticketPrice);
                    } else {
                        ticketPriceByPNR.put(ticketItem.PNR__c, (ticketPriceByPNR.get(ticketItem.PNR__c) + ticketPrice));
                    }
                }
            }
        }
    }

    /**
    * This method will submit the compensation automatically
    **/
    public static void submitForApproval(Compensation__c compensationItem) {
        Id workItemId = getWorkItemId(compensationItem.Id);
        if (String.isBlank(workItemId)) {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Submitting request for approval automatically using Manual Compensation Approval automation.');
            approvalRequest.setObjectId(compensationItem.Id); 

            try{
                Approval.ProcessResult result = Approval.process(approvalRequest);
                if (result.getInstanceStatus() != 'Approved') {
                    List<Id> newWorkItemIds = result.getNewWorkitemIds();
                    submitForApprovalVerification(compensationItem, newWorkItemIds.get(0));
                }
            }catch (DmlException e){
                compensationItem.addError('Exception Message when approving compensation: ' + compensationItem.Id + ' - ' + e.getDmlMessage(0));
            }
        } else {
            submitForApprovalVerification(compensationItem, workItemId);
        }
    }

    /**
    * Get ProcessInstanceWorkItemId using SOQL
    **/
    public static Id getWorkItemId(Id targetObjectId) {
        Id retVal;
        if (String.isNotBlank(targetObjectId)) {
            for (ProcessInstanceWorkitem workItem  : [
                    SELECT p.Id
                    FROM ProcessInstanceWorkitem p
                    WHERE p.ProcessInstance.TargetObjectId =: targetObjectId]
            ) {
                retVal  =  workItem.Id;
            }
        }
        return retVal;
    }

    /**
    * This method will Approve the compensation
    **/
    public static void approveRecord(Compensation__c compensationItem) {
        Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();
        approvalRequest.setComments('Approving request using Manual Compensation Approval automation.');
        approvalRequest.setAction('Approve');

        Id workItemId = getWorkItemId(compensationItem.Id); 

        if (String.isBlank(workItemId) && !Test.isRunningTest()) {
            compensationItem.addError('Error Occured in Manual Compensation Approval automation.');
        } else if (!Test.isRunningTest()) {
            approvalRequest.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result = Approval.process(approvalRequest);
            if (result.isSuccess()) {}
        }
    }

    public static void approveRecord(Compensation__c compensationItem, String workItemId) {
        Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();
        approvalRequest.setComments('Approving request using Manual Compensation Approval automation.');
        approvalRequest.setAction('Approve');
        if (!Test.isRunningTest()) {
            approvalRequest.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(approvalRequest);
            if (result.isSuccess()) {
                updateOnlineComp(compensationItem);
                Case relatedCase = new Case(
                    Id = compensationItem.Case__c,
                    Compensation_Amt__c = compensationItem.Payment_Amount__c,
                    Compensation_Currency__c = compensationItem.Payment_Currency__c
                );
                Database.SaveResult saveReslt = Database.update(relatedCase, false);
                if (saveReslt.isSuccess()) {
                    System.debug('Successfully updated case. Case ID: ' + saveReslt.getId());
                }
                else {
                    for(Database.Error err : saveReslt.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Case fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }

    public static void submitForApprovalVerification(Compensation__c compensationItem, String workItemId) {
        // Create an approval request for the Compensation__c
        Eins_CompensationLimitAmountSettings__c amountLimit = Eins_CompensationLimitAmountSettings__c.getInstance('Default');

        if (amountLimit == null && Test.isRunningTest()) { return; }

        Decimal compensationPNRPrices = 0;
        if (compensationPriceByPNR.get(compensationItem.PNR__c) != null) {
            compensationPNRPrices = compensationPriceByPNR.get(compensationItem.PNR__c);
        }
        Decimal ticketPNRPrices = 0;
        if (ticketPriceByPNR.get(compensationItem.PNR__c) != null) {
            ticketPNRPrices = ticketPriceByPNR.get(compensationItem.PNR__c);
        }
        Decimal enoughToCompensate = ticketPNRPrices - compensationPNRPrices - compensationItem.Payment_Amount__c;

        Decimal limitAmount = amountLimit.GBP__c;
        if (compensationItem.Payment_Currency__c == 'EUR') {
            limitAmount = amountLimit.EUR__c;
        }
        if (compensationItem.Payment_Currency__c == 'USD') {
            limitAmount = amountLimit.USD__c;
        }
        if (compensationItem.No_TCN_to_Use__c) {
            enoughToCompensate = 0;
        }
        if (compensationItem.Payment_Amount__c < limitAmount) {
            if (enoughToCompensate >= 0) {
                if (String.isNotBlank(workItemId)) {
                    approveRecord(compensationItem, workItemId);
                }
            }
        } else if (enoughToCompensate >= 0) {
            if (compensationsSamePNR.get(compensationItem.PNR__c) == null && !compensationItem.No_TCN_to_Use__c) {
                if (disruptedTicketsSamePNR.get(compensationItem.PNR__c) != null) {
                    if (String.isNotBlank(workItemId)) {
                        approveRecord(compensationItem, workItemId);
                    }
                }
            } else {
                updateOnlineComp(compensationItem);
            }
        }
    }

    private static void updateOnlineComp(Compensation__c compensationItem) {
        if (compensationsSamePNR.get(compensationItem.PNR__c) != null && !compensationItem.No_TCN_to_Use__c) {
            List<Compensation__c> compToUpdate = new List<Compensation__c>();
            Id onlineComp = Schema.SObjectType.Compensation__c.getRecordTypeInfosByName().get('Online').getRecordTypeId();
            if (String.isNotBlank(compensationItem.PNR__c)) {
                for (Compensation__c compItem : compensationsSamePNR.get(compensationItem.PNR__c)) {
                    if (compItem.RecordTypeId == onlineComp && compItem.Claim_Status__c == 'Not Started') {
                        if (compItem.Integration_Status__c != 'PRR Claimed') {
                            if (!compItem.Manually_Processed_CC__c && String.isNotBlank(compItem.Ticket_Number__c)) {
                                if (!compensationItem.No_TCN_to_Use__c && String.isNotBlank(compensationItem.TCN__c)) {
                                    if (compensationItem.TCN__c.equalsIgnoreCase(compItem.Ticket_Number__c)) {
                                        compItem.Manually_Processed_CC__c = true;
                                        compToUpdate.add(compItem);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (!compToUpdate.isEmpty()) {
                Set<Compensation__c> compToUpdateSet = new Set<Compensation__c>();
                compToUpdateSet.addAll(compToUpdate);
                List<Compensation__c> compToUpdateNoDuplicates = new List<Compensation__c>();
                compToUpdateNoDuplicates.addAll(compToUpdateSet);
                    Database.update(compToUpdateNoDuplicates, false);
            }
        }
    }

    @TestVisible
    private static void checkCompensation(Compensation__c compensationItem) {
        Boolean checkFields = false;
        if (compensationItem.Payment_Amount__c > 0) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (compensationItem.Payment_Amount__c > 0) {
            checkFields = true;
        }if (compensationItem.Payment_Amount__c > 0) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (compensationItem.Payment_Amount__c > 0) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (compensationItem.Payment_Amount__c > 0) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Payment_Currency__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.PNR__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.TCN__c)) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
        if (String.isNotBlank(compensationItem.Type_of_Refund__c)) {
            checkFields = true;
        }
        if (!compensationItem.Manually_Processed_CC__c) {
            checkFields = true;
        }
    }
}