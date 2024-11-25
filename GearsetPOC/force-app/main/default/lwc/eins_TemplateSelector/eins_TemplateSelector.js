import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import LANGUAGE_FIELD from '@salesforce/schema/Case.Preferred_Language__c';
import CaseObject from '@salesforce/schema/Case'; 

import getEmailTemplates from '@salesforce/apex/Eins_CaseEmailTemplateController.getEmailTemplates';
import getCaseLanguage from '@salesforce/apex/Eins_CaseEmailTemplateController.getCasePreferredLanguage';
import setCaseLanguage from '@salesforce/apex/Eins_CaseEmailTemplateController.setCasePreferredLanguage';
import updateTemplateOnCase from '@salesforce/apex/Eins_CaseEmailTemplateController.updateTemplateOnCase';
import discardTemplateFromCase from '@salesforce/apex/Eins_CaseEmailTemplateController.discardTemplateFromCase';
import sendAndCloseCase from '@salesforce/apex/Eins_CaseEmailTemplateController.sendAndCloseCase';
import quickSend from '@salesforce/apex/Eins_CaseEmailTemplateController.quickSend';
import getCurrentLabel from '@salesforce/apex/eins_AdvisorTagCorrectorController.getCurrentLabel';
import updateMasterLabel from '@salesforce/apex/eins_AdvisorTagCorrectorController.updateMasterLabel';

const TOOLTIP_WIDTH = 35;

