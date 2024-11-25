import { LightningElement, api, track } from 'lwc';
import { getTranslatedLabel, getAddSomethingParams, getDynLabelsByPnrData, getMidStepParams } from 'c/generic_utils';
import { LANGUAGE_CODE_TO_HOME_PAGE_URL } from 'c/dltConstants';

export default class Generic_container extends LightningElement {
    @api
    langCode;
    @api
    isGroupBooking = false;
    @api
    hideSpinner;

    @track
    breadcrumbs = [];

    // PNR and booking details
    @track
    pnrData = {
        pnr: '',
        isDisrupted: false,
        bookingType: '',
        isFree: false,
        isRefundable: false,
        isExchangable: false,
        isChangeableOnline: false,
        addInfo: false,
        cancelOption: '',
        error: ''
    };

    @track
    membershipData = {
        membershipNumber: '',
        birthDate: null,
        error: ''
    };

    //---
    prevLabel;
    helpCenterLink;
    helpCenterLabel;
    contactUsPageTitle;
    cuPermanentPageText;
    pageSubtitle;
    pageTitle;
    btnListType;
    btnListLabel;
    formType;
    showUploader = false;
    showDynamicText = false;
    dynTextLabel;
    dynamicTextOutput;
    selectedAction;
    currLabel;
    addToExisting = false;
    topic;
    whatIsTheQuestion;
    origin;
    destination;
    isLondon = false;
    b2bForm = false;
    isCompensationCheck = false;

    @track
    inputData = [];

    @track
    formData = {};

    showMessage = false;
    message;
    messageTypeClass = 'result-message success slds-text-align_center slds-m-bottom_medium';

    _eventDetailsStorage = {};

    // GETTERS
    get hasBtnListType() {
        return this.btnListType ? true : false;
    }

    get hasPrevStep() {
        return this.breadcrumbs.length > 1 ? true : false;
    }

    get hasForm() {
        return this.formType ? true : false;
    }

    get hasGenericInput() {
        return this.inputData?.length > 0 ? true : false;
    }

    get showBreadcrumbs() {
        return this.breadcrumbs.length > 1 ? true : false;
    }

    get exitButtonLabel() {
        return getTranslatedLabel('cu_Exit_BTN', this.langCode);
    }

    connectedCallback() {
        this.setInitials();
    }

    setInitials() {
        this.pageSubtitle = getTranslatedLabel('cu_DoYouHaveBookingWithEurostar', this.langCode);
        this.helpCenterLabel = getTranslatedLabel('cu_HelpCenter', this.langCode);
        this.contactUsPageTitle = getTranslatedLabel('cu_NeedToAskQuestion', this.langCode);
        this.cuPermanentPageText = getTranslatedLabel('cu_PermanentPageText', this.langCode);
        this.prevLabel = getTranslatedLabel('cu_Back', this.langCode);
        this.helpCenterLink = getTranslatedLabel('cu_HelpCenterLink', this.langCode);
        this.btnListType = 'initial';
        this.breadcrumbs.push({
            label: getTranslatedLabel('cu_DoYouHaveBookingWithEurostar', this.langCode),
            step: 0,
            eventDetails: {
                listType: 'initial',
                showDynamicText: false,
                showUploader: false,
                subtitle: 'cu_DoYouHaveBookingWithEurostar'
            }
        });
        this.showUploader = true;
        this.formType = '';
        if (this.isGroupBooking) {
            this.setGroupBookingInitialPage();
        } else {
            this.hideSpinner();
        }
    }

    setGroupBookingInitialPage() {
        this.pageSubtitle = getTranslatedLabel('cu_B2BBookingWelcomeMessage', this.langCode);
        this.contactUsPageTitle = getTranslatedLabel('cu_MakeABooking', this.langCode);
        this.btnListType = 'initialGroupBooking';
        this.breadcrumbs = [];
        this.breadcrumbs.push({
            label: getTranslatedLabel('cu_MakeABooking', this.langCode),
            step: 0,
            eventDetails: {
                listType: 'initialGroupBooking',
                showDynamicText: true,
                dynTextLabel: 'cu_B2BBookingWelcomeMessage',
                showUploader: false,
                subtitle: 'cu_MakeABooking'
            }
        });
    }

