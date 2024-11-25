import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import LANGUAGE_FIELD from "@salesforce/schema/Case.Preferred_Language__c";
import getAccounts from '@salesforce/apex/Eins_VonageLayoutComponentController.getAccounts';
import getTonesOfContact from '@salesforce/apex/Eins_VonageLayoutComponentController.getTonesOfContact';
import createCase from '@salesforce/apex/Eins_VonageLayoutComponentController.createCase';
import getCases from '@salesforce/apex/Eins_VonageLayoutComponentController.getCases';
import searchAccounts from '@salesforce/apex/Eins_VonageLayoutComponentController.searchAccounts';
import searchCases from '@salesforce/apex/Eins_VonageLayoutComponentController.searchCases';
import updateOpenedCase from '@salesforce/apex/Eins_VonageLayoutComponentController.updateOpenedCase';
import createCustomer from '@salesforce/apex/Eins_VonageLayoutComponentController.createCustomer';
 
const accountColumns = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' }, 
            target: '_blank'
        }
    },
    { label: 'Email', fieldName: 'Customer_Email__c', type: 'email'},
    { label: 'Phone', fieldName: 'PersonMobilePhone', type: 'phone'},
    { label: 'Preferred Language', fieldName: 'Preferred_Language__c'},
    { label: 'Action', fieldName: 'Id', type: 'selectRecordButton', typeAttributes: { buttonLabel: 'Select Record'}}
];

const caseColumns = [
    { label: 'Case Number', fieldName: 'CaseNumber' },
    { label: 'Contact Name', fieldName: 'Customer_Name_Formula__c'},
    { label: 'Case Status', fieldName: 'Status'},
    { label: 'Date Closed', fieldName: 'Date_Closed__c'},
    { label: 'Case Owner', fieldName: 'Owner.Name'},
    { label: 'Case Subject', fieldName: 'Subject'},
    // { label: 'Phone', fieldName: 'Contact.Phone', type: 'phone' },
    { label: 'Action', fieldName: 'Id', type: 'selectRecordButton', typeAttributes: { buttonLabel: 'Open Record'}}
];

export default class Eins_VonageLayoutComponent extends LightningElement {
    @api phoneNumber;
    @api callGUID;

    @track error;

    @track accountRecords;
    @track personContactIds = [];
    @track tonesOfContact = [];
    @track accountColumns = accountColumns;
    @track initialAccountRecords;

    @track caseRecords;
    @track caseColumns = caseColumns;
    @track initialCaseRecords;

    caseRecordTypeId;
    preferredLanguages = [];
    preferredLanguage;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    results({ error, data }) {
      if (data) {
        console.log(data);
        const caseRecordTypes = data.recordTypeInfos
        this.caseRecordTypeId =  Object.keys(caseRecordTypes).find((rti) => caseRecordTypes[rti].name === "New Standard Case");
        this.error = undefined;
      } else if (error) {
        this.error = error;
        this.caseRecordTypeId = undefined;
      }
    }
  
    @wire(getPicklistValues, { recordTypeId: "$caseRecordTypeId", fieldApiName: LANGUAGE_FIELD })
    picklistResults({ error, data }) {
      if (data) {
        console.log(data.values);
        this.preferredLanguages = data.values;
        this.error = undefined;
      } else if (error) {
        this.error = error;
        this.preferredLanguages = undefined;
      }
    }


    totalAccounts = 0;
    totalCases = 0;
    pageSize = 7;
    accounts;
    cases;
    accountName;
    accountEmail;
    accountPhone;
    createNewAccount = false;
    createNewCase = false;
    casePNR;
    caseMultiplePNR;
    caseComment;
    selectedAccountId;
    searchAccountString;
    searchCaseString;
    selectedTone;
    showLoader = false;

    @wire(getTonesOfContact, {})
    tonesFromApex({error, data}) {
        if (data) {
            let tonesOfContactValues = [];
            for (let i = 0; i < data.length; i++) {
                tonesOfContactValues.push({
                    label: data[i].toneOfContactlabel,
                    value: data[i].toneOfContactValue
                })
            }
            this.tonesOfContact = tonesOfContactValues;
        }
        else if (error) {
            window.console.log('error ===> ' + JSON.stringify(error));
        }
    }
 
