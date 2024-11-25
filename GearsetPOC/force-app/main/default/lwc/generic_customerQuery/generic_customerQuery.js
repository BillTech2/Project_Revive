import { LightningElement, api, track } from 'lwc';
import { getTranslatedLabel } from 'c/generic_utils';
import submitCase from '@salesforce/apex/CaseServiceController.submitCase';
import updateCases from '@salesforce/apex/CaseServiceController.updateCases';
import updateCasesByPNR from '@salesforce/apex/CaseServiceController.updateCasesByPNR';

import { CUSTOMER_TYPE } from './constants.js';

export default class Generic_customerQuery extends LightningElement {
    @api addToExisting;
    @api b2bForm;
    @api currentLabel;
    @api formData;
    @api langCode;
    @api pnrItem = {};
    @api selectedAction;
    @api showUploader;
    @api topic;
    @api whatIsTheQuestion;

    @track cases = [];

    comment;
    confirmEmail;
    email;
    fileIds;
    firstName;
    lastName;
    phoneNumber;
    toneOfContact;
    toneOfContactOptions = [];

    commentLabel;
    commentPlaceholder;
    confirmEmailLabel;
    emailConfirmPlaceholder;
    emailLabel;
    emailPlaceholder;
    firstNameLabel;
    lastNameLabel;
    phoneNumberLabel;
    phoneNumberPlaceholder;
    submitLabel;
    toneOfContactLabel;
    toneOfContactPlaceholder;

    allowSubmit = false;
    checkOnExisting = true;
    isCaseExists = false;
    showBtnList = false;
    showForm = true;
    showMessage = false;
    showSpinner = false;

    message;
    messageTypeClass = 'result-message success slds-text-align_center';

    // LIFECYCLE CALLBACKS
    connectedCallback() {
        this.setInitialValues();
    }

    renderedCallback() {
        if (this.message) {
            this.template.querySelector('.text-container').innerHTML = this.message;
        }
    }

    disconnectedCallback() {
        this.clearForm();
    }

    // EVENT HANDLERS
    handleChangeComment(event) {
        this.comment = event.target.value;
    }

    handleChangeToneOfContact(event) {
        this.toneOfContact = event.detail.value;
    }

    handleChangeFirstName(event) {
        this.firstName = event.target.value;
    }

    handleChangeLastName(event) {
        this.lastName = event.target.value;
    }

    handleChangeEmail(event) {
        this.email = event.target.value;
    }

    handleChangeEmailConfirm(event) {
        this.confirmEmail = event.target.value;
    }

    handleChangePhone(event) {
        this.phoneNumber = event.target.value;
    }

    handleUploadFilesIds(event) {
        this.fileIds = event.detail.files;
    }

    handleCaptchaReceived(event) {
        if (event.detail.isVerified) {
            this.allowSubmit = true;
        }
    }

    handleListButtonClick(event) {
        event.stopPropagation();

        this.showBtnList = false;
        this.addToExisting = event.detail?.eventDetails?.addToExisting ? true : false;

        if (this.addToExisting) {
            this.updateCaseRecords();
        } else {
            this.checkOnExisting = false;
            this.handleSubmit();
        }
    }

    handleSubmit() {
        this.message = null;
        this.showMessage = false;


        if (!this.isInputsValid()) {
            return;
        }
        if (this.email !== this.confirmEmail) {
            this.showError(getTranslatedLabel('cu_EmailsDoNotMatch', this.langCode));
            return;
        }

        this.submitCase();
    }

    // APEX ACTIONS
    submitCase() {
        this.showForm = false;
        this.showSpinner = true;

        const generic_phoneNumberInput = this.template.querySelector('c-generic_phone-number-input');
        if (generic_phoneNumberInput !== null) {
            this.phoneNumber = generic_phoneNumberInput.phoneNumber;
        }

        this.sendSubmitToContainer();

        const argsJSON = this.createApexParams();

        submitCase({ action: this.selectedAction, argsJSON: argsJSON })
            .then((data) => {
                if (!data?.error) {
                    if (data.cases && data.cases.length > 0) {
                        this.isCaseExists = true;
                        this.cases = data.cases;
                        this.showBtnList = true;
                        this.showForm = false;
                    }
                    if (data?.success && data?.createdCases) {
                        this.message = this.createCaseCreatedMessage(data.createdCases);
                        this.messageTypeClass = 'result-message success slds-text-align_center';
                        this.showMessage = true;
                        this.showForm = false;
                    }
                } else {
                    this.showError(data.error);
                    this.showForm = false;
                }
                this.showSpinner = false;
            })
            .catch((e) => {
                console.log(`Submit Case error: ${e}`);
            });
    }

