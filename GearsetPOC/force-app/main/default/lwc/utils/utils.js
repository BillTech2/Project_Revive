import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ERROR from '@salesforce/label/c.cu_ErrorTitle';
import WARNING from '@salesforce/label/c.cu_WarningTitle';
import SUCCESS from '@salesforce/label/c.cu_SuccessTitle';

export default class Utils {
    static handleError(component, error){
        window.console.log('error', error);
        let errorMessage = error.message;
        if (error.body && error.body.enhancedErrorType && error.body.enhancedErrorType.toLowerCase() === 'recorderror') {
            if(error.body.output.errors[0]){
                errorMessage = error.body.output.errors[0].message;
            }else{
                const fieldErrors = error.body.output.fieldErrors;
                const fieldError = Object.values(fieldErrors)[0];
                const fieldErrorMessage = Object.values(fieldError)[0].message;
                errorMessage = fieldErrorMessage;
            }
        } else if (!errorMessage) {
            if (error.body) {
                errorMessage = error.body.message;

                if (!errorMessage && error.body.pageErrors && error.body.pageErrors.length) {
                    errorMessage = error.body.pageErrors[0].message;
                }
            }
        }

        if (!errorMessage) {
            errorMessage = error;
        }

        const evt = new ShowToastEvent({
            title: ERROR,
            message: errorMessage,
            variant: 'error'
        });
        component.dispatchEvent(evt);
    };

    static handleWarning(component, warningMessage) {
        const evt = new ShowToastEvent({
            title: WARNING,
            message: warningMessage,
            variant: 'warning'
        });
        component.dispatchEvent(evt);
    };

    static handleSuccess(component, successMessage) {
        const evt = new ShowToastEvent({
            title: SUCCESS,
            message: successMessage,
            variant: 'success'
        });
        component.dispatchEvent(evt);
    };
}