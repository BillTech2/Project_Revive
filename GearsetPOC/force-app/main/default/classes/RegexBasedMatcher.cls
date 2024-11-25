public class RegexBasedMatcher implements MatcherApi {
    public static MatcherApi create() {
        return new RegexBasedMatcher();
    }

    //private final RegexCache regexCache = new RegexCache(100);
    private static final RegexCache regexCacheInstance = RegexCache.getInstance();

    private RegexBasedMatcher() {}

    public static Boolean matchNationalNumber(String phNumber, PhoneMetadata.PhoneNumberDesc numberDesc,
            Boolean allowPrefixMatch) {
        String nationalNumberPattern = numberDesc.nationalNumberPattern;
        // We don't want to consider it a prefix match when matching non-empty input against an empty
        // pattern.
        if (nationalNumberPattern.length() == 0) {
            return false;
        }
        return match(phNumber, regexCacheInstance.getPatternForRegex(nationalNumberPattern), allowPrefixMatch);
    }

    private static Boolean match(String phNumber, Pattern patt, boolean allowPrefixMatch) {
        Matcher matcher = patt.matcher(phNumber);
        if (!matcher.lookingAt()) {
            return false;
        } else {
            return (matcher.matches()) ? true : allowPrefixMatch;
        }
    }
}