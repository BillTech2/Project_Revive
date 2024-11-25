import { LightningElement, api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getNegotiatedRatePreselectData from'@salesforce/apex/DLT_CreateNegotiatedRateQuickActionCtrl.getNegotiatedRatePreselectData';
import { doRequest } from 'c/dltUtils';


export default class DltCreateNegotiatedRateQuickAction extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback() {
        this.redirectWithPresetData();
    }

    redirectWithPresetData() {
        if (!this.recordId) {
            return;
        }
        doRequest(getNegotiatedRatePreselectData, { contractId: this.recordId })
            .then(response => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'B2b_NrDetails__c',
                        actionName: 'new'
                    },
                    state : {
                        nooverride: '1',
                        recordTypeId: response.recordTypeId,
                        defaultFieldValues: this.getDefaultFieldValues(response.startDate)
                    }
                });
            });
    }


    getDefaultFieldValues(startDate) {
        return "ContractID__c=" + this.recordId +
        ",B2b_Status__c=New" +
        (startDate ? ",B2b_RouteStartDate__c=" + startDate : '');
    }
}