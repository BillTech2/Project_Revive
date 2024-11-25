import { LightningElement, api, track } from 'lwc';
import sendEmailAndCloseCase from '@salesforce/apex/DLT_CaseSendAndCloseButtonController.sendEmailAndCloseCase';
import { doRequest, showToastNotification, reloadPage } from 'c/dltUtils'


export default class DltCaseSendAndCloseButton extends LightningElement {

    @api recordId;
    error;
    @track 
    spinnerStatus = {
        isLoading: false
    };

    handleClick(){
        doRequest(sendEmailAndCloseCase, {caseId: this.recordId}, this.spinnerStatus, true)
            .then(result => { 
                showToastNotification('Success', 'Email was sent.');
                reloadPage();
            })

    }
}