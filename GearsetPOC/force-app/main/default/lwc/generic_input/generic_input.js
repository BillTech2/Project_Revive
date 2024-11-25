import { LightningElement, api, track } from 'lwc';
import checkPNR from '@salesforce/apex/cu_Utils.checkPNR';
import checkTCN from '@salesforce/apex/cu_Utils.checkTCN';
import checkDepartureDate from '@salesforce/apex/cu_Utils.checkDepartureDate';
import checkMembership from '@salesforce/apex/cu_Utils.checkMembership';
import {
    PARAMS_MAPPING,
    getTranslatedLabel,
    getParamsForNextStepByInput,
    addParamsForNextStepByDisruption
} from 'c/generic_utils';
import { BOOKING_TYPE } from 'c/dltConstants';
import * as OPTIONS from './selectOptions';

export default class Generic_input extends LightningElement {
    @api
    inputType;
    @api
    inputLabelName;
    @api
    inputName;
    @api
    inputPlaceholderName;
    @api
    langCode;
    @api
    submitLabelName;
    @api
    checkPnr;
    @api
    checkTcn;
    @api
    checkMembership;
    @api
    nextStepKey;
    @api
    showSubmit;
    @api
    regexp;
    @api
    required;
    @api
    origin;
    @api
    isLondon;
    @api
    isCompensationCheck;
    @api
    checkDepartureDate;
    @api
    pnr;

    @track
    options = [];

    value;

    _eventData = {};

    //--- PNR DATA
    pnrData = {};

    //---membership data
    membershipData = {};

    showSpinner = false;

    // getters for generic input display

    get type() {
        return this.inputType ? (this.inputType == 'departuredate' ? 'date' : this.inputType) : 'text';
    }

    get isTextarea() {
        return this.inputType && this.inputType === 'textarea' ? true : false;
    }

    get isSelect() {
        return this.inputType && this.inputType === 'select' ? true : false;
    }

    get isBirthDate() {
        return this.inputType && this.inputType === 'bdate' ? true : false;
    }

    get isSimple() {
        return this.type &&
            (this.type == 'text' ||
                this.type == 'date' ||
                this.type == 'datetime' ||
                this.type == 'number' ||
                this.type == 'checkbox')
            ? true
            : false;
    }

    get inputLabel() {
        return this.inputLabelName ? getTranslatedLabel(this.inputLabelName, this.langCode) : '';
    }

    get inputPlaceholder() {
        return this.inputPlaceholderName ? getTranslatedLabel(this.inputPlaceholderName, this.langCode) : '';
    }

    get submitLabel() {
        return this.submitLabelName
            ? getTranslatedLabel(this.submitLabelName, this.langCode)
            : getTranslatedLabel('cu_Submit', this.langCode);
    }

    get showButton() {
        return this.showSubmit !== false ? true : false;
    }

    @api
    getInputValue() {
        return this.value;
    }

    connectedCallback() {
        if (this.isSelect) {
            this.defineSelectOptions();
        }
    }

    defineSelectOptions() {
        switch (this.inputLabelName) {
            case 'cu_United_Kingdom':
                this.pushStationOptions(OPTIONS.UK_STATIONS_LIST);
                break;
            case 'cu_France':
                this.pushStationOptions(OPTIONS.FRANCE_STATIONS_LIST);
                break;
            case 'cu_Belgium':
                this.pushStationOptions(OPTIONS.BELGIUM_STATIONS_LIST);
                break;
            case 'cu_Germany':
                this.pushStationOptions(OPTIONS.GERMANY_STATIONS_LIST);
                break;
            case 'cu_Netherlands':
                this.pushStationOptions(OPTIONS.NETHERLANDS_STATIONS_LIST);
                break;
            case 'cu_LMRBooking_Location':
                this.pushStationOptions(OPTIONS.BOOKING_LOCATION_LIST);
                break;
            case 'cu_ClassService':
                if (this.isLondon) {
                    this.pushStationOptions(OPTIONS.CLASS_OF_SERVICE_LIST_LONDON);
                } else {
                    this.pushStationOptions(OPTIONS.CLASS_OF_SERVICE_LIST_ALL);
                }
                break;
            case 'cu_Time':
                this.pushStringOptions(OPTIONS.TIME_LIST);
                break;
            default:
                this.pushStationOptions(OPTIONS.OPTIONS_LIST);
        }

        switch (this.inputName) {
            case 'additionalAssistanceOptions':
                this.setTranslatedOptions(OPTIONS.ADDITIONAL_ASSISTANCE_OPTIONS);
                break;
            default:
        }
    }

    pushStationOptions(options) {
        this.options = [];

        options.forEach((element) => {
            if (this.origin !== getTranslatedLabel(element, this.langCode)) {
                this.options.push({
                    value: getTranslatedLabel(element, 'EN'),
                    label: getTranslatedLabel(element, this.langCode)
                });
            }
        });
    }

    pushStringOptions(options) {
        this.options = [];

        options.forEach((element) => {
            this.options.push({
                value: element,
                label: element
            });
        });
    }

