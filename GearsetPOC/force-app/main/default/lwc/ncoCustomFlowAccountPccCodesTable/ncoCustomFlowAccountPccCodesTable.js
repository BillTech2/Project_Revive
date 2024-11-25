import { LightningElement, api, track } from 'lwc';

const columns = [
    { label: 'Corporate Code Name', fieldName: 'Corporate_Code__c', type: 'text' },
    { label: 'Record Type', fieldName: 'Code_Record_Type__c', type: 'text' },
    { label: 'Active', fieldName: 'Active__c', type: 'boolean' },
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

export default class NcoCustomFlowAccountPccCodesTable extends LightningElement {
    @api accountPccCodesInput;
    @api accountPccCodesOutput = [];
    @track columnsList = columns;

    handleSelect(event) {
        const optionValue = event.detail.value === 'Activate';
        const recordId = event.detail.recordId;

        const selectedRecordIndex = this.accountPccCodesInput.findIndex(record => record.Id === recordId);
        const selectedRecord = { ...this.accountPccCodesInput[selectedRecordIndex] };
        const outputRecordIndex  = this.accountPccCodesOutput.findIndex(record => record.Id === recordId);
        const recordIsInOutptut = outputRecordIndex > -1;

        if (selectedRecord['Active__c'] !== optionValue && !recordIsInOutptut) {
            selectedRecord['Active__c'] = optionValue;
            this.accountPccCodesOutput.push(selectedRecord);
        } else if (selectedRecord['Active__c'] === optionValue && recordIsInOutptut) {
            this.accountPccCodesOutput.splice(outputRecordIndex, 1);
        }
    }
}