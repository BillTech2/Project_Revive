public without sharing class Eins_EventTriggerHandler {

    public static void updateDogAssistanceEvent(List<Event> dogEvents) {
        Map<Id, Event> oldDogEvents = new Map<Id, Event>();
        updateDogAssistanceEvent(dogEvents, oldDogEvents);
    }

    public static void updateDogAssistanceEvent(List<Event> dogEvents, Map<Id, Event> oldDogEvents) {
        String recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Dog_Approval_Event').getRecordTypeId();
        List<Event> dogApprovalEvents = new List<Event>();
        for (Event eventItem : dogEvents) {
            if (eventItem.RecordTypeId == recordTypeId) {
                dogApprovalEvents.add(eventItem);
            }
        }
        if (!dogApprovalEvents.isEmpty()) {
            Set<String> dogFormIds = new Set<String>();
            Set<String> ticketIds = new Set<String>();
            for (Event dogEvent : dogEvents) {
                if (String.isNotBlank(dogEvent.WhatId)) {
                    dogFormIds.add(dogEvent.WhatId);
                }
                if (String.isNotBlank(dogEvent.Ticket__c)) {
                    ticketIds.add(dogEvent.Ticket__c);
                }
            }

            Map<Id, Guide_assistance_dog__c> dogAssistances = new Map<Id, Guide_assistance_dog__c>([
                SELECT Id, Status__c, Is_Dog_Tattooed__c, Is_Dog_Microchipped__c
                FROM Guide_assistance_dog__c
                WHERE Id IN : dogFormIds
            ]);

            List<Ticket__c> tickets = [
                SELECT Id, Destination__c, Departure_Date_Time_Format__c, PNR__c, Booker__c, Contact_Email__c
                FROM Ticket__c
                WHERE Id IN : ticketIds
            ];
            Map<String, Ticket__c> ticketsByIds = new Map<String, Ticket__c>();
            for (Ticket__c ticket : tickets) {
                ticketsByIds.put(ticket.Id, ticket);
            }

            for (Event dogEvent : dogEvents) {
                if (dogAssistances.get(dogEvent.WhatId) != null) {
                    if (dogAssistances.get(dogEvent.WhatId).Status__c == 'Approved') {
                        dogEvent.Has_the_dog_been_approved_to_travel__c = true;
                    }

                    dogEvent.Was_the_dog_tattooed_before__c = dogAssistances.get(dogEvent.WhatId).Is_Dog_Tattooed__c;
                    dogEvent.Has_the_dog_got_a_microchip__c = dogAssistances.get(dogEvent.WhatId).Is_Dog_Microchipped__c;

                    if (ticketsByIds.get(dogEvent.Ticket__c) != null) {
                        dogEvent.IsAllDayEvent = false;
                        dogEvent.DurationInMinutes = 60;
                        dogEvent.ActivityDateTime = ticketsByIds.get(dogEvent.Ticket__c).Departure_Date_Time_Format__c;
                        dogEvent.At_which_station_will_they_alight__c = ticketsByIds.get(dogEvent.Ticket__c).Destination__c;
                        dogEvent.StartDateTime = ticketsByIds.get(dogEvent.Ticket__c).Departure_Date_Time_Format__c;
                        dogEvent.EndDateTime = ticketsByIds.get(dogEvent.Ticket__c).Departure_Date_Time_Format__c.addHours(1);
                        dogEvent.PNR__c = ticketsByIds.get(dogEvent.Ticket__c).PNR__c;
                    }
                    
                }
            }

            Eins_SendEmailController.sendEmails(dogEvents, oldDogEvents, false);
        }
    }

    public static void updateDogAssistanceEvent(List<Ticket__c> tickets, Map<Id, Ticket__c> oldTickets) {
        List<Ticket__c> ticketsWithUpdates = new List<Ticket__c>();
        for (Ticket__c ticketItem : tickets) {
            if (
                (ticketItem.Departure_Date_Time_Format__c != oldTickets.get(ticketItem.Id).Departure_Date_Time_Format__c) ||
                (ticketItem.PNR__c != oldTickets.get(ticketItem.Id).PNR__c) ||
                (ticketItem.Destination__c != oldTickets.get(ticketItem.Id).Destination__c) ||
                (ticketItem.Cancelled_By_Customer__c != oldTickets.get(ticketItem.Id).Cancelled_By_Customer__c)
            ) {
                ticketsWithUpdates.add(ticketItem);
            }
        }
        if (!ticketsWithUpdates.isEmpty()) {
            String recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Dog_Approval_Event').getRecordTypeId();
            Set<String> ticketIds = new Set<String>();
            Map<String, Ticket__c> ticketsByIds = new Map<String, Ticket__c>();
            for (Ticket__c ticket : tickets) {
                if (String.isNotBlank(ticket.Id)) {
                    ticketIds.add(ticket.Id);
                    ticketsByIds.put(ticket.Id, ticket);
                }
            }
    
            List<Event> relatedEvents = [
                SELECT Id, External_email_addresses__c, At_which_station_will_they_alight__c, StartDateTime,
                    EndDateTime, CreatedDate, LastModifiedDate, Subject, Description, PNR__c, Has_the_dog_been_approved_to_travel__c,
                    Does_the_dog_have_documents__c, Is_the_name_of_the_owner_the_same__c, Has_the_dog_got_a_microchip__c,
                    Was_the_dog_tattooed_before__c, Ticket__c
                FROM Event
                WHERE Ticket__c IN : ticketIds
                    AND RecordTypeId = :recordTypeId
            ];
    
            List<Event> updatedEvents = new List<Event>();
            for (Event dogEvent : relatedEvents) {
                if (String.isNotBlank(dogEvent.Ticket__c) && ticketsByIds.get(dogEvent.Ticket__c) != null) {
                    dogEvent.At_which_station_will_they_alight__c = ticketsByIds.get(dogEvent.Ticket__c).Destination__c;
                    dogEvent.StartDateTime = ticketsByIds.get(dogEvent.Ticket__c).Departure_Date_Time_Format__c;
                    dogEvent.EndDateTime = ticketsByIds.get(dogEvent.Ticket__c).Departure_Date_Time_Format__c.addHours(1);
                    if (ticketsByIds.get(dogEvent.Ticket__c).Cancelled_By_Customer__c) {
                        if (String.isNotBlank(dogEvent.Description)) {
                            dogEvent.Description = 'Cancelled by Customer. ' + dogEvent.Description;
                        }
                        dogEvent.Description = 'Cancelled by Customer.';
                    }
                    updatedEvents.add(dogEvent);
                }
            }
    
            if (!updatedEvents.isEmpty()) {
                try {
                    update updatedEvents;
                } catch(Exception e) {
                    System.debug(e);
                }
            }
        }
    }

    public static void cancelDogAssistanceEvent(List<Event> dogEvents) {
        Eins_SendEmailController.sendEmails(dogEvents, new Map<Id, Event>(), true);
    }
}