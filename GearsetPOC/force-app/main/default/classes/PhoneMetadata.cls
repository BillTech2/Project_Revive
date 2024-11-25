public class PhoneMetadata{
    public class NumberFormat {
        public String pattern; //required
        public String format; //required
        public List<String> leadingDigitsPattern;
        public String nationalPrefixFormattingRule; //optional
        public Boolean nationalPrefixOptionalWhenFormatting = false; //optional [default=false]
        public String domesticCarrierCodeFormattingRule; //optional
    }

    public class PhoneNumberDesc {
        public String nationalNumberPattern; //optional
        public List<Integer> possibleLength;
        public List<Integer> possibleLengthLocalOnly;
        //exampleNumber not used in parsing
        public String exampleNumber; //optional
    }


    public PhoneNumberDesc generalDesc; //optional
    public PhoneNumberDesc fixedLine; //optional
    public PhoneNumberDesc mobile; //optional
    public PhoneNumberDesc tollFree; //optional
    public PhoneNumberDesc premiumRate; //optional
    public PhoneNumberDesc sharedCost; //optional
    public PhoneNumberDesc personalNumber; //optional
    public PhoneNumberDesc voip; //optional
    public PhoneNumberDesc pager; //optional
    public PhoneNumberDesc uan; //optional
    public PhoneNumberDesc emergency; //optional
    public PhoneNumberDesc voicemail; //optional
    public PhoneNumberDesc shortCode; //optional
    public PhoneNumberDesc standardRate; //optional
    public PhoneNumberDesc carrierSpecific; //optional
    public PhoneNumberDesc smsServices; //optional
    public PhoneNumberDesc noInternationalDialling; //optional
    public String id; //required
    public Integer countryCode; //optional int32
    public String internationalPrefix; //optional
    public String preferredInternationalPrefix; //optional
    public String nationalPrefix; //optional
    public String preferredExtnPrefix; //optional
    public String nationalPrefixForParsing; //optional
    public String nationalPrefixTransformRule; //optional
    public Boolean sameMobileAndFixedLinePattern = false; //optional [default=false];
    public List<NumberFormat> numberFormat;
    public List<NumberFormat> intlNumberFormat;
    public Boolean mainCountryForCode = false; //optional [default=false];
    public String leadingDigits; //optional

    // Deprecated: do not use. Will be deletd when there are no references to this
    // later. (leading_zero_possible only)
    //optional bool leading_zero_possible = 26 [default=false];
    public Boolean mobileNumberPortableRegion = false;  //optional [default=false]

    public class PhoneMetadataCollection {
        public List<PhoneMetadata> metadata;
    }
}