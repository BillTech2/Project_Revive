import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import deleteFiles from '@salesforce/apex/CaseDeleteRelatedFilesController.deleteFiles';
import getRelatedFiles from '@salesforce/apex/CaseDeleteRelatedFilesController.getRelatedFiles';
export default class CaseDeleteRelatedFilesButton extends LightningElement {
    @api recordId;
    @track relatedFiles;
    selectedFiles = [];
    isLoading = false;

    connectedCallback(){
        getRelatedFiles({ caseId: this.recordId})
            .then(result => {
                if(result.length === 0){
                    this.showNotification('Warning' , 'There are no related files.', 'Warning');
                } else {
                    this.relatedFiles = result;
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleChange(e) {
        this.selectedFiles = e.detail.value;
    }

    handleDelete(){
        this.isLoading = true;
        deleteFiles({ docIds: this.selectedFiles})
            .then((result) => {
                this.refreshView();
                this.isLoading = false;
                this.closeModal();
                this.showNotification('Success' ,'Selected files are successfully deleted!', 'Success');
            })
            .catch(error => {
                this.isLoading = false;
                this.showNotification('Error' , error.body.message, 'Error');
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

    refreshView(){
        this.dispatchEvent(new CustomEvent('update'));
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}