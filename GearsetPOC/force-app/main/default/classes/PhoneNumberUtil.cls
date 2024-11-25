public without sharing class PhoneNumberUtil {
    public static PhoneNumberUtil instance;

    public static PhoneNumberUtil getInstance() {
        if (instance == null) {
            instance = new PhoneNumberUtil();
        }
        return instance;
    }

    private static final Integer MAX_INPUT_STRING_LENGTH = 250;
    // The minimum and maximum length of the national significant number.
    private static final Integer MIN_LENGTH_FOR_NSN = 2;
    // The ITU says the maximum length should be 15, but we have found longer numbers in Germany.
    static final Integer MAX_LENGTH_FOR_NSN = 17;
    // The maximum length of the country calling code.
    static final Integer MAX_LENGTH_COUNTRY_CODE = 3;
    // Region-code for the unknown region.
    private static final String UNKNOWN_REGION = 'ZZ';

    // The PLUS_SIGN signifies the international prefix.
    static final String PLUS_SIGN = '+';
    private static final String STAR_SIGN = '*';
    private static final String RFC3966_EXTN_PREFIX = ';ext=';
    private static final String RFC3966_PREFIX = 'tel:';
    private static final String RFC3966_PHONE_CONTEXT = ';phone-context=';
    private static final String RFC3966_ISDN_SUBADDRESS = ';isub=';

    // Only upper-case variants of alpha characters are stored.
    private static final Map<String, String> ALPHA_MAPPINGS = new Map<String, String> {
            'A' => '2','B' => '2','C' => '2','D' => '3','E' => '3','F' => '3','G' => '4','H' => '4','I' => '4',
            'J' => '5','K' => '5','L' => '5','M' => '6','N' => '6','O' => '6','P' => '7','Q' => '7','R' => '7',
            'S' => '7','T' => '8','U' => '8','V' => '8','W' => '9','X' => '9','Y' => '9','Z' => '9'};

    // For performance reasons, amalgamate both into one map.
    private static final Map<String, String> ALPHA_PHONE_MAPPINGS = new Map<String, String> {
            'A' => '2','B' => '2','C' => '2','D' => '3','E' => '3','F' => '3','G' => '4','H' => '4','I' => '4',
            'J' => '5','K' => '5','L' => '5','M' => '6','N' => '6','O' => '6','P' => '7','Q' => '7','R' => '7',
            'S' => '7','T' => '8','U' => '8','V' => '8','W' => '9','X' => '9','Y' => '9','Z' => '9','0' => '0',
            '1' => '1','2' => '2','3' => '3','4' => '4','5' => '5','6' => '6','7' => '7','8' => '8','9' => '9'};
    private static final Map<String, String> DIGITS_MAPPINGS = new Map<String, String> {'0' => '0','1' => '1',
    '2' => '2','3' => '3','4' => '4','5' => '5','6' => '6','7' => '7','8' => '8','9' => '9'};

    //NOT THE PART OF OFFICIAL PHONE LIBRARY!!!
    private static final Map<PhoneNumberType, String> PHONE_TYPES_MAPPINGS = new Map<PhoneNumberType, String> {
            PhoneNumberType.FIXED_LINE => 'Fixed Line',
            PhoneNumberType.MOBILE => 'Mobile',
            PhoneNumberType.FIXED_LINE_OR_MOBILE => 'Fixed Line or Mobile',
            PhoneNumberType.TOLL_FREE => 'Toll Free',
            PhoneNumberType.PREMIUM_RATE => 'Premium Rate',
            PhoneNumberType.SHARED_COST => 'Shared Cost',
            PhoneNumberType.VOIP => 'VOIP',
            PhoneNumberType.PERSONAL_NUMBER => 'Personal Number',
            PhoneNumberType.PAGER => 'Pager',
            PhoneNumberType.UAN => 'UAN',
            PhoneNumberType.VOICEMAIL => 'VoiceMail',
            PhoneNumberType.UNKNOWN => 'Unknown'};

    private static final String DIGITS = '\\p{Nd}';
    static final String PLUS_CHARS = '+\uFF0B';
    static final Pattern PLUS_CHARS_PATTERN = Pattern.compile('[' + PLUS_CHARS + ']+');

    // Regular expression of characters typically used to start a second phone number for the purposes
    // of parsing. This allows us to strip off parts of the number that are actually the start of
    // another number, such as for: (530) 583-6985 x302/x2303 -> the second extension here makes this
    // actually two phone numbers, (530) 583-6985 x302 and (530) 583-6985 x2303. We remove the second
    // extension so that the first number is parsed correctly.
    private static final String SECOND_NUMBER_START = '[\\\\/] *x';
    static final Pattern SECOND_NUMBER_START_PATTERN = Pattern.compile(SECOND_NUMBER_START);

    // Regular expression of trailing characters that we want to remove. We remove all characters that
    // are not alpha or numerical characters. The hash character is retained here, as it may signify
    // the previous block was an extension.
    private static final String UNWANTED_END_CHARS = '[[\\P{N}&&\\P{L}]&&[^#]]+$';
    static final Pattern UNWANTED_END_CHAR_PATTERN = Pattern.compile(UNWANTED_END_CHARS);

    // We use this pattern to check if the phone number has at least three letters in it - if so, then
    // we treat it as a number where some phone-number digits are represented by letters.
    private static final Pattern VALID_ALPHA_PHONE_PATTERN = Pattern.compile('(?:.*?[A-Za-z]){3}.*');

    // Regular expression of acceptable characters that may start a phone number for the purposes of
    // parsing. This allows us to strip away meaningless prefixes to phone numbers that may be
    // mistakenly given to us. This consists of digits, the plus symbol and arabic-indic digits. This
    // does not contain alpha characters, although they may be used later in the number. It also does
    // not include other punctuation, as this will be stripped later during parsing and is of no
    // information value when parsing a number.
    private static final String VALID_START_CHAR = '[' + PLUS_CHARS + DIGITS + ']';
    private static final Pattern VALID_START_CHAR_PATTERN = Pattern.compile(VALID_START_CHAR);

    // Regular expression of acceptable punctuation found in phone numbers, used to find numbers in
    // text and to decide what is a viable phone number. This excludes diallable characters.
    // This consists of dash characters, white space characters, full stops, slashes,
    // square brackets, parentheses and tildes. It also includes the letter 'x' as that is found as a
    // placeholder for carrier information in some phone numbers. Full-width variants are also
    // present.
    static final String VALID_PUNCTUATION = '-x\u2010-\u2015\u2212\u30FC\uFF0D-\uFF0F '
    + '\u00A0\u00AD\u200B\u2060\u3000()\uFF08\uFF09\uFF3B\uFF3D.\\[\\]/~\u2053\u223C\uFF5E';


    // We accept alpha characters in phone numbers, ASCII only, upper and lower case.
    private static final String VALID_ALPHA ='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

    private static final Pattern SEPARATOR_PATTERN = Pattern.compile('[' + VALID_PUNCTUATION + ']+');
    private static final Pattern CAPTURING_DIGIT_PATTERN = Pattern.compile('(' + DIGITS + ')');
    public static final String REGION_CODE_FOR_NON_GEO_ENTITY = '001';

    // Regular expression of viable phone numbers. This is location independent. Checks we have at
    // least three leading digits, and only valid punctuation, alpha characters and
    // digits in the phone number. Does not include extension data.
    // The symbol 'x' is allowed here as valid punctuation since it is often used as a placeholder for
    // carrier codes, for example in Brazilian phone numbers. We also allow multiple "+" characters at
    // the start.
    // Corresponds to the following:
    // [digits]{minLengthNsn}|
    // plus_sign*(([punctuation]|[star])*[digits]){3,}([punctuation]|[star]|[digits]|[alpha])*
    //
    // The first reg-ex is to allow short numbers (two digits long) to be parsed if they are entered
    // as "15" etc, but only if there is no punctuation in them. The second expression restricts the
    // number of digits to three or more, but then allows them to be in international form, and to
    // have alpha-characters and punctuation.
    //
    // Note VALID_PUNCTUATION starts with a -, so must be the first in the range.
    private static final String VALID_PHONE_NUMBER =
            DIGITS + '{' + MIN_LENGTH_FOR_NSN + '}' + '|'
    + '[' + PLUS_CHARS + ']*+(?:[' + VALID_PUNCTUATION + STAR_SIGN + ']*' + DIGITS + '){3,}['
    + VALID_PUNCTUATION + STAR_SIGN + VALID_ALPHA + DIGITS + ']*';


    // Pattern to capture digits used in an extension. Places a maximum length of "7" for an
    // extension.
    private static final String CAPTURING_EXTN_DIGITS = '(' + DIGITS + '{1,7})';

    /**
    * Helper initialiser method to create the regular-expression pattern to match extensions,
    * allowing the one-char extension symbols provided by {@code singleExtnSymbols}.
    */
    private static String createExtnPattern(String singleExtnSymbols) {
        // There are three regular expressions here. The first covers RFC 3966 format, where the
        // extension is added using ";ext=". The second more generic one starts with optional white
        // space and ends with an optional full stop (.), followed by zero or more spaces/tabs/commas
        // and then the numbers themselves. The other one covers the special case of American numbers
        // where the extension is written with a hash at the end, such as "- 503#"
        // Note that the only capturing groups should be around the digits that you want to capture as
        // part of the extension, or else parsing will fail!
        // Canonical-equivalence doesn't seem to be an option with Android java, so we allow two options
        // for representing the accented o - the character itself, and one in the unicode decomposed
        // form with the combining acute accent.
        return (RFC3966_EXTN_PREFIX + CAPTURING_EXTN_DIGITS + '|' + '[ \u00A0\\t,]*'
        + '(?:e?xt(?:ensi(?:o\u0301?|\u00F3))?n?|\uFF45?\uFF58\uFF54\uFF4E?|'
        + '\u0434\u043E\u0431|' + '[' + singleExtnSymbols + ']|int|anexo|\uFF49\uFF4E\uFF54)'
        + '[:\\.\uFF0E]?[ \u00A0\\t,-]*' + CAPTURING_EXTN_DIGITS + '#?|'
        + '[- ]+(' + DIGITS + '{1,5})#');
    }

    /** Flags to use when compiling regular expressions for phone numbers. */
    //static final Integer REGEX_FLAGS = Pattern.UNICODE_CASE | Pattern.CASE_INSENSITIVE;

    // Regexp of all possible ways to write extensions, for use when parsing. This will be run as a
    // case-insensitive regexp match. Wide character versions are also provided after each ASCII
    // version.
    private static final String EXTN_PATTERNS_FOR_PARSING;
    static final String EXTN_PATTERNS_FOR_MATCHING;
    static {
        // One-character symbols that can be used to indicate an extension.
        String singleExtnSymbolsForMatching = 'x\uFF58#\uFF03~\uFF5E';
        // For parsing, we are slightly more lenient in our interpretation than for matching. Here we
        // allow "comma" and "semicolon" as possible extension indicators. When matching, these are
        // hardly ever used to indicate this.
        String singleExtnSymbolsForParsing = ',;' + singleExtnSymbolsForMatching;

        EXTN_PATTERNS_FOR_PARSING = createExtnPattern(singleExtnSymbolsForParsing);
        EXTN_PATTERNS_FOR_MATCHING = createExtnPattern(singleExtnSymbolsForMatching);
    }

    // Regexp of all known extension prefixes used by different regions followed by 1 or more valid
    // digits, for use when parsing.
    private static final Pattern EXTN_PATTERN =
            Pattern.compile('(?:' + EXTN_PATTERNS_FOR_PARSING + ')$');

    // We append optionally the extension pattern to the end here, as a valid phone number may
    // have an extension prefix appended, followed by 1 or more digits.
    private static final Pattern  VALID_PHONE_NUMBER_PATTERN =
            Pattern.compile(VALID_PHONE_NUMBER + '(?:' + EXTN_PATTERNS_FOR_PARSING + ')?');



    /**
    * Possible outcomes when testing if a PhoneNumber is possible.
    */
    public enum ValidationResult {
        /** The number length matches that of valid numbers for this region. */
        IS_POSSIBLE,
        /**
         * The number length matches that of local numbers for this region only (i.e. numbers that may
         * be able to be dialled within an area, but do not have all the information to be dialled from
         * anywhere inside or outside the country).
         */
        IS_POSSIBLE_LOCAL_ONLY,
        /** The number has an invalid country calling code. */
        INVALID_COUNTRY_CODE,
        /** The number is shorter than all valid numbers for this region. */
        TOO_SHORT,
        /**
         * The number is longer than the shortest valid numbers for this region, shorter than the
         * longest valid numbers for this region, and does not itself have a number length that matches
         * valid numbers for this region. This can also be returned in the case where
         * isPossibleNumberForTypeWithReason was called, and there are no numbers of this type at all
         * for this region.
         */
        INVALID_LENGTH,
        /** The number is longer than all valid numbers for this region. */
        TOO_LONG
    }

    /**
    * Type of phone numbers.
    */
    public enum PhoneNumberType {
        FIXED_LINE,
        MOBILE,
        // In some regions (e.g. the USA), it is impossible to distinguish between fixed-line and
        // mobile numbers by looking at the phone number itself.
        FIXED_LINE_OR_MOBILE,
        // Freephone lines
        TOLL_FREE,
        PREMIUM_RATE,
        // The cost of this call is shared between the caller and the recipient, and is hence typically
        // less than PREMIUM_RATE calls. See // http://en.wikipedia.org/wiki/Shared_Cost_Service for
        // more information.
        SHARED_COST,
        // Voice over IP numbers. This includes TSoIP (Telephony Service over IP).
        VOIP,
        // A personal number is associated with a particular person, and may be routed to either a
        // MOBILE or FIXED_LINE number. Some more information can be found here:
        // http://en.wikipedia.org/wiki/Personal_Numbers
        PERSONAL_NUMBER,
        PAGER,
        // Used for "Universal Access Numbers" or "Company Numbers". They may be further routed to
        // specific offices, but allow one number to be used for a company.
        UAN,
        // Used for "Voice Mail Access Numbers".
        VOICEMAIL,
        // A phone number is of type UNKNOWN when it does not fit any of the known patterns for a
        // specific region.
        UNKNOWN
    }

    // An API for validation checking.
    private final MatcherApi matcherApiInstance = RegexBasedMatcher.create();

    // A cache for frequently used region-specific regular expressions.
    // The initial capacity is set to 100 as this seems to be an optimal value for Android, based on
    // performance measurements.
    private final RegexCache regexCacheInstance = RegexCache.getInstance();

    // The set of regions the library supports.
    private final Set<String> supportedRegions = new Set<String>();

    // The set of country calling codes that map to the non-geo entity region ("001"). This set
    // currently contains < 12 elements so the default capacity of 16 (load factor=0.75) is fine.
    private final Set<Integer> countryCodesForNonGeographicalRegion = new Set<Integer>();

    // Metadata Unsorted
    private static final List<PhoneMetadata> phoneMetadataUnsorted = PhoneNumberMetadataExtractor.processPhoneNumberRawMetadata();
    // Metadata Map by Region
    private static final Map<String, PhoneMetadata> phoneMetadataByRegion = new Map<String, PhoneMetadata>();


    static Map<Integer, List<String>> countryCallingCodeToRegionCodeMap =
                               CountryCodeToRegionCodeMap.getCountryCodeToRegionCodeMap();

    {
        Set<Integer> countryCallingCodes = countryCallingCodeToRegionCodeMap.keySet();
        for (Integer countryCallingCode : countryCallingCodes) {
            for (String regionCodes : countryCallingCodeToRegionCodeMap.get(countryCallingCode)) {
                // We can assume that if the country calling code maps to the non-geo entity region code then
                // that's the only region code it maps to.
                if (countryCallingCodes.size() == 1 && REGION_CODE_FOR_NON_GEO_ENTITY.equals(countryCallingCodeToRegionCodeMap.get(countryCallingCode).get(0))) {
                    // This is the subset of all country codes that map to the non-geo entity region code.
                    countryCodesForNonGeographicalRegion.add(countryCallingCode);
                } else {
                    // The supported regions set does not include the "001" non-geo entity region code.
                    supportedRegions.addAll(countryCallingCodeToRegionCodeMap.get(countryCallingCode));
                }
            }
        }
        for (PhoneMetadata metadata : phoneMetadataUnsorted){
            phoneMetadataByRegion.put(metadata.id, metadata);
        }
    }
/*      NEXT TIME IMPORTANT CHECK IT
        // If the non-geo entity still got added to the set of supported regions it must be because
        // there are entries that list the non-geo entity alongside normal regions (which is wrong).
        // If we discover this, remove the non-geo entity from the set of supported regions and log.
        if (supportedRegions.remove(REGION_CODE_FOR_NON_GEO_ENTITY)) {
            logger.log(Level.WARNING, 'invalid metadata (country calling code was mapped to the non-geo '
            + 'entity as well as specific region(s))');
        }
*/



    public PhoneNumber parseAndValidateUsingCorrectionAlgo(String numberToParse) {
        //throws NumberParseException
        PhoneNumber parsedNumber;
        String modifiedNumber;

        //a)The phone number should not have any alphabet or special characters.Formula used is regexp_replace(phone_number,'([^0-9])','')
        modifiedNumber = '+' + numberToParse.replaceAll('[^0-9]', '').remove('+');
        try {
            parsedNumber = parse(new StringBuilder(modifiedNumber), '');
            if (isValidNumber(parsedNumber)) {
                return parsedNumber;
            }
        } catch (NumberParseException e) {
        }

        //b)Check if the phone number has REA or REC or REL or REG they are attempted with germany country code
        modifiedNumber = numberToParse.left(3);
        switch on modifiedNumber {
            when 'REA', 'REC', 'REL', 'REG' {
                modifiedNumber = '+49' + numberToParse.substring(3);
                try {
                    parsedNumber = parse(new StringBuilder(modifiedNumber), '');
                    if (isValidNumber(parsedNumber)) {
                        return parsedNumber;
                    }
                } catch (NumberParseException e) {
                }
            }
        }

        //c)Check if the phone number has FR M or FRL these are attempted with france country code
        //to ask if it FR M and FRL or FR M and FR P or whatever combination is it
        modifiedNumber = numberToParse.right(4);
        switch on modifiedNumber {
            when 'FR L', 'FR P' {
                modifiedNumber = '+33' + numberToParse.replaceAll('[^0-9]', '');
                try {
                    parsedNumber =  parse(new StringBuilder(modifiedNumber),'');
                    if (isValidNumber(parsedNumber)) {
                        return parsedNumber;
                    }
                } catch (NumberParseException e) {
                }
            }
        }

        //d-1)Remove leading zeroes
        modifiedNumber = numberToParse.replaceAll('[^0-9]', '').remove('+');
        while (modifiedNumber.left(1) == '0' && modifiedNumber.length() > 6) {
            modifiedNumber = modifiedNumber.replaceFirst('0', '');
        }
        //In case if country code is present after leading zeroes
        try {
            parsedNumber = parse(new StringBuilder('+' + modifiedNumber), '');
            if (isValidNumber(parsedNumber)) {
                return parsedNumber;
            }
        } catch (NumberParseException e) {
        }

        //d-2)Trim double or triple country code (GB, FR, NL, DK, BE, DE  only)
        Integer countryCodeDubs = 0;
        Integer pos = 0;  //31 -netherlands, 45 - denmark, 32 - belgium, 49 - germany
        String digitCC = modifiedNumber.left(2);
        if (digitCC == '44' || digitCC == '33' || digitCC == '31' || digitCC == '45' || digitCC == '32' || digitCC == '49') {
            while ((modifiedNumber.length() - pos) > 8 && modifiedNumber.substring(pos, pos + 2) == digitCC ) {
                countryCodeDubs++;
                pos += 2;
            }
            modifiedNumber = modifiedNumber.right(modifiedNumber.length() - ((countryCodeDubs - 1) << 1));
            system.debug(modifiedNumber);
            try {
                parsedNumber = parse(new StringBuilder('+' + modifiedNumber), '');
                if (isValidNumber(parsedNumber)) {
                    return parsedNumber;
                }
            } catch (NumberParseException e) {
            }
        }

        //e)Phone number without country code are attempted with UK country code.
        try { 
            parsedNumber = parse(new StringBuilder(modifiedNumber), 'GB');
            if (isValidNumber(parsedNumber)) {
                return parsedNumber;
            }
        } catch (NumberParseException e) {
        }

        //f)Phone number without country code are attempted with FR country code.
        try {
            parsedNumber = parse(new StringBuilder(modifiedNumber), 'FR');
            if (isValidNumber(parsedNumber)) {
                return parsedNumber;
            }
        } catch (NumberParseException e) {
        }

        parsedNumber = new PhoneNumber();
        parsedNumber.countryCode = 0;
        parsedNumber.nationalNumber = 0;
        parsedNumber.rawInput = numberToParse;
        return parsedNumber;
    }


    /**
    * Parses a string and returns it as a phone number in proto buffer format. The method is quite
    * lenient and looks for a number in the input text (raw input) and does not check whether the
    * string is definitely only a phone number. To do this, it ignores punctuation and white-space,
    * as well as any text before the number (e.g. a leading "Tel: ") and trims the non-number bits.
    * It will accept a number in any format (E164, national, international etc), assuming it can be
    * interpreted with the defaultRegion supplied. It also attempts to convert any alpha characters
    * into digits if it thinks this is a vanity number of the type "1800 MICROSOFT".
    *
    * <p> This method will throw a {@link com.google.i18n.phonenumbers.NumberParseException} if the
    * number is not considered to be a possible number. Note that validation of whether the number
    * is actually a valid number for a particular region is not performed. This can be done
    * separately with {@link #isValidNumber}.
    *
    * <p> Note this method canonicalizes the phone number such that different representations can be
    * easily compared, no matter what form it was originally entered in (e.g. national,
    * international). If you want to record context about the number being parsed, such as the raw
    * input that was entered, how the country code was derived etc. then call {@link
    * #parseAndKeepRawInput} instead.
    *
    * @param numberToParse  number that we are attempting to parse. This can contain formatting such
    *     as +, ( and -, as well as a phone number extension. It can also be provided in RFC3966
    *     format.
    * @param defaultRegion  region that we are expecting the number to be from. This is only used if
    *     the number being parsed is not written in international format. The country_code for the
    *     number in this case would be stored as that of the default region supplied. If the number
    *     is guaranteed to start with a '+' followed by the country calling code, then RegionCode.ZZ
    *     or null can be supplied.
    * @return  a phone number proto buffer filled with the parsed number
    * @throws NumberParseException  if the string is not considered to be a viable phone number (e.g.
    *     too few or too many digits) or if no default region was supplied and the number is not in
    *     international format (does not start with +)
    */
    public PhoneNumber parse(CharSequence numberToParse, String defaultRegion) {
        //throws NumberParseException
        PhoneNumber phoneNumber = new PhoneNumber();
        parse(numberToParse, defaultRegion, phoneNumber);
        return phoneNumber;
    }

    /**
   * Same as {@link #parse(CharSequence, String)}, but accepts mutable PhoneNumber as a
   * parameter to decrease object creation when invoked many times.
   */
    public void parse(CharSequence numberToParse, String defaultRegion, PhoneNumber phoneNumber) {
        //throws NumberParseException
        parseHelper(numberToParse, defaultRegion, false, true, phoneNumber);
    }


    /**
    * Parses a string and fills up the phoneNumber. This method is the same as the public
    * parse() method, with the exception that it allows the default region to be null, for use by
    * isNumberMatch(). checkRegion should be set to false if it is permitted for the default region
    * to be null or unknown ("ZZ").
    *
    * Note if any new field is added to this method that should always be filled in, even when
    * keepRawInput is false, it should also be handled in the copyCoreFieldsOnly() method.
    */
    private void parseHelper(CharSequence numberToParse, String defaultRegion,
            boolean keepRawInput, boolean checkRegion, PhoneNumber outputPhoneNumber) {
        //throws NumberParseException {
        if (numberToParse == null) {
            throw new NumberParseException(NumberParseException.ErrorType.NOT_A_NUMBER,
                    'The phone number supplied was null.');
        } else if (numberToParse.length() > MAX_INPUT_STRING_LENGTH) {
            throw new NumberParseException(NumberParseException.ErrorType.TOO_LONG,
                    'The string supplied was too long to parse.');
        }

        StringBuilder nationalNumber = new StringBuilder();
        String numberBeingParsed = numberToParse.toString();
        buildNationalNumberForParsing(numberBeingParsed, nationalNumber);

        if (!isViablePhoneNumber(nationalNumber.toString())) {
            throw new NumberParseException(NumberParseException.ErrorType.NOT_A_NUMBER,
                    'The string supplied did not seem to be a phone number.');
        }

        // Check the region supplied is valid, or that the extracted number starts with some sort of +
        // sign so the number's region can be determined.
        if (checkRegion && !checkRegionForParsing(nationalNumber, defaultRegion)) {
            throw new NumberParseException(NumberParseException.ErrorType.INVALID_COUNTRY_CODE,
                    'Missing or invalid default region.');
        }

        if (keepRawInput) {
            outputPhoneNumber.rawInput = numberBeingParsed;
        }
        // Attempt to parse extension first, since it doesn't require region-specific data and we want
        // to have the non-normalised number here.
        String extension = maybeStripExtension(nationalNumber);
        if (extension.length() > 0) {
            outputPhoneNumber.extension = extension;
        }

        PhoneMetadata regionMetadata = getMetadataForRegion(defaultRegion);
        // Check to see if the number is given in international format so we know whether this number is
        // from the default region or not.
        StringBuilder normalizedNationalNumber = new StringBuilder();
        Integer countryCode = 0;
        try {
        // This method should really just take in the string buffer that has already
        // been created, and just remove the prefix, rather than taking in a string and then
        // outputting a string buffer.
            countryCode = maybeExtractCountryCode(nationalNumber, regionMetadata,
                    normalizedNationalNumber, keepRawInput, outputPhoneNumber);
        } catch (NumberParseException e) {
            Matcher matcher = PLUS_CHARS_PATTERN.matcher(nationalNumber.toString());
            if (e.getErrorType() == NumberParseException.ErrorType.INVALID_COUNTRY_CODE
                    && matcher.lookingAt()) {
                // Strip the plus-char, and try again.
                countryCode = maybeExtractCountryCode(new StringBuilder(nationalNumber.toString().substring(matcher.end())),
                        regionMetadata, normalizedNationalNumber,
                        keepRawInput, outputPhoneNumber);
                if (countryCode == 0) {
                    throw new NumberParseException(NumberParseException.ErrorType.INVALID_COUNTRY_CODE,
                            'Could not interpret numbers after plus-sign.');
                }
            } else {
                throw new NumberParseException(e.getErrorType(), e.getMessage());
            }
        }
        if (countryCode != 0) {
            String phoneNumberRegion = getRegionCodeForCountryCode(countryCode);
            if (!phoneNumberRegion.equals(defaultRegion)) {
                // Metadata cannot be null because the country calling code is valid.
                regionMetadata = getMetadataForRegionOrCallingCode(countryCode, phoneNumberRegion);
            }
        } else {
        // If no extracted country calling code, use the region supplied instead. The national number
        // is just the normalized version of the number we were given to parse.
            normalizedNationalNumber.append(normalize(nationalNumber).toString());
            if (defaultRegion != null) {
                countryCode = regionMetadata.countryCode;
                outputPhoneNumber.countryCode = countryCode;
            } else if (keepRawInput) {
                outputPhoneNumber.countryCodeSource = PhoneNumber.CountryCodeSources.UNSPECIFIED;
            }
        }
        if (normalizedNationalNumber.length() < MIN_LENGTH_FOR_NSN) {
            throw new NumberParseException(NumberParseException.ErrorType.TOO_SHORT_NSN,
                    'The string supplied is too short to be a phone number.');
        }
        if (regionMetadata != null) {
            StringBuilder carrierCode = new StringBuilder();
            StringBuilder potentialNationalNumber = new StringBuilder(normalizedNationalNumber.toString());
            maybeStripNationalPrefixAndCarrierCode(potentialNationalNumber, regionMetadata, carrierCode);
            // We require that the NSN remaining after stripping the national prefix and carrier code be
            // long enough to be a possible length for the region. Otherwise, we don't do the stripping,
            // since the original number could be a valid short number.
            ValidationResult validationResult = testNumberLength(potentialNationalNumber.toString(), regionMetadata);
            if (validationResult != PhoneNumberUtil.ValidationResult.TOO_SHORT
                    && validationResult != PhoneNumberUtil.ValidationResult.IS_POSSIBLE_LOCAL_ONLY
                    && validationResult != PhoneNumberUtil.ValidationResult.INVALID_LENGTH) {
                normalizedNationalNumber = potentialNationalNumber;
                if (keepRawInput && carrierCode.length() > 0) {
                    outputPhoneNumber.preferredDomesticCarrierCode = carrierCode.toString();
                }
            }
        }
        Integer lengthOfNationalNumber = normalizedNationalNumber.length(); //int
        if (lengthOfNationalNumber < MIN_LENGTH_FOR_NSN) {
            throw new NumberParseException(NumberParseException.ErrorType.TOO_SHORT_NSN,
                    'The string supplied is too short to be a phone number.');
        }
        if (lengthOfNationalNumber > MAX_LENGTH_FOR_NSN) {
            throw new NumberParseException(NumberParseException.ErrorType.TOO_LONG,
                    'The string supplied is too long to be a phone number.');
        }
        setItalianLeadingZerosForPhoneNumber(normalizedNationalNumber, outputPhoneNumber);
        outputPhoneNumber.nationalNumber = Long.valueOf((normalizedNationalNumber.toString()));
    }

    /**
    * Converts numberToParse to a form that we can parse and write it to nationalNumber if it is
    * written in RFC3966; otherwise extract a possible number out of it and write to nationalNumber.
    */
    private void buildNationalNumberForParsing(String numberToParse, StringBuilder nationalNumber) {
        Integer indexOfPhoneContext = numberToParse.indexOf(RFC3966_PHONE_CONTEXT);
        if (indexOfPhoneContext >= 0) {
            Integer phoneContextStart = indexOfPhoneContext + RFC3966_PHONE_CONTEXT.length();
            // If the phone context contains a phone number prefix, we need to capture it, whereas domains
            // will be ignored.
            if (phoneContextStart < (numberToParse.length() - 1)
                    && numberToParse.substring(phoneContextStart, phoneContextStart + 1) == PLUS_SIGN) {
                // Additional parameters might follow the phone context. If so, we will remove them here
                // because the parameters after phone context are not important for parsing the
                // phone number.
                Integer phoneContextEnd = numberToParse.indexOf(';', phoneContextStart);
                if (phoneContextEnd > 0) {
                    nationalNumber.append(numberToParse.substring(phoneContextStart, phoneContextEnd));
                } else {
                    nationalNumber.append(numberToParse.substring(phoneContextStart));
                }
            }

            // Now append everything between the "tel:" prefix and the phone-context. This should include
            // the national number, an optional extension or isdn-subaddress component. Note we also
            // handle the case when "tel:" is missing, as we have seen in some of the phone number inputs.
            // In that case, we append everything from the beginning.
            Integer indexOfRfc3966Prefix = numberToParse.indexOf(RFC3966_PREFIX);
            Integer indexOfNationalNumber = (indexOfRfc3966Prefix >= 0)
                    ? indexOfRfc3966Prefix + RFC3966_PREFIX.length() : 0;
            nationalNumber.append(numberToParse.substring(indexOfNationalNumber, indexOfPhoneContext));
        } else {
            // Extract a possible number from the string passed in (this strips leading characters that
            // could not be the start of a phone number.)
            nationalNumber.append(extractPossibleNumber(numberToParse));
        }

        // Delete the isdn-subaddress and everything after it if it is present. Note extension won't
        // appear at the same time with isdn-subaddress according to paragraph 5.3 of the RFC3966 spec,
        Integer indexOfIsdn = nationalNumber.toString().indexOf(RFC3966_ISDN_SUBADDRESS);
        if (indexOfIsdn > 0) {
            nationalNumber.left(indexOfIsdn);
        }
        // If both phone context and isdn-subaddress are absent but other parameters are present, the
        // parameters are left in nationalNumber. This is because we are concerned about deleting
        // content from a potential number string when there is no strong evidence that the number is
        // actually written in RFC3966.
    }

    /**
    * Checks to see if the string of characters could possibly be a phone number at all. At the
    * moment, checks to see that the string begins with at least 2 digits, ignoring any punctuation
    * commonly found in phone numbers.
    * This method does not require the number to be normalized in advance - but does assume that
    * leading non-number symbols have been removed, such as by the method extractPossibleNumber.
    *
    * @param number  string to be checked for viability as a phone number
    * @return  true if the number could be a phone number of some sort, otherwise false
    */

    static Boolean isViablePhoneNumber(String phoneNumber) {
        if (phoneNumber.length() < MIN_LENGTH_FOR_NSN) {
            return false;
        }
        Matcher m = VALID_PHONE_NUMBER_PATTERN.matcher(phoneNumber);
        return m.matches();
    }

    /**
    * Checks to see that the region code used is valid, or if it is not valid, that the number to
    * parse starts with a + symbol so that we can attempt to infer the region from the number.
    * Returns false if it cannot use the region provided and the region cannot be inferred.
    */
    private boolean checkRegionForParsing(CharSequence numberToParse, String defaultRegion) {
        if (!isValidRegionCode(defaultRegion)) {
            // If the number is null or empty, we can't infer the region.
            if ((numberToParse == null) || (numberToParse.length() == 0)
                    || !PLUS_CHARS_PATTERN.matcher(numberToParse.toString()).lookingAt()) {
                return false;
            }
        }
        return true;
    }

    // Helper function to check region code is not unknown or null.
    private boolean isValidRegionCode(String regionCode) {
        return regionCode != null && supportedRegions.contains(regionCode);
    }


    String maybeStripExtension(StringBuilder phoneNumber) {
        Matcher m = EXTN_PATTERN.matcher(phoneNumber.toString());
        // If we find a potential extension, and the number preceding this is a viable number, we assume
        // it is an extension.
        if (m.find() && isViablePhoneNumber(phoneNumber.toString().substring(0, m.start()))) {
            // The numbers are captured into groups in the regular expression.
            for (Integer i = 1, length = m.groupCount(); i <= length; i++) {
                if (m.group(i) != null) {
                    // We go through the capturing groups until we find one that captured some digits. If none
                    // did, then we will return the empty string.
                    String extension = m.group(i);
                    phoneNumber.left(m.start());
                    return extension;
                }
            }
        }
        return '';
    }

    Integer maybeExtractCountryCode(CharSequence nationalNonNormalizedNumber, PhoneMetadata defaultRegionMetadata,
            StringBuilder nationalNumber, boolean keepRawInput,
            PhoneNumber phNumber){
        if (nationalNonNormalizedNumber.length() == 0) {
            return 0;
        }
        StringBuilder fullNumber = new StringBuilder(nationalNonNormalizedNumber.toString());
// Set the default prefix to be something that will never match.
        String possibleCountryIddPrefix = 'NonMatch';
        if (defaultRegionMetadata != null) {
            possibleCountryIddPrefix = defaultRegionMetadata.internationalPrefix;
        }

        PhoneNumber.CountryCodeSources countryCodeSource =
                maybeStripInternationalPrefixAndNormalize(fullNumber, possibleCountryIddPrefix);
        if (keepRawInput) {
            phNumber.countryCodeSource = countryCodeSource;
        }
        if (countryCodeSource != PhoneNumber.CountryCodeSources.FROM_DEFAULT_COUNTRY) {
            if (fullNumber.length() <= MIN_LENGTH_FOR_NSN) {
                throw new NumberParseException(NumberParseException.ErrorType.TOO_SHORT_AFTER_IDD,
                        'Phone number had an IDD, but after this was not '
                                + 'long enough to be a viable phone number.');
            }
            Integer potentialCountryCode = extractCountryCode(fullNumber, nationalNumber);
            if (potentialCountryCode != 0) {
                phNumber.countryCode = potentialCountryCode;
                return potentialCountryCode;
            }

// If this fails, they must be using a strange country calling code that we don't recognize,
// or that doesn't exist.
            throw new NumberParseException(NumberParseException.ErrorType.INVALID_COUNTRY_CODE,
                    'Country calling code supplied was not recognised.');
        } else if (defaultRegionMetadata != null) {
// Check to see if the number starts with the country calling code for the default region. If
// so, we remove the country calling code, and do some checks on the validity of the number
// before and after.
            Integer defaultCountryCode = defaultRegionMetadata.countryCode;
            String defaultCountryCodeString = String.valueOf(defaultCountryCode);
            String normalizedNumber = fullNumber.toString();
            if (normalizedNumber.startsWith(defaultCountryCodeString)) {
                StringBuilder potentialNationalNumber =
                        new StringBuilder(normalizedNumber.substring(defaultCountryCodeString.length()));
                PhoneMetadata.PhoneNumberDesc generalDesc = defaultRegionMetadata.generalDesc;
                maybeStripNationalPrefixAndCarrierCode(
                        potentialNationalNumber, defaultRegionMetadata, null /* Don't need the carrier code */);
// If the number was not valid before but is valid now, or if it was too long before, we
// consider the number with the country calling code stripped to be a better result and
// keep that instead.
                if ((!matcherApiInstance.matchNationalNumber(normalizedNumber, generalDesc, false)
                        && matcherApiInstance.matchNationalNumber(potentialNationalNumber.toString(), generalDesc, false))
                        || testNumberLength(normalizedNumber, defaultRegionMetadata) == PhoneNumberUtil.ValidationResult.TOO_LONG) {
                    nationalNumber.append(potentialNationalNumber.toString());
                    if (keepRawInput) {
                        phNumber.countryCodeSource = PhoneNumber.CountryCodeSources.FROM_NUMBER_WITHOUT_PLUS_SIGN;
                    }
                    phNumber.countryCode = defaultCountryCode;
                    return defaultCountryCode;
                }
            }
        }
// No country calling code present.
        phNumber.countryCode = 0;
        return 0;
    }

 /**
 * Strips any international prefix (such as +, 00, 011) present in the number provided, normalizes
 * the resulting number, and indicates if an international prefix was present.
 *
 * @param number  the non-normalized telephone number that we wish to strip any international
 *     dialing prefix from
 * @param possibleIddPrefix  the international direct dialing prefix from the region we
 *     think this number may be dialed in
 * @return  the corresponding CountryCodeSource if an international dialing prefix could be
 *     removed from the number, otherwise CountryCodeSource.FROM_DEFAULT_COUNTRY if the number did
 *     not seem to be in international format
 */
    // @VisibleForTesting
    PhoneNumber.CountryCodeSources maybeStripInternationalPrefixAndNormalize(
            StringBuilder phNumber,
            String possibleIddPrefix) {
        if (phNumber.length() == 0) {
            return Phonenumber.CountryCodeSources.FROM_DEFAULT_COUNTRY;
        }
        // Check to see if the number begins with one or more plus signs.
        Matcher m = PLUS_CHARS_PATTERN.matcher(phNumber.toString());
        if (m.lookingAt()) {
            phNumber.right(m.end());
            // Can now normalize the rest of the number since we've consumed the "+" sign at the start.
            normalize(phNumber);
            return PhoneNumber.CountryCodeSources.FROM_NUMBER_WITH_PLUS_SIGN;
        }
        // Attempt to parse the first digits as an international prefix.
        //Pattern iddPattern = regexCache.getPatternForRegex(possibleIddPrefix);
        Pattern iddPattern = Pattern.compile(possibleIddPrefix);
        normalize(phNumber);
        return parsePrefixAsIdd(iddPattern, phNumber)
                ? PhoneNumber.CountryCodeSources.FROM_NUMBER_WITH_IDD
                : PhoneNumber.CountryCodeSources.FROM_DEFAULT_COUNTRY;
    }

    /**
    * Strips the IDD from the start of the number if present. Helper function used by
    * maybeStripInternationalPrefixAndNormalize.
    */
    private boolean parsePrefixAsIdd(Pattern iddPattern, StringBuilder phNumber) {
        Matcher m = iddPattern.matcher(phNumber.toString());
        if (m.lookingAt()) {
            Integer matchEnd = m.end();
            // Only strip this if the first digit after the match is not a 0, since country calling codes
            // cannot begin with 0.
            Matcher digitMatcher = CAPTURING_DIGIT_PATTERN.matcher(phNumber.toString().right(matchEnd));
            if (digitMatcher.find()) {
                String normalizedGroup = normalizeDigitsOnly(new StringBuilder(digitMatcher.group(1)));
                if (normalizedGroup.equals('0')) {
                    return false;
                }
            }
            phNumber.right(matchEnd);
            return true;
        }
        return false;
    }

    /**
 * Normalizes a string of characters representing a phone number. This performs the following
 * conversions:
 *   - Punctuation is stripped.
 *   For ALPHA/VANITY numbers:
 *   - Letters are converted to their numeric representation on a telephone keypad. The keypad
 *     used here is the one defined in ITU Recommendation E.161. This is only done if there are 3
 *     or more letters in the number, to lessen the risk that such letters are typos.
 *   For other numbers:
 *   - Wide-ascii digits are converted to normal ASCII (European) digits.
 *   - Arabic-Indic numerals are converted to European numerals.
 *   - Spurious alpha characters are stripped.
 *
 * @param number  a StringBuilder of characters representing a phone number that will be
 *     normalized in place
 */
    static StringBuilder normalize(StringBuilder phNumber) {
        Matcher m = VALID_ALPHA_PHONE_PATTERN.matcher(phNumber.toString());
        if (m.matches()) {
            phNumber.replace(normalizeHelper(phNumber, ALPHA_PHONE_MAPPINGS, true));
        } else {
            phNumber.replace(normalizeDigitsOnly(phNumber));
        }
        return phNumber;
    }

    /**
   * Normalizes a string of characters representing a phone number by replacing all characters found
   * in the accompanying map with the values therein, and stripping all other characters if
   * removeNonMatches is true.
   *
   * @param number  a string of characters representing a phone number
   * @param normalizationReplacements  a mapping of characters to what they should be replaced by in
   *     the normalized version of the phone number
   * @param removeNonMatches  indicates whether characters that are not able to be replaced should
   *     be stripped from the number. If this is false, they will be left unchanged in the number.
   * @return  the normalized string version of the phone number
   */
    private static String normalizeHelper(CharSequence phNumber,
            Map<String, String> normalizationReplacements,
            boolean removeNonMatches) {
        StringBuilder normalizedNumber = new StringBuilder();
        for (Integer i = 0; i < phNumber.length(); i++) {
            String character = phNumber.charAt(i);
            String newDigit = normalizationReplacements.get(character.toUpperCase());
            if (newDigit != null) {
                normalizedNumber.append(newDigit);
            } else if (!removeNonMatches) {
                normalizedNumber.append(character);
            }
// If neither of the above are true, we remove this character.
        }
        return normalizedNumber.toString();
    }

    /**
 * Normalizes a string of characters representing a phone number. This converts wide-ascii and
 * arabic-indic numerals to European numerals, and strips punctuation and alpha characters.
 *
 * @param number  a string of characters representing a phone number
 * @return  the normalized string version of the phone number
 */
    public static String normalizeDigitsOnly(CharSequence phNumber) {
        return normalizeDigits(phNumber, false /* strip non-digits */).toString();
    }

    static StringBuilder normalizeDigits(CharSequence phNumber, boolean keepNonDigits) {
        StringBuilder normalizedDigits = new StringBuilder();
        for (Integer i = 0; i < phNumber.length(); i++) {
            String c = phNumber.charAt(i);
            String digit = DIGITS_MAPPINGS.get(c);
            if (digit != null) {
                normalizedDigits.append(digit);
            } else if (keepNonDigits) {
                normalizedDigits.append(c);
            }
        }
        return normalizedDigits;
    }


    // Extracts country calling code from fullNumber, returns it and places the remaining number in
    // nationalNumber. It assumes that the leading plus sign or IDD has already been removed. Returns
    // 0 if fullNumber doesn't start with a valid country calling code, and leaves nationalNumber
    // unmodified.
    Integer extractCountryCode(StringBuilder fullNumber, StringBuilder nationalNumber) {
        if ((fullNumber.length() == 0) || (fullNumber.charAt(0) == '0')) {
            // Country codes do not begin with a '0'.
            return 0;
        }
        Integer potentialCountryCode;
        Integer numberLength = fullNumber.length();
        for (Integer i = 1; i <= MAX_LENGTH_COUNTRY_CODE && i <= numberLength; i++) {
            potentialCountryCode = Integer.valueOf(fullNumber.toString().substring(0, i));
            if (countryCallingCodeToRegionCodeMap.containsKey(potentialCountryCode)) {
                nationalNumber.append(fullNumber.toString().substring(i));
                return potentialCountryCode;
            }
        }
        return 0;
    }

    /**
    * Returns the region code that matches the specific country calling code. In the case of no
    * region code being found, ZZ will be returned. In the case of multiple regions, the one
    * designated in the metadata as the "main" region for this calling code will be returned. If the
    * countryCallingCode entered is valid but doesn't match a specific region (such as in the case of
    * non-geographical calling codes like 800) the value "001" will be returned (corresponding to
    * the value for World in the UN M.49 schema).
    */
    public String getRegionCodeForCountryCode(Integer countryCallingCode) {
        List<String> regionCodes = countryCallingCodeToRegionCodeMap.get(countryCallingCode);
        return regionCodes == null ? UNKNOWN_REGION : regionCodes.get(0);
    }

    /**
    * Strips any national prefix (such as 0, 1) present in the number provided.
    *
    * @param number  the normalized telephone number that we wish to strip any national
    *     dialing prefix from
    * @param metadata  the metadata for the region that we think this number is from
    * @param carrierCode  a place to insert the carrier code if one is extracted
    * @return true if a national prefix or carrier code (or both) could be extracted
    */
    // @VisibleForTesting
    boolean maybeStripNationalPrefixAndCarrierCode(
            StringBuilder phNumber, PhoneMetadata metadata, StringBuilder carrierCode) {
        Integer numberLength = phNumber.length();
        String possibleNationalPrefix = metadata.nationalPrefixForParsing;
        if (numberLength == 0 || possibleNationalPrefix == null) {
            // Early return for numbers of zero length.
            return false;
        }
        // Attempt to parse the first digits as a national prefix.
        Matcher prefixMatcher = regexCacheInstance.getPatternForRegex(possibleNationalPrefix).matcher(phNumber.toString());
        if (prefixMatcher.lookingAt()) {
            PhoneMetadata.PhoneNumberDesc generalDesc = metadata.generalDesc;
            // Check if the original number is viable.
            Boolean isViableOriginalNumber = matcherApiInstance.matchNationalNumber(phNumber.toString(), generalDesc, false);
            // prefixMatcher.group(numOfGroups) == null implies nothing was captured by the capturing
            // groups in possibleNationalPrefix; therefore, no transformation is necessary, and we just
            // remove the national prefix.
            Integer numOfGroups = prefixMatcher.groupCount();
            String transformRule = metadata.nationalPrefixTransformRule;
            if (transformRule == null || transformRule.length() == 0
                    || prefixMatcher.group(numOfGroups) == null) {
                // If the original number was viable, and the resultant number is not, we return.
                if (isViableOriginalNumber
                        && !matcherApiInstance.matchNationalNumber(
                        phNumber.toString().substring(prefixMatcher.end()), generalDesc, false)) {
                    return false;
                }
                if (carrierCode != null && numOfGroups > 0 && prefixMatcher.group(numOfGroups) != null) {
                    carrierCode.append(prefixMatcher.group(1));
                }
                phNumber.right(prefixMatcher.end());
                return true;
            } else {
// Check that the resultant number is still viable. If not, return. Check this by copying
// the string buffer and making the transformation on the copy first.
                /* FISHY CODE BLOCK
                StringBuilder transformedNumber = new StringBuilder(phNumber.toString());
                transformedNumber.replace(0, numberLength, prefixMatcher.replaceFirst(transformRule));
                if (isViableOriginalNumber
                        && !matcherApiInstance.matchNationalNumber(transformedNumber.toString(), generalDesc, false)) {
                    return false;
                }
                if (carrierCode != null && numOfGroups > 1) {
                    carrierCode.append(prefixMatcher.group(1));
                }
                phNumber.replace(0, phNumber.length(), transformedNumber.toString());
                return true;
                */

                String transformedNumber = prefixMatcher.replaceFirst(transformRule);
                if (isViableOriginalNumber
                        && !matcherApiInstance.matchNationalNumber(transformedNumber, generalDesc, false)) {
                    return false;
                }
                if (carrierCode != null && numOfGroups > 1) {
                    carrierCode.append(prefixMatcher.group(1));
                }
                phNumber.replace(transformedNumber);
                return true;
            }
        }
        return false;
    }

    /**
    * Attempts to extract a possible number from the string passed in. This currently strips all
    * leading characters that cannot be used to start a phone number. Characters that can be used to
    * start a phone number are defined in the VALID_START_CHAR_PATTERN. If none of these characters
    * are found in the number passed in, an empty string is returned. This function also attempts to
    * strip off any alternative extensions or endings if two or more are present, such as in the case
    * of: (530) 583-6985 x302/x2303. The second extension here makes this actually two phone numbers,
    * (530) 583-6985 x302 and (530) 583-6985 x2303. We remove the second extension so that the first
    * number is parsed correctly.
    *
    * @param phNumber  the string that might contain a phone number
    * @return  the number, stripped of any non-phone-number prefix (such as "Tel:") or an empty
    *     string if no character used to start phone numbers (such as + or any digit) is found in the
    *     number
    *!!!!!!!CharSequence was replaced to String as input and output!!!!!!!
    */
    static String extractPossibleNumber(String phNumber) {
        Matcher m = VALID_START_CHAR_PATTERN.matcher(phNumber);
        if (m.find()) {
            phNumber = phNumber.substring(m.start(), phNumber.length());
            // Remove trailing non-alpha non-numerical characters.
            Matcher trailingCharsMatcher = UNWANTED_END_CHAR_PATTERN.matcher(phNumber);
            if (trailingCharsMatcher.find()) {
                phNumber = phNumber.substring(0, trailingCharsMatcher.start());
            }
            // Check for extra phNumbers at the end.
            Matcher secondNumber = SECOND_NUMBER_START_PATTERN.matcher(phNumber);
            if (secondNumber.find()) {
                phNumber = phNumber.substring(0, secondNumber.start());
            }
            return phNumber;
        } else {
            return '';
        }
    }

    /**
    * Helper method to check a number against possible lengths for this region, based on the metadata
    * being passed in, and determine whether it matches, or is too short or too long.
    */
    private ValidationResult testNumberLength(String phNumber, PhoneMetadata metadata) {
        return testNumberLength(phNumber, metadata, PhoneNumberType.UNKNOWN);
    }

    /**
     * Helper method to check a number against possible lengths for this number type, and determine
     * whether it matches, or is too short or too long.
     */
    private ValidationResult testNumberLength(
            String phNumber, PhoneMetadata metadata, PhoneNumberType phType) {
        PhoneMetadata.PhoneNumberDesc descForType = getNumberDescByType(metadata, phType);
        // There should always be "possibleLengths" set for every element. This is declared in the XML
        // schema which is verified by PhoneNumberMetadataSchemaTest.
        // For size efficiency, where a sub-description (e.g. fixed-line) has the same possibleLengths
        // as the parent, this is missing, so we fall back to the general desc (where no numbers of the
        // type exist at all, there is one possible length (-1) which is guaranteed not to match the
        // length of any real phone number).
        List<Integer> possibleLengths = descForType.possibleLength == null
                ? metadata.generalDesc.possibleLength : descForType.possibleLength;
         List<Integer> localLengths = descForType.possibleLengthLocalOnly;

        if (phType == PhoneNumberType.FIXED_LINE_OR_MOBILE) {
            PhoneMetadata.PhoneNumberDesc fixedLineDesc = getNumberDescByType(metadata, PhoneNumberType.FIXED_LINE);
            if (fixedLineDesc.possibleLength == null || fixedLineDesc.possibleLength.size() == 0) {
            //if (!descHasPossibleNumberData(getNumberDescByType(metadata, PhoneNumberType.FIXED_LINE))) {
                // The rare case has been encountered where no fixedLine data is available (true for some
                // non-geographical entities), so we just check mobile.
                return testNumberLength(phNumber, metadata, PhoneNumberType.MOBILE);
            } else {
                PhoneMetadata.PhoneNumberDesc mobileDesc = getNumberDescByType(metadata, PhoneNumberType.MOBILE);
                if (mobileDesc.possibleLength != null && mobileDesc.possibleLength.size() > 0) {
                    // Merge the mobile data in if there was any. We have to make a copy to do this.
                    possibleLengths = new List<Integer>(possibleLengths);
                    // Note that when adding the possible lengths from mobile, we have to again check they
                    // aren't empty since if they are this indicates they are the same as the general desc and
                    // should be obtained from there.
                    possibleLengths.addAll(mobileDesc.possibleLength.size() == 0
                            ? metadata.generalDesc.possibleLength
                            : mobileDesc.possibleLength);
                    // The current list is sorted; we need to merge in the new list and re-sort (duplicates
                    // are okay). Sorting isn't so expensive because the lists are very small.
                    possibleLengths.sort();

                    if (localLengths.isEmpty()) {
                        localLengths = mobileDesc.possibleLengthLocalOnly;
                    } else {
                        localLengths = new List<Integer>(localLengths);
                        localLengths.addAll(mobileDesc.possibleLengthLocalOnly);
                        localLengths.sort();
                    }
                }
            }
        }

        // If the type is not supported at all (indicated by the possible lengths list is empty at this
        // point) we return invalid length.
        if (possibleLengths == null) {
            return ValidationResult.INVALID_LENGTH;
        }

        Integer actualLength = phNumber.length();
        // This is safe because there is never an overlap beween the possible lengths and the local-only
        // lengths; this is checked at build time.
        if (localLengths.contains(actualLength)) {
            return ValidationResult.IS_POSSIBLE_LOCAL_ONLY;
        }

        Integer minimumLength = possibleLengths.get(0);
        if (minimumLength == actualLength) {
            return ValidationResult.IS_POSSIBLE;
        } else if (minimumLength > actualLength) {
            return ValidationResult.TOO_SHORT;
        } else if (possibleLengths.get(possibleLengths.size() - 1) < actualLength) {
            return ValidationResult.TOO_LONG;
        }
        // We skip the first element; we've already checked it.
        //return possibleLengths.subList(1, possibleLengths.size()).contains(actualLength)
        return possibleLengths.contains(actualLength) && possibleLengths[0] != actualLength
                ? ValidationResult.IS_POSSIBLE : ValidationResult.INVALID_LENGTH;
    }

    PhoneMetadata.PhoneNumberDesc getNumberDescByType(PhoneMetadata metadata, PhoneNumberType phType) {
        switch on pHType {
            when PREMIUM_RATE {
                return metadata.premiumRate;
            }
            when TOLL_FREE {
                return metadata.tollFree;
            }
            when MOBILE {
                return metadata.mobile;
            }
            when FIXED_LINE, FIXED_LINE_OR_MOBILE {
                return metadata.fixedLine;
            }
            when SHARED_COST {
                return metadata.sharedCost;
            }
            when VOIP {
                return metadata.voip;
            }
            when PERSONAL_NUMBER {
                return metadata.personalNumber;
            }
            when PAGER {
                return metadata.pager;
            }
            when UAN {
                return metadata.uan;
            }
            when VOICEMAIL {
                return metadata.voicemail;
            }
            when else {
                return metadata.generalDesc;
            }
        }
    }

    /**
    * A helper function to set the values related to leading zeros in a PhoneNumber.
    */
    static void setItalianLeadingZerosForPhoneNumber(CharSequence nationalNumber,
            PhoneNumber phoneNumber) {
        if (nationalNumber.length() > 1 && nationalNumber.charAt(0) == '0') {
            phoneNumber.italianLeadingZero = true;
            Integer numberOfLeadingZeros = 1;
            // Note that if the national number is all "0"s, the last "0" is not counted as a leading
            // zero.
            while (numberOfLeadingZeros < nationalNumber.length() - 1
                    && nationalNumber.charAt(numberOfLeadingZeros) == '0') {
                numberOfLeadingZeros++;
            }
            if (numberOfLeadingZeros != 1) {
                phoneNumber.numberOfLeadingZeros = numberOfLeadingZeros;
            }
        }
    }

    private PhoneMetadata getMetadataForRegionOrCallingCode(
            Integer countryCallingCode, String regionCode) {
        return REGION_CODE_FOR_NON_GEO_ENTITY.equals(regionCode)
                ? getMetadataForNonGeographicalRegion(countryCallingCode)
                : getMetadataForRegion(regionCode);
    }

    /**
    * Returns the metadata for the given region code or {@code null} if the region code is invalid
    * or unknown.
    */
    PhoneMetadata getMetadataForRegion(String regionCode) {
        if (!isValidRegionCode(regionCode)) {
            return null;
        }
        return phoneMetadataByRegion.get(regionCode);
    }

    PhoneMetadata getMetadataForNonGeographicalRegion(Integer countryCallingCode) {
        if (!countryCallingCodeToRegionCodeMap.containsKey(countryCallingCode)) {
            return null;
        }
        //return metadataSource.getMetadataForNonGeographicalRegion(countryCallingCode);
        throw new NumberParseException(NumberParseException.ErrorType.NOT_A_NUMBER,
                'ALTERNATE FORMATS ARE NOT IMPLEMENTED YET');

    }

    /**
    * Tests whether a phone number matches a valid pattern. Note this doesn't verify the number
    * is actually in use, which is impossible to tell by just looking at a number itself. It only
    * verifies whether the parsed, canonicalised number is valid: not whether a particular series of
    * digits entered by the user is diallable from the region provided when parsing. For example, the
    * number +41 (0) 78 927 2696 can be parsed into a number with country code "41" and national
    * significant number "789272696". This is valid, while the original string is not diallable.
    *
    * @param number  the phone number that we want to validate
    * @return  a boolean that indicates whether the number is of a valid pattern
    */
    public Boolean isValidNumber(PhoneNumber phNumber) {
        String regionCode = getRegionCodeForNumber(phNumber);
        return isValidNumberForRegion(phNumber, regionCode);
    }

    /**
    * Returns the region where a phone number is from. This could be used for geocoding at the region
    * level. Only guarantees correct results for valid, full numbers (not short-codes, or invalid
    * numbers).
    *
    * @param number  the phone number whose origin we want to know
    * @return  the region where the phone number is from, or null if no region matches this calling
    *     code
    */
    public String getRegionCodeForNumber(PhoneNumber phNumber) {
        Integer countryCode = phNumber.countryCode;
        List<String> regions = countryCallingCodeToRegionCodeMap.get(countryCode);
        if (regions == null) {
            System.debug('Missing/invalid country_code (' + countryCode + ')');
            return null;
        }
        if (regions.size() == 1) {
            return regions.get(0);
        } else {
            return getRegionCodeForNumberFromRegionList(phNumber, regions);
        }
    }

    private String getRegionCodeForNumberFromRegionList(PhoneNumber phNumber, List<String> regionCodes) {
        String nationalNumber = getNationalSignificantNumber(phNumber);
        for (String regionCode : regionCodes) {
            // If leadingDigits is present, use this. Otherwise, do full validation.
            // Metadata cannot be null because the region codes come from the country calling code map.
            PhoneMetadata metadata = getMetadataForRegion(regionCode);
            if (metadata.leadingDigits != null) {
                if (regexCacheInstance.getPatternForRegex(metadata.leadingDigits)
                        .matcher(nationalNumber).lookingAt()) {
                    return regionCode;
                }
            } else if (getNumberTypeHelper(nationalNumber, metadata) != PhoneNumberType.UNKNOWN) {
                return regionCode;
            }
        }
        return null;
    }

    /**
    * Tests whether a phone number is valid for a certain region. Note this doesn't verify the number
    * is actually in use, which is impossible to tell by just looking at a number itself. If the
    * country calling code is not the same as the country calling code for the region, this
    * immediately exits with false. After this, the specific number pattern rules for the region are
    * examined. This is useful for determining for example whether a particular number is valid for
    * Canada, rather than just a valid NANPA number.
    * Warning: In most cases, you want to use {@link #isValidNumber} instead. For example, this
    * method will mark numbers from British Crown dependencies such as the Isle of Man as invalid for
    * the region "GB" (United Kingdom), since it has its own region code, "IM", which may be
    * undesirable.
    *
    * @param number  the phone number that we want to validate
    * @param regionCode  the region that we want to validate the phone number for
    * @return  a boolean that indicates whether the number is of a valid pattern
    */
    public boolean isValidNumberForRegion(PhoneNumber phNumber, String regionCode) {
        Integer countryCode = phNumber.countryCode;
        PhoneMetadata metadata = getMetadataForRegionOrCallingCode(countryCode, regionCode);
        if ((metadata == null)
                || (!REGION_CODE_FOR_NON_GEO_ENTITY.equals(regionCode)
                && countryCode != getCountryCodeForValidRegion(regionCode))) {
            // Either the region code was invalid, or the country calling code for this number does not
            // match that of the region code.
            return false;
        }
        String nationalSignificantNumber = getNationalSignificantNumber(phNumber);
        return getNumberTypeHelper(nationalSignificantNumber, metadata) != PhoneNumberType.UNKNOWN;
    }

    /**
    * Returns the country calling code for a specific region. For example, this would be 1 for the
    * United States, and 64 for New Zealand. Assumes the region is already valid.
    *
    * @param regionCode  the region that we want to get the country calling code for
    * @return  the country calling code for the region denoted by regionCode
    * @throws IllegalArgumentException if the region is invalid
    */
    private Integer getCountryCodeForValidRegion(String regionCode) {
        PhoneMetadata metadata = getMetadataForRegion(regionCode);
        if (metadata == null) {
            throw new NumberParseException('Invalid region code: ' + regionCode);
        }
        return metadata.countryCode;
    }

    /**
    * Gets the national significant number of a phone number. Note a national significant number
    * doesn't contain a national prefix or any formatting.
    *
    * @param number  the phone number for which the national significant number is needed
    * @return  the national significant number of the PhoneNumber object passed in
    */
    public String getNationalSignificantNumber(PhoneNumber phNumber) {
        // If leading zero(s) have been set, we prefix this now. Note this is not a national prefix.
        String nationalNumber = '';
        if (phNumber.italianLeadingZero && phNumber.numberOfLeadingZeros > 0) {
            nationalNumber = '0'.repeat(phNumber.numberOfLeadingZeros);
        }
        nationalNumber += String.valueOf(phNumber.nationalNumber);
        return nationalNumber;
    }

    private PhoneNumberType getNumberTypeHelper(String nationalNumber, PhoneMetadata metadata) {
        if (!isNumberMatchingDesc(nationalNumber, metadata.generalDesc)) {
            return PhoneNumberType.UNKNOWN;
        }

        if (isNumberMatchingDesc(nationalNumber, metadata.premiumRate)) {
            return PhoneNumberType.PREMIUM_RATE;
        }
        if (isNumberMatchingDesc(nationalNumber, metadata.tollFree)) {
            return PhoneNumberType.TOLL_FREE;
        }
        if (isNumberMatchingDesc(nationalNumber, metadata.sharedCost)) {
            return PhoneNumberType.SHARED_COST;
        }
        if (isNumberMatchingDesc(nationalNumber, metadata.voip)) {
            return PhoneNumberType.VOIP;
        }
        if (isNumberMatchingDesc(nationalNumber, metadata.personalNumber)) {
            return PhoneNumberType.PERSONAL_NUMBER;
        }
        if (isNumberMatchingDesc(nationalNumber, metadata.pager)) {
            return PhoneNumberType.PAGER;
        }
        if (isNumberMatchingDesc(nationalNumber, metadata.uan)) {
            return PhoneNumberType.UAN;
        }
        if (isNumberMatchingDesc(nationalNumber, metadata.voicemail)) {
            return PhoneNumberType.VOICEMAIL;
        }

        boolean isFixedLine = isNumberMatchingDesc(nationalNumber, metadata.fixedLine);
        if (isFixedLine) {
            if (metadata.sameMobileAndFixedLinePattern) {
                return PhoneNumberType.FIXED_LINE_OR_MOBILE;
            } else if (isNumberMatchingDesc(nationalNumber, metadata.mobile)) {
                return PhoneNumberType.FIXED_LINE_OR_MOBILE;
            }
            return PhoneNumberType.FIXED_LINE;
        }
        // Otherwise, test to see if the number is mobile. Only do this if certain that the patterns for
        // mobile and fixed line aren't the same.
        if (!metadata.sameMobileAndFixedLinePattern
                && isNumberMatchingDesc(nationalNumber, metadata.mobile)) {
            return PhoneNumberType.MOBILE;
        }
        return PhoneNumberType.UNKNOWN;
    }

    Boolean isNumberMatchingDesc(String nationalNumber, PhoneMetadata.PhoneNumberDesc numberDesc) {
        // Check if any possible number lengths are present; if so, we use them to avoid checking the
        // validation pattern if they don't match. If they are absent, this means they match the general
        // description, which we have already checked before checking a specific number type.
        if (numberDesc == null) {
            return false;
        }
        Integer actualLength = nationalNumber.length();
        List<Integer> possibleLengths = numberDesc.possibleLength;
        if (possibleLengths != null && !possibleLengths.contains(actualLength)) {
            return false;
        }
        return matcherApiInstance.matchNationalNumber(nationalNumber, numberDesc, false);
    }

    /**
    * NOT THE PART OF OFFICIAL PHONE LIBRARY!!!
    * returns string representation of Phone Number Type if this type is FIXED_LINE_OR_MOBILE or MOBILE.
    *
    * @param number  the phone number to find out the type of
    * @return  a string representation of Phone Number Type if this type is FIXED_LINE_OR_MOBILE or MOBILE
    */
    public String getNumberType(PhoneNumber phNumber) {
        String regionCode = getRegionCodeForNumber(phNumber);
        Integer countryCode = phNumber.countryCode;
        PhoneMetadata metadata = getMetadataForRegionOrCallingCode(countryCode, regionCode);
        if ((metadata == null)
                || (!REGION_CODE_FOR_NON_GEO_ENTITY.equals(regionCode)
                && countryCode != getCountryCodeForValidRegion(regionCode))) {
            // Either the region code was invalid, or the country calling code for this number does not
            // match that of the region code.
            return '';
        }
        String nationalSignificantNumber = getNationalSignificantNumber(phNumber);
        PhoneNumberType foundType = getNumberTypeHelper(nationalSignificantNumber, metadata);
        return PHONE_TYPES_MAPPINGS.get(foundType);
    }
}