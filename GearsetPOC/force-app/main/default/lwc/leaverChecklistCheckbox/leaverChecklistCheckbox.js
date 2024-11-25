import { LightningElement, api, track, wire } from "lwc";
export default class LeaverChecklistCheckbox extends LightningElement {
    @api label;
    @api size;
    @api paired;

    _editMode = false;
    _internalValue = undefined;
    initialized = false;

    @api 
    get value() {
        return this._internalValue;
    }

    set value(val) {
        if (this.paired) { 
            if (this.paired.startsWith("complement")) {
                this._internalValue = val;
            } else {
                this._internalValue = !val;
            }
        } else {
            this._internalValue = val;
        }
    }


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
        return this._internalValue;
    }

    @api 
    setState(value) {
        this.template.querySelector("input").checked = value;
        this._internalValue = value;
    }

    renderedCallback() {
        if (!this.initialized) {
            if (this.value !== undefined) { 
                if (this.paired) { 
                    if (this.paired.startsWith("complement")) {
                        this.template.querySelector("input").checked = this.value;
                    } else {
                        this.template.querySelector("input").checked = !(this.value);
                    }
                } else {
                    this.template.querySelector("input").checked = this.value;
                }
                this.initialized = true;
            } 
        } else {
            if (this._internalValue === undefined) { 
                this.template.querySelector("input").checked = false;
            } else {
                this.template.querySelector("input").checked = this._internalValue;
            }
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

    handleChange() {
        let currentState = this.template.querySelector("input").checked;
        this._internalValue = currentState; 

        if (this.paired) {
            this.dispatchEvent(new CustomEvent('updated', {detail : {'target': this.paired, 'value' : currentState}}));
        }
    }

    get checkboxClass() {
      let baseClass = "lc-checkbox lc-checkbox-";
      if (this.size !== undefined) {
        return baseClass + (this.size = "huge" ? "huge" : "small");
      } else {
        return baseClass + "small"; 
      }
    }

    get labelSize() {
      if (this.label === "") {
        let baseStyle = "width: ";
        if (this.size !== undefined) {
          return baseStyle + (this.size = "huge" ? "2em;" : "1em;");
        } else {
          return baseStyle + "1em;";
        }
      } else {
        return "";
      }
    }
}