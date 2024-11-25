public class CompApp_Utils {
    //FIX
    public static final Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

    private static String telephoneNumber;

    public static Id getContactIdByEmail(String userEmail, String fName, String lName) {
        String searchQuery = 'FIND \'' + String.escapeSingleQuotes(userEmail) + '\' IN EMAIL FIELDS RETURNING Account (Id, Customer_Email__pc, Contact_Number__c, PersonContactId, RecordTypeId)' ;
        //!!!COMMENTED OUT DURING FIX!!! Id personAccountRecordTypeId =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'][0].id;
        List<Account> accsToUpdateByTelephoneNumber = new List<Account>();
        Id personContactId = null;

        List<Account> perAccountList = (List<Account>) CompApp_Utils.getFieldIdMap2list(search.query(searchQuery)[0], 'RecordTypeId').get(personAccountRecordTypeId);
        if (CompApp_Utils.isWellBehaved(perAccountList)) {
            for (Account iteratedAcc : perAccountList) {
                if (iteratedAcc.Customer_Email__pc != null && iteratedAcc.Customer_Email__pc.toLowerCase() == userEmail.toLowerCase() && personContactId == null) {
                    personContactId = iteratedAcc.PersonContactId;
                    if (!String.isEmpty(telephoneNumber)) {
                        iteratedAcc.Contact_Number__c = getTelephoneNumberForPersonAccount();
                        accsToUpdateByTelephoneNumber.add(iteratedAcc);
                    }
                }
            }
            if (!accsToUpdateByTelephoneNumber.isEmpty()) {
                update accsToUpdateByTelephoneNumber;
            }
            return personContactId != null ? personContactId : perAccountList[0].PersonContactId;
        } else {
            try {
                Account newPersonAccount = new Account(
                        FirstName = fName,
                        LastName = lName,
                        RecordTypeId = personAccountRecordTypeId,
                        Customer_Email__pc = userEmail,
                        Customer_Email__c = userEmail,
                        Contact_Number__c = getTelephoneNumberForPersonAccount()
                );
                insert newPersonAccount;
                return [SELECT PersonContactId FROM Account WHERE Id = :newPersonAccount.Id limit 1][0].PersonContactId;
            } catch (Exception e) {
                system.debug(e.getMessage());
                Contact c = [SELECT Id FROM Contact WHERE Customer_Email__c = :userEmail LIMIT 1];
                Id cId = (c != null) ? c.Id : null;
                return cId;
            }
        }
    }

    // Jira-1715 - added to set telephone number from CompApp_CtrlContactUs class
    public static void setTelephoneNumberForPersonAccount(String phoneNumber) {
        telephoneNumber = phoneNumber;
    }
    // Jira-1715 - added to get telephone number for Person Account
    private static String getTelephoneNumberForPersonAccount() {
        return telephoneNumber;
    }

    public static Map<String, Decimal> compensationFlatFeeRuleAmountByXKeyMap {
        get { // XKey = currencyCode+incidentType+travelerClass
            if (compensationFlatFeeRuleAmountByXKeyMap == null) {
                compensationFlatFeeRuleAmountByXKeyMap = new Map<String, Decimal>();
                for (CompApp_Constructs.CompensationFlatFeeRulesWrapper compFlatFeeRule : getCompensationFlatFeeRulesListByCustomSettingList(Compensation_Flat_Fee_Rules__c.getAll().values())) {
                    system.debug(compFlatFeeRule);
                    compensationFlatFeeRuleAmountByXKeyMap.put(compFlatFeeRule.currencyCode + compFlatFeeRule.incidentType + compFlatFeeRule.travelerClass, compFlatFeeRule.voucherAmount);
                }
            }

            return compensationFlatFeeRuleAmountByXKeyMap;
        }
    }

    private static List<CompApp_Constructs.CompensationFlatFeeRulesWrapper> getCompensationFlatFeeRulesListByCustomSettingList(List<Compensation_Flat_Fee_Rules__c> customRuleList) {
        List<CompApp_Constructs.CompensationFlatFeeRulesWrapper> retList = new List<CompApp_Constructs.CompensationFlatFeeRulesWrapper>();

        for (Compensation_Flat_Fee_Rules__c compFlatFeeRule : customRuleList) {
            retList.add(new CompApp_Constructs.CompensationFlatFeeRulesWrapper(compFlatFeeRule));
        }

        return retList;
    }

    public static List<CompApp_Constructs.CompensationRuleWrapper> compensationRuleList {
        get {
            if (compensationRuleList == null) {
                compensationRuleList = getCompensationRuleListByCustomSettingList(Compensation_Rules__c.getAll().values(), 'Delay');
            }

            return compensationRuleList;
        }
    }

    public static List<CompApp_Constructs.CompensationRuleWrapper> zeroPriceCompensationList {
        get {
            if (zeroPriceCompensationList == null) {
                zeroPriceCompensationList = getCompensationRuleListByCustomSettingList(Comp_App_Zero_Price_Compensation__c.getAll().values(), '');
            }

            return zeroPriceCompensationList;
        }
    }

    private static List<CompApp_Constructs.CompensationRuleWrapper> getCompensationRuleListByCustomSettingList(List<Sobject> customRuleList, String type) {
        List<CompApp_Constructs.CompensationRuleWrapper> retList = new List<CompApp_Constructs.CompensationRuleWrapper>();
        Boolean checkType = CompApp_Utils.isWellBehaved(type);
        for (Sobject compRule : customRuleList) {
            if (Boolean.valueOf(compRule.get('isValidRule__c')) && (!checkType || safe_StringValueOf(compRule.get('Type__c')) == type)) {
                retList.add(new CompApp_Constructs.CompensationRuleWrapper(compRule));
            }
        }

        if (retList.size() == 0) {
            throw new CompApp_Constructs.CompApp_DataIssueException('A Delay Compensation_Rules__c record is not defined.');
        }
        retList.sort();
        return retList;

    }

    public static Compensation_Rules__c cancelledCompensationRule {
        get {
            if (cancelledCompensationRule == null) {
                cancelledCompensationRule = Compensation_Rules__c.getInstance('Delay');
                if (cancelledCompensationRule == null) {
                    throw new CompApp_Constructs.CompApp_DataIssueException('A Delay Compensation_Rules__c record is not defined.');
                }
            }
            return cancelledCompensationRule;
        }
    }

    public static Map<CompApp_Constructs.CompansationExclusionRuleType, Pattern> patternByCompansationExclusionRuleTypeMap {
        get {
            if (patternByCompansationExclusionRuleTypeMap == null) {
                patternByCompansationExclusionRuleTypeMap = new Map<CompApp_Constructs.CompansationExclusionRuleType, Pattern>();
                Map<String, Comp_App_Exclusion_Rules__c> excludedCompensationRulesMap = Comp_App_Exclusion_Rules__c.getAll();

                if (excludedCompensationRulesMap == null) {
                    throw new CompApp_Constructs.CompApp_DataIssueException('A Comp_App_Exclusion_Rules__c record is not defined.');
                }

                String FBCcodeString = '';
                for (Comp_App_Exclusion_Rules__c iteratedRule : excludedCompensationRulesMap.values()) {
                    FBCcodeString += iteratedRule.Exclude_Matching__c;
                }

                Pattern compiledFBC = Pattern.compile(FBCcodeString);

                // Due legacy support, we put the same compiled form for Zero & non-zeroprice ticket.
                patternByCompansationExclusionRuleTypeMap.put(
                        CompApp_Constructs.CompansationExclusionRuleType.NON_ZERO_PRICE_TICKET,
                        compiledFBC
                );

                patternByCompansationExclusionRuleTypeMap.put(
                        CompApp_Constructs.CompansationExclusionRuleType.ZERO_PRICE_TICKET,
                        compiledFBC
                );
            }

            return patternByCompansationExclusionRuleTypeMap;
        }
    }

    public static Id compensationOnlineRecTypeID {
        get {
            if (compensationOnlineRecTypeID == null) {
                List<RecordType> recTypeList = [SELECT Id FROM RecordType where SobjectType = 'Compensation__c' AND DeveloperName = 'Online' limit 1];
                if (!isWellBehaved(recTypeList)) {
                    throw new CompApp_Constructs.CompApp_DataIssueException('Record type "Online" for Ticket__c must be defined');
                } else {
                    compensationOnlineRecTypeID = recTypeList[0].id;
                }

            }

            return compensationOnlineRecTypeID;
        }
    }


    public Static CompApp_Constructs.CompApp_DataIssueException getStandardDataException() {
        return new CompApp_Constructs.CompApp_DataIssueException('Unknown data error encountered. please verify custom settings data.');
    }

    public static Boolean isUserCaptchaVerified(String userRemoteIp) {
        log('userRemoteIp @ isUserCaptchaVerified: ' + userRemoteIp);
        List<CompApp_CaptchaLogger__c> captchLogList = [
                SELECT
                        isVerified__c
                FROM
                        CompApp_CaptchaLogger__c
                WHERE
                        name = :userRemoteIp
                        AND
                        LastModifiedDate > :Datetime.now().addMinutes(-CompApp_Constructs.GOOGLE_CAPTCHA_LIVIDITY_TIME)
                        AND
                        isVerified__c = true
                ORDER BY
                        LastModifiedDate DESC
                LIMIT
                        1
        ];


        return isWellBehaved(captchLogList);
    }

    public static String remove2LeadingAlpha(String inStr) {
        String retStr;

        if (inStr.left(2).isAlpha()) {
            retStr = inStr.mid(2, inStr.length());
        } else if (inStr.left(1).isAlpha()) {
            retStr = inStr.mid(1, inStr.length());
        } else {
            retStr = inStr;
        }

        return retStr;
    }

    public static Boolean processCaptchaResult(String userRemoteIp, String captchaRes) {
        Boolean isVerified = checkCaptchaViaGoogle(captchaRes, userRemoteIp);
        incrementCaptchaAttempt(userRemoteIp, isVerified);
        return isVerified;
    }

    private static Void incrementCaptchaAttempt(String userRemoteIp, Boolean isVerified) {
        List<CompApp_CaptchaLogger__c> captchLogList = [
                SELECT
                        id, Name, isVerified__c, verification_attempts__c
                FROM
                        CompApp_CaptchaLogger__c
                WHERE
                        name = :userRemoteIp
                ORDER BY
                        LastModifiedDate DESC
                LIMIT
                        1
        ];

        if (CompApp_Utils.isWellBehaved(captchLogList)) {
            update new CompApp_CaptchaLogger__c(
                    id = captchLogList[0].id,
                    isVerified__c = isVerified,
                    verification_attempts__c = 1 + captchLogList[0].verification_attempts__c
            );
        } else {
            insert new CompApp_CaptchaLogger__c(Name = userRemoteIp, isVerified__c = isVerified, verification_attempts__c = 1);
        }
    }


    private static Boolean checkCaptchaViaGoogle(String captchaRes, String userRemoteIp) {
        String GOOGLE_CAPTCH_ENDPOINT = 'https://www.google.com/recaptcha/api/siteverify';

        String GOOGLE_CAPTCH_SECRET = Compensation_App_Metadata__c.getValues('google_captcha_secret').Data__c;

        String userVerificationParams = '?secret=' + GOOGLE_CAPTCH_SECRET + '&remoteip=' + userRemoteIp + '&response=' + captchaRes;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(GOOGLE_CAPTCH_ENDPOINT + userVerificationParams);
        req.setMethod('GET');

        return Test.isRunningTest() || Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(new Http().send(req).getBody())).get('success'));
    }

    public static String getPointsFromVoucherSum(String currencyCode, Decimal compToAdd, Ticket__c parentTicket) {
        if (parentTicket.Ticket_Price__c != 0) {
            // Clculates the total points for the Compensation.
            if (currencyCode == 'USD') {
                return '0';
            }

            return String.valueOf(Math.ceil(compToAdd /
                    (
                            (currencyCode == 'GBP') ?
                                    CompApp_Constructs.GBP_2_POINT_CONVERSION_RATE :
                                    (currencyCode == 'EUR') ?
                                            CompApp_Constructs.EUR_2_POINT_CONVERSION_RATE :
                                            1
                    )));
        } else {
            CompApp_Constructs.CompensationRuleWrapper chosenCompensationRule = CompApp_Utils.getZeroPriceCompensationByTicket(parentTicket);
            return chosenCompensationRule == null ? '0' : String.valueOf(chosenCompensationRule.points);
        }
    }


    public static Decimal getPointsFromCompensation(Compensation__c comp, Ticket__c parentTicket) {
        return Decimal.valueOf(getPointsFromVoucherSum(comp.Payment_Currency__c, comp.Total_Online_Compensation__c, parentTicket));
    }

    public static String safe_StringValueOf(Object o) {
        try {
            return String.valueOf(o);
        } catch (Exception e) {
            return '';
        }
    }

    public static String getLabelContent(String labelAPIName, String languageCode) {
        return labelAPIName;
/* OLD VERSION
        PageReference translationPage =  Page.CompApp_LabelTranslationPage;
        translationPage.getParameters().put('labelAPIName',labelAPIName);
        translationPage.getParameters().put('languageCode',languageCode);
        if (!Test.IsRunningTest()){
            return translationPage.getContent().toString().normalizeSpace().trim();
        }
        else{
            return '';
        }
*/
    }

    public static void log(Object ob) {
        system.debug('\n\n\n' + ob + '\n\n\n');
    }

    public static Boolean isWellBehaved(String inStr) {
        return inStr != null && inStr != '';
    }

    public static Boolean isWellBehaved(sObject sobj) {
        return sobj != null;
    }

    public static Boolean isWellBehaved(Set<Id> obSet) {
        return obSet != null && obSet.size() != 0;
    }

    public static Boolean isWellBehaved(List<sObject> sObList) {
        return sObList != null && sObList.size() != 0;
    }

    public static Boolean isWellBehaved(List<Object> ObList) {
        return ObList != null && ObList.size() != 0;
    }

    // returns the rule wrapper where the Rule.startDelay > inputDelay > Ruls.endDelay, if more than 1 found, returns the record withe the lowest startDelay.
    public static CompApp_Constructs.CompensationRuleWrapper getCompRuleByTicket(Ticket__c parentTicket) {
        if (parentTicket.Cancelled__c) {
            return new CompApp_Constructs.CompensationRuleWrapper(cancelledCompensationRule);
        } else {
            for (CompApp_Constructs.CompensationRuleWrapper compRule : compensationRuleList) {
                if (compRule.isInRange(parentTicket.Delay_mins__c)) {
                    return compRule;
                }
            }

            // If none in range, and inputDelay > Max delay, falls back to the highest one 
            if (
                    compensationRuleList.size() > 0 &&
                            parentTicket.Delay_mins__c > compensationRuleList[compensationRuleList.size() - 1].delayStart
            ) {
                return compensationRuleList[compensationRuleList.size() - 1];
            } else {
                return null;
            }
        }
    }

    // returns the rule wrapper where the Rule.startDelay > inputDelay > Ruls.endDelay, if more than 1 found, returns the record withe the lowest startDelay.
    public static CompApp_Constructs.CompensationRuleWrapper getZeroPriceCompensationByTicket(Ticket__c parentTicket) {
        CompApp_Utils.log('parentTicket @ getZeroPriceCompensationByTicket:' + parentTicket);
        CompApp_Utils.log('zeroPriceCompensationList[0] @ getZeroPriceCompensationByTicket:' + zeroPriceCompensationList[0]);
        for (CompApp_Constructs.CompensationRuleWrapper zeroPriceComp : zeroPriceCompensationList) {
            if (
                    (parentTicket.FBC__c != null && zeroPriceComp.fbc.containsIgnoreCase(parentTicket.FBC__c)) &&
                            parentTicket.Original_Currency__c == zeroPriceComp.originalCurrency &&
                            (
                                    zeroPriceComp.isInMaxRange(parentTicket.Delay_mins__c) ||
                                            zeroPriceComp.isInRange(parentTicket.Delay_mins__c) ||
                                            (parentTicket.Cancelled__c && zeroPriceComp.type == 'Cancelled')
                            )
            ) {
                return zeroPriceComp;
            }
        }

        return null;
    }

    public static Map<Id, Sobject> getSobjectIdMap(String fieldName, List<Sobject> objList) {
        return ((Map<Id, Sobject>) JSON.deserialize(JSON.serialize(getSobjectMap(fieldName, objList)), Map<Id, Sobject>.class));
    }


    public static Map<String, Sobject> getSobjectMap(String fieldName, List<Sobject> objList) {
        Map<String, sObject> retMap = new Map<String, sObject> ();

        if (isWellBehaved(objList) && isWellBehaved(fieldName)) {
            for (sObject obj : objList) {
                retMap.put(safe_StringValueOf(obj.get(fieldName)), obj);
            }
        }
        return retMap;
    }

    @testVisible
    // Warning: Changes the input Compensation
    private static Compensation__c populateDelayFields(Ticket__c parentTicket, Compensation__c childCompensatiob) {
        CompApp_Constructs.CompensationRuleWrapper compRule = getCompRuleByTicket(parentTicket);
        CompApp_Constructs.CompensationRuleWrapper zeroPriceComp = getZeroPriceCompensationByTicket(parentTicket);
        if (parentTicket.Ticket_Price__c != 0) {
            childCompensatiob.Base_Compensation__c = getBaseCompensationByTicket(parentTicket, compRule, new List<String>());
        } else {
            if (zeroPriceComp != null) {
                childCompensatiob.Base_Compensation__c = zeroPriceComp.voucher;
            } else
                    childCompensatiob.Base_Compensation__c = 0;
        }

        childCompensatiob.Is_Excluded_From_Delay_Compensation__c = isTicketExcludedFromDelayCompensation(parentTicket);

        return childCompensatiob;
    }

    public static Decimal getBaseCompensationByTicket(Ticket__c parentTicket, CompApp_Constructs.CompensationRuleWrapper compRule, List<String> compensationPercentageList) {
        Decimal baseCompensationPercentage = compRule.eligibleCompensation;
        baseCompensationPercentage = baseCompensationPercentage == null ? 0 : baseCompensationPercentage;
        compensationPercentageList.add('All (' + baseCompensationPercentage + '%)');
        if (getLoyaltyTier(parentTicket.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CC) {
            compensationPercentageList.add('CC (' + compRule.eligibleBaseCompensationCC + '%)');
            baseCompensationPercentage += compRule.eligibleBaseCompensationCC;
        } else if (getLoyaltyTier(parentTicket.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CB) {
            compensationPercentageList.add('CB (' + compRule.eligibleBaseCompensationCB + '%)');
            baseCompensationPercentage += compRule.eligibleBaseCompensationCB;
        } else if (getLoyaltyTier(parentTicket.Loyalty_Tier__c) == CompApp_Constructs.LOYALTY_TIER.CBE) {
            compensationPercentageList.add('CBE (' + compRule.eligibleBaseCompensationCBE + '%)');
            baseCompensationPercentage += compRule.eligibleBaseCompensationCBE;
        }
        return parentTicket.Ticket_Price__c * baseCompensationPercentage / 100;
    }

    public static CompApp_Constructs.LOYALTY_TIER getLoyaltyTier(String str) {
        return
                str == NULL ?
                        NULL :
                        str.containsIgnoreCase('Carte Blanche (Elite)') ?
                                CompApp_Constructs.LOYALTY_TIER.CBE :
                                str.containsIgnoreCase('Carte Blanche') ?
                                        CompApp_Constructs.LOYALTY_TIER.CB :
                                        str.containsIgnoreCase('Carte Classique') ?
                                                CompApp_Constructs.LOYALTY_TIER.CC :
                                                NULL;

    }

    public static Decimal getDecimalValue(Decimal num) {
        if (num != null) {
            return num;
        } else {
            return 0;
        }
    }

    public static boolean isTicketExcludedFromDelayCompensation(Ticket__c tik) {
        if (!(tik.Checked_In__c && isWellBehaved(tik.FBC__c))) {
            return false;
        } else {
            if (tik.Ticket_Price__c == 0) {
                system.debug('patternByCompansationExclusionRuleTypeMap.get(CompApp_Constructs.CompansationExclusionRuleType.ZERO_PRICE_TICKET) = ' + patternByCompansationExclusionRuleTypeMap.get(CompApp_Constructs.CompansationExclusionRuleType.ZERO_PRICE_TICKET));
                return patternByCompansationExclusionRuleTypeMap.get(CompApp_Constructs.CompansationExclusionRuleType.ZERO_PRICE_TICKET).matcher(tik.FBC__c).matches();
            } else {
                return patternByCompansationExclusionRuleTypeMap.get(CompApp_Constructs.CompansationExclusionRuleType.NON_ZERO_PRICE_TICKET).matcher(tik.FBC__c).matches();
            }
        }
    }


    public static map<Id, list<SObject>> getFieldIdMap2list(list<Sobject> objList, string fieldAPIName) {
        return ((Map<Id, List<Sobject>>) JSON.deserialize(JSON.serialize(getFieldValueMap2list(objList, fieldAPIName)), Map<Id, List<Sobject>>.class));
    }


    public static map<String, list<SObject>> getFieldValueMap2list(list<Sobject> objList, string fieldAPIName) {
        map<String, list<SObject>> returnMap = new map<String, list<SObject>>();

        if (objList != null || objList.size() != 0) {
            list <string> apiNames = new list<string>(fieldAPIName.split('\\.'));

            for (Sobject obj : objList) {
                Sobject fieldValue = obj;
                list<string> tmpAPINames = apiNames.clone();

                while (tmpAPINames != null && tmpAPINames.size() > 1) {
                    fieldValue = fieldValue.getSObject(tmpAPINames.remove(0));
                }

                if (!returnMap.containsKey(string.ValueOf(fieldValue.get(tmpAPINames[0])))) {
                    returnMap.put(string.ValueOf(fieldValue.get(tmpAPINames[0])), new list<Sobject>());
                }

                returnMap.get(string.ValueOf(fieldValue.get(tmpAPINames[0]))).add(obj);
            }
        }
        return returnMap;
    }

    public static Boolean isNotCompensationThirdParty(String directPointOfSale) {
        Set<String> directPointsOfSale = new Set<String>();

        for (Compensation_Third_Party__c compensationThirdParty : Compensation_Third_Party__c.getAll().values()) {
            directPointsOfSale.add(compensationThirdParty.Direct_Points_of_Sale__c);
        }
        if (String.isNotBlank(directPointOfSale) && directPointsOfSale.contains(directPointOfSale)) {
            return true;
        } else {
            return false;
        }
    }

    public static Decimal calculateBaseCompensation(Compensation_Ticket__c junctionCompensationTicket, CompApp_Constructs.CompensationRuleWrapper compRule, List<String> compensationPercentageList){

        Decimal baseCompensation;

        if(junctionCompensationTicket.Ticket__r.Ticket_Price__c == null || junctionCompensationTicket.Ticket__r.Ticket_Price__c < 0) return null;

        try{
            // Passing Point Override
            if(junctionCompensationTicket.Passing_Point__c != null && junctionCompensationTicket.Passing_Point__r.PassingPoint_Voucher__c != null){
                return junctionCompensationTicket.Ticket__r.Ticket_Price__c * junctionCompensationTicket.Passing_Point__r.PassingPoint_Voucher__c / 100;
            }
            // Train Override
            else if(junctionCompensationTicket.Passing_Point__c == null && junctionCompensationTicket.Ticket__r.Train__r.Destination_Voucher__c != null){
                return junctionCompensationTicket.Ticket__r.Ticket_Price__c * junctionCompensationTicket.Ticket__r.Train__r.Destination_Voucher__c / 100;
            }
            // Standard calculation
            else if(compRule != null){
                return CompApp_Utils.getBaseCompensationByTicket(junctionCompensationTicket.Ticket__r, compRule, compensationPercentageList);
            }
            return null;
        }
        catch(NullPointerException ex){
            return null;
        }

    }

    public static Decimal calculatePRRAmount(Compensation_Ticket__c junctionCompensationTicket, CompApp_Constructs.CompensationRuleWrapper compRule, Decimal prr_percentage){

        Decimal prrAmount;

        if(junctionCompensationTicket.Ticket__r.Ticket_Price__c == null || junctionCompensationTicket.Ticket__r.Ticket_Price__c < 0) return null;

        try{
            // Passing Point Override
            if(junctionCompensationTicket.Passing_Point__c != null && junctionCompensationTicket.Passing_Point__r.Passing_Point_Cash__c != null){

                prr_percentage = junctionCompensationTicket.Passing_Point__r.Passing_Point_Cash__c/100;
                return junctionCompensationTicket.Ticket__r.Ticket_Price__c * junctionCompensationTicket.Passing_Point__r.Passing_Point_Cash__c / 100;
            }
            // Train Override
            else if(junctionCompensationTicket.Passing_Point__c == null && junctionCompensationTicket.Ticket__r.Train__r.Destination_Cash__c != null){

                prr_percentage = junctionCompensationTicket.Ticket__r.Train__r.Destination_Cash__c/100;
                return junctionCompensationTicket.Ticket__r.Ticket_Price__c * junctionCompensationTicket.Ticket__r.Train__r.Destination_Cash__c / 100;
            }
            // Standard calculation
            else if (compRule != null){
                
                prr_percentage = (compRule.eligiblePRRCompensation==null?0:compRule.eligiblePRRCompensation)/100;                   
                return junctionCompensationTicket.Compensation__r.PRR_Amount__c = (junctionCompensationTicket.Ticket__r.Ticket_Price__c* prr_percentage).setScale(2, RoundingMode.HALF_UP);
            }
            return null;
        }
        catch(NullPointerException ex){
            return null;
        }

    }
}