    handleListButtonClick(event) {
        try {
            event.stopPropagation();

            let eventDetails = this.processMidStep(event.detail.eventDetails);

            if (eventDetails?.addSomething) {
                Object.assign(
                    eventDetails,
                    getAddSomethingParams(this.pnrData?.bookingType ? this.pnrData.bookingType : '')
                );
            }

            if (
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_Yes', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_No', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_StillNeedHelp', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_StillNeedAssistance', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_NoINeedMoreAssistance', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_YesAddToExisting', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_NoCreateNewCase', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_InTheEurozone', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_InTheUK', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_OutsideOfEurope', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_IWouldLikeToMakeAClaim', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_AskAQuestion', this.langCode) &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_Yes', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_No', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_StillNeedHelp', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_StillNeedAssistance', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_NoINeedMoreAssistance', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_YesAddToExisting', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_NoCreateNewCase', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_InTheEurozone', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_InTheUK', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_OutsideOfEurope', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_IWouldLikeToMakeAClaim', 'EN') &&
                event.detail.eventDetails.currLabel != getTranslatedLabel('cu_AskAQuestion', 'EN')
            ) {
                this.currLabel = event.detail.eventDetails.currLabel;
            }

            this.addBreadcrumbItem(eventDetails);
            this.buildComponents(eventDetails);
        } catch (error) {
            console.log(`ListButtonClick error: ${error}`);
        }
    }

    handleBreadcrumbClick(event) {
        event.stopPropagation();
        this.breadcrumbs.length = event.detail + 1;
        const eventDetails = this.breadcrumbs[event.detail].eventDetails;
        this.buildComponents(eventDetails);
        if (
            this.breadcrumbs.filter((e) => e.eventDetails.subtitle == 'cu_WhereAreYouTravellingFrom').length == 0 ||
            this.breadcrumbs[event.detail].eventDetails.subtitle == 'cu_WhereAreYouTravellingFrom'
        ) {
            this.origin = null;
        }
    }

    handlePrevClick() {
        if (this.breadcrumbs[this.breadcrumbs.length - 1].eventDetails.subtitle == 'cu_WhereAreYouTravellingTo') {
            this.origin = null;
        }
        this.breadcrumbs.length = this.breadcrumbs.length - 1;
        const eventDetails = this.breadcrumbs[this.breadcrumbs.length - 1].eventDetails;
        this.buildComponents(eventDetails);
    }

    handleProcessInputData(event) {
        event.stopPropagation();

        let eventDetails = event.detail.eventDetails;

        const emptyPnrData = {
            pnr: '',
            isDisrupted: false,
            bookingType: '',
            isFree: false,
            isRefundable: false,
            isExchangable: false,
            isChangeableOnline: false,
            addInfo: false,
            cancelOption: '',
            error: ''
        };

        if (eventDetails?.pnrData) {
            this.pnrData = eventDetails?.pnrData?.pnr ? eventDetails?.pnrData : emptyPnrData;
        }
        if (eventDetails?.membershipData && eventDetails?.membershipData?.membershipNumber) {
            this.membershipData = eventDetails.membershipData;
        }
        if (this.template.querySelector('c-generic_input')) {
            eventDetails.formData = [];
            this.template.querySelectorAll('c-generic_input').forEach((element) => {
                eventDetails.formData.push({ inputName: element.inputName, inputValue: element.getInputValue() });
            });
        }
        if (eventDetails?.checkBirthDate) {
            const dateValue = this.template.querySelector('c-generic_input').getInputValue();
            if (this.membershipData.birthDate !== dateValue) {
                this.message = getTranslatedLabel('cu_CannotSubmitWithoutDOB', this.langCode);
                this.messageTypeClass = 'result-message error slds-text-align_center slds-m-bottom_medium';
                this.showMessage = true;
                return;
            }
        }
        if (eventDetails?.subtitle == 'cu_WhereAreYouTravellingTo') {
            this.origin = this.template.querySelector('c-generic_input').getInputValue();
        }
        if (eventDetails?.subtitle == 'cu_ReturnOrSingle') {
            this.destination = this.template.querySelector('c-generic_input').getInputValue();
        }

        if (
            this.destination == getTranslatedLabel('cu_Station_St_Pancras_International', this.langCode) ||
            this.origin == getTranslatedLabel('cu_Station_St_Pancras_International', this.langCode)
        ) {
            this.isLondon = true;
        }

        eventDetails = this.processMidStep(eventDetails);

        this.addBreadcrumbItem(eventDetails);
        this.buildComponents(eventDetails);
    }

    processMidStep(initialEvtDetails) {
        let eventDetails = { ...initialEvtDetails };

        if (eventDetails.midStep) {
            eventDetails.midStep = undefined;

            this._eventDetailsStorage.mainStep = eventDetails;

            eventDetails =
                {
                    ...getMidStepParams(initialEvtDetails.midStep),
                    ...{ formData: eventDetails.formData }
                } || eventDetails;
        }

        if (eventDetails.finishMidStep) {
            eventDetails = { ...this._eventDetailsStorage.mainStep, ...{ formData: eventDetails.formData } };
        }

        return eventDetails;
    }

    buildComponents(eventDetails) {
        try {
            this.showMessage = false;
            this.pageTitle = null;
            if (eventDetails?.topic) {
                this.topic = eventDetails.topic;
            }
            if (eventDetails?.whatIsTheQuestion) {
                this.whatIsTheQuestion = eventDetails.whatIsTheQuestion;
            }
            if (eventDetails?.redirectUrl) {
                this.openLink(getTranslatedLabel(eventDetails.redirectUrl, this.langCode));
                return;
            }
            if (eventDetails?.title && eventDetails?.title != '') {
                this.pageTitle = getTranslatedLabel(eventDetails.title, this.langCode);
            }
            if (eventDetails?.subtitle && eventDetails?.subtitle != '') {
                this.pageSubtitle = getTranslatedLabel(eventDetails.subtitle, this.langCode);
            }

            if (eventDetails?.listType && eventDetails.listType == 'notDisruptedWithPNR') {
                if (this.pnrData.isLastMinuteTicket) {
                    eventDetails.showDynamicText = true;
                    eventDetails.dynTextLabel = 'cu_LastMinuteTicketDynamicText';
                }
            }

            if (eventDetails?.showDynamicText && eventDetails?.dynTextLabel != '') {
                this.dynamicTextOutput = eventDetails.dynTextLabel;
            }
            if (eventDetails?.isCompensationCheck) {
                this.isCompensationCheck = true;
            }

            if (
                eventDetails?.showDynamicText &&
                eventDetails?.defineDynByPnr &&
                eventDetails?.flowType &&
                eventDetails?.param &&
                this.pnrData?.pnr
            ) {
                this.dynamicTextOutput = getDynLabelsByPnrData(this.pnrData, eventDetails.flowType, eventDetails.param);
                if (!this.dynamicTextOutput) {
                    this.pageSubtitle = eventDetails?.subtitle
                        ? getTranslatedLabel(eventDetails.subtitle, this.langCode)
                        : this.pageSubtitle;
                }
            }

            if (eventDetails?.formType && eventDetails.formType) {
                this.generateFormData();
                this.formType = eventDetails.formType;
                this.addToExisting = eventDetails?.addToExisting ? true : false;
            } else {
                this.formType = '';
                this.selectedAction = '';
            }
            if (eventDetails?.b2bForm && eventDetails.b2bForm) {
                this.b2bForm = true;
            }

            this.showUploader = eventDetails?.showUploader ? true : false;
            this.showDynamicText = eventDetails?.showDynamicText ? true : false;

            if (eventDetails?.inputData?.length > 0) {
                if (eventDetails?.subtitle == 'cu_SpecialAssistancePicklist' && this.isLondon == false) {
                    this.inputData = [];
                    eventDetails.inputData.forEach((element) => {
                        if (element?.showForAll) this.inputData.push(element);
                    });
                } else {
                    this.inputData = eventDetails.inputData;
                }
            } else {
                this.inputData = [];
            }

            if (eventDetails?.listType && eventDetails.listType !== '') {
                this.btnListType = eventDetails.listType;
                this.btnListLabel =
                    eventDetails?.listType && eventDetails?.btnListLabel && eventDetails.btnListLabel !== ''
                        ? eventDetails.btnListLabel
                        : '';
                if (
                    eventDetails?.listData &&
                    eventDetails?.listData?.objectName &&
                    eventDetails.listData.objectName !== ''
                ) {
                    this.loadButtonListWithData(eventDetails.listData.objectName, this.langCode);
                } else {
                    this.loadButtonList();
                }
            } else {
                this.btnListLabel = '';
                this.btnListType = '';
            }
        } catch (error) {
            console.log(`Build Components error: ${error}`);
        }
    }

    openLink(url) {
        window.open(url, '_blank');
    }

    loadButtonList() {
        if (this.template.querySelector('c-generic_button-list')) {
            this.template.querySelector('c-generic_button-list').loadButtons(this.btnListType, this.btnListLabel);
        }
    }

    loadButtonListWithData(objectName, lang) {
        this.template.querySelector('c-generic_button-list').loadButtonsWithData(objectName, lang);
    }

    addBreadcrumbItem(eventDetails) {
        if (!eventDetails?.redirectUrl) {
            this.breadcrumbs.push({
                label: getTranslatedLabel(eventDetails.subtitle, this.langCode),
                step: this.breadcrumbs.length,
                eventDetails: eventDetails
            });
            this.loadBreadcrumbs();
        }
    }

    loadBreadcrumbs() {
        if (this.template.querySelector('c-generic_breadcrumbs')) {
            this.template.querySelector('c-generic_breadcrumbs').loadElements(this.breadcrumbs);
        }
    }

    generateFormData() {
        this.formData = {};
        this.breadcrumbs.forEach((element) => {
            if (element?.eventDetails && element?.eventDetails?.formData && element.eventDetails.formData.length > 0) {
                element.eventDetails.formData.forEach((element) => {
                    this.formData[element.inputName] = element.inputValue;
                });
            }
        });
        this.selectedAction = this.breadcrumbs.findLast(
            (element) => element?.eventDetails?.selectedAction && element.eventDetails.selectedAction !== ''
        )?.eventDetails.selectedAction;
    }

    handleShowErrorInput(event) {
        event.stopPropagation();
        this.message = event.detail;
        this.messageTypeClass = 'result-message error slds-text-align_center slds-m-bottom_medium';
        this.showMessage = true;
    }

    handleChangePageSubtitle(event) {
        this.pageSubtitle = getTranslatedLabel(event.detail, this.langCode);
        this.showDynamicText = false;
    }

    handleCleanErrorMessage() {
        this.message = '';
        this.showMessage = false;
    }

    handleExitButtonClick() {
        let confirmMessage = getTranslatedLabel('cu_LeavePage_BTN', this.langCode);
        let agreedToProceed = confirm(confirmMessage);
        if (agreedToProceed) {
            this.redirectToHomePage();
        }
    }

    redirectToHomePage() {
        let url = this.langCode ? LANGUAGE_CODE_TO_HOME_PAGE_URL[this.langCode] : LANGUAGE_CODE_TO_HOME_PAGE_URL.EN;
        if (url) {
            window.open(url, '_self');
        }
    }
}