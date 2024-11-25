import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class NcoCustomFlowFooter extends LightningElement {
    @api add;
    @api amend;
    @api cancel;
    @api save;
    @api back;
    @api next;
    @api output;

    get buttons() {
        const buttonsArray = [];
        if (this.add) buttonsArray.push({ label: this.add, variant: 'Brand', class: 'slds-float_right slds-m-around_x-small' });
        if (this.amend) buttonsArray.push({ label: this.amend, variant: 'Brand', class: 'slds-float_right slds-m-around_x-small' });
        if (this.save) buttonsArray.push({ label: this.save, variant: 'Brand', class: 'slds-float_right slds-m-around_x-small' });
        if (this.back) buttonsArray.push({ label: this.back, variant: 'Neutral', class: 'slds-float_left slds-m-around_x-small' });
        if (this.next) buttonsArray.push({ label: this.next, variant: 'Brand', class: 'slds-float_right slds-m-around_x-small' });
        if (this.cancel) buttonsArray.push({ label: this.cancel, variant: 'Neutral', class: 'slds-float_right slds-m-around_x-small' });
        return buttonsArray;
    }

    handleClick(event) {
        this.output = event.target.label;
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}