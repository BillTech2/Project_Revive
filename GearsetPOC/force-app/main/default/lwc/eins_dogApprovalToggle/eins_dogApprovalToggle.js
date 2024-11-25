import { LightningElement, api } from 'lwc';
import Eins_DogApprovalToggle from "@salesforce/label/c.Eins_DogApprovalToggle";
import Eins_DogApprovalEmail from "@salesforce/label/c.Eins_DogApprovalEmail";
import Eins_DogApprovalNoForm from "@salesforce/label/c.Eins_DogApprovalNoForm";
import Eins_DogApprovalThankYou1 from "@salesforce/label/c.Eins_DogApprovalThankYou1";
import Eins_DogApprovalThankYou2 from "@salesforce/label/c.Eins_DogApprovalThankYou2";
import getSubmittedDogForm from '@salesforce/apex/DogApproval.getSubmittedDogForm'

export default class Eins_dogApprovalToggle extends LightningElement {
    labels = {
        Eins_DogApprovalToggle,
        Eins_DogApprovalEmail,
        Eins_DogApprovalNoForm,
        Eins_DogApprovalThankYou1,
        Eins_DogApprovalThankYou2
    };

    @api pageLanguageCode;

    wasFilled = false;
    showSpinner = false;
    dogObjId = '';
    customerEmail;
    dogFormExists = false;
    showError = false;
    showThankYou = false;

    handleToggleChange(event) {
        this.wasFilled = !this.wasFilled;
    }

    handleEmaiChange(event) {
        this.customerEmail = event.target.value;
    }

    submitEmail() {
        this.getDogFormId();
    }

    getDogFormId() {
        this.showSpinner = true;
        this.showError = false;
        getSubmittedDogForm({ customerEmail: this.customerEmail }).then(data => {
            if (data) {
                this.dogObjId = data;
                this.showSpinner = false;
                if (this.dogObjId) {
                    this.showThankYou = true;
                }
            } else {
                this.showSpinner = false;
                this.showError = true;
            }
        }).catch(error => {
            console.log('Error: ' + error.body.message);
            this.showSpinner = false;
        })
    }

    showForm() {
        this.dogFormExists = true;
    }

    handleBack() {
        this.dogFormExists = false;
        this.showSpinner = false;
        this.wasFilled = false;
        this.showError = false;
    }
}