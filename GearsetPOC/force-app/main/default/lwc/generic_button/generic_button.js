import { LightningElement, api } from 'lwc';
import { getTranslatedLabel } from 'c/generic_utils';

export default class Generic_button extends LightningElement {
    @api
    buttonLabelName;
    @api
    eventDetails;
    @api
    langCode;

    get buttonLabel() {
        return getTranslatedLabel(this.buttonLabelName, this.langCode);
    }

    handleClick() {
        try {
            const details = {};
            const formData = [];
            for (let prop in this.eventDetails) {
                details[prop] = this.eventDetails[prop];
            }
            details.currLabel = getTranslatedLabel(this.buttonLabelName, 'EN');
            if (this.buttonLabelName === 'cu_OnOurApp') {
                formData.push({inputName: 'isOnOurApp', inputValue: true});
            }
            if (formData.length) {
                details.formData = formData;
            }
            this.dispatchEvent(
                new CustomEvent('btnclick', {detail: {eventDetails: details}, bubbles: true, composed: true})
            );
        } catch (error) {
            console.log(`Generic Button Error: ${error}`);
        }
    }
}