export default class Eins_TemplateSelector extends LightningElement {
    selectedValue;
    @track selectedLanguage;
    showSpinner = false;
    showTemplate = false;
    showLanguage = false;
    @track tooltipText;
    htmlText;
    templatesWithHtml = new Map();
    @track wiredTemplateResponse = [];
    @track wiredTagResponse = [];
    @wire (getObjectInfo, {objectApiName: CaseObject})
    objectInfo
    @track options = [];
    @track languageOptions;
    @api recordId;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LANGUAGE_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) 
            this.languageOptions = data.values;
    }  
    @wire(getCaseLanguage, { recordId : '$recordId' })
    acceptCaseLanguage(result) {
        if (result) {
            this.selectedLanguage = result.data;
        }
    }

    @wire(getEmailTemplates, { recordId : '$recordId' })
    typePicklistValues(result) {
        if (result) {
            // window.console.log('typePicklistValues ===> ' + JSON.stringify(result));
            this.wiredTemplateResponse = result;
            
            if (result.data) {
                if(result.data.length > 0 && result.data[0]?.showLanguage
                    || result.data.length === 0){
                    this.showLanguage = true;
                }
                let optionsValues = [];
                this.selectedValue = null;
                for (let i = 0; i < result.data.length; i++) {
                    let plainText = result.data[i].emailTemplatePlain;

                    if (plainText.length > 150) {
                        plainText = plainText.substring(0, 149) + "...";
                    }
                    if (result.data[i].selected) {
                        this.selectedValue = result.data[i].emailId;
                    }
                    //window.console.log('typePicklistValues ===> ' + plainText);
                    this.templatesWithHtml.set(result.data[i].emailId, result.data[i].emailTemplate);
                    optionsValues.push({
                        htmlText: result.data[i].emailTemplate,
                        emailId: result.data[i].emailId,
                        plainText: plainText,
                        name: result.data[i].name,
                        selected: result.data[i].selected
                    })
                }
                this.options = optionsValues;
            }
            else if (result.error) {
                window.console.log('error ===> ' + JSON.stringify(result.error));
            }
            this.showSpinner = false;
        }   
    }

    onMouseOver(event){
        this.tooltipPosition(event);
        this.mouseToggle(event);
    }

    onMouseOut(event){
        this.mouseToggle(event);
    }

    mouseToggle(event){
        let targEmailId = event.currentTarget.dataset.emailid;
        let emailInd = this.options.findIndex((op => op.emailId == targEmailId))
        this.options[emailInd].showTooltip ^= true;
    }

    tooltipPosition(event){
        let currentLeft = event.currentTarget.getBoundingClientRect().left;
        let screenWidth = window.innerWidth;
        let leftspace = currentLeft/screenWidth *100;
        let leftPos = currentLeft > screenWidth/2 ? `${leftspace - TOOLTIP_WIDTH}%` : `${leftspace + TOOLTIP_WIDTH}%`;

        document.documentElement.style.setProperty('--tooltip-left', leftPos );
    }

    setTemplate(event) {
        this.showSpinner = true;
        this.selectedValue = event.target.value;
        updateTemplateOnCase({recordId: this.recordId, templateId: this.selectedValue})
            .then(()=> {
                this.showSpinner = false;
                refreshApex(this.wiredTemplateResponse);
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(
                error => {
                    this.showSpinner = false;
                    this.showMessage('Error', error.body.message, 'error');
                }
            );
    }

    showEmailTemplate(event){
        this.showTemplate = true;
        let emailId = event.currentTarget.id;
        emailId = emailId.substring(0, emailId.indexOf('-'));
        this.htmlText = this.templatesWithHtml.get(emailId);
    }

    hideEmailTemplate(event){
        this.showTemplate = false;
    }
    handleLanguageSelect(evt){
        this.showSpinner = true;
        this.selectedLanguage = evt.detail.value;

        setCaseLanguage({recordId: this.recordId, language: this.selectedLanguage}) 
            .then(data => {
                if (data == null) {
                    this.showMessage('Success', 'Language was changed.', 'success');
                }
                this.showSpinner = false;
                window.open(`/${this.recordId}`, "_self");
            })
            .catch(
                error => {
                    this.showSpinner = false;
                    this.showMessage('Error', error.body.message, 'error');
                }
            );

    }
    handleSendAndCloseCase() {
        this.showSpinner = true;
        sendAndCloseCase({recordId: this.recordId, templateId: this.selectedValue})
            .then(data => {

                if (data) {
                    this.showMessage('Success', 'Email was send.', 'success');
                }
                this.showSpinner = false;
                window.open(`/${this.recordId}`, "_self");
            })
            .catch(
                error => {
                    this.showSpinner = false;
                    this.showMessage('Error', error.body.message, 'error');
                }
            );
    }

    handleQuickSend() {
        this.showSpinner = true;
        quickSend({recordId: this.recordId, templateId: this.selectedValue})
            .then(data => {
                if (data) {
                    this.showMessage('Success', 'Email was send.', 'success');
                }
                this.showSpinner = false;
                window.open(`/${this.recordId}`, "_self");
            })
            .catch(
                error => {
                    this.showSpinner = false;
                    this.showMessage('Error', error.body.message, 'error');
                }
            );
    }

    @api showTagSelector = false;
    @api showEditTag = false;
    @api showSpinnerAdviser = false;
    @api showSaveButton = false;
    // @api tagValue = 'REFUND'
    @api currentTagValue = 'REFUND'
    @track optionsTag = []

    @wire(getCurrentLabel, { recordId : '$recordId' })
    getTagData(result){
        if (result) {
            // window.console.log('getTagData ===> ' + JSON.stringify(result));
            let tagValue = '';
            this.wiredTagResponse = result;
            if (result.data) {
                tagValue = result.data.currentTag;
                if (tagValue != 'No intent') {
                    this.currentTagValue = 'This case was tagged by Einstein as ' + result.data.currentTag;
                } else {
                    this.currentTagValue = 'Classification suggestion has not been done yet';
 
                }
                this.optionsTag = []
                if  (Object.keys(result.data).indexOf('tags') && result.data.tags.length > 0) {
                    for (let i = 0; i < result.data.tags.length; i++) {
                        if (tagValue!= result.data.tags[i]) {
                            this.optionsTag.push( { label: result.data.tags[i], value: result.data.tags[i]});
                        }
                   }
                   this.optionsTag.sort((a, b) => (a.label > b.label) ? 1 : -1)
                }
            } else if (result.error) {
                window.console.log('error ===> ' + JSON.stringify(result.error));
            }
            this.showSpinnerAdviser = false;
            this.showTagSelector = true;

        }

    }

    get isDiscardButtonDisabled() {
        return this.selectedValue == null;
    }

    handleUpdateClick() {
        this.showTagSelector = false;
        this.showEditTag = true;
    }

    handleChange(event) {
        if (this.value != event.detail.value) {
            this.tagValue = event.detail.value;
            this.showSaveButton = true;
        }
    }

    handleSaveClick() {
        this.showSpinnerAdviser = true;
        updateMasterLabel({recordId: this.recordId, label: this.tagValue})
        .then(data => {
                refreshApex(this.wiredTagResponse);
                this.showSpinner = true;
                refreshApex(this.wiredTemplateResponse);
                this.showMessage('Success', 'Case tag was changed!', 'success');
                this.showSpinnerAdviser = false;
                this.showTagSelector = true;
                this.showEditTag = true;
                this.showSaveButton = false;
            
        })
        .catch(
            error => {
                this.showSpinnerAdviser = false;
                this.showMessage('Error', error.body.message, 'error');
            }
        );
    }

    handleDiscardTemplate() {
        this.showSpinner = true;
        discardTemplateFromCase({ recordId: this.recordId })
            .then(()=> {
                let selectedTemplateButton = this.template.querySelector(`input[id*='${this.selectedValue}']`);
                if (selectedTemplateButton) {
                    selectedTemplateButton.checked = false;
                }
                this.showSpinner = false;
                refreshApex(this.wiredTemplateResponse);
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(
                error => {
                    this.showSpinner = false;
                    this.showMessage('Error', error.body.message, 'error');
                }
            );
    }

    showMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message,
                variant: variant,
            }),
        );
    }
}