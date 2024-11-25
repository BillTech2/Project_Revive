public class PhoneNumber {

    public enum CountryCodeSources {
        UNSPECIFIED,
        FROM_NUMBER_WITH_PLUS_SIGN,
        FROM_NUMBER_WITH_IDD,
        FROM_NUMBER_WITHOUT_PLUS_SIGN,
        FROM_DEFAULT_COUNTRY
    }

    public Integer countryCode;
    public Long nationalNumber;
    public String extension;
    public Boolean italianLeadingZero = false;
    public Integer numberOfLeadingZeros = 0; // [ default = 1 ?]

    // The next few fields are non-essential fields for a phone number. They
    // retain extra information about the form the phone number was in when it was
    // provided to us to parse. They can be safely ignored by most clients. To
    // populate them, call parseAndKeepRawInput on PhoneNumberUtil.

    public String rawInput;
    public CountryCodeSources countryCodeSource;
    public String preferredDomesticCarrierCode;
}