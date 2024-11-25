public without sharing class Eins_TaskTriggerHandler {
    public static void updateCase(List<NVMStatsSF__NVM_Call_Summary__c> callSummaries) {
        Map<String, Case> casesByCallSummary = new Map<String, Case>();
        Map<String, Id> callsByCallGuid = new Map<String, Id>();
        String searchGuidString = '{';
        Set<Id> callSummariesIds = new Set<Id>();
        Set<Id> callSummariesWithCategories = new Set<Id>();
        for (Integer i = 0; i < callSummaries.size(); i++) {
            callSummariesIds.add(callSummaries[i].Id);
            if (String.isNotBlank(callSummaries[i].NVMStatsSF__CallGuid__c)) {
                callsByCallGuid.put(callSummaries[i].NVMStatsSF__CallGuid__c, callSummaries[i].Id);
                if (i != callSummaries.size() - 1) {
                    searchGuidString += ' "' + callSummaries[i].NVMStatsSF__CallGuid__c + '" OR';
                } else {
                    searchGuidString += ' "' + callSummaries[i].NVMStatsSF__CallGuid__c + '"}';
                }
            }
            if (String.isNotBlank(callSummaries[i].NVMStatsSF__Categories__c)) {
                callSummariesWithCategories.add(callSummaries[i].Id);
            }
        }
        searchGuidString = searchGuidString.replace('-', '\\-');

        if (!callSummariesWithCategories.isEmpty()) {
            try {
                String searchQuery = 'FIND ' + searchGuidString + ' IN ALL FIELDS RETURNING Case(Id, Status, Do_Not_Update_From_Call__c, PNR__c, Initial_Reason_For_Contact__c, Journey_Type_Product__c, Customer_Type__c, Sundry__c, Travel_Based_Disruption__c, Alternative_Disruption__c, Loyalty_Topic__c, Loyalty_Category__c, Type_of_Assistance__c, Booking_Type__c, Technical_Issue__c, Using_The_App__c, Customer_Issue__c, What_Is_The_Question__c, Area_On_Website__c, Customer_Struggle__c, Tone_of_Contact__c, Vonage_Call_Summary__c, Subject, Call_GUID__c ORDER BY LastModifiedDate DESC)'; 
                System.debug(searchQuery);
                List<List<SObject>> searchList = search.query(searchQuery);
                // List<Case> cases = [
                //     SELECT Id, PNR__c, Initial_Reason_For_Contact__c, Journey_Type_Product__c,
                //         Customer_Type__c, Sundry__c, Travel_Based_Disruption__c, Alternative_Disruption__c,
                //         Loyalty_Topic__c, Loyalty_Category__c, Type_of_Assistance__c, Booking_Type__c,
                //         Technical_Issue__c, Using_The_App__c, Customer_Issue__c, What_Is_The_Question__c,
                //         Area_On_Website__c, Customer_Struggle__c, Tone_of_Contact__c, Vonage_Call_Summary__c,
                //         Subject, Call_GUID__c
                //     FROM Case
                //     WHERE Vonage_Call_Summary__c IN : callSummariesIds
                //     ORDER BY LastModifiedDate DESC
                // ];
                List<Case> cases = (Case[]) searchList[0];
                for (Case caseItem : cases) {
                    if (String.isNotBlank(caseItem.Vonage_Call_Summary__c)) {
                        if (casesByCallSummary.get(caseItem.Vonage_Call_Summary__c) == null) {
                            casesByCallSummary.put(caseItem.Vonage_Call_Summary__c, caseItem);
                        }
                    } else if (String.isNotBlank(caseItem.Call_GUID__c)) {
                        if (callsByCallGuid.get(caseItem.Call_GUID__c) != null) {
                            if (casesByCallSummary.get(callsByCallGuid.get(caseItem.Call_GUID__c)) == null) {
                                casesByCallSummary.put(callsByCallGuid.get(caseItem.Call_GUID__c), caseItem);
                            }
                        }
                    }
                }

                updateCase(callSummaries, casesByCallSummary);
            } catch (Exception e) {
                System.debug('Call Summary Trigger error: ' + e.getMessage());
            }
        }
    }

    public static void updateCase(List<NVMStatsSF__NVM_Call_Summary__c> callSummaries, Map<String, Case> casesByCallSummaryToUpdate) {
        List<Case> casesToUpdate = new List<Case>();
        for (NVMStatsSF__NVM_Call_Summary__c callSummary : callSummaries) {
            Case caseItem = casesByCallSummaryToUpdate.get(callSummary.Id);
            if (caseItem != null) {
                if (!caseItem.Do_Not_Update_From_Call__c && String.isNotBlank(callSummary.NVMStatsSF__Categories__c)) {
                    if (callSummary.Initial_Reason_for_Contact__c) {
                        caseItem = updateInitialReasonforContact(caseItem, callSummary);
                    }
                    if (callSummary.Information_Topic__c) {
                        caseItem = updateTopic(caseItem, callSummary);
                    }
                    if (callSummary.Disruption__c) {
                        caseItem = updateDisruption(caseItem, callSummary);
                    }
                    if (callSummary.Route_or_Product__c) {
                        caseItem = updateRouteOrProduct(caseItem, callSummary);
                    }
                    if (callSummary.Loyalty__c) {
                        caseItem = updateLoyaltyTopic(caseItem, callSummary);
                    }
                    if (callSummary.Assistance__c) {
                        caseItem = updateAssistance(caseItem, callSummary);
                    }
                    if (callSummary.Trade_and_GDS__c) {
                        caseItem = updateTradeAndGDS(caseItem, callSummary);
                    }
                    if (callSummary.Staff_Travel__c) {
                        caseItem = updateStaffTravel(caseItem, callSummary);
                    }
                    if (callSummary.Groups__c) {
                        caseItem = updateGroups(caseItem, callSummary);
                    }
                    if (callSummary.Technical_Issue__c) {
                        caseItem = updateTechnicalIssue(caseItem, callSummary);
                    }
                    if (callSummary.Customer_Struggle__c) {
                        caseItem = updateCustomerStruggle(caseItem, callSummary);
                    }
                    if (callSummary.Area_of_website__c) {
                        caseItem = updateAreaOfWebsite(caseItem, callSummary);
                    }
                    if (callSummary.Customer_Experience__c) {
                        caseItem = updateCustomerExperience(caseItem, callSummary);
                    }
    
                    if (String.isNotBlank(callSummary.NVMStatsSF__Categories__c)) {
                        caseItem.Subject = '';
                        if (caseItem.Status == 'New') {
                            caseItem.Status = 'Closed';
                        }
                        if (String.isBlank(caseItem.Vonage_Call_Summary__c) || (caseItem.Vonage_Call_Summary__c != callSummary.Id)) {
                            caseItem.Vonage_Call_Summary__c = callSummary.Id;
                        }
                    } else {
                        caseItem.Subject = 'Values are not updated within this case';
                    }
                    casesToUpdate.add(caseItem);
                }
                if (String.isBlank(caseItem.Vonage_Call_Summary__c) || (caseItem.Vonage_Call_Summary__c != callSummary.Id)) {
                    caseItem.Vonage_Call_Summary__c = callSummary.Id;
                    casesToUpdate.add(caseItem);
                }
            }
        }

        try {
            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }
        } catch (Exception exept) {
            System.debug(exept);
        }

    }

    public static Case updateInitialReasonforContact(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> initialReasons = new List<Decimal>{
            callSummary.Initial_Reason_for_Contact_Book__c, callSummary.Initial_Reason_for_Contact_Information__c,
            callSummary.Initial_Reason_for_Contact_Change__c, callSummary.Initial_Reason_for_Contact_Cancel_or_Ref__c,
            callSummary.Initial_Reason_for_Contact_Disruption__c, callSummary.Initial_Reason_for_Contact_Feedback__c
        };
        initialReasons.sort();
        Decimal maxValue = initialReasons[initialReasons.size() - 1];
        if (maxValue == callSummary.Initial_Reason_for_Contact_Book__c && maxValue > 0) {
            caseItem.Initial_Reason_For_Contact__c = 'Buy or Book';
        }
        if (maxValue == callSummary.Initial_Reason_for_Contact_Information__c && maxValue > 0) {
            caseItem.Initial_Reason_For_Contact__c = 'Info or Advice or Confirmation';
        }
        if (maxValue == callSummary.Initial_Reason_for_Contact_Change__c && maxValue > 0) {
            caseItem.Initial_Reason_For_Contact__c = 'Change';
        }
        if (maxValue == callSummary.Initial_Reason_for_Contact_Cancel_or_Ref__c && maxValue > 0) {
            caseItem.Initial_Reason_For_Contact__c = 'Cancel or Refund';
        }
        if (maxValue == callSummary.Initial_Reason_for_Contact_Disruption__c && maxValue > 0) {
            caseItem.Initial_Reason_For_Contact__c = 'Disruption or Compensation';
        }
        if (maxValue == callSummary.Initial_Reason_for_Contact_Feedback__c && maxValue > 0) {
            caseItem.Initial_Reason_For_Contact__c = 'Feedback';
        }

        return caseItem;
    }

    public static Case updateRouteOrProduct(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> topics = new List<Decimal>{
            callSummary.Route_or_Product_Core_routes__c, callSummary.Route_or_Product_Kent_Stations__c,
            callSummary.Route_or_Product_Disney__c, callSummary.Route_or_Product_Dutch_Routes__c,
            callSummary.Route_or_Product_Connections__c, callSummary.Route_or_Product_Ski__c, 
            callSummary.Route_or_Product_LSOF__c, callSummary.Route_or_Product_Child_Standalone__c,
            callSummary.Route_or_Product_Passholder__c, callSummary.Route_or_Product_Assistance_Booking__c,
            callSummary.Route_or_Product_Guide_Dog__c, callSummary.Route_or_Product_Points_ticket__c,
            callSummary.Route_or_Product_Insurance__c, callSummary.Route_or_Product_Vouchers__c,
            callSummary.Route_or_Product_Hotel__c, callSummary.Route_or_Product_Package__c,
            callSummary.Route_or_Product_Prize_winner__c, callSummary.Route_or_Product_Trade__c,
            callSummary.Route_or_Product_Concessions__c, callSummary.Route_or_Product_Staff_travel__c,
            callSummary.Route_or_Product_GDS__c, callSummary.Route_or_Product_Last_Minute__c,
            callSummary.Route_or_Product_Groups__c
        };
        topics.sort();
        Decimal maxValue = topics[topics.size() - 1];
        if (maxValue == callSummary.Route_or_Product_Core_routes__c && maxValue > 0) {
            caseItem.Journey_Type_Product__c = 'Cross channel routes';
        }
        if (maxValue == callSummary.Route_or_Product_Kent_Stations__c && maxValue > 0) {
            caseItem.StationLocation__c = 'Kent Stations';
        }
        if (maxValue == callSummary.Route_or_Product_Disney__c && maxValue > 0) {
            caseItem.Journey_Type_Product__c = 'Cross channel routes';
        }
        if (maxValue == callSummary.Route_or_Product_Dutch_Routes__c && maxValue > 0) {
            caseItem.Journey_Type_Product__c = 'Continental routes';
        }
        if (maxValue == callSummary.Route_or_Product_Connections__c && maxValue > 0) {
            caseItem.Journey_Type_Product__c = 'Connections';
        }
        if (maxValue == callSummary.Route_or_Product_Ski__c && maxValue > 0) {
            caseItem.Journey_Type_Product__c = 'Ski routes';
        }
        if (maxValue == callSummary.Route_or_Product_LSOF__c && maxValue > 0) {
            caseItem.Journey_Type_Product__c = 'Sun routes';
        }
        if (maxValue == callSummary.Route_or_Product_Last_Minute__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Last-Minute';
        }
        if (maxValue == callSummary.Route_or_Product_Child_Standalone__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Child Add on booking';
        }
        if (maxValue == callSummary.Route_or_Product_Child_Standalone__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Child Add on booking';
        }
        if (maxValue == callSummary.Route_or_Product_Passholder__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Passholder fare';
        }
        if (maxValue == callSummary.Route_or_Product_Assistance_Booking__c && maxValue > 0) {
            caseItem.Customer_Type__c = 'Special Assistance';
        }
        if (maxValue == callSummary.Route_or_Product_Guide_Dog__c && maxValue > 0) {
            caseItem.Customer_Type__c = 'Special Assistance';
        }
        if (maxValue == callSummary.Route_or_Product_Points_ticket__c && maxValue > 0) {
            caseItem.Customer_Type__c = 'Loyalty';
            caseItem.Booking_Type__c = 'Points Booking';
        }
        if (maxValue == callSummary.Route_or_Product_Insurance__c && maxValue > 0) {
            caseItem.Sundry__c = 'Insurance';
        }
        if (maxValue == callSummary.Route_or_Product_Vouchers__c && maxValue > 0) {
            caseItem.Sundry__c = 'Voucher';
        }
        if (maxValue == callSummary.Route_or_Product_Hotel__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Hotel only';
        }
        if (maxValue == callSummary.Route_or_Product_Package__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Package';
        }
        if (maxValue == callSummary.Route_or_Product_Prize_winner__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Gift certificate/Prizewinner';
        }
        if (maxValue == callSummary.Route_or_Product_Trade__c && maxValue > 0) {
            caseItem.Customer_Type__c = 'Trade';
        }
        if (maxValue == callSummary.Route_or_Product_Concessions__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Concession fare';
        }
        if (maxValue == callSummary.Route_or_Product_Staff_travel__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Staff travel';
        }
        if (maxValue == callSummary.Route_or_Product_GDS__c && maxValue > 0) {
            caseItem.Customer_Type__c = 'Trade';
        }
        // if (maxValue == callSummary.Route_or_Product_Groups__c && maxValue > 0) {
        //     caseItem.Journey_Type_Product__c = '?';
        // }

        return caseItem;
    }

    public static Case updateTopic(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> topics = new List<Decimal>{
            callSummary.Information_Topic_Animals__c,
            callSummary.Information_Topic_Bikes__c,
            callSummary.Information_Topic_Catering__c,
            callSummary.Information_Topic_Check_in_security__c,
            callSummary.Information_Topic_Children_and_infants__c,
            callSummary.Information_Topic_Communications__c,
            callSummary.Information_Topic_Destination_info__c,
            callSummary.Information_Topic_Documents_paperwork__c,
            callSummary.Information_Topic_Fraud__c,
            callSummary.Information_Topic_health_and_safety__c,
            callSummary.Information_Topic_Luggage__c,
            callSummary.Information_Topic_Medical_supplies__c,
            callSummary.Information_Topic_Names__c,
            callSummary.Information_Topic_Payments__c,
            callSummary.Information_Topic_Promotions__c,
            callSummary.Information_Topic_Seats__c,
            callSummary.Information_Topic_Special_assistance__c,
            callSummary.Information_Topic_Staff__c,
            callSummary.Information_Topic_Station__c,
            callSummary.Information_Topic_Ticket_Collection__c,
            callSummary.Information_Topic_Ticket_Conditions__c,
            callSummary.Information_Topic_Timetable__c,
            callSummary.Information_Topic_Travel_Classes__c,
            callSummary.Information_Topic_Website__c,
            callSummary.Information_Topic_Wifi__c
        };
        topics.sort();
        Decimal maxValue = topics[topics.size() - 1];
        if (maxValue == callSummary.Information_Topic_Ticket_Conditions__c && maxValue > 0) {
            caseItem.Topic__c = 'Ticket Conditions';
        }
        if (maxValue == callSummary.Information_Topic_Ticket_Collection__c && maxValue > 0) {
            caseItem.Topic__c = 'Ticket Collection';
            caseItem.Sundry__c = 'Ticket Collection';
        }
        if (maxValue == callSummary.Information_Topic_Documents_paperwork__c && maxValue > 0) {
            caseItem.Topic__c = 'Documents Or Paperwork';
        }
        if (maxValue == callSummary.Information_Topic_Luggage__c && maxValue > 0) {
            caseItem.Topic__c = 'Luggage';
        }
        if (maxValue == callSummary.Information_Topic_Check_in_security__c && maxValue > 0) {
            caseItem.Topic__c = 'Check-In Or Security';
        }
        if (maxValue == callSummary.Information_Topic_Medical_supplies__c && maxValue > 0) {
            caseItem.Topic__c = 'Medical Supplies';
        }
        if (maxValue == callSummary.Information_Topic_Seats__c && maxValue > 0) {
            caseItem.Topic__c = 'Seats';
            caseItem.Sundry__c = 'Seats';
        }
        if (maxValue == callSummary.Information_Topic_Catering__c && maxValue > 0) {
            caseItem.Topic__c = 'Catering';
        }
        if (maxValue == callSummary.Information_Topic_Wifi__c && maxValue > 0) {
            caseItem.Topic__c = 'Wifi';
        }
        if (maxValue == callSummary.Information_Topic_Destination_info__c && maxValue > 0) {
            caseItem.Topic__c = 'Destination Info';
        }
        if (maxValue == callSummary.Information_Topic_Station__c && maxValue > 0) {
            caseItem.Topic__c = 'Station';
        }
        if (maxValue == callSummary.Information_Topic_Payments__c && maxValue > 0) {
            caseItem.Topic__c = 'Payments';
        }
        if (maxValue == callSummary.Information_Topic_Communications__c && maxValue > 0) {
            caseItem.Topic__c = 'Communications';
        }
        if (maxValue == callSummary.Information_Topic_Animals__c && maxValue > 0) {
            caseItem.Topic__c = 'Animals';
        }
        if (maxValue == callSummary.Information_Topic_Special_assistance__c && maxValue > 0) {
            caseItem.Topic__c = 'Special Assistance - General';
            caseItem.Customer_Type__c = 'Special Assistance';
        }
        if (maxValue == callSummary.Information_Topic_Children_and_infants__c && maxValue > 0) {
            caseItem.Topic__c = 'Children & Infants';
        }
        if (maxValue == callSummary.Information_Topic_Travel_Classes__c && maxValue > 0) {
            caseItem.Topic__c = 'Travel Classes';
        }
        if (maxValue == callSummary.Information_Topic_Timetable__c && maxValue > 0) {
            caseItem.Topic__c = 'Timetable';
        }
        if (maxValue == callSummary.Information_Topic_Fraud__c && maxValue > 0) {
            caseItem.Topic__c = 'Fraud';
        }
        if (maxValue == callSummary.Information_Topic_Staff__c && maxValue > 0) {
            caseItem.Topic__c = 'Staff';
        }
        if (maxValue == callSummary.Information_Topic_health_and_safety__c && maxValue > 0) {
            caseItem.Topic__c = 'Health and Safety';
        }
        if (maxValue == callSummary.Information_Topic_Bikes__c && maxValue > 0) {
            caseItem.Topic__c = 'Bikes';
        }
        if (maxValue == callSummary.Information_Topic_Website__c && maxValue > 0) {
            caseItem.Topic__c = 'Website';
        }
        if (maxValue == callSummary.Information_Topic_Names__c && maxValue > 0) {
            caseItem.Topic__c = 'Names';
            caseItem.Sundry__c = 'Names';
        }
        if (maxValue == callSummary.Information_Topic_Promotions__c && maxValue > 0) {
            caseItem.Topic__c = 'Promotions';
        }

        return caseItem;
    }

    public static Case updateDisruption(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> disruptions = new List<Decimal>{
            callSummary.Disruption_Cancellation__c,
            callSummary.Disruption_COVID__c,
            callSummary.Disruption_Delay__c,
            callSummary.Disruption_Engineering_works__c,
            callSummary.Disruption_Eurostar_Strike__c,
            callSummary.Disruption_Expenses__c,
            callSummary.Disruption_Issue_wit_other_rail_provider__c,
            callSummary.Disruption_Onboard_experience__c,
            callSummary.Disruption_Poor_service__c,
            callSummary.Disruption_Real_time_train_information__c,
            callSummary.Disruption_Schedule_changes__c,
            callSummary.Disruption_Setswap_reaccom__c
        };
        disruptions.sort();
        Decimal maxValue = disruptions[disruptions.size() - 1];
        if (maxValue == callSummary.Disruption_Real_time_train_information__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Real Time Train Information';
            caseItem.Topic__c = 'Real time train information';
        }
        if (maxValue == callSummary.Disruption_Engineering_works__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Engineering Works';
        }
        if (maxValue == callSummary.Disruption_Schedule_changes__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Schedule Changes';
        }
        if (maxValue == callSummary.Disruption_Eurostar_Strike__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Eurostar Strike';
        }
        if (maxValue == callSummary.Disruption_Setswap_reaccom__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Setswap Or Reaccom';
        }
        if (maxValue == callSummary.Disruption_Cancellation__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Cancellation';
        }
        if (maxValue == callSummary.Disruption_Delay__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Delay';
        }
        if (maxValue == callSummary.Disruption_Issue_wit_other_rail_provider__c && maxValue > 0) {
            caseItem.Travel_Based_Disruption__c = 'Issue With Other Rail Provider';
        }
        if (maxValue == callSummary.Disruption_Expenses__c && maxValue > 0) {
            caseItem.Alternative_Disruption__c = 'Expenses';
        }
        if (maxValue == callSummary.Disruption_Poor_service__c && maxValue > 0) {
            caseItem.Alternative_Disruption__c = 'Poor Service';
        }
        if (maxValue == callSummary.Disruption_Onboard_experience__c && maxValue > 0) {
            caseItem.Alternative_Disruption__c = 'Comfort';
        }
        if (maxValue == callSummary.Disruption_COVID__c && maxValue > 0) {
            caseItem.Alternative_Disruption__c = 'Covid';
        }

        return caseItem;
    }

    public static Case updateLoyaltyTopic(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> loyaltyTopics = new List<Decimal>{
            callSummary.Loyalty_Club_Eurostar_monthly_prizedraw__c,
            callSummary.Loyalty_Communications__c,
            callSummary.Loyalty_COVID_loyalty_policy__c,
            callSummary.Loyalty_Earning_and_spending_points__c,
            callSummary.Loyalty_Failed_security_checks_not_autho__c,
            callSummary.Loyalty_History_statement_query__c,
            callSummary.Loyalty_Missing_points__c,
            callSummary.Loyalty_Partner_rewards__c,
            callSummary.Loyalty_Points_promotions__c,
            callSummary.Loyalty_Problems_with_online_account__c,
            callSummary.Loyalty_Program_and_benefits__c,
            callSummary.Loyalty_Request_to_add_points_ticket_to__c,
            callSummary.Loyalty_Request_to_change_personal_or_se__c,
            callSummary.Loyalty_Request_to_join__c,
            callSummary.Loyalty_Request_to_leave__c,
            callSummary.Loyalty_Request_to_reopen_a_closed_accou__c,
            callSummary.Loyalty_Tier_and_points_expiry__c,
            callSummary.Loyalty_Tier_and_status_info__c
        };
        loyaltyTopics.sort();
        Decimal maxValue = loyaltyTopics[loyaltyTopics.size() - 1];
        if (maxValue == callSummary.Loyalty_Request_to_join__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Open a new account';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_Request_to_leave__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Close an account';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_Program_and_benefits__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'What are the benefits?';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_Tier_and_status_info__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Tier and status info';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_Earning_and_spending_points__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Earning and Spending points';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_Partner_rewards__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Partner rewards';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_Tier_and_points_expiry__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Tier and Points expiry';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_COVID_loyalty_policy__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Covid Policy';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_Club_Eurostar_monthly_prizedraw__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Club Eurostar monthly prizedraw';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_Missing_points__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Querying missing points';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_History_statement_query__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'History/statement query';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_Request_to_reopen_a_closed_accou__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Request to reopen a closed account';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_Request_to_change_personal_or_se__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Request to change personal or security info';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_Request_to_add_points_ticket_to__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Request to add points/ticket to account';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_Problems_with_online_account__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Problems with online account (display, details . balance etc)';
            caseItem.Loyalty_Category__c = 'Account maintenance';
        }
        if (maxValue == callSummary.Loyalty_Failed_security_checks_not_autho__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Failed security checks/not authorised';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }
        if (maxValue == callSummary.Loyalty_Points_promotions__c && maxValue > 0) {
            caseItem.Loyalty_Topic__c = 'Points promotions';
            caseItem.Loyalty_Category__c = 'Loyalty program information';
        }

        return caseItem;
    }

    public static Case updateAssistance(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> assistanceTopics = new List<Decimal>{
            callSummary.Assistance_Assistance_Animal__c,
            callSummary.Assistance_Assistance_Dog__c,
            callSummary.Assistance_Companion__c,
            callSummary.Assistance_Hidden_Disability__c,
            callSummary.Assistance_Other_Assistance_Animal__c,
            callSummary.Assistance_Physical_Disability__c,
            callSummary.Assistance_Reduced_Mobility__c,
            callSummary.Assistance_Wheelchair__c,
            callSummary.Information_Topic_Special_assistance__c,
            callSummary.Route_or_Product_Assistance_Booking__c
        };
        assistanceTopics.sort();
        Decimal maxValue = assistanceTopics[assistanceTopics.size() - 1];
        if (maxValue == callSummary.Assistance_Wheelchair__c && maxValue > 0) {
            caseItem.Type_of_Assistance__c = 'wheelchair assistance';
            caseItem.Booking_Type__c = 'Assistance';
        }
        if (maxValue == callSummary.Assistance_Reduced_Mobility__c && maxValue > 0) {
            caseItem.Type_of_Assistance__c = 'mobility assistance';
        }
        if (maxValue == callSummary.Assistance_Companion__c && maxValue > 0) {
            caseItem.Type_of_Assistance__c = 'Companion';
        }
        if (maxValue == callSummary.Assistance_Assistance_Animal__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Assistance';
            caseItem.Type_of_Assistance__c = 'Assistance animal';
        }
        if (maxValue == callSummary.Assistance_Assistance_Dog__c && maxValue > 0) {
            caseItem.Booking_Type__c = 'Assistance';
            caseItem.Type_of_Assistance__c = 'Assistance animal';
        }
        if (maxValue == callSummary.Assistance_Physical_Disability__c && maxValue > 0) {
            caseItem.Customer_Type__c = 'Special Assistance';
            caseItem.Topic__c = 'Special Assistance - General';
        }
        if (maxValue == callSummary.Assistance_Hidden_Disability__c && maxValue > 0) {
            caseItem.Type_of_Assistance__c = 'hidden disability';
        }
        
        return caseItem;
    }

    public static Case updateTradeAndGDS(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        return caseItem;
    }

    public static Case updateStaffTravel(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        return caseItem;
    }

    public static Case updateGroups(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        return caseItem;
    }

    public static Case updateTechnicalIssue(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> technicalIssues = new List<Decimal>{
            callSummary.Technical_Issue_Data_input_error__c,
            callSummary.Technical_Issue_Error_message_unclear__c,
            callSummary.Technical_Issue_No_availability__c,
            callSummary.Technical_Issue_Overcharged_double_booki__c,
            callSummary.Technical_Issue_Password_reset__c,
            callSummary.Technical_Issue_Points_discount_issue__c,
            callSummary.Technical_Issue_Price_availability_chang__c,
            callSummary.Technical_Issue_Problems_accessing_onlin__c,
            callSummary.Technical_Issue_Problems_with_the_app__c,
            callSummary.Technical_Issue_Split_booking__c,
            callSummary.Technical_Issue_Web_error__c,
            callSummary.Technical_Issue_Website_down_completely__c
        };
        technicalIssues.sort();
        Decimal maxValue = technicalIssues[technicalIssues.size() - 1];
        if (maxValue == callSummary.Technical_Issue_Website_down_completely__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Website Down Completely';
        }
        if (maxValue == callSummary.Technical_Issue_Web_error__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Web error';
        }
        if (maxValue == callSummary.Technical_Issue_Price_availability_chang__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Price/availability changed during booking';
        }
        if (maxValue == callSummary.Technical_Issue_Data_input_error__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Data input error (dob/phone number/membership number etc)';
        }
        if (maxValue == callSummary.Technical_Issue_No_availability__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'No availability';
        }
        if (maxValue == callSummary.Technical_Issue_Points_discount_issue__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Part points payment issue';
        }
        if (maxValue == callSummary.Initial_Reason_for_Contact_Book__c && maxValue > 0) {
            caseItem.What_Is_The_Question__c = 'I need to reset my password';
        }
        if (maxValue == callSummary.Technical_Issue_Problems_accessing_onlin__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Problems accessing online account';
        }
        if (maxValue == callSummary.Technical_Issue_Problems_with_the_app__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Problems with the app';
            caseItem.Using_The_App__c = true;
        }
        if (maxValue == callSummary.Technical_Issue_Split_booking__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Split booking';
        }
        if (maxValue == callSummary.Technical_Issue_Error_message_unclear__c && maxValue > 0) {
            caseItem.Technical_Issue__c = 'Error message unclear';
        }
        if (maxValue == callSummary.Technical_Issue_Overcharged_double_booki__c && maxValue > 0) {
            caseItem.Customer_Issue__c = 'Double Booking';
        }
        
        return caseItem;
    }

    public static Case updateAreaOfWebsite(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> areaOfWebsite = new List<Decimal>{
            callSummary.Area_of_website_AOP__c,
            callSummary.Area_of_website_Availability_searches__c,
            callSummary.Area_of_website_Booking_path__c,
            callSummary.Area_of_website_Checkout__c,
            callSummary.Area_of_website_Compensation_form__c,
            callSummary.Area_of_website_Contact_Us_form__c,
            callSummary.Area_of_website_Content_Pages__c,
            callSummary.Area_of_website_Exchange_path__c,
            callSummary.Area_of_website_Extras__c,
            callSummary.Area_of_website_FAQs__c,
            callSummary.Area_of_website_Home_page__c,
            callSummary.Area_of_website_Lowest_fare_finder__c,
            callSummary.Area_of_website_MYB__c,
            callSummary.Area_of_website_PRR_form__c
        };
        areaOfWebsite.sort();
        Decimal maxValue = areaOfWebsite[areaOfWebsite.size() - 1];
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Home_page__c) {
            caseItem.Area_On_Website__c = 'Home page';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Booking_path__c) {
            caseItem.Area_On_Website__c = 'Booking path';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Lowest_fare_finder__c) {
            caseItem.Area_On_Website__c = 'Lowest fare finder';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Checkout__c) {
            caseItem.Area_On_Website__c = 'Checkout';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Availability_searches__c) {
            caseItem.Area_On_Website__c = 'Availability searches';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Exchange_path__c) {
            caseItem.Area_On_Website__c = 'Exchange path';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Extras__c) {
            caseItem.Area_On_Website__c = 'Extras';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_MYB__c) {
            caseItem.Area_On_Website__c = 'MYB';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_FAQs__c) {
            caseItem.Area_On_Website__c = 'FAQs';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Content_Pages__c) {
            caseItem.Area_On_Website__c = 'Content Pages';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Contact_Us_form__c) {
            caseItem.Area_On_Website__c = 'Contact Us form';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_Compensation_form__c) {
            caseItem.Area_On_Website__c = 'Compensation form';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_PRR_form__c) {
            caseItem.Area_On_Website__c = 'PRR form';
        }
        if (maxValue > 0 && maxValue == callSummary.Area_of_website_AOP__c) {
            caseItem.Area_On_Website__c = 'AOP';
        }
        
        return caseItem;
    }

    public static Case updateCustomerStruggle(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> customerStruggles = new List<Decimal>{
            callSummary.Customer_Struggle_Couldn_t_find__c,
            callSummary.Customer_Struggle_Customer_error__c,
            callSummary.Customer_Struggle_Didn_t_understand__c,
            callSummary.Customer_Struggle_Don_t_want_to_use_web__c,
            callSummary.Customer_Struggle_Eurostar_Error__c,
            callSummary.Customer_Struggle_Needed_more_informatio__c,
            callSummary.Customer_Struggle_Needed_recap_reassuran__c,
            callSummary.Customer_Struggle_No_self_service_option__c,
            callSummary.Customer_Struggle_Unable_to_use_website__c
        };
        customerStruggles.sort();
        Decimal maxValue = customerStruggles[customerStruggles.size() - 1];
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Couldn_t_find__c) {
            caseItem.Customer_Struggle__c = 'Couldn\'t Find';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Didn_t_understand__c) {
            caseItem.Customer_Struggle__c = 'Didn\'t understand';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Don_t_want_to_use_web__c) {
            caseItem.Customer_Struggle__c = 'Don\'t Want To Use Website Or No Access To Website';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_No_self_service_option__c) {
            caseItem.Customer_Struggle__c = 'No self service option';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Eurostar_Error__c) {
            caseItem.Customer_Struggle__c = 'Eurostar Error';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Unable_to_use_website__c) {
            caseItem.Customer_Struggle__c = 'Unable to use website due to disability';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Needed_more_informatio__c) {
            caseItem.Customer_Struggle__c = 'Need More Information';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Needed_recap_reassuran__c) {
            caseItem.Customer_Struggle__c = 'Needed A Recap Or Reassurance';
        }
        if (maxValue > 0 && maxValue == callSummary.Customer_Struggle_Customer_error__c) {
            caseItem.Customer_Struggle__c = 'Customer error';
        }
        
        return caseItem;
    }

    public static Case updateCustomerExperience(Case caseItem, NVMStatsSF__NVM_Call_Summary__c callSummary) {
        List<Decimal> customerExperience = new List<Decimal>{
            callSummary.Customer_Experience_Praise__c, callSummary.Customer_Experience_Complaint__c
        };
        customerExperience.sort();
        Decimal maxValue = customerExperience[customerExperience.size() - 1];
        if (maxValue == callSummary.Customer_Experience_Praise__c) {
            caseItem.Tone_of_Contact__c = 'Praise';
        }
        if (maxValue == callSummary.Customer_Experience_Complaint__c) {
            caseItem.Tone_of_Contact__c = 'Complaint';
        }
        
        return caseItem;
    }

    public static void updateCaseByTask(List<Task> tasksFromTrigger, Map<Id, Task> oldTasks) {
    //     Set<String> callSummariesGuid = new Set<String>();
    //     for (Task taskFromTrigger : tasksFromTrigger) {
    //         if (String.isNotBlank(taskFromTrigger.CallObject) && (taskFromTrigger.PNR__c != oldTasks.get(taskFromTrigger.Id).PNR__c)) {
    //             callSummariesGuid.add(taskFromTrigger.CallObject);
    //         }
    //     }

    //     if (!callSummariesGuid.isEmpty()) {
    //         List<NVMStatsSF__NVM_Call_Summary__c> callSummaries = [
    //             SELECT Id, Initial_Reason_for_Contact__c,
    //                 Initial_Reason_for_Contact_Book__c,
    //                 Initial_Reason_for_Contact_Cancel_or_Ref__c,
    //                 Initial_Reason_for_Contact_Change__c,
    //                 Initial_Reason_for_Contact_Disruption__c,
    //                 Initial_Reason_for_Contact_Feedback__c,
    //                 Initial_Reason_for_Contact_Information__c,
    //                 Route_or_Product__c,
    //                 Route_or_Product_Assistance_Booking__c,
    //                 Route_or_Product_Child_Standalone__c,
    //                 Route_or_Product_Concessions__c,
    //                 Route_or_Product_Connections__c,
    //                 Route_or_Product_Core_routes__c,
    //                 Route_or_Product_Disney__c,
    //                 Route_or_Product_Dutch_Routes__c,
    //                 Route_or_Product_GDS__c,
    //                 Route_or_Product_Groups__c,
    //                 Route_or_Product_Guide_Dog__c,
    //                 Route_or_Product_Hotel__c,
    //                 Route_or_Product_Insurance__c,
    //                 Route_or_Product_Kent_Stations__c,
    //                 Route_or_Product_LSOF__c,
    //                 Route_or_Product_Package__c,
    //                 Route_or_Product_Passholder__c,
    //                 Route_or_Product_Points_ticket__c,
    //                 Route_or_Product_Prize_winner__c,
    //                 Route_or_Product_Ski__c,
    //                 Route_or_Product_Staff_travel__c,
    //                 Route_or_Product_Trade__c,
    //                 Route_or_Product_Vouchers__c,
    //                 Information_Topic__c,
    //                 Information_Topic_Animals__c,
    //                 Information_Topic_Bikes__c,
    //                 Information_Topic_Catering__c,
    //                 Information_Topic_Check_in_security__c,
    //                 Information_Topic_Children_and_infants__c,
    //                 Information_Topic_Communications__c,
    //                 Information_Topic_Destination_info__c,
    //                 Information_Topic_Documents_paperwork__c,
    //                 Information_Topic_Fraud__c,
    //                 Information_Topic_health_and_safety__c,
    //                 Information_Topic_Luggage__c,
    //                 Information_Topic_Medical_supplies__c,
    //                 Information_Topic_Names__c,
    //                 Information_Topic_Payments__c,
    //                 Information_Topic_Promotions__c,
    //                 Information_Topic_Seats__c,
    //                 Information_Topic_Special_assistance__c,
    //                 Information_Topic_Staff__c,
    //                 Information_Topic_Station__c,
    //                 Information_Topic_Ticket_Collection__c,
    //                 Information_Topic_Ticket_Conditions__c,
    //                 Information_Topic_Timetable__c,
    //                 Information_Topic_Travel_Classes__c,
    //                 Information_Topic_Website__c,
    //                 Information_Topic_Wifi__c,
    //                 Disruption__c,
    //                 Disruption_Cancellation__c,
    //                 Disruption_COVID__c,
    //                 Disruption_Delay__c,
    //                 Disruption_Engineering_works__c,
    //                 Disruption_Eurostar_Strike__c,
    //                 Disruption_Expenses__c,
    //                 Disruption_Issue_wit_other_rail_provider__c,
    //                 Disruption_Onboard_experience__c,
    //                 Disruption_Poor_service__c,
    //                 Disruption_Real_time_train_information__c,
    //                 Disruption_Schedule_changes__c,
    //                 Disruption_Setswap_reaccom__c,
    //                 Loyalty__c,
    //                 Loyalty_Club_Eurostar_monthly_prizedraw__c,
    //                 Loyalty_Communications__c,
    //                 Loyalty_COVID_loyalty_policy__c,
    //                 Loyalty_Earning_and_spending_points__c,
    //                 Loyalty_Failed_security_checks_not_autho__c,
    //                 Loyalty_History_statement_query__c,
    //                 Loyalty_Missing_points__c,
    //                 Loyalty_Partner_rewards__c,
    //                 Loyalty_Points_promotions__c,
    //                 Loyalty_Problems_with_online_account__c,
    //                 Loyalty_Program_and_benefits__c,
    //                 Loyalty_Request_to_add_points_ticket_to__c,
    //                 Loyalty_Request_to_change_personal_or_se__c,
    //                 Loyalty_Request_to_join__c,
    //                 Loyalty_Request_to_leave__c,
    //                 Loyalty_Request_to_reopen_a_closed_accou__c,
    //                 Loyalty_Tier_and_points_expiry__c,
    //                 Loyalty_Tier_and_status_info__c,
    //                 Assistance__c,
    //                 Assistance_Assistance_Animal__c,
    //                 Assistance_Assistance_Dog__c,
    //                 Assistance_Companion__c,
    //                 Assistance_Hidden_Disability__c,
    //                 Assistance_Other_Assistance_Animal__c,
    //                 Assistance_Physical_Disability__c,
    //                 Assistance_Reduced_Mobility__c,
    //                 Assistance_Wheelchair__c,
    //                 Technical_Issue__c,
    //                 Technical_Issue_Data_input_error__c,
    //                 Technical_Issue_Error_message_unclear__c,
    //                 Technical_Issue_No_availability__c,
    //                 Technical_Issue_Overcharged_double_booki__c,
    //                 Technical_Issue_Password_reset__c,
    //                 Technical_Issue_Points_discount_issue__c,
    //                 Technical_Issue_Price_availability_chang__c,
    //                 Technical_Issue_Problems_accessing_onlin__c,
    //                 Technical_Issue_Problems_with_the_app__c,
    //                 Technical_Issue_Split_booking__c,
    //                 Technical_Issue_Web_error__c,
    //                 Technical_Issue_Website_down_completely__c,
    //                 Area_of_website__c,
    //                 Area_of_website_AOP__c,
    //                 Area_of_website_Availability_searches__c,
    //                 Area_of_website_Booking_path__c,
    //                 Area_of_website_Checkout__c,
    //                 Area_of_website_Compensation_form__c,
    //                 Area_of_website_Contact_Us_form__c,
    //                 Area_of_website_Content_Pages__c,
    //                 Area_of_website_Exchange_path__c,
    //                 Area_of_website_Extras__c,
    //                 Area_of_website_FAQs__c,
    //                 Area_of_website_Home_page__c,
    //                 Area_of_website_Lowest_fare_finder__c,
    //                 Area_of_website_MYB__c,
    //                 Area_of_website_PRR_form__c,
    //                 Customer_Struggle__c,
    //                 Customer_Struggle_Couldn_t_find__c,
    //                 Customer_Struggle_Customer_error__c,
    //                 Customer_Struggle_Didn_t_understand__c,
    //                 Customer_Struggle_Don_t_want_to_use_web__c,
    //                 Customer_Struggle_Eurostar_Error__c,
    //                 Customer_Struggle_Needed_more_informatio__c,
    //                 Customer_Struggle_Needed_recap_reassuran__c,
    //                 Customer_Struggle_No_self_service_option__c,
    //                 Customer_Struggle_Unable_to_use_website__c,
    //                 Trade_and_GDS__c,
    //                 Staff_Travel__c,
    //                 Groups__c,
    //                 Customer_Experience__c,
    //                 NVMStatsSF__Related_Case__c,
    //                 NVMStatsSF__CallGuid__c,
    //                 NVMStatsSF__Categories__c
    //             FROM NVMStatsSF__NVM_Call_Summary__c
    //             WHERE NVMStatsSF__CallGuid__c IN : callSummariesGuid
    //         ];
    
    //         Map<String, Case> casesByCallSummaryToUpdate = Eins_CallSummaryTriggerHandler.updateRelatedCase(callSummaries);
    //         Eins_TaskTriggerHandler.updateCase(callSummaries, casesByCallSummaryToUpdate);
    //     }
    }
}