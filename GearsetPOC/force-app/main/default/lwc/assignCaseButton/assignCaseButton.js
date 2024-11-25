import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import assignCurrentCase from '@salesforce/apex/ContactCentreConsoleController.assignCurrentCase';
import assignRelatedCases from '@salesforce/apex/ContactCentreConsoleController.assignRelatedCases';
import getRelatedCases from '@salesforce/apex/ContactCentreConsoleController.getRelatedCases';
export default class AssignCaseButton extends LightningElement {
    @api recordId;
    @track isOpenedPopup = false;
    @track totalCases;

    @api invoke(){
        getRelatedCases({ caseId: this.recordId})
            .then(result => {
                this.totalCases = result.length;
                if(this.totalCases <= 1){
                    this.assignCase();
                } else {
                    this.isOpenedPopup = true;
                }
            })
            .catch(error => {
                this.showNotification(error.body.message);
            });
    }

    assignAllCases(){
        this.isOpenedPopup = false;
        assignRelatedCases({ caseId: this.recordId})
            .then(result => {
                if(result !== 0) {
                    this.showNotification('Success!', result + ' cases has been assigned to you!', 'success');
                    getRecordNotifyChange([{recordId: this.recordId}]);
                } else {
                    this.showNotification('Warning!', 'All customer\s cases are already assigned to you.', 'warning');
                }
            })
            .catch(error => {
                this.showNotification('Error:', error.body.message, 'error');
            });
    }

    assignCase(){
        this.isOpenedPopup = false;
        assignCurrentCase({ caseId: this.recordId})
            .then(result => {
                if(result === 'True'){
                    this.showNotification('Success!', 'This case has been assigned!', 'success');
                    getRecordNotifyChange([{recordId: this.recordId}]);
                } else if(result === 'False'){
                    this.showNotification('Warning!', 'This case is already assigned to you.', 'warning');
                } else {
                    this.showNotification('Warning!', 'This case is closed', 'warning');
                }
            })
            .catch(error => {
                this.showNotification('Error:', error.body.message, 'error');
            });
    }

    closeModal(){
        this.isOpenedPopup = false;
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