public without sharing class Eins_SendEmailController {
    public static List<OrgWideEmailAddress> fromAddress = new List<OrgWideEmailAddress>();
    public static Eins_CalendarEventSettings__c settings = Eins_CalendarEventSettings__c.getInstance('Default');

    public static void sendEmails(List<Event> dogEvents, Map<Id, Event> oldDogEvents, Boolean isCancelled) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        if (settings == null) {
            settings = new Eins_CalendarEventSettings__c();
        }
        if (fromAddress.isEmpty()) {
            fromAddress = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = 'Eurostar Customer Care'
                LIMIT 1
            ];
        }
        String assistanceAnimalBookingDevName = 'Assistance_Animal_Booking';
        String assistanceAnimalBookingAmendmentDevName = 'Assistance_Animal_Booking_AMENDMENT';
        String assistanceAnimalBookingCancelledDevName = 'Assistance_Animal_Booking_CANCELLATION';
        List<EmailTemplate> assistanceAnimalBookingTemplates = [
            SELECT Id, HtmlValue, Body, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName =: assistanceAnimalBookingDevName
                OR DeveloperName =: assistanceAnimalBookingAmendmentDevName
                OR DeveloperName =: assistanceAnimalBookingCancelledDevName
        ];
        EmailTemplate assistanceAnimalBookingTemplate = new EmailTemplate();
        EmailTemplate assistanceAnimalBookingAmendmentTemplate = new EmailTemplate();
        EmailTemplate assistanceAnimalBookingCancelledTemplate = new EmailTemplate();
        for (EmailTemplate template :assistanceAnimalBookingTemplates) {
            if (template.DeveloperName == assistanceAnimalBookingDevName) {
                assistanceAnimalBookingTemplate = template;
            }
            if (template.DeveloperName == assistanceAnimalBookingAmendmentDevName) {
                assistanceAnimalBookingAmendmentTemplate = template;
            }
            if (template.DeveloperName == assistanceAnimalBookingCancelledDevName) {
                assistanceAnimalBookingCancelledTemplate = template;
            }
        }
        for (Event dogEvent : dogEvents) {
            Messaging.SingleEmailMessage emailMessage = createEmailMessageWithICS(dogEvent, isCancelled);
            if (String.isNotBlank(assistanceAnimalBookingTemplate.DeveloperName) && (oldDogEvents.get(dogEvent.Id) == null) && !isCancelled) {
                emailMessage = createAssistanceAnimalBooking(
                    emailMessage,
                    dogEvent,
                    assistanceAnimalBookingTemplate,
                    ''
                );
            } else {
                System.debug('Email error. No template with this developer name: ' + assistanceAnimalBookingDevName);
            }
            if (String.isNotBlank(assistanceAnimalBookingAmendmentTemplate.DeveloperName) && (oldDogEvents.get(dogEvent.Id) != null)  && !isCancelled) {
                emailMessage = createAssistanceAnimalBooking(
                    emailMessage,
                    dogEvent,
                    assistanceAnimalBookingAmendmentTemplate,
                    String.valueOfGmt(oldDogEvents.get(dogEvent.Id).StartDateTime)
                );
            } else {
                System.debug('Email error. No template with this developer name: ' + assistanceAnimalBookingAmendmentDevName);
            }
            if (String.isNotBlank(assistanceAnimalBookingCancelledTemplate.DeveloperName) && isCancelled) {
                emailMessage = createAssistanceAnimalBooking(
                    emailMessage,
                    dogEvent,
                    assistanceAnimalBookingCancelledTemplate,
                    ''
                );
            } else {
                System.debug('Email error. No template with this developer name: ' + assistanceAnimalBookingCancelledDevName);
            }
            if (Test.isRunningTest()) {
                fromAddress = new List<OrgWideEmailAddress>();
            }
            if (!fromAddress.isEmpty()) {
                emailMessage.setOrgWideEmailAddressId(fromAddress[0].Id);
            }
            Set<String> emailAddressesFromField = new Set<String>(dogEvent.External_email_addresses__c.split(','));
            List<String> emailAddresses = new List<String>();
            for (String emailAddress : emailAddressesFromField) {
                if (String.isNotBlank(emailAddress)) {
                    emailAddresses.add(emailAddress.trim());
                }
            }
            if (!emailAddresses.isEmpty()) {
                emailMessage.setToAddresses(emailAddresses);
            }
            emailMessages.add(emailMessage);
        }

        if (!emailMessages.isEmpty()) {
            sendEmails(emailMessages);
        }
    }

    public static void sendEmails(List<Messaging.SingleEmailMessage> emailMessages) {
        Messaging.reserveSingleEmailCapacity(emailMessages.size());
        try {
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emailMessages);
        } catch(System.EmailException ex) {
            System.debug('Email error: ' + ex.getMessage());
        }
    }

    public static Messaging.SingleEmailMessage createAssistanceAnimalBooking(Messaging.SingleEmailMessage emailMessage, Event dogEvent, EmailTemplate template, String oldDateTime) {
        String emailHTMLBody = template.HtmlValue;
        String plainTextBody = template.Body;
        String startDate = String.valueOfGmt(dogEvent.StartDateTime).substringBefore(' ');
        String startTime = String.valueOfGmt(dogEvent.StartDateTime).substringAfter(' ');

        emailHTMLBody = emailHTMLBody.replace('{!Event.TravelDate}', startDate);
        emailHTMLBody = emailHTMLBody.replace('{!Event.TravelTime}', startTime);
        emailHTMLBody = emailHTMLBody.replace('{!Event.PNR}', dogEvent.PNR__c);
        emailHTMLBody = emailHTMLBody.replace('{!Event.DogApproved}', convertBooleanFieldToString(dogEvent.Has_the_dog_been_approved_to_travel__c));
        emailHTMLBody = emailHTMLBody.replace('{!Event.Destination}', dogEvent.At_which_station_will_they_alight__c);
        emailHTMLBody = emailHTMLBody.replace('{!Event.Documents}', convertBooleanFieldToString(dogEvent.Does_the_dog_have_documents__c));
        emailHTMLBody = emailHTMLBody.replace('{!Event.OwnerName}', convertBooleanFieldToString(dogEvent.Is_the_name_of_the_owner_the_same__c));
        emailHTMLBody = emailHTMLBody.replace('{!Event.Microchip}', convertBooleanFieldToString(dogEvent.Has_the_dog_got_a_microchip__c));
        emailHTMLBody = emailHTMLBody.replace('{!Event.Tattooed}', convertBooleanFieldToString(dogEvent.Was_the_dog_tattooed_before__c));
        emailHTMLBody = emailHTMLBody.replace('{!Event.OldTravelDate}', oldDateTime.substringBefore(' '));
        emailHTMLBody = emailHTMLBody.replace('{!Event.OldTravelTime}', oldDateTime.substringAfter(' '));

        if (!String.isNotBlank(plainTextBody)) {
            if (plainTextBody.containsIgnoreCase('{!Event.TravelDate}')) {
                plainTextBody = plainTextBody.replace('{!Event.TravelDate}', startDate);
            }
            if (plainTextBody.containsIgnoreCase('{!Event.TravelTime}')) {
                plainTextBody = plainTextBody.replace('{!Event.TravelTime}', startTime);
            }
            if (plainTextBody.containsIgnoreCase('{!Event.PNR}')) {
                plainTextBody = plainTextBody.replace('{!Event.PNR}', dogEvent.PNR__c);
            }
            if (plainTextBody.containsIgnoreCase('{!Event.DogApproved}')) {
                plainTextBody = plainTextBody.replace('{!Event.DogApproved}', convertBooleanFieldToString(dogEvent.Has_the_dog_been_approved_to_travel__c));
            }
            if (plainTextBody.containsIgnoreCase('{!Event.Destination}')) {
                plainTextBody = plainTextBody.replace('{!Event.Destination}', dogEvent.At_which_station_will_they_alight__c);
            }
            if (plainTextBody.containsIgnoreCase('{!Event.Documents}')) {
                plainTextBody = plainTextBody.replace('{!Event.Documents}', convertBooleanFieldToString(dogEvent.Does_the_dog_have_documents__c));
            }
            if (plainTextBody.containsIgnoreCase('{!Event.OwnerName}')) {
                plainTextBody = plainTextBody.replace('{!Event.OwnerName}', convertBooleanFieldToString(dogEvent.Is_the_name_of_the_owner_the_same__c));
            }
            if (plainTextBody.containsIgnoreCase('{!Event.Microchip}')) {
                plainTextBody = plainTextBody.replace('{!Event.Microchip}', convertBooleanFieldToString(dogEvent.Has_the_dog_got_a_microchip__c));
            }
            if (plainTextBody.containsIgnoreCase('{!Event.Tattooed}')) {
                plainTextBody = plainTextBody.replace('{!Event.Tattooed}', convertBooleanFieldToString(dogEvent.Was_the_dog_tattooed_before__c));
            }
            if (plainTextBody.containsIgnoreCase('{!Event.OldTravelDate}')) {
                plainTextBody = plainTextBody.replace('{!Event.OldTravelDate}', oldDateTime.substringBefore(' '));
            }
            if (plainTextBody.containsIgnoreCase('{!Event.OldTravelTime}')) {
                plainTextBody = plainTextBody.replace('{!Event.OldTravelTime}', oldDateTime.substringAfter(' '));
            }
            emailMessage.setPlainTextBody(plainTextBody);
        }

        emailMessage.setHtmlBody(emailHTMLBody);
        emailMessage.setTargetObjectId(UserInfo.getUserId());
        emailMessage.setTreatTargetObjectAsRecipient(false);

        return emailMessage;
    }

    public static String convertBooleanFieldToString(Boolean fieldValue) {
        return (fieldValue) ? 'Yes' : 'No';
    }

    public static List<Messaging.SingleEmailMessage> sendCorrectionsEmails(List<Guide_assistance_dog__c> dogs) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        String templateDevName = 'Guide_Dog_Edits_Amends_Template';
        List<EmailTemplate> template = [
            SELECT Id, HtmlValue, Body
            FROM EmailTemplate
            WHERE DeveloperName =: templateDevName
            LIMIT 1
        ];
        if (fromAddress.isEmpty()) {
            fromAddress = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = 'Eurostar Customer Care'
                LIMIT 1
            ];
        }
        Eins_DogFormSiteSettings__c siteSettings = Eins_DogFormSiteSettings__c.getInstance();
        String siteUrl = siteSettings.Site_URL__c;
        for (Guide_assistance_dog__c dogItem : dogs) {
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            if (!template.isEmpty()) {
                String emailHTMLBody = template[0].HtmlValue;
                String plainTextBody = template[0].Body;

                emailHTMLBody = emailHTMLBody.replace('{!Contact.FirstName}', dogItem.Name_of_Applicant__c);
                emailHTMLBody = emailHTMLBody.replace(
                    'here {link}',
                    '<a href="' + siteUrl + '?id=' + dogItem.Id + '">here</a>'
                );
                if (String.isNotBlank(dogItem.Comments_for_customer__c)) {
                    emailHTMLBody = emailHTMLBody.replace('{populatedFromFields}', dogItem.Comments_for_customer__c);
                } else {
                    emailHTMLBody = emailHTMLBody.replace('{populatedFromFields}', ' ');
                }

                if (!String.isNotBlank(plainTextBody)) {
                    if (plainTextBody.containsIgnoreCase('{!Contact.FirstName}')) {
                        plainTextBody = plainTextBody.replace('{!Contact.FirstName}', dogItem.Name_of_Applicant__c);
                    }
                    if (plainTextBody.containsIgnoreCase('{link}')) {
                        plainTextBody = plainTextBody.replace('{link}', siteUrl + '?id=' + dogItem.Id);
                    }
                    if (plainTextBody.containsIgnoreCase('{populatedFromFields}')) {
                        if (String.isNotBlank(dogItem.Comments_for_customer__c)) {
                            plainTextBody = plainTextBody.replace('{populatedFromFields}', dogItem.Comments_for_customer__c);
                        } else {
                            plainTextBody = plainTextBody.replace('{populatedFromFields}', ' ');
                        }
                    }
                    emailMessage.setPlainTextBody(plainTextBody);
                }

                emailMessage.setHtmlBody(emailHTMLBody);
                emailMessage.setTargetObjectId(UserInfo.getUserId());
                emailMessage.setWhatId(dogItem.Id);
                emailMessage.setTreatTargetObjectAsRecipient(false);
                if (Test.isRunningTest()) {
                    fromAddress = new List<OrgWideEmailAddress>();
                }
                if (!fromAddress.isEmpty()) {
                    emailMessage.setOrgWideEmailAddressId(fromAddress[0].Id);
                }
                emailMessage.setToAddresses(new String[] { dogItem.Email__c.trim() });
                emailMessages.add(emailMessage);
            } else {
                System.debug('Email error. No template with this developer name: ' + templateDevName);
            }
        }

        return emailMessages;
    }


    public static List<Messaging.SingleEmailMessage> sendApprovalEmails(List<Guide_assistance_dog__c> dogs) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        String templateDevName = 'New_Assistance_Dog_Approved';
        List<EmailTemplate> template = [
            SELECT Id, HtmlValue, Body
            FROM EmailTemplate
            WHERE DeveloperName =: templateDevName
            LIMIT 1
        ];
        if (fromAddress.isEmpty()) {
            fromAddress = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = 'Eurostar Customer Care'
                LIMIT 1
            ];
        }
        String todayDate = Date.today().format();
        for (Guide_assistance_dog__c dogItem : dogs) {
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            if (!template.isEmpty()) {
                String emailHTMLBody = template[0].HtmlValue;
                String plainTextBody = template[0].Body;

                emailHTMLBody = emailHTMLBody.replace('{!Contact.FirstName}', dogItem.Name_of_Applicant__c);
                if (emailHTMLBody.containsIgnoreCase('{!Dog.Name}')) {
                    emailHTMLBody = emailHTMLBody.replace('{!Dog.Name}', dogItem.Name_of_Dog__c);
                }
                if (emailHTMLBody.containsIgnoreCase('{!Dog.Name}')) {
                    emailHTMLBody = emailHTMLBody.replace('{!Dog.Name}', dogItem.Name_of_Dog__c);
                }
                // emailHTMLBody = emailHTMLBody.replace('{!Dog.Name}', dogItem.Name_of_Dog__c);
                emailHTMLBody = emailHTMLBody.replace('{today}', todayDate);

                if (!String.isNotBlank(plainTextBody)) {
                    if (plainTextBody.containsIgnoreCase('{!Contact.FirstName}')) {
                        plainTextBody = plainTextBody.replace('{!Contact.FirstName}', dogItem.Name_of_Applicant__c);
                    }
                    if (plainTextBody.containsIgnoreCase('{!Dog.Name}')) {
                        plainTextBody = plainTextBody.replace('{!Dog.Name}', dogItem.Name_of_Dog__c);
                    }
                    if (plainTextBody.containsIgnoreCase('{!Dog.Name}')) {
                        plainTextBody = plainTextBody.replace('{!Dog.Name}', dogItem.Name_of_Dog__c);
                    }
                    if (plainTextBody.containsIgnoreCase('{today}')) {
                        plainTextBody = plainTextBody.replace('{today}', todayDate);
                    }
                    emailMessage.setPlainTextBody(plainTextBody);
                }

                emailMessage.setHtmlBody(emailHTMLBody);
                emailMessage.setTargetObjectId(UserInfo.getUserId());
                emailMessage.setWhatId(dogItem.Id);
                emailMessage.setTreatTargetObjectAsRecipient(false);
                if (Test.isRunningTest()) {
                    fromAddress = new List<OrgWideEmailAddress>();
                }
                if (!fromAddress.isEmpty()) {
                    emailMessage.setOrgWideEmailAddressId(fromAddress[0].Id);
                }
                emailMessage.setToAddresses(new String[] { dogItem.Email__c.trim() });
                emailMessages.add(emailMessage);
            } else {
                System.debug('Email error. No template with this developer name: ' + templateDevName);
            }
        }

        return emailMessages;
    }

    public static List<Messaging.SingleEmailMessage> sendVerificationEmail(Guide_assistance_dog__c dogItem, String customerEmail) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        String templateDevName = 'Eurostar_Assistance_Animal_Form';
        List<EmailTemplate> template = [
            SELECT Id, HtmlValue, Body
            FROM EmailTemplate
            WHERE DeveloperName =: templateDevName
            LIMIT 1
        ];
        if (fromAddress.isEmpty()) {
            fromAddress = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = 'Eurostar Customer Care'
                LIMIT 1
            ];
        }
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        Eins_DogFormSiteSettings__c siteSettings = Eins_DogFormSiteSettings__c.getInstance();
        String siteUrl = siteSettings.Site_URL__c + '?id=' + dogItem.Id;
        if (!template.isEmpty()) {
            String emailHTMLBody = template[0].HtmlValue;
            String plainTextBody = template[0].Body;

            emailHTMLBody = emailHTMLBody.replace('{!Contact.FirstName}', dogItem.Name_of_Applicant__c);
            if (emailHTMLBody.containsIgnoreCase('{!Dog.Link}')) {
                emailHTMLBody = emailHTMLBody.replace('{!Dog.Link}', siteUrl);
            }

            if (!String.isNotBlank(plainTextBody)) {
                if (plainTextBody.containsIgnoreCase('{!Contact.FirstName}')) {
                    plainTextBody = plainTextBody.replace('{!Contact.FirstName}', dogItem.Name_of_Applicant__c);
                }
                if (plainTextBody.containsIgnoreCase('{!Dog.Link}')) {
                    plainTextBody = plainTextBody.replace('{!Dog.Link}', siteUrl);
                }
                emailMessage.setPlainTextBody(plainTextBody);
            }

            emailMessage.setHtmlBody(emailHTMLBody);
            emailMessage.setTargetObjectId(UserInfo.getUserId());
            emailMessage.setWhatId(dogItem.Id);
            emailMessage.setTreatTargetObjectAsRecipient(false);
            if (Test.isRunningTest()) {
                fromAddress = new List<OrgWideEmailAddress>();
            }
            if (!fromAddress.isEmpty()) {
                emailMessage.setOrgWideEmailAddressId(fromAddress[0].Id);
            }
            emailMessage.setToAddresses(new String[] { customerEmail.trim() });
            emailMessages.add(emailMessage);
        } else {
            System.debug('Email error. No template with this developer name: ' + templateDevName);
        }
        return emailMessages;
    }

    private static Messaging.SingleEmailMessage createEmailMessageWithICS(Event dogEvent, Boolean isCancelled) {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('invite.ics');
        efa.setContentType('text/calendar; charset=utf-8; method=REQUEST');

        Datetime createdDate;
        Datetime lastModifiedDate;
        if (dogEvent.CreatedDate == null) {
            createdDate = System.now();
        } else {
            createdDate = dogEvent.CreatedDate;
        }

        if (dogEvent.LastModifiedDate == null) {
            lastModifiedDate = System.now();
        } else {
            lastModifiedDate = dogEvent.LastModifiedDate;
        }

        String calendarStatus = 'CONFIRMED';
        if (isCancelled) {
            calendarStatus = 'CANCELLED';
        }

        String vCal = 
            // 'BEGIN:VCALENDAR' + '\n' + 
            // 'VERSION:2.0' + '\n' + 
            // 'PRODID:-//salesforce.com//Calendar//EN' + '\n' +
            // // 'CALSCALE:GREGORIAN' + '\n' + 
            // 'BEGIN:VEVENT'+ '\n' +
            // 'UID:' + settings.Organizer_Email__c + '\n' +
            // 'DTSTAMP:' + convertDateTime(System.now()) + '\n' +
            // 'DTSTART:' + convertDateTime(dogEvent.StartDateTime) + '\n' + 
            // 'DTEND:' + convertDateTime(dogEvent.EndDateTime) + '\n' + 
            // 'ORGANIZER;CN=' + settings.Organizer_Name__c + ':MAILTO:' + settings.Organizer_Email__c + '\n' + 
            // // 'CREATED:' + convertDateTime(createdDate) + '\n' + 
            // 'SUMMARY:' + dogEvent.Subject + '\n' + 
            // 'DESCRIPTION:' + dogEvent.Subject + '\n' + 
            // // 'LAST-MODIFIED:' + convertDateTime(System.now()) + '\n' + 
            // 'SEQUENCE:0' + '\n' + 
            // 'STATUS:' + calendarStatus + '\n' + 
            // 'X-MICROSOFT-CDO-APPT-SEQUENCE:0' + '\n' + 
            // 'X-MICROSOFT-CDO-BUSYSTATUS:TENTATIVE' + '\n' + 
            // 'X-MICROSOFT-CDO-INTENDEDSTATUS:BUSY' + '\n' + 
            // 'X-MICROSOFT-CDO-ALLDAYEVENT:FALSE' + '\n' + 
            // 'X-MICROSOFT-CDO-IMPORTANCE:1' + '\n' + 
            // 'X-MICROSOFT-CDO-INSTTYPE:0' + '\n' + 
            // 'X-MICROSOFT-DONOTFORWARDMEETING:FALSE' + '\n' + 
            // 'X-MICROSOFT-DISALLOW-COUNTER:FALSE' + '\n' + 
            // 'X-MICROSOFT-LOCATIONS:[]' + '\n' + 
            // // 'TRANSP:OPAQUE' + '\n' + 
            // 'END:VEVENT'+ '\n' + 
            // 'END:VCALENDAR';
            'BEGIN:VCALENDAR' + '\n' + 
            'PRODID:-//Microsoft Corporation//Outlook 12.0 MIMEDIR//EN' + '\n' + 
            'VERSION:2.0' + '\n' + 
            'METHOD:REQUEST' + '\n' + 
            'CALSCALE:GREGORIAN ' + '\n' + 
            'X-MS-OLK-FORCEINSPECTOROPEN:TRUE' + '\n' + 
            'BEGIN:VEVENT' + '\n' + 
            'CLASS:PUBLIC' + '\n' + 
            'CREATED:' + convertDateTime(System.now()) + '\n' + 
            'DTEND:' + convertDateTime(dogEvent.EndDateTime) + '\n' + 
            'DTSTAMP:' + convertDateTime(System.now()) + '\n' + 
            'DTSTART:' + convertDateTime(dogEvent.StartDateTime) + '\n' + 
            'LAST-MODIFIED:' + convertDateTime(System.now()) + '\n' + 
            'PRIORITY:5' + '\n' + 
            'SEQUENCE:0' + '\n' + 
            'ACTION:DISPLAY' + '\n' + 
            'SUMMARY:' + dogEvent.Subject + ';\n' + 
            'LANGUAGE=en-us:Meeting Reminder' + '\n' + 
            'TRANSP:OPAQUE' + '\n' + 
            'UID:' + settings.Organizer_Email__c + '\n' +
            'ORGANIZER;CN=' + settings.Organizer_Name__c + ':MAILTO:' + settings.Organizer_Email__c + '\n' + 
            'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY></BODY></HTML>\n' + 
            'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n' + 
            'X-MICROSOFT-CDO-IMPORTANCE:1\n' + 
            'END:VEVENT' + '\n' + 
            'END:VCALENDAR';
        efa.setBody(blob.valueOf(vCal));
        System.debug(convertDateTime(dogEvent.StartDateTime));

        emailMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
        return emailMessage;
    }

    private static String convertDateTime(DateTime dt) {
        String month;
        String day;
        String hour;
        String minute;
        String second;
        if (dt != null) {
            if (dt.month() < 10) {
                month = '0' + String.valueOf(dt.month());
            } else {
                month = String.valueOf(dt.month());
            }
            if (dt.day() < 10) {
                day = '0' + String.valueOf(dt.day());
            } else {
                day = String.valueOf(dt.day());
            }
            if (dt.hour() < 10) {
                hour = '0' + String.valueOf(dt.hour());
            } else {
                hour = String.valueOf(dt.hour());
            }
            if (dt.minute() < 10) {
                minute = '0' + String.valueOf(dt.minute());
            } else {
                minute = String.valueOf(dt.minute());
            }
            if (dt.second() < 10) {
                second = '0' + String.valueOf(dt.second());
            } else {
                second = String.valueOf(dt.second());
            }
        }
        String zuluDateTime = String.valueOf(dt.year()) + month + day + 'T' + 
            hour + minute + second + 'Z';

        return zuluDateTime;
    }
}