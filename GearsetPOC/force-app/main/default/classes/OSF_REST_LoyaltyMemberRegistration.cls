@RestResource(urlMapping = '/RegisterLoyaltyMember/*')
global with sharing class OSF_REST_LoyaltyMemberRegistration {
    private static final Integer BAD_REQUEST = 404;
    private static final Integer EXCEPTION_CODE = 400;
    private static final Integer OK_CODE = 200;
    
    @HttpPost
    global static void upsertAccounts() {
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;
        LoyaltyProgramMember lpm = new LoyaltyProgramMember();
        try {
            Blob body = request.requestBody;
            String bodyString = body.toString();
            //Deserializing the data sent into concrete SFDC objects
                Jsondata jsonwrap =(Jsondata)JSON.deserialize(bodyString,Jsondata.class);
                system.debug(String.isBlank(jsonwrap.AccountId));
            if(String.isBlank(jsonwrap.AccountId)) {
                response.responseBody = createResponse(false, BAD_REQUEST, '','invalidParameters');
                return;
            } else {
                String requestTier = !String.isBlank(jsonwrap.tier) ? jsonwrap.tier : 'Classique';
                List<Account> lstCurrentAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :jsonwrap.AccountId FOR UPDATE]; 
                System.debug('### lstCurrentAccount: ' + lstCurrentAccount);
                System.debug('### jsonwrap: ' + jsonwrap);
                if (lstCurrentAccount != null && lstCurrentAccount.size() == 1) {
                    List<LoyaltyProgramMember> lstExistingLPM = [SELECT Id, MembershipNumber FROM LoyaltyProgramMember WHERE ContactId = :lstCurrentAccount[0].PersonContactId];
                    if (lstExistingLPM.size() > 0) {
                       lstExistingLPM[0].MemberStatus = 'Active';
                        update lstExistingLPM;
                        
                        lstCurrentAccount[0].Loyalty_Opt_In__c = true;
                        update lstCurrentAccount;
                        
                        response.responseBody = createResponse(true, OK_CODE, lstExistingLPM[0].MembershipNumber, 'success');
                        return;
                        // response.responseBody = createResponse(false, BAD_REQUEST, '','memberExists'); return;
                    }   
                    
                    //get the current highest incremental number
                    LoyaltyProgram lp = [SELECT Id, CurrentMembers__c FROM LoyaltyProgram LIMIT 1];
                    //get 40000 of the existing non incremental numbers ordered ascending
                    List<LoyaltyProgramMember> lstExistingLPMs = [SELECT Id, MembershipNumber, IncrementalExtId__c FROM LoyaltyProgramMember WHERE IncrementalExtId__c > :lp.CurrentMembers__c AND IncrementalExtId__c <= :(lp.CurrentMembers__c + 10000) ORDER BY IncrementalExtId__c ASC LIMIT 10000];
                    List<Decimal> lstExistingRandomNumbers = new List<Decimal>();
                    for (LoyaltyProgramMember lpme :lstExistingLPMs) {
                        lstExistingRandomNumbers.add(lpme.IncrementalExtId__c);
                    }

                    Decimal increment = lp.CurrentMembers__c;
                    do {
                        increment++;
                    } while (lstExistingRandomNumbers.contains(increment));

                    String partialNumber = '308381100' + String.valueOf(increment).leftPad(7,'0');
                    System.debug('### partialNumber: ' + partialNumber);
                    lpm.IncrementalExtId__c = increment;
                    lpm.ProgramId =	lp.Id;
                    lpm.EnrollmentDate = Date.today();
                    lpm.MemberStatus = 'Active';                        
                    lpm.MemberType = 'Individual';
                    lpm.MembershipNumber = partialNumber + String.valueOf(getLuhnCheckDigit(partialNumber));
                    lpm.ContactId = lstCurrentAccount[0].PersonContactId;
                    lpm.EnrollmentChannel = String.isBlank(jsonwrap.EnrollmentChannel) ? 'Dotcom' : jsonwrap.EnrollmentChannel;
                    Database.SaveResult sr = Database.insert(lpm, false); 
                    System.debug('### lpm: ' + lpm);
                    if(!sr.isSuccess()){
                        do {
                        increment++; partialNumber = '308381100' + String.valueOf(increment).leftPad(7,'0'); lpm.IncrementalExtId__c = increment; lpm.MembershipNumber = partialNumber + String.valueOf(getLuhnCheckDigit(partialNumber));
                        sr = Database.insert(lpm, false); 
                        } while (!sr.isSuccess()); 
                        System.debug('### lpm2: ' + lpm);
                    }

                    lp.CurrentMembers__c = increment;
                    update lp;
                    
                    Account acc = new Account(Id = jsonwrap.AccountId, Loyalty_Opt_In__c = true);
                    update acc;

                    List<LoyaltyMemberTier> lstCurrentLMT = [SELECT Id, LoyaltyTierId, LoyaltyTierGroupId, ReasonForChange FROM LoyaltyMemberTier WHERE LoyaltyMemberId = :lpm.Id];
                    if (!lstCurrentLMT.isEmpty() && lstCurrentLMT.size() == 1) {
                        lstCurrentLMT[0].TierExpirationDate = Date.today().addYears(1);
                        update lstCurrentLMT[0];
                    }
                    System.debug('### lstCurrentLMT: ' + lstCurrentLMT);
                    //if we have a valid loyalty tier as a parameter we have to compare it to the default loyalty tier created and check if we have to update it or not
                    System.debug('### requestTier: ' + requestTier);
                    if (!String.isBlank(requestTier)) {
                        System.debug('### inside if1 ');
                        List<LoyaltyTier> lstCurrentLoyaltyTier = [SELECT Id, Name, Maximum_Threshold__c, Minimum_Threshold__c, LoyaltyTierGroupId FROM LoyaltyTier WHERE Name = :requestTier]; 
                        System.debug('### lstCurrentLoyaltyTier: ' + lstCurrentLoyaltyTier);
                        if (!lstCurrentLoyaltyTier.isEmpty() && lstCurrentLoyaltyTier.size() == 1) {
                            System.debug('### inside if2 ');
                            Decimal statusPointsToNextTier = lstCurrentLoyaltyTier[0].Maximum_Threshold__c != null ? lstCurrentLoyaltyTier[0].Maximum_Threshold__c + 1 : null;
                            Decimal statusPointsToRemainInTier =  lstCurrentLoyaltyTier[0].Minimum_Threshold__c;
                            System.debug('### statusPointsToNextTier: ' + statusPointsToNextTier);
                            System.debug('### statusPointsToRemainInTier: ' + statusPointsToRemainInTier);
                            List<LoyaltyMemberTier> lstLMT = [SELECT Id, LoyaltyTierId, LoyaltyTierGroupId, ReasonForChange FROM LoyaltyMemberTier WHERE LoyaltyMemberId = :lpm.Id];
                            System.debug('### lstLMT: ' + lstLMT);
                            if (!lstLMT.isEmpty() && lstLMT.size() == 1) {
                                System.debug('### inside if3 ');
                                if (lstLMT[0].LoyaltyTierId != lstCurrentLoyaltyTier[0].Id) {
                                    System.debug('### inside if4 ');
                                    LoyaltyMemberTier lmt = new LoyaltyMemberTier(Id = lstLMT[0].Id, Name = lstCurrentLoyaltyTier[0].Name, LoyaltyTierId = lstCurrentLoyaltyTier[0].Id, LoyaltyTierGroupId = lstCurrentLoyaltyTier[0].LoyaltyTierGroupId, TierExpirationDate = Date.today().addYears(1), ReasonForChange = 'Registration Override');
                                    update lmt;
                                }
                            }
                            lpm.Status_Points_To_Next_Tier__c = statusPointsToNextTier; lpm.StatusPointsToRemainInTier__c = statusPointsToRemainInTier;
                            update lpm;
                            System.debug('### lpm3: ' + lpm);
                        }
                    }
                    
                } else {
                    response.responseBody = createResponse(false, BAD_REQUEST, '','invalidAccountId');
                    return;
                }
            }
            if(lpm.Id != null) {
                response.responseBody = createResponse(true, OK_CODE, lpm.MembershipNumber, 'success');
            } else {
                response.responseBody = createResponse(false, EXCEPTION_CODE, '','pleaseTryAgain');
            }
        } catch(Exception e) {
            response.statusCode = EXCEPTION_CODE;
            response.responseBody = createResponse(false, EXCEPTION_CODE, e.getMessage(), '');
            OSF_ErrorLogHandler.logError(e, 'OSF_REST_LoyaltyMemberRegistration');
        } finally {
            OSF_ErrorLogHandler.saveErrors();
        }
        
    }
    
    private static Blob createResponse(Boolean success, Integer statusCode,String membershipNumber,String message) {
        return Blob.valueOf(JSON.serialize(new ResponseBody(success, statusCode, membershipNumber, message )));
    }

    public static Integer getLuhnCheckDigit(String num) {
        Integer sum = 0;
        Integer digit = 0;
        Integer addend = 0;
        Boolean timesTwo = true;
        for (Integer i = num.length() - 1; i >= 0; i--) {
            digit = Integer.valueOf(num.substring(i, i + 1));
            if (timesTwo) {
                addend = digit * 2;
                if (addend > 9) {
                    addend -= 9;
                }
            } else {
                addend = digit;
            }
            sum += addend;
            timesTwo = !timesTwo;
        }
        Integer modulus = Math.mod(sum, 10); 
        return modulus == 0 ? 0 : 10 - modulus;
    }

    public class ResponseBody {
        public Boolean success;
        public Integer statusCode;
        public String membershipNumber;
        public String message;
        
        public ResponseBody(Boolean success, Integer statusCode,String membershipNumber,String message ) {
            
            this.success = success;
            this.statusCode = statusCode;
            this.membershipNumber = membershipNumber;
            this.message = message;
            
        }
    }
    
    public class Jsondata {  
        public String AccountId;
        public String EnrollmentChannel;
        public String tier;
        

    }
}