/**
 * Internal phonenumber matching API used to isolate the underlying implementation of the
 * matcher and allow different implementations to be swapped in easily.
 */
public interface MatcherApi {
    /**
    * Returns whether the given national number (a string containing only decimal digits) matches
    * the national number pattern defined in the given {@code PhoneNumberDesc} message.
    */
    Boolean matchNationalNumber(String phNumber, PhoneMetadata.PhoneNumberDesc numberDesc,
            boolean allowPrefixMatch);
}