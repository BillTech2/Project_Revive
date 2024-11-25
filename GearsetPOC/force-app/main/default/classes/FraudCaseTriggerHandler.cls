public  class FraudCaseTriggerHandler  {
    //FIX 
    public static final User ersgu = [select Id from User where name='Emergency Response Site Guest User'][0];
    public static final List<Current_OOO_session_users__c> OOO_SessionList = [Select Id,User_id__c from Current_OOO_session_users__c];
/**
* This class is used to update the ticket with Case ID when a Fraud Audit Case is created.
* All the tickets with PNR number given in the case will we updated with the case id in FraudCaseReference Field
* This Class is invoked from the case trigger FraudCaseHandler'
* */      
    private static  Id FRAUD_AUDIT_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fraud Audit').getRecordTypeId();
    public static void beforeInsert(List<Case> cases){
        getTotalFraudValue(cases);
    }
    public static void afterInsert(List<Case> cases){
        //System.debug('Calling Attach ticket from after Insert');
        attachTicketsToCase(cases);
    }
    
    public static void beforeUpdate(List<Case> cases,  Map<Id, Case> oldVersion){
        //System.debug('In Before Update');
         List<Case> casesToProcess = new List<Case>();
         List<Case> fraudCasesToProcess = new List<Case>();
         List<Case> casesToDetach = new List<Case>();
        Map<Id, Case> oldVersionOfToProcess = new map<Id, Case>();
        //Select only the cases which are not closed
        for (Case nextCase : cases) {
            if (nextCase.Status != 'Closed'){
                if (oldVersion.get(nextCase.Id).pnr__c!=nextCase.PNR__c || oldVersion.get(nextCase.Id).affected_tickets__c!=nextCase.Affected_Tickets__c) {
                    // If PNR or tickets is changed, we need to detach existing tickets from the case
                    //System.debug(oldVersion.get(nextCase.Id).pnr__c+'<-->'+nextCase.PNR__c +'<-->'+ oldVersion.get(nextCase.Id).affected_tickets__c+'<-->'+nextCase.Affected_Tickets__c);
                	casesToDetach.add( nextCase);
                }
                if (nextCase.recordTypeId==FRAUD_AUDIT_TYPE_ID){
                    fraudCasesToProcess.add(nextCase);
                }
                else{
                	casesToProcess.add(nextCase);
                }
            }
        }
        
     	if (casesToDetach.size()>0){
             detachTicketsFromCase(casesToDetach);  //detach old tickets
         }
        if (FraudcasesToProcess.size()>0){ 
            //This will calculate Fraud Value and Attch tickets to the cases
            //System.debug('Calling getTotalFraudValue ' + fraudCasesToProcess.size());
            getTotalFraudValue(fraudCasesToProcess);          
        }
        
       if (casesToProcess.size()>0){           
           //Non Fraud tickets, just attcah tickets
           //System.debug('Calling attachTicketsToCase ' + casesToProcess.size());
            attachTicketsToCase(casesToProcess);
        }
    }
    /*
     * This method is getting called from After Insert Trigger
     * This is required just becuase in the Before Insert we will not get the Case ID
     * Through the before insert trigger 
     * */
    private static void attachTicketsToCase(List<Case> cases){ 

        System.debug('------------------CPU Time upon entering attachTicketsToCase of FraudCaseTriggerHandler: ' + Limits.getCpuTime());

           Date departuredate = Date.today().addDays(-180);  
        //[Select Id From RecordType where Name = 'Fraud Audit' and SobjectType = 'Case' limit 1].Id;
        //!!!COMMENTED OUT DURING FIX!!! User ersgu = [select Id from User where name='Emergency Response Site Guest User'][0];
        List<Case> casestoUpdate=new List<Case>();  
        
        List<String> pnrs= new List<String>();
        //
        //Preparing a list of PNRs
        //
        for (Case c:cases){
            if (c.pnr__c !=null && c.pnr__c!=''){
                pnrs.add(c.pnr__c);
                casestoUpdate.add(c);
            }
        }   
        //
        //Selecting the tickets which are marked as Fradulent thought the Before insert trigger
        List<Ticket__c> tkt = new List<Ticket__c>(); 
        List<String> tcns=null;
		ID firstTktCaseID=null;        
         boolean originalCaseClosed=false;
         boolean covidCase=false;
        boolean fraudCase=false;
        boolean linkedToCovidCase = false;
        If (pnrs !=null && pnrs.size()>0){
        tkt=[select pnr__C, Name, Id, FraudCaseReference__c, Fraud__c, Ticket_Price__c, Original_Currency__c  , Departure_Date__c, FraudCaseReference__r.CreatedBy.name,  FraudCaseReference__r.Status, FraudCaseReference__r.CreatedByID,
             FraudCaseReference__r.Reason_Code__r.Name, FraudCaseReference__r.recordTypeId, FraudCaseReference__r.Allow_Re_submission__c from ticket__c 
             where pnr__c in :pnrs and Departure_Date__c>=:departuredate order by pnr__c, FraudCaseReference__c desc NULLS LAST	];
        }
        If (tkt !=null && tkt.size()>0){
            for (Case c:casestoUpdate){ 
                firstTktCaseID = null;
                covidCase=isCovidCase(ersgu, c.CreatedById);
                fraudCase=(c.recordTypeId==FRAUD_AUDIT_TYPE_ID);
                
                /*System.debug('Case----------'+c.subject + '<-->'+c.Id+'<--->'+c.pnr__c +'<--->'+covidCase+'---'+c.CreatedBy.name+'---ID'+c.CreatedByID);
                System.debug('Case----------recordTypeId'+c.recordTypeId );
                System.debug('firstTktCaseID----------'+firstTktCaseID + '<-->'+c.Id+'<--->'+c.pnr__c);*/
                
                originalCaseClosed=false;
                If (covidcase && c.Allow_Re_submission__c ){
                    //The case is marked for a re-submission
                    //Hence no need for re-link and skip to next case
                    continue;
                }
                for(Ticket__c t:tkt){        
                    System.debug(t.pnr__c + '---' + t.name +'-->'+t.FraudCaseReference__c + '===='+firstTktCaseID); 
                    if (t.pnr__c != c.pnr__c ){
                        continue;
                    } 
                    else{   
                         System.debug('Found PNR');
                        if (fraudCase){                              
                             System.debug('Fraud Case');
                             //Fraud Case has the highest priorty. If the current case if fraud, nothing else to check, assign the ticket to case
                        	if (t.Fraud__c){ //If Fraud Case, then associate only the tickets marked as Fraud
                                System.debug('Ticket updated with case' + t.name +'--'+firstTktCaseID);
                            	t.FraudCaseReference__c=c.id	; //Assigning Case ID                                    
                        	}
                            continue;//Go to next ticket
                        }
                        else{
                            //No Fraud Case
                            if (firstTktCaseID==null){
                                if (t.FraudCaseReference__c !=null){
                                  //  System.debug('Tick Already has Case');
                                    firstTktCaseID = t.FraudCaseReference__c ;
                                    Ticket__c originalcase = t; //[select status, CreatedBy.name, CreatedById, Reason_Code__r.Name, recordTypeId from Case where id=:firstTktCaseID][0];
                                    
                                    if (t.FraudCaseReference__r.recordTypeId==FRAUD_AUDIT_TYPE_ID){
                                        //if the tikcket is alredy linked to a Fraud csae, cannot relink it
                                        //hence can be moved to next case
                                        break;
                                    }
                                    else{
                                        linkedToCovidCase = isCovidCase(ersgu, originalcase.FraudCaseReference__r.CreatedById);
                                        if (covidCase){
                                            // System.debug('Current Case is Covid');
                                            if  (!linkedToCovidCase || originalCase.FraudCaseReference__r.Allow_Re_submission__c){
                                                // System.debug('Not linked to Covid Case');
                                            //Current Case is a Covid Cliam and 
                                            //	the ticket is not linked to a covid case or the case linked is marked for resubmission
                                            //Ticket needs to be linked to current case;
                                                t.FraudCaseReference__c=null;
                                                firstTktCaseID = c.id ;
                                            }
                                            else{
                                                //Original Case id a Covid Case
                                                //Now checking if is closed or not. If yes, we cannot assign any more tickets to that case.
                                                firstTktCaseID = t.FraudCaseReference__c;
                                                if (t.FraudCaseReference__r.Status=='Closed')
                                                    originalCaseClosed=true;
                                                
                                                
                                            }
                                        }
                                        else{ 
                                            firstTktCaseID = t.FraudCaseReference__c;
                                        }
                                         if (t.FraudCaseReference__r.Status=='Closed')
                                                    originalCaseClosed=true;
                                	}
                                }
                                else
                                    firstTktCaseID = c.id ;
                            }
                            if (t.FraudCaseReference__c !=null && t.FraudCaseReference__r.recordTypeID!=FRAUD_AUDIT_TYPE_ID){
                                if (covidCase){
                                    if (t.FraudCaseReference__r.Allow_re_submission__c){
                                         t.FraudCaseReference__c =null ;
                                    }
                                    else{
                                        if (isCovidCase(ersgu, t.FraudCaseReference__r.CreatedByID)){
                                            if (t.FraudCaseReference__c==firstTktCaseID){
                                            //Ticket is Already linked to a covid Case Hence skip
                                                continue;
                                            }
                                            else{
                                                
                                                c.addError('Multiple Covid References for same PNR' 	);
                                            }
                                        }
                                        else{
                                            //Current Case a Covid Claim and the tickte is linked to a different type of case
                                            //Ticket needs to be linked to Covid Case
                                            t.FraudCaseReference__c =null ;
                                        }
                                    }
                                       
                                }
                                    //System.debug('Tick Already has Case Hence skipping the ticket'); 
                                    //continue;
                            }
                            //System.debug('Comparing IDs --'+firstTktCaseID +'<------->'+c.id+'<------v---->'+originalCaseClosed);
                            if (firstTktCaseID != c.id){
                                if (originalCaseClosed){
                                    break;
                                }
                            }
                            else{
                               System.debug('Comparing IDs 2 --'+firstTktCaseID +'<------->'+c.id+'<------v---->'+originalCaseClosed);
                            }
                            //Identified a ticket with PNR given in the case
                           
                             { 
                                System.debug('Non Fraud Case');
                                if ( null!= c.affected_tickets__c && ''!= c.affected_tickets__c){
                                     tcns=c.affected_tickets__c.split(',');
                                     for(String s:tcns){                              
                                        if (s==t.Name){ 
                                            //System.debug('Found a ticket --'+t.name +'<------->'+c.affected_tickets__c);
                                            t.FraudCaseReference__c=firstTktCaseID;
                                            break;
                                        }
                                    } 
                                }
                                else{
                                    t.FraudCaseReference__c=firstTktCaseID;
                                    //System.debug('Updating ticket with Case reference:'+t.name+'<-->'+firstTktCaseID);
                                }
                            }
                    	}
                    }
                } 
            } 
        
        }
        if (tkt!=null && tkt.size()>0)
            update tkt; 
            System.debug('------------------CPU Time after tickets update inside attachTicketsToCase (exiting) of FraudCaseTriggerHandler: ' + Limits.getCpuTime());
        
    }
    private static  boolean isCovidCase(User u, ID createdBy){
        return (u.Id == createdBy); // && reason=='Disruption/Compensation/Coronavirus (COVID-19)');
        
    } 
    /**
     * This method calculates total fraud value and associate the ticket to a case
     * But when this is called from Before Insert trigger association will not happen and Case Id will not be generated in the Before Insert
     * */
    private static void getTotalFraudValue (List<Case> cases){
        Date departuredate = Date.today().addDays(-180);

        //!!!COMMENTED OUT DURING FIX!!! User ersgu = [select Id from User where name='Emergency Response Site Guest User'][0];
        
        //[Select Id From RecordType where Name = 'Fraud Audit' and SobjectType = 'Case' limit 1].Id;
        
        List<Case> casestoUpdate=new List<Case>();
        //
        //Identify the case of appropriate type
        //
        for(Case c:cases){
            if (c.recordTypeId==FRAUD_AUDIT_TYPE_ID )
                casestoUpdate.add(c);
        }
        
        List<String> pnrs= new List<String>();
        //
        //Prepare a list of PNRS from all relevent Cases
        //
        for (Case c:casestoUpdate){
            if (c.pnr__c !=null && c.pnr__c!=''){
                pnrs.add(c.pnr__c);
            }
        } 
        //
        //Get all the tickets assocated to the PNRS in the PNR List
        //
        List<Ticket__c> tkt = new List<Ticket__c>();
        if (pnrs!=null && pnrs.size()>0){
        	tkt = [select pnr__C, Name, Id, FraudCaseReference__c,FraudCaseReference__r.createdByID, Fraud__c, Ticket_Price__c, Original_Currency__c  
                   from ticket__c where   cancelled_by_customer__c=false and pnr__c in :pnrs and Departure_Date__c>=:departuredate	];
        }     
        Decimal fraud_ticketprice=0;
        Decimal ticketprice=0;
        String[] tcns =null;
        String affectedTickets=null;
        String currecyCode=null;
        ////System.debug('FOUND' + tkt.size() + 'Tickets');
        
        //
        //Iterate through relevant cases
        //
        for (Case c:casestoUpdate){
            affectedTickets=c.affected_tickets__c; //Case is interested in only specific TCNs
            tcns =null;
            currecyCode=null;
            fraud_ticketprice=0;
            ticketprice=0;
            if ( null!= affectedTickets && ''!= affectedTickets){
                tcns=affectedTickets.split(',');
            }
            for(Ticket__c t:tkt){       //Iterate thorough the ticket list
                //If the ticket is already linked to a Covid Case, do not re-link it
                //if (t.FraudCaseReference__c!=null && isCovidCase(ersgu,t.FraudCaseReference__r.CreatedByID)) 
                //    continue;
                t.Fraud__c=false;
                currecyCode = t.Original_Currency__c;
                ////System.debug(t.pnr__c +'-'+ c.pnr__c);
                if (t.pnr__c != c.pnr__c ){// If PNR of the ticket is not same as PNR in the Case then this ticket is not relevant to this case
                    continue; 
                } 
                else{ //Founf a ticket Relevant to the case
                    if (tcns==null || tcns.size()==0){
                        //
                        //No specific TCN is mentioned in the case hence we are marking all the tickets as Fradulent
                        //
                        
                        ////System.debug('NO TCNS.. MARKING TICKET TRUE');
                        t.Fraud__c=true;
                    }
                    else{//Specific ticket is mentioned in the case, hence ned to identify them
                        for(String s:tcns){
                             System.debug(s +'-'+ t.name + 'TCN CHECK');
                            if (s==t.Name){
                                t.Fraud__c=true;
                                System.debug('YES (1) TCNS.. MARKING TICKET TRUE');
                                break;
                            }
                        }
                    }                
                    if (t.Fraud__c){
                       System.debug('YES TCNS.. MARKING TICKET CCID' + c.id);
                       // 
                       // This is a fraud ticket, hence update the ticket with Case ID
                       // 
                        t.FraudCaseReference__c=c.id	;
                        fraud_ticketprice += t.Ticket_Price__c;
                    }
                    ticketprice += t.Ticket_Price__c;
                }
            }
            c.Value_Of_Fraudulent_Tickets__c=(fraud_ticketprice==0?ticketprice:fraud_ticketprice);
            c.Currency__c = currecyCode;
        } 
        if (tkt!=null && tkt.size()>0) //Now save tickets
            update tkt;  
        
    }
    /**
     * This method removes the link of tcsn to the cases which are being modified. This will consider only those cases whose TCN or PNR is changed
     * */
	
    public  static void detachTicketsFromCase(List<Case> cases ){ 
        //Clear current tickets
        if (cases!=null && cases.size()>0){
            List<Ticket__c> oldtkt=[select Id, FraudCaseReference__c from ticket__c where FraudCaseReference__c in :cases];
            //System.debug('Released ' + oldtkt.size() + ' Tickets');
            for(Ticket__c t:oldtkt){ 
                t.FraudCaseReference__c=null	;
            }
            update oldtkt;
        } 
        
        
    } 
    
}