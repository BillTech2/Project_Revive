import { LightningElement, api, track } from 'lwc';

const columns = [
    { label: 'Record Type', fieldName: 'Record_Type_Name__c', type: 'text' },
    { label: 'Corporate Code Name', fieldName: 'Name', type: 'text' },
    { label: 'Corp Type', fieldName: 'Corp_Type__c', type: 'text' },
    { label: 'Create Account CTC Yes/No', fieldName: 'CreateAccountCtcYesOrNo', type: 'picklist', wrapText: true,
        typeAttributes: {
            placeholder: 'No',
            recordId: { fieldName: 'Id' },
            options: [
                { label: 'Yes', value: 'Yes' },
                { label: 'No', value: 'No' }
            ]
        }
    }
];

export default class NcoCustomFlowAccountCTCsTable extends LightningElement {
    @api codesInput;
    @api codesOutput = [];
    @track columnsList = columns;

    handleSelect(event) {
        const isYesSelected = event.detail.value === 'Yes';
        const isNoSelected = event.detail.value === 'No';
        const recordId = event.detail.recordId;

        const selectedRecordIndex = this.codesInput.findIndex(record => record.Id === recordId);
        const selectedRecord = { ...this.codesInput[selectedRecordIndex] };
        const outputRecordIndex = this.codesOutput.findIndex(record => record.Id === recordId);
        const recordIsInOutptut = outputRecordIndex > -1;

        if (isYesSelected && !recordIsInOutptut) {
            this.codesOutput.push(selectedRecord);
        } else if (isNoSelected && recordIsInOutptut) {
            this.codesOutput.splice(outputRecordIndex, 1);
        }

        console.log('this.codesOutput:', this.codesOutput);
    }
}