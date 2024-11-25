import { LightningElement, api, track } from 'lwc';

const columns = [
    { label: 'Corporate Code Name', fieldName: 'Corporate_Code__c', type: 'text' },
    { label: 'Record Type', fieldName: 'Code_Record_Type__c', type: 'text' },
    { label: 'Active/Inactive', fieldName: 'Active__c', type: 'boolean' },
    { label: 'Activate/Deactivate', fieldName: 'Activate/Deactivate', type: 'picklist', wrapText: true,
        typeAttributes: {
            placeholder: 'Select option',
            recordId: { fieldName: 'Id' },
            options: [
                { label: 'Activate', value: 'Activate' },
                { label: 'Deactivate', value: 'Deactivate' }
            ]
        }
    }
];

export default class NcoCustomFlowAccountCTCsTable extends LightningElement {
    @api accountCTCsInput;
    @api accountCTCsOutput = [];
    @track columnsList = columns;

    handleSelect(event) {
        const optionValue = event.detail.value === 'Activate';
        const recordId = event.detail.recordId;

        const selectedRecordIndex = this.accountCTCsInput.findIndex(record => record.Id === recordId);
        const selectedRecord = { ...this.accountCTCsInput[selectedRecordIndex] };
        const outputRecordIndex  = this.accountCTCsOutput.findIndex(record => record.Id === recordId);
        const recordIsInOutptut = outputRecordIndex > -1;

        if (selectedRecord['Active__c'] !== optionValue && !recordIsInOutptut) {
            selectedRecord['Active__c'] = optionValue;
            this.accountCTCsOutput.push(selectedRecord);
        } else if (selectedRecord['Active__c'] === optionValue && recordIsInOutptut) {
            this.accountCTCsOutput.splice(outputRecordIndex, 1);
        }
    }
}