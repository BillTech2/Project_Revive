import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

import getRelatedCases from '@salesforce/apex/ContactCentreConsoleController.getRelatedCases';

export default class CustomerRelatedCases extends NavigationMixin(LightningElement) {
    @api recordid;
    @track relatedCases;
    @track casesTotal = 0;
    wiredCases;

    @wire(getRelatedCases, {caseId : '$recordid'})
    wiredRecords(result) {
        console.log(result);
        this.wiredCases = result;
        if (this.wiredCases.data) {
            this.relatedCases = this.wiredCases.data;
            this.casesTotal = this.relatedCases.length;
        } else if (this.wiredCases.error) {
            this.showNotification('Error:', this.wiredCases.error.body.message, 'error');
        } 
    }

    navigateToCasePage(event) {
        let caseId = event.target.dataset.targetId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
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

    @api
    refreshView(){
        refreshApex(this.wiredCases);
    }
}