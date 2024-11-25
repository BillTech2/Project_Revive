import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import closeTravel from '@salesforce/apex/StaffAndDutyTravelRecordPageController.closeTravel';
export default class StaffAndDutyTravelCloseButton extends LightningElement {
    @api recordId;
    @api invoke(){
        closeTravel({ recordId: this.recordId})
            .then(() => {
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.showNotification('Success:' , 'The travel has been updated', 'success');
            })
            .catch((error) => {
                this.showNotification('Error:' , error.body.message, 'error');
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