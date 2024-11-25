public class NumberParseException extends Exception {
    public enum ErrorType {
        // The country code supplied did not belong to a supported country or non-geographical entity.
        INVALID_COUNTRY_CODE,
        // This generally indicates the string passed in had less than 3 digits in it. More
        // specifically, the number failed to match the regular expression VALID_PHONE_NUMBER
        NOT_A_NUMBER,
        // This indicates the string started with an international dialing prefix, but after this was
        // stripped from the number, had less digits than any valid phone number (including country code) could have.
        TOO_SHORT_AFTER_IDD,
        // This indicates the string, after any country code has been stripped, had less digits than any
        // valid phone number could have.
        TOO_SHORT_NSN,
        // This indicates the string had more digits than any valid phone number could have.
        TOO_LONG
    }

    private ErrorType errorType;
    private String message;

    public NumberParseException(ErrorType errorType, String message) {
        //super(message);
        this.message = message;
        this.errorType = errorType;
    }

    public ErrorType getErrorType() {
        return errorType;
    }

    //public override String toString() {
    //    return 'Error type: ' + errorType + '. ' + message;
    //}
}