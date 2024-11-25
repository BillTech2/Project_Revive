import { LightningElement, api } from "lwc";
export default class LeaverChecklistInput extends LightningElement {
    @api size;
    @api paired;

    @api value;


    _editMode = false;
    initialized = false;


    @api   
    get editMode() {
        return this._editMode;
    }

    set editMode(val) {
        this._editMode = val;
        this.updateMode(this._editMode);
    }

    @api 
    get resultvalue() {
        return this.template.querySelector("input").value;
    }

    @api 
    setState(value) {
        this.template.querySelector("input").value = value;
    }

    renderedCallback() {
        if (!this.initialized) {
            if (this.value === undefined) {
                this.template.querySelector("input").value = "";
            } else {
                this.template.querySelector("input").value = this.value;
            }
            this.initialized = true;
        }
        this.updateMode(this._editMode);
    }

    updateMode(mode) {
        let control = this.template.querySelector("input");
        if (control) {
            if (mode) {
                control.removeAttribute('disabled');
            } else {
                control.setAttribute('disabled', true);
            }
        }
    }

    handleChange(event) {
        let currentState = this.template.querySelector("input").value;
        this.dispatchEvent(new CustomEvent('updated', {detail : {'target': this.paired, 'value' : currentState}}));
    }
}