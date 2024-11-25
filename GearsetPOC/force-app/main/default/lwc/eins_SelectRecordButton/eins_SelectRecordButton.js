import { LightningElement, api } from 'lwc';

export default class Eins_SelectRecordButton extends LightningElement {
    @api recordId;
    @api buttonLabel;
    @api buttonVariant = 'base';
    selected = false;

    fireSelectThisRecord() {
        if (this.selected) {
            this.selected = false;
        } else {
            this.selected = true;
        }
        const event = new CustomEvent('selectthisrecordevent', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordId: this.recordId,
                selected: this.selected
            },
        });
        this.dispatchEvent(event);
    }
}