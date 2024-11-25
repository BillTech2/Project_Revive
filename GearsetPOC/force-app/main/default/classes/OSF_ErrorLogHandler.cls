/*************************************************************************************
 * @Name         : OSF_ErrorLogHandler.cls
 * @Description  : Methods for Error Handling
 * @Created By   : Ugurcan Erkal
 * @Created Date : Sept 16, 2021
 * @Modification Log:
 **************************************************************************************
 * Version     Developer      Date        Description
 *-------------------------------------------------------------------------------------
 *
 *************************************************************************************/
public class OSF_ErrorLogHandler{
    public static final String CUSTOM_EXCEPTION = 'Custom Exception';
    public static Boolean asyncSave = false;
    public static List<OSF_Error_Log__c> errors = new List<OSF_Error_Log__c>();
    /*********************************************************************************
     * @Name         : logError
     * @Description  : Log exception to OSF_Error_Log__c custom object
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param Database.Error[]
     *********************************************************************************/
    public static void logError(Database.Error[] errorsDB) {
        if(!errorsDB.isEmpty()) {
            for(Database.Error errorDB : errorsDB) {
                OSF_Error_Log__c currentLog = new OSF_Error_Log__c(
                    Error_Log_Type__c = CUSTOM_EXCEPTION,
                    Error_Message__c = (errorDB.getStatusCode() + '' + errorDB.getMessage())
                );

                System.debug(currentLog);
                errors.add(currentLog);
            }
        }
    }

    /*********************************************************************************
     * @Name         : logError
     * @Description  : Log exception to OSF_Error_Log__c custom object
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param Exception
     *********************************************************************************/
    public static void logError(Exception error, String className) {
        OSF_Error_Log__c currentLog = new OSF_Error_Log__c(
            Error_Log_Type__c = error.getTypeName(),
            Error_Message__c = error.getMessage(),
            Line_Number__c = error.getLineNumber(),
            Class_Name__c = className,
            Stack_Trace__c = error.getStackTraceString()
        );

        System.debug(currentLog);
        errors.add(currentLog);
    }

    /*********************************************************************************
     * @Name         : logError
     * @Description  : Log exception to OSF_Error_Log__c custom object
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param String
     * @Param String
     *********************************************************************************/
    public static void logError(String errorMessage, String apexClassName){
        OSF_Error_Log__c currentLog = new OSF_Error_Log__c(Error_Log_Type__c = CUSTOM_EXCEPTION, Error_Message__c = errorMessage, Stack_Trace__c = apexClassName);

        System.debug(currentLog);
        errors.add(currentLog);
    }

    /*********************************************************************************
     * @Name         : logError
     * @Description  : Log exception to OSF_Error_Log__c custom object
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param HTTPResponse
     * @Param String
     *********************************************************************************/
    public static void logError(HTTPResponse response, String errorLocation){
        String message = errorLocation + ' callout status code: ' + String.ValueOf(response.getStatusCode())+' ' + response.getStatus()+' ' + response.getBody();
        OSF_Error_Log__c currentLog = new OSF_Error_Log__c(Error_Log_Type__c = CUSTOM_EXCEPTION, Error_Message__c = message);
        System.debug(message);
        errors.add(currentLog);
    }

    /*********************************************************************************
     * @Name         : saveErrors
     * @Description  : Save all OSF_Error_Log__c records
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     *********************************************************************************/
    public static void saveErrors(){
        if (!asyncSave && errors != null && errors.size() > 0){
            try{
                insert errors;
                errors = new List<OSF_Error_Log__c>();
            } catch (DmlException currentException){
                System.debug(currentException);
            }
        }
    }

    /*********************************************************************************
     * @Name         : saveCurrentLog
     * @Description  : Save current OSF_Error_Log__c record
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param OSF_Error_Log__c
     *********************************************************************************/
    private static void saveCurrentLog(OSF_Error_Log__c currentLog){
        System.debug(currentLog);
        if (asyncSave){
            errors.add(currentLog);
        } else{
            try{
                insert currentLog;
            } catch (DmlException currentException){
                System.debug(currentException);
            }
        }
    }

    /*********************************************************************************
     * @Name         : saveError
     * @Description  : Create a new OSF_Error_Log__c and save it
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param Exception
     *********************************************************************************/
    public static String saveError(Exception error) {
        OSF_Error_Log__c currentLog = new OSF_Error_Log__c(
            Error_Log_Type__c = error.getTypeName(),
            Error_Message__c = error.getMessage(),
            Line_Number__c = error.getLineNumber(),
            Stack_Trace__c = error.getStackTraceString()
        );

        saveCurrentLog(currentLog);

        //Return the insertes log id in order to display it to the user. The ID can be used for communication later on.
        return currentLog.Id;
    }

    /*********************************************************************************
     * @Name         : saveError
     * @Description  : Create a new OSF_Error_Log__c and save it
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param String
     * @Param String
     *********************************************************************************/
    public static String saveError(String errorMessage, String apexClassName) {
        OSF_Error_Log__c currentLog = new OSF_Error_Log__c(
            Error_Log_Type__c = CUSTOM_EXCEPTION,
            Error_Message__c = errorMessage,
            Stack_Trace__c = apexClassName
        );

        saveCurrentLog(currentLog);

        //Return the insertes log id in order to display it to the user. The ID can be used for communication later on.
        return currentLog.Id;
    }

    /*********************************************************************************
     * @Name         : saveError
     * @Description  : Create a new OSF_Error_Log__c and save it
     * @Created By   : Ugurcan Erkal
     * @Created Date : Sept 16, 2021
     * @Param HTTPResponse
     * @Param String
     *********************************************************************************/
    public static String  saveError(HTTPResponse response, String errorLocation){
        String message = errorLocation + ' callout status code: ' + String.ValueOf(response.getStatusCode())+' ' + response.getStatus()+' ' + response.getBody();
        OSF_Error_Log__c currentLog = new OSF_Error_Log__c(Error_Log_Type__c = CUSTOM_EXCEPTION, Error_Message__c = message);

        saveCurrentLog(currentLog);

        return currentLog.Id;
    }
}