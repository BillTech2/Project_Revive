import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import assignCurrentUser from '@salesforce/apex/TradeSalesAccountAssignButtonController.assignCurrentUser';
export default class TradeSalesAccountAssignButton extends LightningElement {
    @api recordId;
    @api invoke(){
        assignCurrentUser({ recordId: this.recordId})
            .then(() => {
                getRecordNotifyChange([{recordId: this.recordId}]);
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