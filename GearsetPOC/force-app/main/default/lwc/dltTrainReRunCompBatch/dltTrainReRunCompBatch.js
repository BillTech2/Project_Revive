import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import runBatch from'@salesforce/apex/DLT_TrainBatchReRunController.runBatch';
import { doRequest, showToastNotification, reloadPage } from 'c/dltUtils'

import successMessageText from "@salesforce/label/c.DLT_ReRun_Success";
import errorMessageText from "@salesforce/label/c.DLT_ReRun_Error";
import successMessageTitle from "@salesforce/label/c.cu_SuccessTitle";
import errorMessageTitle from "@salesforce/label/c.cu_WarningTitle";

export default class DltTrainReRunCompBatch extends NavigationMixin(LightningElement) {

    @api recordId;

    @api 
    invoke() {
        this.reRunBatch();
    }

    reRunBatch() {
        if (!this.recordId) {
            return;
        }
        doRequest(runBatch, { trainId: this.recordId })
            .then(response => {
                if(response){
                    showToastNotification(successMessageTitle, successMessageText);
                }
                if(!response){
                    showToastNotification(errorMessageTitle, errorMessageText, 'error');
                }
                
            });
    }

}