    updateCaseRecords() {
        this.showSpinner = true;

        this.updateCasesData();

        updateCases({
            cases: this.cases,
            customerQuery: this.comment,
            toneOfContact: this.toneOfContact,
            pnr: this.pnrItem?.pnr,
            departureDate: this.formData?.travelDate
        })
            .then((data) => {
                if (data?.success) {
                    this.message = getTranslatedLabel('cu_CaseUpdatedSuccessfullyMessage', this.langCode);
                    this.messageTypeClass = 'result-message success slds-text-align_center';
                    this.showMessage = true;
                }
                if (data?.error) {
                    this.showError(data.error);
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(`Update Cases error: ${JSON.stringify(error)}`);
                this.showError(error.body.message);
            });
    }

    updateCaseRecordsByPNR() {
        this.showForm = false;
        this.showSpinner = true;

        this.updateCasesData();

        updateCasesByPNR({
            pnr: this.pnrItem.pnr,
            customerQuery: this.formData.comment,
            toneOfContact: this.toneOfContact,
            departureDate: this.formData.travelDate
        })
            .then((data) => {
                if (data?.success) {
                    this.message = getTranslatedLabel('cu_CaseUpdatedSuccessfullyMessage', this.langCode);
                    this.messageTypeClass = 'result-message success slds-text-align_center';
                    this.showMessage = true;
                }
                if (data?.error) {
                    this.message = data.error;
                    this.messageTypeClass = 'result-message error slds-text-align_center';
                    this.showMessage = true;
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                this.message = error.body.message;
                this.messageTypeClass = 'result-message error slds-text-align_center';
                this.showMessage = true;
                console.log(`Update cases with PNR error: ${JSON.stringify(error)}`);
            });
    }

    // HELPERS
    clearForm() {
        this.template.querySelectorAll('input, textarea').forEach((element) => (element.value = ''));
    }

    sendSubmitToContainer() {
        this.dispatchEvent(new CustomEvent('changesubtitle', { detail: 'cu_WeAreCreatingYourCase' }));
    }

    showError(message) {
        this.messageTypeClass = 'result-message error slds-text-align_center';
        this.message = message;
        this.showMessage = true;
    }

    setInitialValues() {
        this.firstNameLabel = getTranslatedLabel('cu_FirstName', this.langCode);
        this.lastNameLabel = getTranslatedLabel('cu_LastName', this.langCode);
        this.phoneNumberLabel = getTranslatedLabel('cu_PhoneNumber', this.langCode);
        this.emailLabel = getTranslatedLabel('cu_Email', this.langCode);
        this.confirmEmailLabel = getTranslatedLabel('cu_ConfirmEmail', this.langCode);
        this.commentLabel = getTranslatedLabel('cu_YourComment', this.langCode);
        this.toneOfContactLabel = getTranslatedLabel('cu_ToneOfContactLabel', this.langCode);
        this.toneOfContactPlaceholder = getTranslatedLabel('cu_ToneOfContactPlaceholder', this.langCode);
        this.commentPlaceholder = getTranslatedLabel('cu_CommentPlaceholder', this.langCode);
        this.emailPlaceholder = getTranslatedLabel('cu_EmailPlaceholder', this.langCode);
        this.emailConfirmPlaceholder = getTranslatedLabel('cu_EmailConfirmPlaceholder', this.langCode);
        this.phoneNumberPlaceholder = getTranslatedLabel('cu_PhoneNumberPlaceholder', this.langCode);
        this.submitLabel = getTranslatedLabel('cu_Submit', this.langCode);
        this.praiseLabel = getTranslatedLabel('cu_Praise', this.langCode);
        this.toneOfContactOptions.push({
            label: this.praiseLabel,
            value: 'Praise'
        });
        this.neutralLabel = getTranslatedLabel('cu_NeutralFeedback', this.langCode);
        this.toneOfContactOptions.push({
            label: this.neutralLabel,
            value: 'Neutral'
        });
        this.complaintLabel = getTranslatedLabel('cu_Complaint', this.langCode);
        this.toneOfContactOptions.push({
            label: this.complaintLabel,
            value: 'Complaint'
        });

        if (this.addToExisting) {
            this.updateCaseRecordsByPNR();
        }
    }

    isInputsValid() {
        if (this.showForm) {
            if (!this.template.querySelector('c-generic_phone-number-input').isValid) {
                return false;
            }
            const emailRegexp = new RegExp(
                /^[a-zA-Z0-9][\-_\.\+\!\#\$\%\&\'\*\/\=\?\^\`\{\|]{0,1}([a-zA-Z0-9][\-_\.\+\!\#\$\%\&\'\*\/\=\?\^\`\{\|]{0,1})*[a-zA-Z0-9]@[a-zA-Z0-9][-\.]{0,1}([a-zA-Z0-9][-\.]{0,1})*[a-zA-Z0-9]\.[a-zA-Z0-9]{1,}([\.\-]{0,1}[a-zA-Z]){0,}[a-zA-Z0-9]{0,}$/i
            );
            if (emailRegexp.test(this.email)) {
                this.template.querySelector('input[name="email"]').setCustomValidity('');
            } else {
                this.template
                    .querySelector('input[name="email"]')
                    .setCustomValidity(getTranslatedLabel('cu_EmailIsNotValid', this.langCode));
                this.template.querySelector('input[name="email"]').reportValidity();
                return false;
            }
            if (emailRegexp.test(this.confirmEmail)) {
                this.template.querySelector('input[name="confirmEmail"]').setCustomValidity('');
            } else {
                this.template
                    .querySelector('input[name="confirmEmail"]')
                    .setCustomValidity(getTranslatedLabel('cu_EmailIsNotValid', this.langCode));
                this.template.querySelector('input[name="confirmEmail"]').reportValidity();
                return false;
            }

            const validationEmpty = [];

            this.template.querySelectorAll('input, textarea').forEach((field) => {
                if (field.value === '') {
                    validationEmpty.push(false);
                } else {
                    validationEmpty.push(true);
                }
            });

            if (!this.toneOfContact && !this.b2bForm) {
                validationEmpty.push(false);
            }

            if (validationEmpty.includes(false)) {
                this.showError(getTranslatedLabel('cu_PleaseFillAllNecessaryFields', this.langCode));
                return false;
            }
        }

        return true;
    }

    createCaseCreatedMessage(createdCases) {
        return (
            getTranslatedLabel('cu_CaseCreatedSuccessfullyMessage', this.langCode) +
            ' <b>' +
            createdCases[0].CaseNumber +
            '</b>. ' +
            getTranslatedLabel('cu_YouWillShortlyReceive', this.langCode)
        );
    }

    createApexParams() {
        let guest = {
            email: this.email,
            firstName: this.firstName,
            lastName: this.lastName,
            message: this.comment,
            phone: this.phoneNumber,
            dateOfTravel: this.formData.dateOfTravel,
            iban: this.formData.iban,
            bicOrSwift: this.formData.bicOrSwift,
            accountNumber: this.formData.accountNumber,
            sortCode: this.formData.sortCode,
            destination: this.formData.destination,
            selectedCountry: this.currentLabel,
            paypal: this.formData.paypal,
            savedFiles: this.fileIds,
            checkOnExisting: this.checkOnExisting,
            language: this.langCode,
            membershipNumber: this.formData.membershipNumber,
            birthDate: this.formData.birthDate,
            toneOfContact: this.toneOfContact,
            topic: this.topic,
            whatIsTheQuestion: this.whatIsTheQuestion,
            bookingLocation: this.formData.location,
            bookingDate: this.formData.bookingDate,
            departureDate: this.formData.travelDate,
            additionalAssistance: this.formData.additionalAssistanceOptions,
            additionalAssistanceOther: this.formData.additionalAssistanceOther
        };

        let args = {
            pnrItem: this.pnrItem,
            guestDetails: guest,
            buttonLabel: this.currentLabel,
            station: this.formData.direction,
            errorMessage: this.formData.errorMessage,
            origin: this.formData.origin,
            destination: this.formData.destination,
            isOnOurApp: this.formData.isOnOurApp || false,
            checkOnExisting: this.checkOnExisting,
            topic: this.topic ? getTranslatedLabel(this.topic, 'EN') : '',
            topicApiName: this.topic,
            whatIsTheQuestion: this.whatIsTheQuestion,
            classService: this.formData.classService,
            companyName: this.formData.companyName,
            dateOfTravel: this.formData.dateOfTravel,
            dateOfReturn: this.formData.dateOfReturn,
            timeOfTravel: this.formData.timeOfTravel,
            timeOfReturn: this.formData.timeOfReturn,
            assistanceCatering: this.formData?.assistanceCatering ? true : false,
            assistanceLuggage: this.formData?.assistanceLuggage ? true : false,
            assistanceBranding: this.formData?.assistanceBranding ? true : false,
            assistanceExperience: this.formData?.assistanceExperience ? true : false,
            assistanceCarriage: this.formData?.assistanceCarriage ? true : false,
            assistanceHalfcharter: this.formData?.assistanceHalfcharter ? true : false,
            assistanceCharter: this.formData?.assistanceCharter ? true : false,
            adultPassengers: this.formData.adultPassengers ? this.formData.adultPassengers : 0,
            childrenPassengers: this.formData?.childrenPassengers ? this.formData?.childrenPassengers : 0,
            infantsPassengers: this.formData?.infantsPassengers ? this.formData?.infantsPassengers : 0,
            tcn: this.formData?.tcn
        };

        return JSON.stringify(args);
    }

    updateCasesData() {
        for (const c of this.cases) {
            if (this.formData.additionalAssistanceOptions) {
                c.Type_of_Assistance__c = this.formData.additionalAssistanceOptions;
                c.Customer_Type__c = CUSTOMER_TYPE.SPECIAL_ASSISTANCE;
            }
            if (this.formData.additionalAssistanceOther) {
                c.Type_of_Assistance_Description__c = this.formData.additionalAssistanceOther;
            }
        }
    }
}