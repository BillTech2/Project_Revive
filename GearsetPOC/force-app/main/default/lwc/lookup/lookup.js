import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const SEARCH_DELAY = 300; 

const KEY_ARROW_UP = 38;
const KEY_ARROW_DOWN = 40;
const KEY_ENTER = 13;

const VARIANT_LABEL_STACKED = 'label-stacked';
const VARIANT_LABEL_INLINE = 'label-inline';
const VARIANT_LABEL_HIDDEN = 'label-hidden';

const REGEX_TRAP = /[+\\?^${}()|[\]\\]/g;

export default class Lookup extends NavigationMixin(LightningElement) {
    @api variant = VARIANT_LABEL_STACKED;
    @api label = '';
    @api required = false;
    @api disabled = false;
    @api placeholder = '';
    @api isMultiEntry = false;
    @api errors = [];
    @api scrollAfterNItems = null;
    @api newRecordOptions = [];
    @api minSearchTermLength = 2;

    searchResultsLocalState = [];
    loading = false;

    _hasFocus = false;
    _isDirty = false;
    _searchTerm = '';
    _cleanSearchTerm;
    _cancelBlur = false;
    _searchThrottlingTimeout;
    _searchResults = [];
    _defaultSearchResults = [];
    _curSelection = [];
    _focusedResultIndex = null;

    @api
    set selection(initialSelection) {
        this._curSelection = Array.isArray(initialSelection) ? initialSelection : [initialSelection];
        this.processSelectionUpdate(false);
    }

    get selection() {
        return this._curSelection;
    }

    @api
    setSearchResults(results) {
        this.loading = false;
        let resultsLocal = JSON.parse(JSON.stringify(results));
        const selectedIds = this._curSelection.map((sel) => sel.id);
        resultsLocal = resultsLocal.filter((result) => selectedIds.indexOf(result.id) === -1);
        const cleanSearchTerm = this._searchTerm.replace(REGEX_TRAP, '');
        const regex = new RegExp(`(${cleanSearchTerm})`, 'gi');
        this._searchResults = resultsLocal.map((result) => {
            if (this._searchTerm.length > 0) {
                result.titleFormatted = result.title
                    ? result.title.replace(regex, '<strong>$1</strong>')
                    : result.title;
                result.subtitleFormatted = result.subtitle
                    ? result.subtitle.replace(regex, '<strong>$1</strong>')
                    : result.subtitle;
            } else {
                result.titleFormatted = result.title;
                result.subtitleFormatted = result.subtitle;
            }
            if (typeof result.icon === 'undefined') {
                result.icon = 'standard:default';
            }
            return result;
        });
        this._focusedResultIndex = null;
        const self = this;
        this.searchResultsLocalState = this._searchResults.map((result, i) => {
            return {
                result,
                state: {},
                get classes() {
                    let cls =
                        'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';
                    if (self._focusedResultIndex === i) {
                        cls += ' slds-has-focus';
                    }
                    return cls;
                }
            };
        });
    }

    @api
    getSelection() {
        return this._curSelection;
    }

    @api
    setDefaultResults(results) {
        this._defaultSearchResults = [...results];
        if (this._searchResults.length === 0) {
            this.setSearchResults(this._defaultSearchResults);
        }
    }

