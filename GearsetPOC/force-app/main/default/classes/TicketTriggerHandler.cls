public with sharing class TicketTriggerHandler {
    public static TicketTriggerHandler instance;
    public static Boolean isBatchUpdateSheduled;

    public static TicketTriggerHandler getInstance() {
        if (instance == null) {
            instance = new TicketTriggerHandler();
        }
        return instance;
    } 
    
     public static Boolean getIsBatchUpdateSheduled() {
        if (isBatchUpdateSheduled == null || !isBatchUpdateSheduled) {
            Integer jobsCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType in ('BatchApexWorker','ScheduledApex') AND ApexClass.Name = 'TicketUpdateBatchScheduler' AND Status = 'Queued' ];
            isBatchUpdateSheduled = jobsCount > 0;
        }
        return isBatchUpdateSheduled;
    }
    
    /**
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    public void onBeforeInsert(final List<Ticket__c> newObjects) {
        PhoneNumberUtil phoneUtil = PhoneNumberUtil.getInstance();
        onBeforeInsertUpdateCommon(newObjects, phoneUtil);
    }

    //IF(ISBLANK(ETAP_Phone__c), IF(ISBLANK(Telephone_Number__c), Booker__r.PersonHomePhone , Telephone_Number__c), ETAP_Phone__c)

    /**
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(List<Ticket__c> newObjects, Map<Id, Ticket__c> newObjectsMap){
        /*system.debug('I enter on after insert method in ticket trigger handler');
        CompApp_TriggerUtils.upsertCompensations(
                                            CompApp_TriggerUtils.getCompensationCreationData(newObjects, newObjectsMap)
                                        );*/
        AccountingSyncHelper.startSync(
            Trigger.newMap.keySet(), AccountingSyncHelper.TICKET_OBJECT_NAME, AccountingSyncHelper.CREATE_OPERATION
        );
    }


    /**
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onBeforeUpdate(final List<Ticket__c> oldObjects, final Map<Id, Ticket__c> oldObjectsMap,
                               final List<Ticket__c> newObjects, final Map<Id, Ticket__c> newObjectsMap) {
        PhoneNumberUtil phoneUtil = PhoneNumberUtil.getInstance();
        onBeforeInsertUpdateCommon(newObjects, phoneUtil);
    }

    /**
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<Ticket__c> oldObjects, final Map<Id, Ticket__c> oldObjectsMap,
                              final List<Ticket__c> newObjects, final Map<Id, Ticket__c> newObjectsMap) {

        /*List<Ticket__c> departuredYesterdayOrEarlier = new List<Ticket__c>();

        Date departureDate;
        for (Ticket__c ticket : newObjects) {
            String tempDate = ticket.Travel_DateTime__c.substring(0, 10);
            departureDate = Date.newInstance(Integer.valueOf(tempDate.substring(6, 10)), Integer.valueOf(tempDate.substring(3, 5)), Integer.valueOf(tempDate.substring(0, 2)));
            if (departureDate < Date.Today()) {
                departuredYesterdayOrEarlier.add(ticket);
            }
        }
        Map<Id, Ticket__c> departuredYesterdayOrEarlierMap = new Map<Id, Ticket__c>(departuredYesterdayOrEarlier);
        System.Debug('BEFORE COMPENSATION');
        if (departuredYesterdayOrEarlier.size() > 0) {
            System.Debug('ENTERED COMPENSATION');
            CompApp_TriggerUtils.upsertCompensations(
                    CompApp_TriggerUtils.getCompensationCreationData(departuredYesterdayOrEarlier, departuredYesterdayOrEarlierMap)
            );
        }*/
        AccountingSyncHelper.startSync(
                Trigger.newMap.keySet(), AccountingSyncHelper.TICKET_OBJECT_NAME, AccountingSyncHelper.UPDATE_OPERATION
        );
        System.debug('------------------CPU Time upon exiting onAfterUpdate of TicketTriggerHandler: ' + Limits.getCpuTime());
    }

    /**
    * @description fired on before delete event, deletes all the attached documents and sets the application active to false
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    public void onBeforeDelete(final List<Ticket__c> oldObjects, final Map<Id, Ticket__c> oldObjectsMap) {
        
    }

    /**
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */
    //public void onAfterDelete(final List<Ticket__c> oldObjects, final Map<Id, Ticket__c> oldObjectsMap) {
    //    delete [SELECT Id FROM Compensation__c where Ticket__c IN : oldObjects];
    //}

    public void onAfterDelete(final List<Ticket__c> oldObjects, final Map<Id, Ticket__c> oldObjectsMap) {
        AccountingSyncHelper.startSync(
            Trigger.oldMap.keySet(), AccountingSyncHelper.TICKET_OBJECT_NAME, AccountingSyncHelper.DELETE_OPERATION
        );
    }

    /**
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    public void onAfterUndelete(final List<Ticket__c> newObjects, final Map<Id, Ticket__c> newObjectsMap) {
    }

    public void onBeforeInsertUpdateCommon(List<Ticket__c> newObjects, PhoneNumberUtil phoneUtil) {

        Map<Integer, PhoneNumber> phoneNumbersAsContact = new Map<Integer, PhoneNumber>();
        Map<Id, List<Integer>> bookerIdsWithRecordIndexesForHomePhone = new Map<Id, List<Integer>>();
        Set<Id> allPersonIds = new Set<Id>();

        for (Integer i = 0; i < newObjects.size(); i++) {
            Ticket__c ticket = newObjects[i];
            allPersonIds.add(ticket.Booker__c);
            PhoneNumber currentPhoneContact = null;

            PhoneNumber parsedNumber;
            if (ticket.Telephone_Number__c != null && ticket.Telephone_Number__c.length() > 0) {
                ticket.raw_telephone_number__c = ticket.Telephone_Number__c;
                parsedNumber = phoneUtil.parseAndValidateUsingCorrectionAlgo(ticket.Telephone_Number__c);
                if (parsedNumber.countryCode != 0 && parsedNumber.nationalNumber != 0) {
                    ticket.Telephone_Number__c = String.valueOf(parsedNumber.countryCode) + ' ' + parsedNumber.nationalNumber;
                    currentPhoneContact = parsedNumber;
                } else {
                    ticket.Telephone_Number__c = null;
                }
            }

            PhoneNumber parsedETAPNumber = null;
            if (ticket.ETAP_Phone__c != null && ticket.ETAP_Phone__c.length() > 0) {
                ticket.raw_ETAP_Phone__c = ticket.ETAP_Phone__c;
                parsedETAPNumber = phoneUtil.parseAndValidateUsingCorrectionAlgo(ticket.ETAP_Phone__c);
                if (parsedETAPNumber.countryCode != 0 && parsedETAPNumber.nationalNumber != 0) {
                    ticket.ETAP_Phone__c = String.valueOf(parsedETAPNumber.countryCode) + ' ' + parsedETAPNumber.nationalNumber;
                    currentPhoneContact = parsedETAPNumber;
                } else {
                    ticket.ETAP_Phone__c = null;
                }
            }




            if (currentPhoneContact != null) {
                phoneNumbersAsContact.put(i, currentPhoneContact);
            } else {
                List<Integer> indexes = bookerIdsWithRecordIndexesForHomePhone.get(ticket.Booker__c);
                if (indexes == null) {
                    indexes = new List<Integer>();
                    bookerIdsWithRecordIndexesForHomePhone.put(ticket.Booker__c, indexes);
                }
                indexes.add(i);
            }

        }

        Set<Id> bookersWithHomePhoneAsContact = bookerIdsWithRecordIndexesForHomePhone.keySet();
        List<Account> bookersInfo = [SELECT Id, PersonHomePhone
            //, Loyalty_Status__pc 
            FROM Account WHERE Id IN :allPersonIds];
        for (Account accountRec : bookersInfo) {
            if (bookersWithHomePhoneAsContact.contains(accountRec.Id)) {
                if (accountRec.PersonHomePhone != null && accountRec.PersonHomePhone.length() > 0) {
                    List<Integer> indexes = bookerIdsWithRecordIndexesForHomePhone.get(accountRec.Id);
                    PhoneNumber parsedPersonHomePhone = phoneUtil.parseAndValidateUsingCorrectionAlgo(accountRec.PersonHomePhone);
                    for (Integer index : indexes) {
                        phoneNumbersAsContact.put(index, parsedPersonHomePhone);
                    }
                }
            }
        }

        for (Integer index : phoneNumbersAsContact.keySet()) {
            PhoneNumber nextNumber = phoneNumbersAsContact.get(index);
            Ticket__c nextTicket = newObjects[index];
            if (nextNumber.nationalNumber != 0 && nextNumber.countryCode != 0) {
                nextTicket.Contact_Phone_Type__c = phoneUtil.getNumberType(nextNumber);
                if (nextTicket.Contact_Phone_Type__c.contains('Mobile')) {
                    nextTicket.Phone_Locale__c = phoneUtil.getRegionCodeForCountryCode(nextNumber.countryCode);
                } else {
                    nextTicket.Phone_Locale__c = '';
                }
            }
        }

        System.debug('------------------CPU Time upon exiting onBeforeInsertUpdateCommon of TicketTriggerHandler: ' + Limits.getCpuTime());

        //put on ticket loyalty tier from account - obsolete due to new formula field introduction - Loyalty_Tier_ICLP__c
        /*
        Loyalty_Info_Update_Status__c loyaltyUpdateStatus = Loyalty_Info_Update_Status__c.getOrgDefaults();
        if (loyaltyUpdateStatus.Update_Loyalty_On_Ticket__c != null && loyaltyUpdateStatus.Update_Loyalty_On_Ticket__c) {
            Map<Id, Account> mappedBookersInfo = new Map<Id, Account>(bookersInfo);
            for (Ticket__c ticket : newObjects) {
                ticket.Loyalty_Tier__c = mappedBookersInfo.get(ticket.Booker__c).Loyalty_Tier__pc;
            }
        }
        */
    }
    
    public static void sendExceptionMessage(Exception e, TicketUpdateSetting__c ticketUpdateSetting){
        System.debug(e.getMessage());
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = ticketUpdateSetting.EmailRecipients__c.split(',');
        message.subject = 'Trigger Update Batch Schedule Failure';
        message.plainTextBody = 'An issue has occured during TrigerUpdateBatchSchedule. \n' + e.getMessage() + '\n'
            + 'Line number' + e.getLineNumber() + '\n'
            + 'Type ' + e.getTypeName() + '\n'
            + ' Stacktrace ' + e.getStackTraceString();
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}