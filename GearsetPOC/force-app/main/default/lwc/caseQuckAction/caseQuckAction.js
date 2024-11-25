import { LightningElement, api, wire, track } from 'lwc';
import getRecordForShowing from'@salesforce/apex/CaseQuickactionController.getpopulatedFields';
import upsertDraftRecord from '@salesforce/apex/CaseQuickactionController.upsertDraftRecord';
import ERROR_DEFAULT_MESSAGE from '@salesforce/label/c.Error_GENERAL_Message';
import WARNING_MESSAGE from '@salesforce/label/c.cu_WarningTitle';
import FOR_WARNING_MESSAGE from '@salesforce/label/c.ForWarningTitle';
import POPULATE_REQUED_FIELDS from '@salesforce/label/c.Please_Populate_Required_Fields';
import DRAFT from '@salesforce/label/c.Draft';
import THIS_DRAFT_CREATED_BY from '@salesforce/label/c.This_Draft_record_was_created_by';
import PLEASE_DISCARD_DRAFT from '@salesforce/label/c.Please_discard_this_draft_to_continue';
import DUPLICATE_PNR from '@salesforce/label/c.Duplicate_PNR';


export default class CaseQuckAction extends LightningElement {
    
    @api quickActionSettings;
    @api errorMessageHeder = '';
    @api errorMessageBody = '';
    @track quickActionFields;
    showSpinner = true;
    isChanged = false;
    isShowErrorMessage = false;
    isDisabled = false;

    disconnectedCallback() {
        this.handleCreateDraft();
    }

    @wire(getRecordForShowing, {quickActionSettings : '$quickActionSettings'})
        getRecordForShowing(result) {

            if (result.data) {
                this.quickActionFields = JSON.parse(JSON.stringify(result.data));
                this.populteFieldValues();
                this.showSpinner = false;

            } else if (result.error) {
                this.errorMessageHeder = 'We Have an error:';
                this.errorMessageBody = error.body.message;
                this.isShowErrorMessage = true;
            }
        }

    handleCreateDraft() {

        this.isShowErrorMessage = false;
        if (this.isChanged) {

            if (this.quickActionFields.draftStatusValue == 'true' || this.quickActionFields.draftStatusValue == 'false') {
                this.quickActionFields.objectRecord[this.quickActionFields.statusField] = this.quickActionFields.draftStatusValue == 'true';
            } else {
                this.quickActionFields.objectRecord[this.quickActionFields.statusField] = this.quickActionFields.draftStatusValue;
            }

            if (this.quickActionFields.sObjectName == 'Compensation__c') {
                this.quickActionFields.objectRecord['Comp_Approval_Status__c'] = 'Draft';
            }

            if (this.quickActionFields.sObjectName == 'BAF_Adjustment_Request__c') {
                this.quickActionFields.objectRecord['PNR_Draft__c'] = this.quickActionFields.objectRecord['PNR__c'];
                this.quickActionFields.objectRecord['PNR__c'] = null;
            }
            
            this.upsertDraftRecord();
        }
    }

    handleCancelDraft() {
        this.isShowErrorMessage = false;
        this.showSpinner = true;

        let childRecord = {};
        childRecord.Id = this.quickActionFields.draftId;

        if (this.quickActionFields.cancelStatusValue == 'true' || this.quickActionFields.cancelStatusValue == 'false') {      
            childRecord[this.quickActionFields.statusField] = this.quickActionFields.cancelStatusValue == 'true';
        } else {
            childRecord[this.quickActionFields.statusField] = this.quickActionFields.cancelStatusValue;
        }

        if (this.quickActionFields.sObjectName == 'Compensation__c') {
            childRecord['Comp_Approval_Status__c'] = 'Draft';
        }
        if (this.quickActionFields.sObjectName == 'Datacash_Refund_Request__c') {
            childRecord['Duplicate_Request_No_Longer_Needed__c'] = true;
        }
        if (this.quickActionFields.sObjectName == 'BAF_Adjustment_Request__c') {
            childRecord['PNR__c'] = null;
        }

        this.quickActionFields.objectRecord = childRecord;

        this.upsertDraftRecord();
    }