    connectedCallback() {
        this.getAccountsFromApex();
    }

    getAccountsFromApex() {
        getAccounts({ phoneNumber: this.phoneNumber }).then(data => {
            if (data) {
                this.totalAccounts = data.length;
                this.initialAccountRecords = data.map(element => {
                    this.personContactIds.push(element.Id);
                    this.personContactIds.push(element.PersonContactId);
                    element.nameUrl = `/${element.Id}`;
                    element.Id = {
                        Id : element.Id,
                        buttonVariant : 'base',
                        language : element.Preferred_Language__c
                    }
                    return element;
                });
                this.accountRecords = this.initialAccountRecords;
                this.accounts = this.accountRecords.slice(0, this.pageSize);
            }
        }).catch(error => {
            this.handleShowToastEvent('Error', error.body.message, 'error');
            this.accountRecords = undefined;
        }).finally(() => {
            this.getCasesFromApex();
        })
    }

    getCasesFromApex() {
        getCases({ phoneNumber: this.phoneNumber, personContactIds : JSON.stringify(this.personContactIds) }).then(data => {
            if (data) {
                this.totalCases = data.length;
                this.initialCaseRecords = data.map(element => {
                    element.Id = {
                        Id : element.Id,
                        buttonVariant : 'base'
                    }
                    return element;
                });
                this.caseRecords = this.initialCaseRecords;
                this.cases = this.caseRecords.slice(0, this.pageSize);
            }
        }).catch(error => {
            this.handleShowToastEvent('Error', error.body.message, 'error');
            this.caseRecords = undefined;
        });
    }

    handleAccountSearchString(event) {
        this.searchAccountString = event.target.value;
    }

    handleAccountSearch() {
        if (this.searchAccountString) {
            searchAccounts({ searchString: this.searchAccountString }).then(data => {
                if (data) {
                    this.accountRecords = data.map(element => Object.assign({}, element, {
                        Id: {
                            Id : element.Id,
                            buttonVariant : 'base',
                            language : element.Preferred_Language__c
                        },
                        nameUrl: `/${element.Id}`
                    }));
                    this.totalAccounts = data.length;
                    this.accounts = this.accountRecords.slice(0, this.pageSize);
                }
            }).catch(error => {
                this.handleShowToastEvent('Error', error.body.message, 'error');
                this.accountRecords = undefined;
            });
        } else {
            this.totalAccounts = this.initialAccountRecords.length;
            this.accountRecords = this.initialAccountRecords;
            this.accounts = this.accountRecords.slice(0, this.pageSize);
        }
    }

    handleCaseSearchString(event) {
        this.searchCaseString = event.target.value;
    }

    handleCaseSearch() {
        if (this.searchCaseString) {
            searchCases({ searchString: this.searchCaseString }).then(data => {
                if (data) {
                    this.caseRecords = data.map(element => Object.assign({}, element, {
                        Id: {
                            Id : element.Id,
                            buttonVariant : 'base'
                        }
                    }));
                    this.totalCases = data.length;
                    this.error = undefined;
                    this.cases = this.caseRecords.slice(0, this.pageSize);
                }
            }).catch(error => {
                this.handleShowToastEvent('Error', error.body.message, 'error');
                this.caseRecords = undefined;
            });
        } else {
            this.totalCases = this.initialCaseRecords.length;
            this.caseRecords = this.initialCaseRecords;
            this.cases = this.caseRecords.slice(0, this.pageSize);
        }
    }

    handleSelectAccountRecord(event) {
        if (this.selectedAccountId === event.detail.recordId) {
            this.selectedAccountId = '';
            this.preferredLanguage = '';
        } else {
            this.selectedAccountId = event.detail.recordId;
        }
        this.accounts = this.accounts.map(element => {
            if (element.Id.Id === this.selectedAccountId) {
                element.Id.buttonVariant = 'brand';
                this.preferredLanguage = element.Id.language;
                return element;
            } else {
                element.Id.buttonVariant = 'base';
                return element;
            }
        });


    }