    updateSearchTerm(newSearchTerm) {
        this._searchTerm = newSearchTerm;

        const newCleanSearchTerm = newSearchTerm.trim().replace(/\*/g, '').toLowerCase();
        if (this._cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        this._cleanSearchTerm = newCleanSearchTerm;

        if (newCleanSearchTerm.length < this.minSearchTermLength) {
            this.setSearchResults(this._defaultSearchResults);
            return;
        }

        if (this._searchThrottlingTimeout) {
            clearTimeout(this._searchThrottlingTimeout);
        }
        this._searchThrottlingTimeout = setTimeout(() => {
            if (this._cleanSearchTerm.length >= this.minSearchTermLength) {
                this.loading = true;

                const searchEvent = new CustomEvent('search', {
                    detail: {
                        searchTerm: this._cleanSearchTerm,
                        rawSearchTerm: newSearchTerm,
                        selectedIds: this._curSelection.map((element) => element.id)
                    }
                });
                this.dispatchEvent(searchEvent);
            }
            this._searchThrottlingTimeout = null;
        }, SEARCH_DELAY);
    }

    isSelectionAllowed() {
        if (this.isMultiEntry) {
            return true;
        }
        return !this.hasSelection();
    }

    hasSelection() {
        return this._curSelection.length > 0;
    }

    processSelectionUpdate(isUserInteraction) {
        this._cleanSearchTerm = '';
        this._searchTerm = '';
        this.setSearchResults([...this._defaultSearchResults]);
        this._isDirty = isUserInteraction;
        if (isUserInteraction) {
            const selectedIds = this._curSelection.map((sel) => sel.id);
            this.dispatchEvent(new CustomEvent('selectionchange', { detail: selectedIds }));
        }
    }


    handleInput(event) {
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleKeyDown(event) {
        if (this._focusedResultIndex === null) {
            this._focusedResultIndex = -1;
        }
        if (event.keyCode === KEY_ARROW_DOWN) {
            this._focusedResultIndex++;
            if (this._focusedResultIndex >= this._searchResults.length) {
                this._focusedResultIndex = 0;
            }
            event.preventDefault();
        } else if (event.keyCode === KEY_ARROW_UP) {
            this._focusedResultIndex--;
            if (this._focusedResultIndex < 0) {
                this._focusedResultIndex = this._searchResults.length - 1;
            }
            event.preventDefault();
        } else if (event.keyCode === KEY_ENTER && this._hasFocus && this._focusedResultIndex >= 0) {
            const selectedId = this._searchResults[this._focusedResultIndex].id;
            this.template.querySelector(`[data-recordid="${selectedId}"]`).click();
            event.preventDefault();
        }
    }

    handleResultClick(event) {
        const recordId = event.currentTarget.dataset.recordid;

        const selectedItem = this._searchResults.find((result) => result.id === recordId);
        if (!selectedItem) {
            return;
        }
        const newSelection = [...this._curSelection];
        newSelection.push(selectedItem);
        this._curSelection = newSelection;

        this.processSelectionUpdate(true);
    }

    handleComboboxMouseDown(event) {
        const mainButton = 0;
        if (event.button === mainButton) {
            this._cancelBlur = true;
        }
    }

    handleComboboxMouseUp() {
        this._cancelBlur = false;
        this.template.querySelector('input').focus();
    }

    handleFocus() {
        if (!this.isSelectionAllowed()) {
            return;
        }
        this._hasFocus = true;
        this._focusedResultIndex = null;
    }

    handleBlur() {
        if (!this.isSelectionAllowed() || this._cancelBlur) {
            return;
        }
        this._hasFocus = false;
    }

    handleRemoveSelectedItem(event) {
        if (this.disabled) {
            return;
        }
        const recordId = event.currentTarget.name;
        this._curSelection = this._curSelection.filter((item) => item.id !== recordId);
        this.processSelectionUpdate(true);
    }

    handleClearSelection() {
        this._curSelection = [];
        this._hasFocus = false;
        this.processSelectionUpdate(true);
    }

    handleNewRecordClick(event) {
        const objectApiName = event.currentTarget.dataset.sobject;
        const selection = this.newRecordOptions.find((option) => option.value === objectApiName);

        const preNavigateCallback = selection.preNavigateCallback
            ? selection.preNavigateCallback
            : () => Promise.resolve();
        preNavigateCallback(selection).then(() => {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName,
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues: selection.defaults
                }
            });
        });
    }


    get hasResults() {
        return this._searchResults.length > 0;
    }

    get getFormElementClass() {
        return this.variant === VARIANT_LABEL_INLINE
            ? 'slds-form-element slds-form-element_horizontal'
            : 'slds-form-element';
    }

    get getLabelClass() {
        return this.variant === VARIANT_LABEL_HIDDEN
            ? 'slds-form-element__label slds-assistive-text'
            : 'slds-form-element__label';
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        const isSearchTermValid = this._cleanSearchTerm && this._cleanSearchTerm.length >= this.minSearchTermLength;
        if (this._hasFocus && this.isSelectionAllowed() && (isSearchTermValid || this.hasResults)) {
            css += 'slds-is-open';
        }
        return css;
    }

    get getClearSelectionButtonClass() {
        return (
            'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
            (this.hasSelection() ? '' : 'slds-hide')
        );
    }

    get getSelectIconName() {
        return this.hasSelection() ? this._curSelection[0].icon : 'standard:default';
    }

    get getSelectIconClass() {
        return 'slds-combobox__input-entity-icon ' + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getInputValue() {
        if (this.isMultiEntry) {
            return this._searchTerm;
        }
        return this.hasSelection() ? this._curSelection[0].title : this._searchTerm;
    }

    get getInputTitle() {
        if (this.isMultiEntry) {
            return '';
        }
        return this.hasSelection() ? this._curSelection[0].title : '';
    }

    get getListboxClass() {
        return (
            'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid ' +
            (this.scrollAfterNItems ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems : '')
        );
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }
}