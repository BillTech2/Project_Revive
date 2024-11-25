import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import assignCurrentCase from '@salesforce/apex/SendCSATEmailController.prepareSendCSATMessage';

export default class SendCSATemailButton extends LightningElement {
    @api recordId;

    @api invoke() {
        assignCurrentCase({ caseId: this.recordId })
            .then(response => {
                this.showNotification(Object.keys(response)[0], Object.values(response)[0], Object.keys(response)[0]);
            })
            .catch(error => {
                this.showNotification('Error:', error.body.message, 'error');
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