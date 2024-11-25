import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

const CASEFIELDS = ['Case.AccountId', 'Case.Customer_Email__c', 'Case.Preferred_Language__c'];
const LINKS = [
    {Name: 'CS Letter: Additional Payment Confirmation', RecordType: '012b0000000cfSE'},
    {Name: 'CS Letter: Cancellation Confirmation', RecordType: '012b0000000cfSF'},
    {Name: 'CS Letter: Delay Confirmation', RecordType: '012b0000000cfSG'},
    {Name: 'CS Letter: VAT Receipt', RecordType: '012b0000000cfSH'}
]
export default class QuickLinksContainer extends NavigationMixin(LightningElement) {
    @api recordId;
    quickLinks = LINKS;
    case;
    accountId;
    customer_Email__c;
    preferred_Language__c;

    @wire(getRecord, { recordId: '$recordId', fields: CASEFIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading case',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.case = data;
            this.accountId = this.case.fields.AccountId.value;
            this.customer_Email__c = this.case.fields.Customer_Email__c.value;
            this.preferred_Language__c = this.case.fields.Preferred_Language__c.value;
        }
    }

    onClick(event) {
        let targetId = event.target.dataset.targetId;
        const defaultValues = encodeDefaultFieldValues({
            Recipient_Name__c: this.accountId,
            Email_Address__c: this.customer_Email__c,
            Requested_Language__c: this.preferred_Language__c
        });

        console.log(defaultValues);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'CS_Letter__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                recordTypeId: targetId
            }
        });

    }
}