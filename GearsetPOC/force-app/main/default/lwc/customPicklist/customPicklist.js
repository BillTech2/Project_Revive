/**
 * Created by JU on 20.12.2022.
 */

import {LightningElement, api, track} from 'lwc';

export default class Picklist extends LightningElement {
    @api label;
    @api
    get wiredOptions() {
        return this.options;
    }
    set wiredOptions(value) {
        this.options = value;
        this.selectedOption = null;
        this.selectedOptionLabel = null;
        this.searchTerm = '';
    }
    @track searchTerm = '';
    @track selectedOption;
    @track selectedOptionLabel;
    @track optionsSearchList;

    isDropdownOpen = false;

    get matchFound() {
        return this.optionsSearchList && this.optionsSearchList.length !== 0;
    }

    searchOption(event) {
        this.searchTerm = event.target.value;
        this.optionsSearchList = this.options.filter(opt => {
            return opt.label.toLowerCase().includes(this.searchTerm.toLowerCase())
        });
        if (this.matchFound) {
            this.expandDropdown();
        } else {
            this.collapseDropdown();
        }
    }

    onOptionSelect(event) {
        this.unselectOption(this.selectedOption);
        this.selectedOption = event.currentTarget.dataset.value;
        this.selectedOptionLabel = event.currentTarget.dataset.name;
        this.searchTerm = this.selectedOptionLabel;
        this.selectOption(this.selectedOption);
        this.collapseDropdown();

        this.dispatchEvent(new CustomEvent('optionselected', {
            detail: {
                value: this.selectedOption
            }
        }));
    }

    onSearchFocus() {
        this.optionsSearchList = this.options.filter(opt => {
            return opt.label.toLowerCase().includes(this.searchTerm.toLowerCase())
        });
        this.expandDropdown();
    }

    onSearchBlur() {
        this.searchTerm = this.selectedOptionLabel ? this.selectedOptionLabel : '';
        this.collapseDropdown();
    }

    expandDropdown() {
        console.log('expand droprown');
        if (!this.isDropdownOpen) {
            this.template.querySelector('[data-id="reason-select"]').classList.add("slds-is-open");
            this.isDropdownOpen = true;
        }
    }

    collapseDropdown() {
        if (this.isDropdownOpen) {
            this.template.querySelector('[data-id="reason-select"]').classList.remove("slds-is-open");
            this.isDropdownOpen = false;
        }
    }

    selectOption(value){
        let option = this.template.querySelector('[data-id="' + value + '"]');
        option.classList.add("slds-is-selected");
        option.querySelector('.slds-icon-utility-check').classList.remove("slds-hidden")
    }

    unselectOption(value) {
        let option =  this.template.querySelector('[data-id="' + value + '"]');
        if (option) {
            option.classList.remove("slds-is-selected");
            option.querySelector('.slds-icon-utility-check').classList.add("slds-hidden")
        }
    }
}