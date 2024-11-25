public without sharing class DLT_NegotiatedRateTriggerHandler {
    public static Boolean isDisabled = false;

    public static Set<Id> processedRecordIds = new Set<Id>();
    public static Set<Id> skipPccUpdatedIds = new Set<Id>();

    public static void run() {
        if (!System.Trigger.isExecuting || isDisabled) { return; }

        if (System.Trigger.isBefore) {
            if (System.Trigger.isInsert) {
                generatePercentage(System.Trigger.new);
                setStatusToNew(System.Trigger.new);
                rollupAndValidateNew(System.Trigger.new);
                setDateAndLinked(System.Trigger.new);
                preventExtractMorePossible(System.Trigger.new);
            }

            if (System.Trigger.isUpdate) {
                generatePercentage(System.Trigger.new);
                processEndDateUpdate((List<B2b_NrDetails__c>) System.Trigger.new, (Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap);
                preventNotSalesAdmin((Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap, System.Trigger.new);
                deactivateCorporateTracking((Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap, System.Trigger.new);
                setTrackingCodeDate((Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap, System.Trigger.new);
                preventExtractMorePossible((Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap, System.Trigger.new);
                rollupAndValidateUpdate((Map<Id, B2b_NrDetails__c>) System.Trigger.newMap);
            }
            if(Trigger.isDelete) {
                deleteNrToAccountPcc(Trigger.old);
            }
        }
        if (System.Trigger.isAfter) {
            if (System.Trigger.isInsert) {
                generateDuplicateRates(System.Trigger.new);
                createAccountPCCs(System.Trigger.new);
                duplicateRateForChildRecord(System.Trigger.new);
            }
            if (System.Trigger.isUpdate) {
                enableValidation();
                submitRatesForApproval((Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap, System.Trigger.new);
                deactivateCorporateTrackingChilds((Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap, System.Trigger.new);
                setDiscountContinentChild((Map<Id, B2b_NrDetails__c>) System.Trigger.oldMap, System.Trigger.new);
            }
        } 
    }


    private static void generatePercentage(List<B2b_NrDetails__c> newNegotiatedRateDetailList) {

        Map<string, List<B2b_ReductionGrid__c>> reductionGridByRoadAndClass = getReductionGridByRoadAndClass();

        for(B2b_NrDetails__c negotiatetdRateDetails : newNegotiatedRateDetailList) {
            if(reductionGridByRoadAndClass.get(negotiatetdRateDetails.B2b_Route__c + DLT_ReductionGridConstants.CLASS_PREMIUM) != null 
                && reductionGridByRoadAndClass.get(negotiatetdRateDetails.B2b_Route__c + DLT_ReductionGridConstants.CLASS_COMFORT) != null 
                && reductionGridByRoadAndClass.get(negotiatetdRateDetails.B2b_Route__c + DLT_ReductionGridConstants.CLASS_STANDARD) != null
            ) {
                negotiatetdRateDetails.B2b_PercentagePossibleFirst__c = executePercentageSearch(negotiatetdRateDetails.B2b_Route__c + DLT_ReductionGridConstants.CLASS_PREMIUM, negotiatetdRateDetails.B2b_TicketsFirst__c, reductionGridByRoadAndClass);
                negotiatetdRateDetails.B2b_PercentagePossibleComfort__c = executePercentageSearch(negotiatetdRateDetails.B2b_Route__c + DLT_ReductionGridConstants.CLASS_COMFORT, negotiatetdRateDetails.B2b_TicketsComfort__c, reductionGridByRoadAndClass);
                negotiatetdRateDetails.B2b_PercentagePossibleStandard__c = executePercentageSearch(negotiatetdRateDetails.B2b_Route__c + DLT_ReductionGridConstants.CLASS_STANDARD, negotiatetdRateDetails.B2b_TicketsStandard__c, reductionGridByRoadAndClass);
            }
        } 
    }

    private static void setStatusToNew(List<B2b_NrDetails__c> newNegotiatedRateDetailList){

        for(B2b_NrDetails__c negotiatetdRateDetail : newNegotiatedRateDetailList) {
            if (negotiatetdRateDetail.B2b_Status__c != null) {
                continue;
            }
            negotiatetdRateDetail.B2b_Status__c = DLT_NegotiatedRateConstants.STATUS_NEW;
        }
    }

    private static void rollupAndValidateNew(List<B2b_NrDetails__c> negotiatedRates) {
        List<B2b_NrDetails__c> existingRates = [
            SELECT ContractID__c, Discount__c, B2b_Route__c, B2b_RouteEndDate__c, RecordTypeId,
                B2b_PercentageDiscountSp__c, B2b_PercentageDiscountBp__c, B2b_Percentage_Discount_Premium__c,
                B2b_Percentage_Discount_Comfort__c, B2b_Percentage_Discount_Standard__c, B2b_RouteStartDate__c, Name
            FROM B2b_NrDetails__c
            WHERE ContractID__c IN :getContractIdsFromNegotiatedRates(negotiatedRates)
        ];
        setDiscount(negotiatedRates, existingRates);
        preventOverlap(negotiatedRates, existingRates);
    }

    private static void rollupAndValidateUpdate(Map<Id, B2b_NrDetails__c> negotiatedRates) {
        List<B2b_NrDetails__c> existingRates = [
            SELECT ContractID__c, Discount__c, B2b_Route__c, B2b_RouteEndDate__c, RecordTypeId,
                B2b_PercentageDiscountSp__c, B2b_PercentageDiscountBp__c, B2b_Percentage_Discount_Premium__c,
                B2b_Percentage_Discount_Comfort__c, B2b_Percentage_Discount_Standard__c, B2b_RouteStartDate__c, Name
            FROM B2b_NrDetails__c
            WHERE ContractID__c IN :getContractIdsFromNegotiatedRates(negotiatedRates.values())
                AND Id NOT IN :negotiatedRates.keySet()
        ];
        setDiscount(negotiatedRates.values(), existingRates);
        preventOverlap(negotiatedRates.values(), existingRates);
    }

    private static void setDiscount(List<B2b_NrDetails__c> negotiatedRates, List<B2b_NrDetails__c> selectedOldRates) {
        Map<Id, Set<B2b_NrDetails__c>> contractIdRateIds = new Map<Id, Set<B2b_NrDetails__c>>();
        for (B2b_NrDetails__c rate : selectedOldRates) {
            if (contractIdRateIds.get(rate.ContractID__c) == null) {
                contractIdRateIds.put(rate.ContractID__c, new Set<B2b_NrDetails__c>());
            }
            contractIdRateIds.get(rate.ContractID__c).add(rate);
        }

        for (B2b_NrDetails__c rate : negotiatedRates) {
            Boolean isHigher = false;
            Boolean isLower = false;
            Set<B2b_NrDetails__c> selectedRates = filterByRouthAndDate(
                contractIdRateIds.get(rate.ContractID__c),
                rate.B2b_Route__c,
                getDayBeforeDate(rate.B2b_RouteStartDate__c)
            );
            if (isNoDiscount(rate)) {
                continue;
            }
            if (selectedRates.isEmpty()) {
                rate.Discount__c = DLT_NegotiatedRateConstants.DISCOUNT_NEW;
                continue;
            }
            for (B2b_NrDetails__c selectedRate : selectedRates) {
                if (selectedRate.RecordTypeId == DLT_NegotiatedRateConstants.CORPORATE_LONDON) {
                    if (convertToInteger(rate.B2b_PercentageDiscountSp__c) >
                        convertToInteger(selectedRate.B2b_PercentageDiscountSp__c)) {
                        isHigher = true;
                    }
                    if (convertToInteger(rate.B2b_PercentageDiscountSp__c) <
                        convertToInteger(selectedRate.B2b_PercentageDiscountSp__c)) {
                        isLower = true;
                    }
                    if (convertToInteger(rate.B2b_PercentageDiscountBp__c) >
                        convertToInteger(selectedRate.B2b_PercentageDiscountBp__c)) {
                        isHigher = true;
                    }
                    if (convertToInteger(rate.B2b_PercentageDiscountBp__c) <
                        convertToInteger(selectedRate.B2b_PercentageDiscountBp__c)) {
                        isLower = true;
                    }
                }
                if (selectedRate.RecordTypeId == DLT_NegotiatedRateConstants.CORPORATE_CONTINENT) {
                    if (isHigherDiscount(rate.B2b_Percentage_Discount_Premium__c, selectedRate.B2b_Percentage_Discount_Premium__c)) {
                        isHigher = true;
                    }
                    if (isLowerDiscount(rate.B2b_Percentage_Discount_Premium__c, selectedRate.B2b_Percentage_Discount_Premium__c)) {
                        isLower = true;
                    }
                    if (isHigherDiscount(rate.B2b_Percentage_Discount_Comfort__c, selectedRate.B2b_Percentage_Discount_Comfort__c)) {
                        isHigher = true;
                    }
                    if (isLowerDiscount(rate.B2b_Percentage_Discount_Comfort__c, selectedRate.B2b_Percentage_Discount_Comfort__c)) {
                        isLower = true;
                    }
                    if (isHigherDiscount(rate.B2b_Percentage_Discount_Standard__c, selectedRate.B2b_Percentage_Discount_Standard__c)) {
                        isHigher = true;
                    }
                    if (isLowerDiscount(rate.B2b_Percentage_Discount_Standard__c, selectedRate.B2b_Percentage_Discount_Standard__c)) {
                        isLower = true;
                    }
                }
            }
            if (isHigher) {
                rate.Discount__c = DLT_NegotiatedRateConstants.DISCOUNT_HIGHER;
            }
            if (!isHigher && isLower) {
                rate.Discount__c = DLT_NegotiatedRateConstants.DISCOUNT_LOWER;
            }
            if (!isHigher && !isLower) {
                rate.Discount__c = DLT_NegotiatedRateConstants.DISCOUNT_SAME;
            }
        }
    }

    private static Boolean isNoDiscount(B2b_NrDetails__c rate) {
        return rate.B2b_PercentageDiscountSp__c == null
            && rate.B2b_PercentageDiscountBp__c == null
            && String.isBlank(rate.B2b_Percentage_Discount_Premium__c)
            && String.isBlank(rate.B2b_Percentage_Discount_Comfort__c)
            && String.isBlank(rate.B2b_Percentage_Discount_Standard__c);
    }

    private static Integer convertToInteger(String discountValue) {
        return discountValue == null ? 0 : Integer.ValueOf(discountValue);
    }

    private static Boolean isHigherDiscount(String newRateDiscount, String oldRateDiscount) {
        return isNotDeutscher(newRateDiscount, oldRateDiscount) &&
            parsePercentage(newRateDiscount) > parsePercentage(oldRateDiscount);
    }

    private static Boolean isLowerDiscount(String newRateDiscount, String oldRateDiscount) {
        return isNotDeutscher(newRateDiscount, oldRateDiscount) &&
            parsePercentage(newRateDiscount) < parsePercentage(oldRateDiscount);
    }

    private static Integer parsePercentage(String percentage) {
        return String.isBlank(percentage) ? 0 : Integer.valueof(percentage.substring(0, 2).trim());
    }

    private static Boolean isNotDeutscher(String newDiscount, String oldDiscount) {
        return (String.isBlank(newDiscount) || !newDiscount.contains(DLT_NegotiatedRateConstants.DEUTSCHER_BUND)) &&
            (String.isBlank(oldDiscount) || !oldDiscount.contains(DLT_NegotiatedRateConstants.DEUTSCHER_BUND));
    }

    private static Date getDayBeforeDate(Date dateInstance) {
        if (dateInstance == null) {
            return null;
        }
        return dateInstance.addDays(-1);
    }

    private static Set<B2b_NrDetails__c> filterByRouthAndDate(Set<B2b_NrDetails__c> rates, String routh, Date dayBeforeStartDate) {
        Set<B2b_NrDetails__c> filteredRates = new Set<B2b_NrDetails__c>();
        if (rates == null || rates.isEmpty() || routh == null || dayBeforeStartDate == null) {
            return filteredRates;
        }
        for (B2b_NrDetails__c rate : rates) {
            if (rate.B2b_Route__c == routh && rate.B2b_RouteEndDate__c >= dayBeforeStartDate) {
                filteredRates.add(rate);
            }
        }
        return filteredRates;
    }

    private static void setDateAndLinked(List<B2b_NrDetails__c> newRates) {
        Map<Id, B2b_NrDetails__c> contractIdRate = new Map<Id, B2b_NrDetails__c>();
        for (B2b_NrDetails__c rate : newRates) {
            contractIdRate.put(rate.ContractID__c, rate);
        }

        B2b_NrDetails__c newRate;
        for (Business_Contract__c contract: [
            SELECT AccountId__r.FCE_Continent_Active__c,
                AccountId__r.FCE_London_Active__c,
                AccountId__r.GND_BE_Continent_Active__c,
                AccountId__r.GND_BE_London_Active__c,
                AccountId__r.GND_NL_Continent_Active__c,
                AccountId__r.GND_NL_London_Active__c,
                AccountId__r.Corporate_Code_Active__c,
                AccountId__r.GDS_Code_Active__c,
                StartDate__c
            FROM Business_Contract__c
            WHERE Id IN :contractIdRate.keySet()
        ]) {
            newRate = contractIdRate.get(contract.Id);

            if (newRate.B2b_RouteStartDate__c == null) {
                newRate.B2b_RouteStartDate__c = contract.StartDate__c;
            }
            if (contract.AccountId__r.FCE_Continent_Active__c) {
                newRate.FCE_Continent_Linked__c = true;
                newRate.FCE_Continent_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
            if (contract.AccountId__r.FCE_London_Active__c) {
                newRate.FCE_London_Linked__c = true;
                newRate.FCE_London_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
            if (contract.AccountId__r.GND_BE_Continent_Active__c) {
                newRate.GND_BE_Continent_Linked__c = true;
                newRate.GND_BE_Continent_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
            if (contract.AccountId__r.GND_BE_London_Active__c) {
                newRate.GND_BE_London_Linked__c = true;
                newRate.GND_BE_London_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
            if (contract.AccountId__r.GND_NL_Continent_Active__c) {
                newRate.GND_NL_Continent_Linked__c = true;
                newRate.GND_NL_Continent_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
            if (contract.AccountId__r.GND_NL_London_Active__c) {
                newRate.GND_NL_London_Linked__c = true;
                newRate.GND_NL_London_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
            if (contract.AccountId__r.Corporate_Code_Active__c) {
                newRate.Corporate_Code_Linked__c = true;
                newRate.Corporate_Code_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
            if (contract.AccountId__r.GDS_Code_Active__c) {
                newRate.GDS_Code_Linked__c = true;
                newRate.GDS_Code_Start_Date__c = newRate.B2b_RouteStartDate__c;
            }
        }
    }

    private static void processEndDateUpdate(List<B2b_NrDetails__c> updatedNegotiatedRateList, Map<Id, B2b_NrDetails__c> oldNegotiatedRateMap) {
        for (B2b_NrDetails__c negotiatedRate : updatedNegotiatedRateList) {
            Boolean shouldBeUpdated = negotiatedRate.B2b_RouteEndDate__c != null && oldNegotiatedRateMap.get(negotiatedRate.Id).B2b_RouteEndDate__c == null && oldNegotiatedRateMap.get(negotiatedRate.Id).B2b_Status__c != null
                    && (oldNegotiatedRateMap.get(negotiatedRate.Id).B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_EXTRACTED || oldNegotiatedRateMap.get(negotiatedRate.Id).B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_INTEGRATED);
            if (shouldBeUpdated) {
                negotiatedRate.B2b_Status__c = DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED;
                negotiatedRate.S3_Extract__c = false;
                negotiatedRate.GDS_Air_Extract__c = false;
                negotiatedRate.B2b_Bene_Extract__c = false;
                negotiatedRate.Skip_Validation__c = true;
            }
        }
    }

    private static void preventNotSalesAdmin(Map<Id, B2b_NrDetails__c> oldIdRates, List<B2b_NrDetails__c> newRates) {
        if (FeatureManagement.checkPermission('Request_Extract')) {
            return;
        }

        for (B2b_NrDetails__c mewRate : newRates) {
            if (oldIdRates.get(mewRate.Id)?.Extract_Requested__c != mewRate.Extract_Requested__c && mewRate.Extract_Requested__c) {
                mewRate.addError('Only a Sales Admin can Request Extract');
            }
        }
    }

    private static void preventExtractMorePossible(List<B2b_NrDetails__c> newRates) {
        preventExtractMorePossible(null, newRates);
    }

    private static void preventExtractMorePossible(Map<Id, B2b_NrDetails__c> oldIdRates, List<B2b_NrDetails__c> newRates) {
        if (FeatureManagement.checkPermission('Sales_Admin')) {
            return;
        }

        for (B2b_NrDetails__c newRate : newRates) {
            B2b_NrDetails__c oldRate = oldIdRates?.get(newRate?.Id);
            if (DLT_NegotiatedRateConstants.isToBeExtracted(newRate)
                    && isChangedDiscountOrStatus(oldRate, newRate)
                    && (hasDiscountPremier(newRate) || isDiscountMoreThenPossible(newRate))
                ) {
                newRate.B2b_Status__c = DLT_NegotiatedRateConstants.STATUS_TO_BE_APPROVED;
            }
        }
    }

    private static Boolean isChangedDiscountOrStatus(B2b_NrDetails__c oldRate, B2b_NrDetails__c newRate) {
        return oldRate?.B2b_PercentagePossibleFirst__c != newRate?.B2b_PercentagePossibleFirst__c
            || oldRate?.B2b_Percentage_Discount_Premium__c != newRate?.B2b_Percentage_Discount_Premium__c
            || oldRate?.B2b_PercentagePossibleComfort__c != newRate?.B2b_PercentagePossibleComfort__c
            || oldRate?.B2b_Percentage_Discount_Comfort__c != newRate?.B2b_Percentage_Discount_Comfort__c
            || oldRate?.B2b_PercentagePossibleStandard__c != newRate?.B2b_PercentagePossibleStandard__c
            || oldRate?.B2b_Percentage_Discount_Standard__c != newRate?.B2b_Percentage_Discount_Standard__c
            || oldRate?.B2b_PercentageDiscountSp__c != newRate?.B2b_PercentageDiscountSp__c
            || oldRate?.B2b_PercentageDiscountBp__c != newRate?.B2b_PercentageDiscountBp__c
            || oldRate?.B2b_Status__c != newRate?.B2b_Status__c;
    }

    private static void setDiscountContinentChild(Map<Id, B2b_NrDetails__c> oldIdRates, List<B2b_NrDetails__c> newRates) {
        Map<Id, B2b_NrDetails__c> parentIdRateMap = new Map<Id, B2b_NrDetails__c>();
        for (B2b_NrDetails__c newRate : newRates) {
            B2b_NrDetails__c oldRate = oldIdRates?.get(newRate?.Id);
            if (oldRate?.B2b_Percentage_Discount_Premium__c != newRate?.B2b_Percentage_Discount_Premium__c
                || oldRate?.B2b_Percentage_Discount_Comfort__c != newRate?.B2b_Percentage_Discount_Comfort__c
                || oldRate?.B2b_Percentage_Discount_Standard__c != newRate?.B2b_Percentage_Discount_Standard__c
                || oldRate?.B2b_PercentageDiscountSp__c != newRate?.B2b_PercentageDiscountSp__c
                || oldRate?.B2b_PercentageDiscountBp__c != newRate?.B2b_PercentageDiscountBp__c
            ) {
                parentIdRateMap.put(newRate.Id, newRate);
            }
        }

        if (parentIdRateMap.isEmpty()) {
            return;
        }

        List<B2b_NrDetails__c> childRates = selectChildByParentId(parentIdRateMap.keySet());

        if (childRates.isEmpty()) {
            return;
        }

        for (B2b_NrDetails__c childRate : childRates) {
            B2b_NrDetails__c parentRate = parentIdRateMap.get(childRate.B2b_ParentNrDetail__c);
            childRate.B2b_Percentage_Discount_Premium__c = parentRate.B2b_Percentage_Discount_Premium__c;
            childRate.B2b_Percentage_Discount_Comfort__c = parentRate.B2b_Percentage_Discount_Comfort__c;
            childRate.B2b_Percentage_Discount_Standard__c = parentRate.B2b_Percentage_Discount_Standard__c;
            childRate.B2b_PercentageDiscountSp__c = parentRate.B2b_PercentageDiscountSp__c;
            childRate.B2b_PercentageDiscountBp__c = parentRate.B2b_PercentageDiscountBp__c;
        }
        update childRates;
    }

    private static Boolean isDiscountMoreThenPossible(B2b_NrDetails__c rate) {
        return rate?.B2b_PercentagePossibleFirst__c < parsePercentage(rate?.B2b_Percentage_Discount_Premium__c) ||
            rate?.B2b_PercentagePossibleComfort__c < parsePercentage(rate?.B2b_Percentage_Discount_Comfort__c) ||
            rate?.B2b_PercentagePossibleStandard__c < parsePercentage(rate?.B2b_Percentage_Discount_Standard__c);
    }

    private static Boolean hasDiscountPremier(B2b_NrDetails__c newRate) {
        return newRate.B2b_PercentageDiscountSp__c != null || newRate.B2b_PercentageDiscountBp__c != null;
    }

    private static void deactivateCorporateTracking(Map<Id, B2b_NrDetails__c> oldIdRates, List<B2b_NrDetails__c> newRates) {
        for (B2b_NrDetails__c newRate : newRates) {
            if (isChangedToBeExtractedAndEnded(oldIdRates?.get(newRate.Id), newRate)) {
                deactivateCorporateTracking(newRate);
            }
        }
    }

    private static void deactivateCorporateTrackingChilds(Map<Id, B2b_NrDetails__c> oldIdRates, List<B2b_NrDetails__c> newRates) {
        Map<Id, B2b_NrDetails__c> parentIdRateMap = new Map<Id, B2b_NrDetails__c>();
        for (B2b_NrDetails__c newRate : newRates) {
            B2b_NrDetails__c parentRate = oldIdRates?.get(newRate.Id);
            if ((isReadyToEndChilds(parentRate, newRate) || isChangedToBeExtracted(parentRate, newRate))
                && newRate.B2b_ParentNrDetail__c == null
                && !skipPccUpdatedIds.contains(newRate.Id)
            ) {
                parentIdRateMap.put(newRate.Id, newRate);
            }
        }

        if (parentIdRateMap.isEmpty()) {
            return;
        }

        List<B2b_NrDetails__c> childRates = selectChildByParentId(parentIdRateMap.keySet());

        if (childRates.isEmpty()) {
            return;
        }

        for (B2b_NrDetails__c childRate : childRates) {
            B2b_NrDetails__c parentRate = parentIdRateMap.get(childRate.B2b_ParentNrDetail__c);
            if (childRate.B2b_RouteEndDate__c == null) {
                childRate.B2b_Status__c = DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED;
                childRate.B2b_RouteEndDate__c = parentRate.B2b_RouteEndDate__c;
            }
            deactivateCorporateTracking(childRate);
        }
        update childRates;
    }

    private static void deleteNrToAccountPcc(List<B2b_NrDetails__c> negotiatedRates) {

        List<NR_to_Account_PCC__c> junctionToDelete = [
                SELECT Id, Negotiated_Rate__c
                FROM NR_to_Account_PCC__c
                WHERE Negotiated_Rate__c IN :negotiatedRates
        ];

        if (!junctionToDelete.isEmpty()) {
            delete junctionToDelete;
        }

    }

    private static void generateDuplicateRates(List<B2b_NrDetails__c> newNegotiatedRateDetailList) {
        Map<Id, Id> businessContractIds = new Map<Id, Id>(); 
        for (B2b_NrDetails__c nr : newNegotiatedRateDetailList)  {
            businessContractIds.put(nr.Id, nr.ContractID__c);
        }
        Map<Id, Set<Id>> parentChildBCmap = new Map<Id, Set<Id>>();
        List<Business_Contract__c> businessContracts = [
            SELECT  Id, Parent_Account__c, Parent_Contract__c, AccountId__r.Red_Account_Type__c, Parent_Account__r.Red_Account_Type__c, 
                    AccountId__r.Blue_Account_Type__c, Parent_Account__r.Blue_Account_Type__c
            FROM Business_Contract__c 
            WHERE (Id IN: businessContractIds.values() 
                OR Parent_Contract__c IN: businessContractIds.values()) 
                AND Parent_Account__r.Managed__c = :DLT_BusinessContractConstants.MANAGED_MANAGED
                AND AccountId__r.RecordTypeId =: DLT_BusinessAccountConstants.RECORD_TYPE_ID_AGENCY];
        for (Business_Contract__c bc : businessContracts) {

            Boolean isRedAccountConditionMet = bc.Parent_Account__c != null && 
                bc.AccountId__r.Red_Account_Type__c == bc.Parent_Account__r.Red_Account_Type__c && 
                DLT_NegotiatedRateConstants.RED_ACCOUNT_TYPE_VALUES.contains(bc.Parent_Account__r.Red_Account_Type__c);

            Boolean isBlueAccountConditionMet = bc.Parent_Account__c != null && 
                bc.AccountId__r.Blue_Account_Type__c == bc.Parent_Account__r.Blue_Account_Type__c && 
                bc.AccountId__r.Blue_Account_Type__c != null;

            if (!isRedAccountConditionMet && !isBlueAccountConditionMet) {
                continue;
            }
            if (bc.Parent_Contract__c != null) {
                Set<Id> childContracts = parentChildBCmap.get(bc.Parent_Contract__c);
                if (childContracts == null) {
                    childContracts = new Set<Id>();
                }
                childContracts.add(bc.Id);
                parentChildBCmap.put(bc.Parent_Contract__c, childContracts);
            } else {
                parentChildBCmap.put(bc.Id, new Set<Id>());
            }
        }
        List<B2b_NrDetails__c> newNegotiationRates = new List<B2b_NrDetails__c>();
        for (B2b_NrDetails__c negotiationRate: newNegotiatedRateDetailList) {
            Set<Id> childContracts = parentChildBCmap.get(negotiationRate.ContractID__c);
            if (childContracts == null) {
                continue;
            }
            for (Id contractId: childContracts) {
                if (childContracts.contains(businessContractIds.get(negotiationRate.Id))) {
                    continue;
                } 
                B2b_NrDetails__c newNegotiationRate = negotiationRate.clone();
                newNegotiationRate.ContractID__c = contractId;
                newNegotiationRates.add(newNegotiationRate);
            }
        }
        Database.insert(newNegotiationRates);
    }

    private static void createAccountPCCs(List<B2b_NrDetails__c> negotiatedRates) {
        Set<Id> accountIds = new Set<Id>();
        for (B2b_NrDetails__c rate : negotiatedRates) {
            accountIds.add(rate.ContractID__r?.AccountId__c);
        }

        Map<Id, Id> accountIdToPccIdMap = new Map<Id, Id>();
        for (B2b_AccountPCC__c accountPCC : [
                SELECT Id, B2b_Account__c
                FROM B2b_AccountPCC__c
                WHERE B2b_Account__r.Id IN :accountIds
        ]) {
            accountIdToPccIdMap.put(accountPCC.B2b_Account__c, accountPCC.Id);
        }

        List<NR_to_Account_PCC__c> neAccountPCCs = new List<NR_to_Account_PCC__c>();
        for (B2b_NrDetails__c rate : negotiatedRates) {
            if (rate.ContractID__r?.AccountId__c == null) continue;
            neAccountPCCs.add(
                new NR_to_Account_PCC__c(
                    Negotiated_Rate__c = rate.Id,
                    Account_PCC__c = accountIdToPccIdMap.get(rate.ContractID__r?.AccountId__c)
                )
            );
        }
        insert neAccountPCCs;
    }

    private static void duplicateRateForChildRecord(List<B2b_NrDetails__c> newRates) {
        Map<Id, B2b_NrDetails__c> contractIdRates = new Map<Id, B2b_NrDetails__c>();
        for (B2b_NrDetails__c rate : newRates) {
            contractIdRates.put(rate.ContractID__c, rate);
        }

        List<Business_Contract__c> childContracts = [
            SELECT Parent_Contract__c, RecordTypeId
            FROM Business_Contract__c
            WHERE Parent_Contract__c IN :contractIdRates.keySet()
                AND (RecordTypeId =: DLT_BusinessContractConstants.CORPORATE_CONTINENT
                    OR RecordTypeId =: DLT_BusinessContractConstants.CORPORATE_LONDON)
        ];

        if (childContracts.isEmpty()) {
            return;
        }

        List<B2b_NrDetails__c> duplicatedNegotiatedRates = new List<B2b_NrDetails__c>();
        for (Business_Contract__c childContract : childContracts) {
            B2b_NrDetails__c originalRate = contractIdRates.get(childContract.Parent_Contract__c);
            B2b_NrDetails__c duplicatedRate = originalRate.clone(false, false, false, false);
            duplicatedRate.ContractID__c = childContract.Id;
            duplicatedRate.B2b_ParentNrDetail__c = originalRate.Id;
            duplicatedRate.Legacy_Id__c = null;
            duplicatedNegotiatedRates.add(duplicatedRate);
        }

        insert duplicatedNegotiatedRates;
    }

    private static void enableValidation() {
        List<B2b_NrDetails__c> nrDetailsToUpdate = new List<B2b_NrDetails__c> ();
        for (B2b_NrDetails__c negotiatedRate : [SELECT Skip_Validation__c FROM B2b_NrDetails__c WHERE Id IN :Trigger.new]) {
            if (!processedRecordIds.contains(negotiatedRate.Id) && negotiatedRate.Skip_Validation__c) {
                negotiatedRate.Skip_Validation__c = false;

                processedRecordIds.add(negotiatedRate.Id);
                nrDetailsToUpdate.add(negotiatedRate);
            }
        }

        if (!nrDetailsToUpdate.isEmpty()) {
            update nrDetailsToUpdate;
        }
    }

    private static void preventOverlap(List<B2b_NrDetails__c> newRates, List<B2b_NrDetails__c> existingRates) {
        for (B2b_NrDetails__c newRate : newRates) {
            for (B2b_NrDetails__c existingRate : existingRates) {
                if (existingRate.ContractID__c == newRate.ContractID__c
                    && existingRate.B2b_Route__c == newRate.B2b_Route__c
                    && (existingRate.B2b_RouteEndDate__c == null
                    || existingRate.B2b_RouteEndDate__c >= newRate.B2b_RouteStartDate__c)
                ){
                    newRate.addError(
                        'New Negotiated Rate cannot overlap the existing one. Check the End Date of ' +
                        existingRate.Name +
                        ' with the fallowing Id ' +
                        existingRate.Id
                    );
                }
            }
        }
    }

    private static void submitRatesForApproval(Map<Id, B2b_NrDetails__c> oldRateMap, List<B2b_NrDetails__c> newRates) {
        Set<Id> toBeApprovedIds = new Set<Id>();

        for (B2b_NrDetails__c updatedRate : newRates) {
            if (oldRateMap?.get(updatedRate.Id)?.B2b_Status__c != updatedRate?.B2b_Status__c
                && updatedRate?.B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_TO_BE_APPROVED) {
                toBeApprovedIds.add(updatedRate.Id);
            }
        }

        if (toBeApprovedIds.isEmpty()) {
            return;
        }

        for (ProcessInstanceWorkitem workItem : [
            SELECT ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId IN :toBeApprovedIds]
        ) {
            toBeApprovedIds.remove(workItem.ProcessInstance.TargetObjectId);
        }
        
        
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (Id toBeApprovedId : toBeApprovedIds) {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments(DLT_NegotiatedRateConstants.APPROVAL_COMMENT_SUBMIT);
            approvalRequest.setProcessDefinitionNameOrId(DLT_NegotiatedRateConstants.APPROVAL_API_RED_NEGOTIATED_RATE);
            approvalRequest.setObjectId(toBeApprovedId);
            requests.add(approvalRequest);
        }
        Approval.process(requests);
    }

    private static void setTrackingCodeDate(Map<Id, B2b_NrDetails__c> oldNegotiatedRatesMap, List<B2b_NrDetails__c> newNegotiatedRates) {
        Date startDate = System.today().addMonths(1).toStartofMonth();
        Date endDate = System.today().addMonths(1).toStartofMonth().addDays(-1);
        for (B2b_NrDetails__c newRate : newNegotiatedRates) {
            if(!isChangedTrackingActivation(oldNegotiatedRatesMap?.get(newRate.Id), newRate)) {
                continue;
            }

            endDate = newRate.B2b_RouteEndDate__c == null ? endDate : newRate.B2b_RouteEndDate__c;

            if (newRate.FCE_London_Linked__c) {
                newRate.FCE_London_Start_Date__c = startDate;
            } else if (newRate.FCE_London_Start_Date__c != null) {
                newRate.FCE_London_End_Date__c = endDate;
            }

            if (newRate.FCE_Continent_Linked__c) {
                newRate.FCE_Continent_Start_Date__c = startDate;
            } else if (newRate.FCE_Continent_Start_Date__c != null) {
                newRate.FCE_Continent_End_Date__c = endDate;
            }

            if (newRate.GND_BE_London_Linked__c) {
                newRate.GND_BE_London_Start_Date__c = startDate;
            } else if (newRate.GND_BE_London_Start_Date__c != null) {
                newRate.GND_BE_London_End_Date__c = endDate;
            }

            if (newRate.GND_BE_Continent_Linked__c) {
                newRate.GND_BE_Continent_Start_Date__c = startDate;
            } else if (newRate.GND_BE_Continent_Start_Date__c != null) {
                newRate.GND_BE_Continent_End_Date__c = endDate;
            }

            if (newRate.GND_NL_London_Linked__c) {
                newRate.GND_NL_London_Start_Date__c = startDate;
            } else if (newRate.GND_NL_London_Start_Date__c != null) {
                newRate.GND_NL_London_End_Date__c = endDate;
            }

            if (newRate.GND_NL_Continent_Linked__c) {
                newRate.GND_NL_Continent_Start_Date__c = startDate;
            } else if (newRate.GND_NL_Continent_Start_Date__c != null) {
                newRate.GND_NL_Continent_End_Date__c = endDate;
            }

            if (newRate.Corporate_Code_Linked__c) {
                newRate.Corporate_Code_Start_Date__c = startDate;
            } else if (newRate.Corporate_Code_Start_Date__c != null) {
                newRate.Corporate_Code_End_Date__c = endDate;
            }

            if (newRate.GDS_Code_Linked__c) {
                newRate.GDS_Code_Start_Date__c = startDate;
            } else if (newRate.GDS_Code_Start_Date__c != null) {
                newRate.GDS_Code_End_Date__c = endDate;
            }
        }
    }

    // ========================= HELPERS =========================

    private static Map<String, List<B2b_ReductionGrid__c>> getReductionGridByRoadAndClass() {

        List<B2b_ReductionGrid__c> reductionGridList = [
            SELECT Id, B2b_Class__c, B2b_MaxNumberOfTickets__c, B2b_MaxPercentage__c, 
            B2b_MinNumberOfTickets__c, B2b_Route__c, B2b_Segment__c
            FROM B2b_ReductionGrid__c
        ];

        Map<String, List<B2b_ReductionGrid__c>> reductionGridMap = new Map<String, List<B2b_ReductionGrid__c>>();

        for(B2b_ReductionGrid__c reductionGrid : reductionGridList) {
            List<B2b_ReductionGrid__c> reductionGridByRoadAndClassList = reductionGridMap.get(reductionGrid.B2b_Route__c + reductionGrid.B2b_Class__c);

            if(reductionGridByRoadAndClassList == null) {
                List<B2b_ReductionGrid__c> newReductionGridByRoadAndClassList = new List<B2b_ReductionGrid__c>();
                newReductionGridByRoadAndClassList.add(reductionGrid);
                reductionGridMap.put(reductionGrid.B2b_Route__c + reductionGrid.B2b_Class__c, newReductionGridByRoadAndClassList);
            } else {
                reductionGridByRoadAndClassList.add(reductionGrid);
            }
        }
        return reductionGridMap;
    }

    private static Decimal executePercentageSearch(String roadAndClass, Decimal ticketNumber, Map<String, List<B2b_ReductionGrid__c>> reductionGridByRoadAndClass) {

        Decimal reductionPercentage = 0.0;

        List<B2b_ReductionGrid__c> reductionGridList = reductionGridByRoadAndClass.get(roadAndClass);

        for(B2b_ReductionGrid__c reductionGrid : reductionGridList) {

            if(reductionGrid.B2b_MaxNumberOfTickets__c != null) {
                if(reductionGrid.B2b_MaxNumberOfTickets__c >= ticketNumber && reductionGrid.B2b_MinNumberOfTickets__c <= ticketNumber) {
                    reductionPercentage = reductionGrid.B2b_MaxPercentage__c;
                }
            } else if(reductionGrid.B2b_MinNumberOfTickets__c <= ticketNumber) {
                reductionPercentage = reductionGrid.B2b_MaxPercentage__c;
            }
        }
        return reductionPercentage;
    }

    private static Boolean isChangedTrackingActivation(B2b_NrDetails__c oldRate, B2b_NrDetails__c newRate) {
        return oldRate?.FCE_London_Linked__c != newRate?.FCE_London_Linked__c
            || oldRate?.FCE_Continent_Linked__c != newRate?.FCE_Continent_Linked__c
            || oldRate?.GND_BE_London_Linked__c != newRate?.GND_BE_London_Linked__c
            || oldRate?.GND_BE_Continent_Linked__c != newRate?.GND_BE_Continent_Linked__c
            || oldRate?.GND_NL_London_Linked__c != newRate?.GND_NL_London_Linked__c
            || oldRate?.GND_NL_Continent_Linked__c != newRate?.GND_NL_Continent_Linked__c
            || oldRate?.Corporate_Code_Linked__c != newRate?.Corporate_Code_Linked__c
            || oldRate?.GDS_Code_Linked__c != newRate?.GDS_Code_Linked__c;
    }

    private static Set<Id> getContractIdsFromNegotiatedRates(List<B2b_NrDetails__c> negotiatedRates) {
        Set<Id> contactIdNegotiatedRates = new Set<Id>();
        for (B2b_NrDetails__c rate : negotiatedRates) {
            contactIdNegotiatedRates.add(rate.ContractID__c);
        }
        return contactIdNegotiatedRates;
    }

    private static void deactivateCorporateTracking(B2b_NrDetails__c newRate) {
        newRate.FCE_London_Linked__c = false;
        newRate.FCE_Continent_Linked__c = false;
        newRate.GND_BE_London_Linked__c = false;
        newRate.GND_BE_Continent_Linked__c = false;
        newRate.GND_NL_London_Linked__c = false;
        newRate.GND_NL_Continent_Linked__c = false;
        newRate.Corporate_Code_Linked__c = false;
        newRate.GDS_Code_Linked__c = false;
    }

    private static Boolean isChangedToBeExtractedAndEnded(B2b_NrDetails__c oldRate, B2b_NrDetails__c newRate) {
        return (oldRate?.B2b_Status__c != newRate.B2b_Status__c || oldRate?.B2b_RouteEndDate__c != newRate.B2b_RouteEndDate__c) 
            && newRate.B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED
            && newRate.B2b_RouteEndDate__c != null;
    }

    private static Boolean isReadyToEndChilds(B2b_NrDetails__c oldRate, B2b_NrDetails__c newRate) {
        return (oldRate?.B2b_RouteEndDate__c != newRate.B2b_RouteEndDate__c || oldRate?.B2b_Status__c != newRate.B2b_Status__c)
            && newRate.B2b_RouteEndDate__c != null
            && (newRate.B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_INTEGRATED 
                || newRate.B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED);
    }

    private static Boolean isChangedToBeExtracted(B2b_NrDetails__c oldRate, B2b_NrDetails__c newRate) {
        return oldRate?.B2b_Status__c != newRate.B2b_Status__c
            && newRate.B2b_Status__c == DLT_NegotiatedRateConstants.STATUS_TO_BE_EXTRACTED;
    }

    private static List<B2b_NrDetails__c> selectChildByParentId(Set<Id> parentIds) {
        return [
            SELECT Id, B2b_ParentNrDetail__c, B2b_RouteEndDate__c
            FROM B2b_NrDetails__c 
            WHERE B2b_ParentNrDetail__c IN :parentIds
        ];
    }
}