    handleConfirmDraft() {
        this.isShowErrorMessage = false;
        this.showSpinner = true;

        let isRequesdFieldsPopulated = true;
                
        if (this.quickActionFields.sObjectName == 'Datacash_Refund_Request__c') {
            let recordValue;
            if (this.quickActionFields.confirmStatusValue == 'true' || this.quickActionFields.confirmStatusValue == 'false') {
                recordValue = this.quickActionFields.confirmStatusValue == 'true';
            } else {
                recordValue = this.quickActionFields.confirmStatusValue;
            }
            this.quickActionFields.objectRecord[this.quickActionFields.statusField] = recordValue;

        } else {
            this.quickActionFields.objectRecord[this.quickActionFields.statusField] = this.quickActionFields.confirmStatusValue;
        }

        
        if (this.quickActionFields.sObjectName == 'Compensation__c') {
            this.quickActionFields.objectRecord['Comp_Approval_Status__c'] = 'Awaiting Approval';
        }
      
        this.quickActionFields.fields.forEach(lineItem => {
            lineItem.forEach(item => {
                if ((item.isRequired == true) && (this.quickActionFields.objectRecord[item.fieldName] == undefined)) {
                    isRequesdFieldsPopulated = false;
                }
            });
        });

        if (isRequesdFieldsPopulated) {
            this.upsertDraftRecord();
        } else {
            this.showSpinner = false;

            this.errorMessageHeder = WARNING_MESSAGE;
            this.errorMessageBody = POPULATE_REQUED_FIELDS;
            this.isShowErrorMessage = true;
        }
    }

    upsertDraftRecord() {
        let recordForUpsert = {};
        for (var key in this.quickActionFields.objectRecord) {
            if (!(this.quickActionFields.objectRecord[key] instanceof Object)) {
                recordForUpsert[key] = this.quickActionFields.objectRecord[key];
            }
        }
        this.isChanged = false;

        upsertDraftRecord({ objectRecord: recordForUpsert,  sObjectName: this.quickActionFields.sObjectName})
            .then(result => {
                this.showSpinner = false;
                if (result.BAFAdjasmentPNRExist) {
                    this.isShowErrorMessage = true;
                    this.errorMessageHeder = FOR_WARNING_MESSAGE;
                    this.errorMessageBody = DUPLICATE_PNR;
                } else {
                    this.quickActionFields = {};
                    window.location.reload();
                }
            })
            .catch(error => {
                console.log('CASE QUICKACTION ERROR: ', error);
                this.errorMessageHeder = ERROR_DEFAULT_MESSAGE;
                this.errorMessageBody = this.getErrorMessage(error);
                this.populteFieldValues();
                this.showSpinner = false;
                this.isShowErrorMessage = true;
            });
    }


    getErrorMessage(errorObject) {
        let errorMessage = '';
        let errorMessages = [];

        if (errorObject.body.message) {
            errorMessage += errorObject.body.message;
        } else if (errorObject.body.output != null) {
            if(errorObject.body.output.fieldErrors) {
                errorMessages = errorObject.body.output.fieldErrors;
                for (var prop in errorMessages) {
                    errorMessage += ' ' + errorMessages[prop][0].message + '; ';
                };
            } else if (Array.isArray(errorObject.body.output.errors)) {
                errorMessages = errorObject.body.output.errors;
                for (var prop in errorMessages) {
                    errorMessage += ' ' + errorMessages[prop].message + '; ';
                };
            }        
        } else if (errorObject.body.fieldErrors) {
            for (var prop in errorObject.body.fieldErrors) {
                errorObject.body.fieldErrors[prop].forEach(fieldError => {
                    errorMessage += ' ' + fieldError.message + '; ';
                });
            };
        }

        return errorMessage;
    }

    populteFieldValues() {
        this.quickActionFields.fields.forEach(lineItem=> {
            lineItem.forEach(field=> {
                if (field.fieldName) {
                    if (this.quickActionFields.sObjectName == 'BAF_Adjustment_Request__c' && field.fieldName == 'PNR__c') {
                        field.value = this.quickActionFields.objectRecord['PNR_Draft__c'];

                        if (this.quickActionFields.isDraft) {
                            this.quickActionFields.objectRecord['PNR__c'] = this.quickActionFields.objectRecord['PNR_Draft__c'];
                        }

                    } else {
                        field.value = this.quickActionFields.objectRecord[field.fieldName];
                    }
                }
            })
        })

        if (this.quickActionFields.isDraft) {
            this.errorMessageHeder = DRAFT;
            if (!this.quickActionFields.isDraftOwner) {
                this.errorMessageBody = THIS_DRAFT_CREATED_BY + ' ' + this.quickActionFields.ownerName + '. ' + PLEASE_DISCARD_DRAFT;
                this.isDisabled = true;
            } 
            this.isShowErrorMessage = true;
        }

        if (this.quickActionFields.BAFAdjasmentPNRExist) {
            if (this.isShowErrorMessage) {
                this.errorMessageBody += DUPLICATE_PNR;
            } else {
                this.isShowErrorMessage = true;
                this.errorMessageHeder = FOR_WARNING_MESSAGE;
                this.errorMessageBody = DUPLICATE_PNR;
            }
        }
    }

    handleChange(event) {
        if (event.detail.checked != undefined) {
            this.quickActionFields.objectRecord[event.target.dataset.id] = event.detail.checked;
        } else {
            this.quickActionFields.objectRecord[event.target.dataset.id] = Array.isArray(event.detail.value) ? event.detail.value[0] : event.detail.value;
        }        
        this.isChanged = true;
    }

    validateFields() {
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
        });
    }

}