    handleOpenCaseRecord(event) {
        this.showLoader = true;
        let caseId = event.detail.recordId;
        updateOpenedCase({ caseId: caseId, callGUID: this.callGUID }).then(data => {
        }).catch(error => {
            this.handleShowToastEvent('Error', error.body.message, 'error');
        }).finally(() => {
            this.openSubTab(caseId);
            this.showLoader = false;
            // window.open(`/${event.detail.recordId}`, "_blank");
        })
       
    }

    openSubTab(recordId) {
        this.dispatchEvent(new CustomEvent('subtab', {
            detail: {
                recordId
            }
        }));
    }

    createNewCustomerApex() {
        if (this.validateCustomerCreation()) {
            this.showLoader = true;
            let args = {
                accountName: this.accountName,
                accountEmail: this.accountEmail,
                accountPhone: this.accountPhone
            }
            let argsJSON = JSON.stringify(args);
            createCustomer({ argsJSON: argsJSON }).then(data => {
                if (data) {
                    this.handleShowToastEvent('Success', 'Customer was created.', 'success');
                    this.getAccountsFromApex();
                    this.selectedAccountId = data;
                    this.createNewAccount = false;
                    this.showLoader = false;
                }
            }).catch(error => {
                this.showLoader = false;
                this.handleShowToastEvent('Error', error.body.message, 'error');
            });
        }
    }

    createNewCaseApex() {
        this.showLoader = true;
        if (!this.preferredLanguage){
            this.handleShowToastEvent('Error', 'Please select a preferred language.', 'error');
            this.showLoader = false;
            return;
        }
        let args = {
            accountId: this.selectedAccountId,
            accountName: this.accountName,
            accountEmail: this.accountEmail,
            accountPhone: this.accountPhone,
            casePNR: this.casePNR,
            caseMultiplePNR: this.caseMultiplePNR,
            caseComment: this.caseComment,
            caseTone: this.selectedTone,
            callGUID: this.callGUID,
            preferredLanguage: this.preferredLanguage
        }
        let argsJSON = JSON.stringify(args);
        createCase({ argsJSON: argsJSON }).then(data => {
            if (data) {
                this.handleShowToastEvent('Success', 'Case was created.', 'success');
                this.getAccountsFromApex();
                this.openSubTab(data);
                this.showLoader = false;
                // window.open(`/${data}`, "_blank");
            }
        }).catch(error => {
            this.showLoader = false;
            this.handleShowToastEvent('Error', error.body.message, 'error');
        });
    }

    validateCustomerCreation() {
        let validated = false;
        if (this.accountName && this.accountEmail && this.accountPhone) {
            validated = true;
        } else {
            this.handleShowToastEvent('Error', 'Please fill in all the customer fields', 'error');
            validated = false;
        }
        return validated;
    }

    handleShowToastEvent(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handleAccountPagination(event) {
        const start = (event.detail - 1) * this.pageSize;
        const end = this.pageSize * event.detail;
        this.accounts = this.accountRecords.slice(start, end);
    }

    handleCasePagination(event) {
        const start = (event.detail - 1) * this.pageSize;
        const end = this.pageSize * event.detail;
        this.cases = this.caseRecords.slice(start, end);
    }

    handleNewAccount() {
        this.accountName = '';
        this.accountEmail = '';
        this.accountPhone  = '';
        this.createNewAccount = !this.createNewAccount;
    }

    handleAccountNameChange(event) {
        this.accountName = event.detail.value;
    }

    handleAccountEmailChange(event) {
        this.accountEmail = event.detail.value;
    }

    handleAccountPhoneChange(event) {
        this.accountPhone = event.detail.value;
    }

    handleNewCase() {
        this.createNewCase = !this.createNewCase;
    }

    handleCasePNRChange(event) {
        this.casePNR = event.detail.value;
    }

    handleCaseMultiplePNRChange(event) {
        this.caseMultiplePNR = event.detail.value;
    }

    handleCaseCommentChange(event) {
        this.caseComment = event.detail.value;
    }

    handleCaseToneChange(event) {
        this.selectedTone = event.detail.value;
    }

    handleLanguageChange(event) {
        this.preferredLanguage = event.detail.value;
    }
}