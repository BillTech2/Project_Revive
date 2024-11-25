/**
 * Created by JU on 08.12.2022.
 */

import {api, track, wire, LightningElement} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getFormFieldsWrapperList from '@salesforce/apex/DogApproval.getFormFieldsWrapperList'
import firstSubmit  from '@salesforce/apex/DogApproval.firstSubmit'
// import downloadPDF from '@salesforce/apex/DogApproval.getPdfFile';
// import uploadSignedDoc from '@salesforce/apex/DogApproval.uploadSignedDoc';
import formDogRequest from '@salesforce/resourceUrl/FormAssistanceDogApprovalRequest';
import Eins_DogApprovalThankYou1 from "@salesforce/label/c.Eins_DogApprovalThankYou1";
import Eins_DogApprovalThankYou2 from "@salesforce/label/c.Eins_DogApprovalThankYou2";
import Eins_DogApprovalDownloadPrintVersion from "@salesforce/label/c.Eins_DogApprovalDownloadPrintVersion";
import Eins_DogApproval from "@salesforce/label/c.Eins_DogApproval";
import Eins_DogApprovalUnderReview from "@salesforce/label/c.Eins_DogApprovalUnderReview";
import Eins_DogApprovalEmailResponse from "@salesforce/label/c.Eins_DogApprovalEmailResponse";
import Eins_DogApprovalReviewComments from "@salesforce/label/c.Eins_DogApprovalReviewComments";
import Eins_DogApprovalCheckFields from "@salesforce/label/c.Eins_DogApprovalCheckFields";

export default class DogApproval extends LightningElement {
    labels = {
        Eins_DogApprovalThankYou1,
        Eins_DogApprovalThankYou2,
        Eins_DogApprovalDownloadPrintVersion,
        Eins_DogApproval,
        Eins_DogApprovalUnderReview,
        Eins_DogApprovalEmailResponse,
        Eins_DogApprovalReviewComments,
        Eins_DogApprovalCheckFields
    };

    @api langCode;
    @api dogObjId;
    fieldsBlocks = [];
    @track showFields;
    @track filesUploaded = [];
    @track fileNames = '';
    populatedFields = [];
    showSpinner = false;
    dogsObg = {};
    @track isFirstSubmittionStep;
    @track isSignedFileUploadNecessaryStep;
    @track isCorrectionStep;
    @track isUnderReview;
    @track disabledInputs;
    @track isParkingPage;
    @track advisorComments;
    isDownloadForm = false;
    showFormBox = true;
    showThankYou = false;
    showError = false;
    pleaseCheckFields = 'Please check that all fields are completed';
    personalDataCheckbox = false;
    responsibilityCheckbox = false;
    animalResponsibilityCheckbox = false;
    showDownload = false;


    @wire(getFormFieldsWrapperList,{ recordId : '$dogObjId' })formFields({error, data}){
        if(data){
            console.log('dogId ' + this.dogObjId);
            console.log(data);
            this.fieldsBlocks = data.formWrapper;
            this.showFields = true;
            this.isFirstSubmittionStep = data.Status==null;
            this.isSignedFileUploadNecessaryStep = data.Status=='Waiting for signature';
            this.isCorrectionStep = data.Status=='Needs corrections';
            this.isUnderReview = data.Status=='Under review'
            this.disabledInputs = this.isSignedFileUploadNecessaryStep||this.isUnderReview;
            this.advisorComments = this.isCorrectionStep&&data.AdvisorComments;
            this.checkErrorFields();
        }
        else if (error) {
           console.log(JSON.stringify(error));
        }
    }


    handleFilesChange(event){
        let files = event.target.files;
        if (files.length > 0) {
            let filesName = '';
            for (let i = 0; i < files.length; i++) {
                let file = files[i];
                filesName = filesName + file.name + ',';
                let freader = new FileReader();
                freader.onload = f => {
                    let base64 = 'base64,';
                    let content = freader.result.indexOf(base64) + base64.length;
                    let fileContents = freader.result.substring(content);
                    this.filesUploaded.push({
                        title: file.name,
                        versionData: fileContents
                    });
                };
                freader.readAsDataURL(file);
            }
            this.fileNames = filesName.slice(0, -1);
        }
    }

    fieldChange(event){
        let fieldApiName = event.target.dataset.apiname;
        let fieldValue = this.getFieldValue(event);
        let fieldChangedInd = this.populatedFields.findIndex((fc => fc.fieldName == fieldApiName))
        if(fieldChangedInd==-1){
            let obj = {'fieldName':fieldApiName,
                    'fieldValue':fieldValue}
            this.populatedFields.push(obj);
        }else{
            this.populatedFields[fieldChangedInd].fieldValue = fieldValue;
        }
    }

    checkErrorFields(){
        console.log('checkErrorFields');
        let fields = this.template.querySelectorAll(".fieldNormal");
        fields.forEach(function(el) {
            el.style.color = "orange";
        })
        console.log(fields);

    }

