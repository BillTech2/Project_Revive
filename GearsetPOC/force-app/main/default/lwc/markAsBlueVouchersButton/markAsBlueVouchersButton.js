import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import markAsBlue from '@salesforce/apex/StaffAndDutyTravelRecordPageController.markAsBlue';
export default class MarkAsBlueVouchersButton extends LightningElement {
    @api recordId;
    @api invoke(){
        markAsBlue({ recordId: this.recordId})
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