    setTranslatedOptions(options) {
        this.options = [];

        options.forEach((element) => {
            this.options.push({
                value: element.value,
                label: getTranslatedLabel(element.label, this.langCode)
            });
        });
    }

    checkPNRAndSendData() {
        this.showSpinner = true;
        checkPNR({ pnr: this.value })
            .then((result) => {
                for (const property in result) {
                    this.pnrData[property] = result[property];
                }
            })
            .then(() => {
                if (!this.pnrData.error) {
                    this.generateEventData();
                    this.sendEvent();
                } else {
                    this.generateEventDataOnErrorAndSend();
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log(`Check PNR error: ${JSON.stringify(error)}`);
            });
    }

    checkTCNAndSendData() {
        this.showSpinner = true;
        checkTCN({ tcn: this.value })
            .then((result) => {
                if (result) {
                    this.generateEventData();
                    this.sendEvent();
                } else {
                    this.showTCNError();
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log(`Check TCN error: ${JSON.stringify(error)}`);
            });
    }

    checkMembersipAndSendData() {
        this.showSpinner = true;
        checkMembership({ mNumber: this.value })
            .then((result) => {
                for (const property in result) {
                    this.membershipData[property] = result[property];
                }
            })
            .then(() => {
                if (!this.membershipData.error) {
                    this.generateEventData();
                    this.sendEvent();
                } else {
                    this.showErrorMessage(getTranslatedLabel(this.membershipData.error, this.langCode));
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log(`Check Membership error: ${JSON.stringify(error)}`);
            });
    }

    checkDepartureDateAndSendData() {
        this.showSpinner = true;
        checkDepartureDate({ pnr: this.pnr, departureDate: this.value })
            .then((result) => {
                if (result) {
                    this.generateEventData();
                    this.sendEvent();
                } else {
                    this.showDepartureDateError();
                }
            })
            .catch((error) => {
                console.log(`Check Departure date error: ${JSON.stringify(error)}`);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    sendEvent() {
        this.dispatchEvent(
            new CustomEvent('processinputdata', {
                detail: { eventDetails: this._eventData },
                bubbles: true,
                composed: true
            })
        );
    }

    handleClick() {
        if (this.inputType !== 'departuredate' && (this.type == 'date' || this.type == 'datetime')) {
            const date1 = new Date(Date.parse(this.value)).toISOString();
            const dateNow = new Date(Date.now()).toISOString();
            if (date1 < dateNow) {
                this.template
                    .querySelector('lightning-input')
                    .setCustomValidity(`${getTranslatedLabel('cu_DateIsInvalid', this.langCode)}`);
                this.template.querySelector('lightning-input').reportValidity();
                return;
            } else {
                this.template.querySelector('lightning-input').setCustomValidity('');
            }
        }
        if (this.type == 'bdate') {
            const today = Date.now();
            if (Date.parse(this.value) > today || Date.parse(this.value) < today - 3532032000000) {
                this.template
                    .querySelector('lightning-input')
                    .setCustomValidity(`${getTranslatedLabel('cu_BirthDateIsInvalid', this.langCode)}`);
                this.template.querySelector('lightning-input').reportValidity();
                return;
            } else {
                this.template.querySelector('lightning-input').setCustomValidity('');
            }
        }
        if (this.type == 'select') {
            if (typeof this.value === 'undefined') {
                this.template
                    .querySelector('lightning-combobox')
                    .setCustomValidity(`${getTranslatedLabel('cu_ChooseYourDestination', this.langCode)}`);
                this.template.querySelector('lightning-combobox').reportValidity();
                return;
            } else {
                this.template.querySelector('lightning-combobox').setCustomValidity('');
            }
        }
        if (this.type == 'text') {
            if (typeof this.value === 'undefined') {
                this.template
                    .querySelector('lightning-input')
                    .setCustomValidity(`${getTranslatedLabel('cu_ChooseYourDestination', this.langCode)}`);
                this.template.querySelector('lightning-input').reportValidity();
                return;
            } else {
                this.template.querySelector('lightning-input').setCustomValidity('');
            }
        }
        if (this.regexp) {
            const regexpRule = new RegExp(this.regexp);
            if (regexpRule.test(this.value)) {
                if (this.type === 'textarea') {
                    this.template.querySelector('textarea').setCustomValidity('');
                } else {
                    this.template.querySelector('lightning-input').setCustomValidity('');
                }
            } else {
                if (this.type === 'textarea') {
                    this.template
                        .querySelector('textarea')
                        .setCustomValidity(
                            `${getTranslatedLabel(this.inputLabelName, this.langCode)}  ${getTranslatedLabel(
                                'cu_ValueIsInvalid',
                                this.langCode
                            )}`
                        );
                    this.template.querySelector('textarea').reportValidity();
                } else {
                    this.template
                        .querySelector('lightning-input')
                        .setCustomValidity(
                            `${getTranslatedLabel(this.inputLabelName, this.langCode)}  ${getTranslatedLabel(
                                'cu_ValueIsInvalid',
                                this.langCode
                            )}`
                        );
                    this.template.querySelector('lightning-input').reportValidity();
                }
                return;
            }
        }
        this.cleanErrorMessage();
        if (this.checkPnr) {
            this.checkPNRAndSendData();
        } else if (this.checkMembership) {
            this.checkMembersipAndSendData();
        } else if (this.checkTcn) {
            this.checkTCNAndSendData();
        } else if (this.checkDepartureDate) {
            this.checkDepartureDateAndSendData();
        } else {
            this.generateEventData();
            this.sendEvent();
        }
    }

    generateEventData() {
        if (this.pnrData?.pnr && this.pnrData.pnr !== '') {
            this._eventData.pnrData = this.pnrData;
        }

        if (this.isCompensationCheck && !this.pnrData?.isDelayed && !this.pnrData?.isCancelled) {
            for (const prop in PARAMS_MAPPING.notDisruptedCompensation) {
                this._eventData[prop] = PARAMS_MAPPING.notDisruptedCompensation[prop];
            }
        } else {
            if (this.pnrData?.pnr && this.pnrData.pnr !== '' && this.nextStepKey != 'pnrOptionalDoc') {
                if (
                    this.pnrData.isDisrupted ||
                    this.pnrData?.bookingType === BOOKING_TYPE.HOTEL_ONLY ||
                    this.pnrData?.bookingType === BOOKING_TYPE.TRAIN_AND_HOTEL
                ) {
                    for (const prop in PARAMS_MAPPING.isDisrupted) {
                        this._eventData[prop] = PARAMS_MAPPING.isDisrupted[prop];
                    }
                } else {
                    for (const prop in PARAMS_MAPPING.notDisrupted) {
                        this._eventData[prop] = PARAMS_MAPPING.notDisrupted[prop];
                    }
                }
            }
            if (this.membershipData?.membershipNumber && this.membershipData.membershipNumber !== '') {
                this._eventData.membershipData = this.membershipData;
            }
            const eventDetails = getParamsForNextStepByInput(this.nextStepKey);
            if (eventDetails) {
                for (const prop in eventDetails) {
                    this._eventData[prop] = eventDetails[prop];
                }
            }
        }
    }

    handleChange(event) {
        this.value = event.target.value;
        if (event.target.checked == true) {
            this.value = true;
        }
    }

    showErrorMessage(message) {
        this.dispatchEvent(new CustomEvent('showerrorinput', { detail: message, bubbles: true, composed: true }));
    }

    generateEventDataOnErrorAndSend() {
        if (this.pnrData.error === 'cu_ErrorCaseExists') {
            if (this.pnrData?.pnr && this.pnrData.pnr !== '') {
                this._eventData.pnrData = this.pnrData;
            }
            addParamsForNextStepByDisruption(
                this.pnrData?.isDisrupted ||
                    this.pnrData?.bookingType === BOOKING_TYPE.HOTEL_ONLY ||
                    this.pnrData?.bookingType === BOOKING_TYPE.TRAIN_AND_HOTEL
                    ? 'isDisrupted'
                    : 'notDisrupted'
            );
            const eventDetails = getParamsForNextStepByInput(this.checkAopDisruptionScenario(this.pnrData));
            if (eventDetails) {
                for (const prop in eventDetails) {
                    this._eventData[prop] = eventDetails[prop];
                }
            }
            this.sendEvent();
        } else {
            this.showErrorMessage(getTranslatedLabel(this.pnrData.error, this.langCode));
        }
    }

    showTCNError() {
        this.showErrorMessage(getTranslatedLabel('cu_ErrorTCN', this.langCode));
    }

    showDepartureDateError() {
        this.showErrorMessage(getTranslatedLabel('cu_WrongTravelDate', this.langCode));
    }

    checkAopDisruptionScenario(pnrData) {
        if (pnrData.isCancelled && pnrData.bookingType === BOOKING_TYPE.TRAIN_ONLY) {
            return 'disruptionFlow_Cancellation_Train';
        }
        if (pnrData.isDelayed && pnrData.bookingType === BOOKING_TYPE.TRAIN_ONLY) {
            return 'disruptionFlow_Delay_Train';
        }
        if (pnrData.cancelOption && pnrData.bookingType === BOOKING_TYPE.TRAIN_ONLY) {
            return 'disruptionFlow_AOPOther_Package';
        }
        if (pnrData.isCancelled && pnrData.bookingType === BOOKING_TYPE.TRAIN_AND_HOTEL) {
            return 'disruptionFlow_Cancellation_Package';
        }
        if (pnrData.isDelayed && pnrData.bookingType === BOOKING_TYPE.TRAIN_AND_HOTEL) {
            return 'disruptionFlow_Delay_Package';
        }
        if (pnrData.cancelOption && pnrData.bookingType === BOOKING_TYPE.TRAIN_AND_HOTEL) {
            return 'disruptionFlow_Delay_Package';
        }
        if (pnrData.bookingType === BOOKING_TYPE.HOTEL_ONLY) {
            return 'disruptionFlow_Hotel';
        }
        return 'errorCaseExists';
    }

    cleanErrorMessage() {
        this.dispatchEvent(new CustomEvent('cleanerror'));
    }
}