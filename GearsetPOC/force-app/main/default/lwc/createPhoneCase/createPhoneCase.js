import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import createPhoneCase from '@salesforce/apex/ContactCentreConsoleController.createPhoneCase';
export default class CreatePhoneCase extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isLoading = true;

    connectedCallback(){
        createPhoneCase()
            .then(result => {
                this.isLoading = false;
                this.navigateToCasePage(result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    navigateToCasePage(caseId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }
}