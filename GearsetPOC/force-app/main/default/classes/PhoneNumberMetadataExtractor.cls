public class PhoneNumberMetadataExtractor {
    public static List<PhoneMetadata> processPhoneNumberRawMetadata(){
        List<PhoneMetadata> phoneMetadataList = new List<PhoneMetadata>();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PhoneNumberMetadataRaw'];
        String body = sr.Body.toString();
        Dom.Document doc = new Dom.Document();
        doc.load(body);
        Dom.XMLNode phoneNumberMetadata = doc.getRootElement();
        List<Dom.XMLNode> territoriesNode = phoneNumberMetadata.getChildElements();
        //system.debug('------');
        List<Dom.XMLNode> territories = territoriesNode[0].getChildElements();
        //system.debug(territories.size());

        for (Dom.XMLNode territoryNode : territories) {
            PhoneMetadata phoneMetadata = new PhoneMetadata();
            //Get territory attributes
            Integer territoryAttributeCount = territoryNode.getAttributeCount();
            for (Integer i = 0; i < territoryAttributeCount; i++) {
                String territoryAttributeKey = territoryNode.getAttributeKeyAt(i);
                String territoryAttributeValue = territoryNode.getAttributeValue(territoryAttributeKey,'');
                //system.debug(territoryAttributeKey + ' = ' + territoryAttributeValue );
                if (territoryAttributeKey == 'id') {
                    phoneMetadata.id = territoryAttributeValue;
                }
                if (territoryAttributeKey == 'countryCode') {
                    phoneMetadata.countryCode = Integer.valueOf(territoryAttributeValue);
                }
                if (territoryAttributeKey == 'internationalPrefix') {
                    phoneMetadata.internationalPrefix = cleanRegEx(territoryAttributeValue);
                }
                if (territoryAttributeKey == 'preferredInternationalPrefix') {
                    phoneMetadata.preferredInternationalPrefix = territoryAttributeValue;
                }
                if (territoryAttributeKey == 'nationalPrefix') {
                    phoneMetadata.nationalPrefix = territoryAttributeValue;
                }
                if (territoryAttributeKey == 'preferredExtnPrefix') {
                    phoneMetadata.preferredExtnPrefix = territoryAttributeValue;
                }
                if (territoryAttributeKey == 'nationalPrefixForParsing') {
                    phoneMetadata.nationalPrefixForParsing = cleanRegEx(territoryAttributeValue);
                }
                if (territoryAttributeKey == 'nationalPrefixTransformRule') {
                    phoneMetadata.nationalPrefixTransformRule = cleanRegEx(territoryAttributeValue);
                }
                if (territoryAttributeKey == 'sameMobileAndFixedLinePattern') {
                    phoneMetadata.sameMobileAndFixedLinePattern = Boolean.valueOf(territoryAttributeValue);
                }
                if (territoryAttributeKey == 'mainCountryForCode') {
                    phoneMetadata.mainCountryForCode = Boolean.valueOf(territoryAttributeValue);
                }
                if (territoryAttributeKey == 'leadingDigits') {
                    phoneMetadata.leadingDigits = cleanRegEx(territoryAttributeValue);
                }
                if (territoryAttributeKey == 'mobileNumberPortableRegion') {
                    phoneMetadata.mobileNumberPortableRegion = Boolean.valueOf(territoryAttributeValue);
                }
            }
            //Cycle through formats and descriptions
            List<Dom.XMLNode> territoryDataTypes = territoryNode.getChildElements();
            for(Dom.XMLNode territoryDataType : territoryDataTypes) {
                //Cycle through formats
                if (territoryDataType.getName() == 'availableFormats') {
                    List<Dom.XMLNode> availableFormats = territoryDataType.getChildElements();
                    List<PhoneMetadata.NumberFormat> numberFormats = new List<PhoneMetadata.NumberFormat>();
                    for(Dom.XMLNode numberFormatNode : availableFormats) {
                        PhoneMetadata.NumberFormat numberFormat = new PhoneMetadata.NumberFormat();
                        //Get format attributes
                        Integer formatAttributeCount = numberFormatNode.getAttributeCount();
                        for (Integer j = 0; j < formatAttributeCount; j++) {
                            String formatAttributeKey = numberFormatNode.getAttributeKeyAt(j);
                            String formatAttributeValue = numberFormatNode.getAttributeValue(formatAttributeKey, '');
                            //system.debug(formatAttributeKey + ' = ' + formatAttributeValue);
                            if (formatAttributeKey == 'pattern') {
                                numberFormat.pattern = formatAttributeValue;
                            }
                            if (formatAttributeKey == 'nationalPrefixFormattingRule') {
                                numberFormat.nationalPrefixFormattingRule = formatAttributeValue;
                            }
                            if (formatAttributeKey == 'nationalPrefixOptionalWhenFormatting') {
                                numberFormat.nationalPrefixOptionalWhenFormatting = Boolean.valueOf(formatAttributeValue);
                            }
                            //Never encountered in metadata resources but can be a sub-node
                            if (formatAttributeKey == 'domesticCarrierCodeFormattingRule') {
                                numberFormat.domesticCarrierCodeFormattingRule = formatAttributeValue;
                            }
                        }
                        //Get format sub-nodes
                        List<Dom.XMLNode> numberFormatSubnodes = numberFormatNode.getChildElements();
                        List<String> leadingDigitsPattern = new List<String>();
                        for(Dom.XMLNode numberFormatSubnode : numberFormatSubnodes) {
                            if (numberFormatSubnode.getName() == 'leadingDigits') {
                                leadingDigitsPattern.add(cleanRegEx(numberFormatSubnode.getText()));
                            }
                            //public List<String> leadingDigitsPattern;
                            if (numberFormatSubnode.getName() == 'format') {
                                numberFormat.format = numberFormatSubnode.getText();
                            }
                            //!!!!!intlFormat subnode wasn't extracted due to ambigousity!!!!!
                        }
                        numberFormat.leadingDigitsPattern = leadingDigitsPattern;
                        //if(leadingDigitsPattern.size() > 1) system.debug(leadingDigitsPattern);
                        numberFormats.add(numberFormat);
                    }
                    phoneMetadata.numberFormat = numberFormats;
                } else {
                    //The node is not 'availableFormats' type just one of the descriptions
                    PhoneMetadata.PhoneNumberDesc phoneNumberDescInstance = new PhoneMetadata.PhoneNumberDesc();
                    List<Dom.XMLNode> descriptionSubNodes = territoryDataType.getChildElements();
                    for (Dom.XMLNode descriptionSubNode : descriptionSubNodes) {
                        if (descriptionSubNode.getName() == 'possibleLengths') {
                            Integer possibleLengthsAttributeCount = descriptionSubNode.getAttributeCount();
                            for (Integer k = 0; k < possibleLengthsAttributeCount; k++) {
                                String possibleLengthsAttributeKey = descriptionSubNode.getAttributeKeyAt(k);
                                String possibleLengthsAttributeValue = descriptionSubNode.getAttributeValue(possibleLengthsAttributeKey, '');
                                //system.debug(formatAttributeKey + ' = ' + formatAttributeValue);
                                //lenghts could be coded as '5' or '5,6,9' or '[5-7]' or '3,[5-7]'
                                if (possibleLengthsAttributeKey == 'national') {
                                    phoneNumberDescInstance.possibleLength = parsePossibleLength(possibleLengthsAttributeValue);
                                }
                                if (possibleLengthsAttributeKey == 'localOnly') {
                                    phoneNumberDescInstance.possibleLengthLocalOnly = parsePossibleLength(possibleLengthsAttributeValue);
                                }
                            }
                        }
                        if (descriptionSubNode.getName() == 'exampleNumber') {
                            phoneNumberDescInstance.exampleNumber = descriptionSubNode.getText();
                        }
                        if (descriptionSubNode.getName() == 'nationalNumberPattern') {
                            phoneNumberDescInstance.nationalNumberPattern = cleanRegEx(descriptionSubNode.getText());
                        }
                    }
                    switch on territoryDataType.getName() {
                        when 'generalDesc' {
                            phoneMetadata.generalDesc = phoneNumberDescInstance;
                        }
                        when 'fixedLine' {
                            phoneMetadata.fixedLine = phoneNumberDescInstance;
                        }
                        when 'mobile' {
                            phoneMetadata.mobile = phoneNumberDescInstance;
                        }
                        when 'tollFree' {
                            phoneMetadata.tollFree = phoneNumberDescInstance;
                        }
                        when 'premiumRate' {
                            phoneMetadata.premiumRate = phoneNumberDescInstance;
                        }
                        when 'sharedCost' {
                            phoneMetadata.sharedCost = phoneNumberDescInstance;
                        }
                        when 'personalNumber' {
                            phoneMetadata.personalNumber = phoneNumberDescInstance;
                        }
                        when 'voip' {
                            phoneMetadata.voip = phoneNumberDescInstance;
                        }
                        when 'pager' {
                            phoneMetadata.pager = phoneNumberDescInstance;
                        }
                        when 'uan' {
                            phoneMetadata.uan = phoneNumberDescInstance;
                        }
                        when 'emergency' {
                            phoneMetadata.emergency = phoneNumberDescInstance;
                        }
                        when 'voicemail' {
                            phoneMetadata.voicemail = phoneNumberDescInstance;
                        }
                        when 'shortCode' {
                            phoneMetadata.shortCode = phoneNumberDescInstance;
                        }
                        when 'standardRate' {
                            phoneMetadata.standardRate = phoneNumberDescInstance;
                        }
                        when 'carrierSpecific' {
                            phoneMetadata.carrierSpecific = phoneNumberDescInstance;
                        }
                        when 'smsServices' {
                            phoneMetadata.smsServices = phoneNumberDescInstance;
                        }
                        when 'noInternationalDialling' {
                            phoneMetadata.noInternationalDialling = phoneNumberDescInstance;
                        }
                    }
                }
            }
            phoneMetadataList.add(phoneMetadata);
            //system.debug(phoneMetadata.generalDesc.possibleLength);
        }
        return phoneMetadataList;
    }

    private static String cleanRegEx(String raw) {
        return raw.remove(' ').remove('\n');
    }

    private static List<Integer> parsePossibleLength(String source) {
        List<Integer> possibleLengths = new List<Integer>();
        List<String> lengthIntervals = source.split(',');
        for (String intervalOrSingle : lengthIntervals) {
            String stripped = intervalOrSingle.remove('[').remove(']');
            if (intervalOrSingle.length() == stripped.length()) {
                possibleLengths.add(Integer.valueOf(stripped));
            } else {
                Integer intervalStart = Integer.valueOf(stripped.substringBefore('-'));
                Integer intervalEnd = Integer.valueOf(stripped.substringAfter('-'));
                for(Integer nextLength = intervalStart; nextLength <= intervalEnd; nextLength++)
                    possibleLengths.add(nextLength);
            }
        }
        return possibleLengths;
    }
}