import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import assignToMainQueue from '@salesforce/apex/ContactCentreConsoleController.assignToMainQueue';
export default class AssignCaseToQueueButton extends LightningElement {
    @api recordId;
    isLoading = false;

    @api invoke(){
        this.isLoading = true;
        assignToMainQueue({ caseId: this.recordId})
            .then(result => {
                this.isLoading = false;
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => {
                this.isLoading = false;
                this.showNotification('Error', error.body.message, 'Error');
            });
    }

    showNotification(title, errorMessage, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: errorMessage,
            variant: variant,
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }
}