    getFieldValue(event){
        let fieldType = event.target.type;
        let checkboxGroup = event.target.placeholder;
        if(fieldType=='toggle'){
            return event.target.checked&&event.target.messageToggleActive||event.target.messageToggleInactive;
        }
        if (fieldType=='checkbox' && checkboxGroup !== 'CheckboxGroupField__c') {
            return event.target.checked;
        } else if (checkboxGroup == 'CheckboxGroupField__c') {
            let checkboxGroupElements = this.template.querySelectorAll(`[data-apiname="${event.target.name}"]`);
            checkboxGroupElements.forEach((checkboxGroupElement) => {
                if (checkboxGroupElement.value !== event.target.value) {
                    checkboxGroupElement.checked = false;
                }
            });
            return event.target.value;
        } else {
            return event.target.value;
        }
    }

    downLoadForm() {
        let dogId = this.dogObjId;
        console.log(dogId);
        downloadPDF({ dogObjId : dogId }).then(response => {
            const linkSource = `data:application/pdf;base64,${response}`;
            const downloadLink = document.createElement("a");
            const fileName = "dogForm.pdf";
            downloadLink.href = linkSource;
            downloadLink.download = fileName;
            downloadLink.click();
        }).catch(error=>{
            console.log(error.body.message);
        })
    }

    firstSubmit() {
        this.showError = false;
        this.showSpinner = true;
        if (this.validateFields()) {
            this.getDogObjFromPopulatedFields();
            if (this.dogObjId) {
                this.dogsObg['Id'] = this.dogObjId;
            }
            console.log(this.dogsObg);
            console.log(this.fileNames);
            console.log(this.filesUploaded);
            firstSubmit({dog:this.dogsObg, attachments: this.filesUploaded})
            .then(data => {
                if (data) {
                    this.dogObjId = data;
                    console.log('this.dogObjId ' + this.dogObjId);
                    // this.downLoadForm(data)
                    this.filesUploaded = [];
                    this.fileNames = '';
                    this.isFirstSubmittionStep = false;
                    this.isSignedFileUploadNecessaryStep = true;
                    this.disabledInputs = this.isSignedFileUploadNecessaryStep;
                    this.showFormBox = false;
                    this.showThankYou = true;
                }
                this.showSpinner = false;
            })
            .catch(
                error => {
                    console.log(error.body.message);
                    this.showSpinner = false;
                }
            );
        } else {
            this.showError = true;
            this.showSpinner = false;
        }
    }

    validateFields() {
        let isValid = false;
        let amountOfPopulatedFields = this.populatedFields.length;
        let populatedFields = this.populatedFields;
        let amountOfFields = 0;
        if (amountOfPopulatedFields == 0) {
            isValid = false;
        } else {
            this.fieldsBlocks.forEach(function(fieldsBlock) {
                amountOfFields += fieldsBlock.fields.length;
                fieldsBlock.fields.forEach(function(field) {
                    if (field.FieldValue__c) {
                        amountOfFields -= 1;
                        if (field.FieldApiName__c == 'Email__c' || 
                            field.FieldApiName__c == 'Name_of_Applicant__c' || 
                            field.FieldApiName__c == 'Telephone_number__c'
                        ) {
                            if (populatedFields.some(populatedField => populatedField.fieldName === field.FieldApiName__c)) {
                                console.log('all necessary fields are included');
                            } else {
                                let obj = {
                                    'fieldName' : field.FieldApiName__c,
                                    'fieldValue' : field.FieldValue__c
                                }
                                populatedFields.push(obj);
                            }
                        }
                    }

                    populatedFields.forEach(function(populatedField) {
                        if (populatedField.fieldName === field.FieldApiName__c) {
                            isValid = true;
                        }
                    });
                });
            });
            amountOfPopulatedFields = populatedFields.length;
            if (amountOfPopulatedFields < amountOfFields) {
                isValid = false;
            }
            if (!this.personalDataCheckbox || !this.responsibilityCheckbox || !this.animalResponsibilityCheckbox) {
                isValid = false;
            }
        }
        this.populatedFields = populatedFields;

        return isValid;
    }

    // uploadSignedFile(){
    //     uploadSignedDoc({dogId:this.dogObjId, attachments: this.filesUploaded})
    //         .then(data => {
    //             if (data) {
    //                 console.log(data);
    //                 this.isSignedFileUploadNecessaryStep = false;
    //                 this.showFields = false;
    //                 this.isParkingPage = true;
    //             }
    //             this.showSpinner = false;
    //         })
    //         .catch(
    //             error => {
    //                 console.log(error.body.message);
    //                 this.showSpinner = false;
    //             }
    //         );
    // }

    getDogObjFromPopulatedFields(){
        for(let i=0; i<this.populatedFields.length; i++){
            this.dogsObg[this.populatedFields[i].fieldName] = this.populatedFields[i].fieldValue;
        }
    }

    handlePersonalDataChange(event) {
        this.personalDataCheckbox = event.target.checked;
    }
    handleResponsibilityChange(event) {
        this.responsibilityCheckbox = event.target.checked;
    }
    handleAnimalResponsibilityChange(event) {
        this.animalResponsibilityCheckbox = event.target.checked;
    }

    downloadForm() {
        this.isDownloadForm = true;
        this.showFormBox = false;
    }

    handleDownloadForm() {
        window.open(formDogRequest,"_self");
        this.isDownloadForm = false;
        this.showFormBox = false;
        this.showDownload = true;
    }

    downloadSignatureTemplate() {
        console.log('downloadSignatureTemplate');
        this.isDownloadForm = false;
        this.showFormBox = false;
        this.showThankYou = true;
    }
}