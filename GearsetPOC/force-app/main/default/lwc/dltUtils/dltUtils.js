import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { TOAST_VARIANT } from 'c/dltConstants';

/**
 * @param {string}  title   - title of the message
 * @param {string}  message - body of the message
 * @param {string}  variant - variant of the message
 */
export function showToastNotification(title, message, variant = TOAST_VARIANT.SUCCESS) {
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        })
    );
}

export function doRequest(action, params, spinnerStatus, showToast = true) {
    if (spinnerStatus) { spinnerStatus.isLoading = true; }

    return new Promise((resolve, reject) => {
        action(params)
            .then(result => {
                resolve(result);
            })
            .catch(errors => {
                logError(errors, showToast);
                reject(errors);
            })
            .finally(() => {
                if (spinnerStatus) { spinnerStatus.isLoading = false; }
            });
    });
}

/**
 * Reduces one or more LDS errors into an array or string of dot separated error messages.
 * @param {FetchResponse|FetchResponse[]} errors single error or errors[]
 * @param {Boolean} convertToString set true if you want to get a string or false if you prefer the array
 * @return {Array} reduced array of error messages
 * @return {String} dot separated error messages
 */
export function reduceErrors(errors, convertToString = true) {
    if (Array.isArray(errors) === false) {
        errors = [errors];
    }

    const reducedErrors = (
        errors
            // Remove null/undefined items
            .filter(error => !!error)
            // Extract an error message
            .map(error => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map(e => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .flat()
            // Remove empty strings
            .filter(message => !!message)
    );

    return convertToString ? reducedErrors.join('. ') : reducedErrors;
}

export function logError(errors, showToast = true) {
    const message = reduceErrors(errors);

    if (showToast) {
        showToastNotification('', message, TOAST_VARIANT.ERROR);
    }

    console.error(message);
}

export function reloadPage() {
    window.location.reload();
}