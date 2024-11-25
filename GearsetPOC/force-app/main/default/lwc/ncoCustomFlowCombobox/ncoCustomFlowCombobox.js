import { LightningElement, api } from 'lwc';

export default class NcoCustomFlowCombobox extends LightningElement {
    @api name;
    @api label;
    @api value;
    @api placeholder;
    @api options;
    @api variant;
    @api recordId;

    handleChange(event) {
        event.preventDefault();
        let value = event.target.value;
        const picklist = new CustomEvent('select', {
            detail: {
                value: value,
                recordId: this.recordId
            },
            bubbles: true,
            composed: true,
            cancelable: true
        });
        this.dispatchEvent(picklist);
    }

}