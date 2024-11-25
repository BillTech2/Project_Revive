import { LightningElement, api, track, wire } from "lwc";
import { pageLabels } from "c/leaverChecklistConfig";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
import LeaverChecklistStaticResources from "@salesforce/resourceUrl/LeaverChecklistStaticResources";

import getChecklistById from "@salesforce/apex/LeaverChecklistCtrl.getChecklistById";
import search  from "@salesforce/apex/LeaverChecklistCtrl.search";

import { refreshApex } from "@salesforce/apex";

const obligatoryCheckboxes = [
     "Contact_Payroll_Service__c",
     "Return_Uniform_Equipment__c",
     "Return_Rules_Books_Publications__c",
     "Return_Clocking_Card_Locker_Keys__c",
     "Return_Security_Passes_Staff_ID_Badge__c",
     "Return_IS_Equipment_Accessories__c",
     "Mobile_Phone_Unlock_Sign_Out__c",
     "Return_Credit_Cards_Settle_Balance__c",
     "Ensure_Expense_Claims_Submission__c",
     "Ensure_HR_Payroll_Notified__c",
     "Ensure_Leavers_Ticket_Raised_With_IS__c",
     "Ensure_MarkView_Queues_Cleared__c",
     "Ensure_DTP_RO_Reassigned__c",
     "Ensure_Financial_Approval_Rights_Reassig__c",
     "Ensure_Box_Folders_Ownership_Altered__c",
     "Ensure_Intranet_Sites_Manager_Altered__c",
     "Ensure_Payslips_Copies_Downloaded__c"
];

const obligatoryInputs = [
    "Employee_Number__c",
    "Job_Title__c"
];

export default class leaverChecklistCore extends NavigationMixin(LightningElement) {
    @api recordId;
    pageLabels = pageLabels;
    @track wiredChecklistProperty;
    @track checklist;
    isEditForm = false;
    isNewRecord = false;
    renderedCallbackCount = 0;
    isLoading = true;
    isSigned = false; 
    lookupPopulationData;
    canEdit = false;
    isSuper = false;
    clearSentStatus = false;

    isConfirmationDialogVisible = false;

    savedEventData;

    searchErrors = []; 


    @wire(getChecklistById, { recordId: "$recordId" })
    checklistWired(result) {
        this.wiredChecklistProperty = result;
        if (result.data && result.data.status === 'SUCCESS') {
            const checklistData = JSON.parse(result.data.resultJSON);
            this.checklist = checklistData['checklist'];
            this.canEdit = checklistData['editAccess'];
            this.isSuper = checklistData['isSuper'];
            if (this.checklist.Employee_Id__c) {
                this.isNewRecord = false;
                this.lookupPopulationData = {
                    "id": this.checklist.Employee_Id__c,
                    "title": this.checklist.Employee_Id__r.LastName + " " + this.checklist.Employee_Id__r.FirstName,
                };
            } else {
                this.lookupPopulationData = [];
                this.isNewRecord = true;
            }
        } else {
            console.log("NO DATA!!!");
            console.log(result);
        }
    }

    connectedCallback() {
        if (this.recordId) {
            this.isEditForm = false;
            this.isNewRecord = false;
        } else {
            this.isEditForm = true;
            this.isNewRecord = true;
        }
        Promise.all([loadStyle(this, LeaverChecklistStaticResources + "/css/ComponentsStyle.css")]);
    }

    handleSubmit(event) {
        event.preventDefault();
        this.savedEventData = event;
        if (this.checkFormValidity()) {
            if (!(this.isSigned) && !(this.checklist.Form_Complete__c)) {
                this.isConfirmationDialogVisible = true;
            } else {
                this.performSave(this.savedEventData);
            }
        }
    }

    handleBackToEdit() {
        this.isConfirmationDialogVisible = false;
    }

    handleProceedWithSave() {
        this.isConfirmationDialogVisible = false;
        this.performSave(this.savedEventData);
    }

    performSave(storedEvent) {
        if (this.checkFormValidity()) {
            const fields = storedEvent.detail.fields;
            fields.Staff_Travel_Card__c = this.valueFromCheckbox("Staff_Travel_Card__c");
            fields.Staff_Travel_Card_Children__c = this.valueFromCheckbox("Staff_Travel_Card_Children__c");
            fields.Staff_Travel_Card_Spouse__c = this.valueFromCheckbox("Staff_Travel_Card_Spouse__c");
            fields.Duty_Travel_Pass__c = this.valueFromCheckbox("Duty_Travel_Pass__c");
            fields.PTAC_Card__c = this.valueFromCheckbox("PTAC_Card__c");
            fields.BR_LUL_Residential_Pass__c = this.valueFromCheckbox("BR_LUL_Residential_Pass__c");
            fields.Unused_Eurostar_Vouchers__c = this.valueFromCheckbox("Unused_Eurostar_Vouchers__c");
            fields.Status_Pass__c = this.valueFromCheckbox("Status_Pass__c");
            fields.Status_Pass_Spouse__c = this.valueFromCheckbox("Status_Pass_Spouse__c");
            fields.Status_Pass_Children__c = this.valueFromCheckbox("Status_Pass_Children__c");
            fields.TFL_Status_Pass__c = this.valueFromCheckbox("TFL_Status_Pass__c");
            fields.TFL_Status_Pass_Spouse__c = this.valueFromCheckbox("TFL_Status_Pass_Spouse__c");

            fields.Contact_Payroll_Service__c = this.valueFromCheckbox("Contact_Payroll_Service__c");
            fields.Return_Uniform_Equipment__c = this.valueFromCheckbox("Return_Uniform_Equipment__c");
            fields.Return_Rules_Books_Publications__c = this.valueFromCheckbox("Return_Rules_Books_Publications__c");
            fields.Return_Clocking_Card_Locker_Keys__c = this.valueFromCheckbox("Return_Clocking_Card_Locker_Keys__c");
            fields.Return_Security_Passes_Staff_ID_Badge__c = this.valueFromCheckbox("Return_Security_Passes_Staff_ID_Badge__c");
            fields.Return_IS_Equipment_Accessories__c = this.valueFromCheckbox("Return_IS_Equipment_Accessories__c");
            fields.Mobile_Phone_Unlock_Sign_Out__c = this.valueFromCheckbox("Mobile_Phone_Unlock_Sign_Out__c");
            fields.Return_Credit_Cards_Settle_Balance__c = this.valueFromCheckbox("Return_Credit_Cards_Settle_Balance__c");
            fields.Ensure_Expense_Claims_Submission__c = this.valueFromCheckbox("Ensure_Expense_Claims_Submission__c");
            
            fields.Ensure_HR_Payroll_Notified__c = this.valueFromCheckbox("Ensure_HR_Payroll_Notified__c");
            fields.Ensure_Leavers_Ticket_Raised_With_IS__c = this.valueFromCheckbox("Ensure_Leavers_Ticket_Raised_With_IS__c");
            fields.Ensure_MarkView_Queues_Cleared__c = this.valueFromCheckbox("Ensure_MarkView_Queues_Cleared__c");
            fields.Ensure_DTP_RO_Reassigned__c = this.valueFromCheckbox("Ensure_DTP_RO_Reassigned__c");
            fields.Ensure_Financial_Approval_Rights_Reassig__c = this.valueFromCheckbox("Ensure_Financial_Approval_Rights_Reassig__c");
            fields.Ensure_Box_Folders_Ownership_Altered__c = this.valueFromCheckbox("Ensure_Box_Folders_Ownership_Altered__c");
            fields.Ensure_Intranet_Sites_Manager_Altered__c = this.valueFromCheckbox("Ensure_Intranet_Sites_Manager_Altered__c");
            fields.Ensure_Payslips_Copies_Downloaded__c = this.valueFromCheckbox("Ensure_Payslips_Copies_Downloaded__c");

            fields.Employee_Number__c = this.valueFromInput("Employee_Number__c");
            fields.Job_Title__c = this.valueFromInput("Job_Title__c");
            fields.Employee_Id__c = this.valueFromLookup("Employee_Id__c");
            fields.Name = this.titleFromLookup("Employee_Id__c"); 
            fields.Last_Day_Of_Employment__c = this.valueFromLWCInput("Last_Day_Of_Employment__c");

            if (this.checklist.Form_Complete__c) {
                fields.Form_Complete__c = !this.clearSentStatus;
            } else {
                fields.Form_Complete__c = this.isSigned;
            }
            
            this.template.querySelector("lightning-record-edit-form").submit(fields);
        }
    }

    handlePairedUpdate(event) {
        const details = event.detail;
        let target = details.target;
        let value = details.value;
        let targetElement = this.template.querySelector(`[data-id=${target}]`);
        targetElement.setState(!value);
        let clearedTarget = details.target.replace("complement", "");

        let highlightedContainers = this.template.querySelectorAll(`[data-container-id=${clearedTarget}]`);
        highlightedContainers.forEach(function(nextContainer) {
            nextContainer.classList.remove("warning-checkbox");
        });

    }

    handleInputUpdate(event) {
        const details = event.detail;
        let target = details.target;
        let value = details.value;
        if (value && value.length > 0) {
            let highlightedContainer = this.template.querySelector(`[data-container-id=${target}]`);
            highlightedContainer.classList.remove("warning-checkbox");
        }
    }

    valueFromCheckbox(dataId) {
        return this.template.querySelector(`[data-id=${dataId}]`).resultvalue;
    }

    valueFromInput(dataId) {
        return this.template.querySelector(`[data-id=${dataId}]`).resultvalue;
    }

    valueFromLWCInput(dataId) {
        return this.template.querySelector(`[data-id=${dataId}]`).value;
    }

    valueFromLookup(dataId) {
        let resultId = "";
        let lookup = this.template.querySelector(`[data-id=${dataId}]`);

        let selection = lookup.getSelection();
        if (selection.length > 0) {
            resultId = selection[0].id;
        } 

        return resultId;
    }

    titleFromLookup(dataId) {
        let resultId = "";
        let lookup = this.template.querySelector(`[data-id=${dataId}]`);

        let selection = lookup.getSelection();
        if (selection.length > 0) {
            resultId = selection[0].title;
        } 

        return resultId;
    }

    handleLoadEditForm() {
    }

    handleConfirmationBoxUpdate(event) {
        this.isSigned = event.detail.value;
    }

    handleClearSentStatusRequestedBoxUpdate(event) {
        this.clearSentStatus = event.detail.value;
    } 

    changeToEditForm() {
        this.isEditForm = true;
    }

    get isReadOnly() {
        return !this.isEditForm;
    }

    successHandler(event) {
        this.recordId = event.detail.id;
        refreshApex(this.wiredChecklistProperty).then(() => {
            if (this.isNewRecord) {
                this.navigateToRecordPage();
            }

            this.isEditForm = false;
            this.isNewRecord = false;
        });
    }

    errorHandler(event) {
        
        console.log("ERROR SAVING RECORD!!!");
        console.log(JSON.stringify(event.detail));
    }

    checkFormValidity() {
        let empId = this.valueFromLookup("Employee_Id__c"); 
        let isValid = true;
        let scrollTo;

        if (!empId || empId.length < 15) {
            let highlightedContainer = this.template.querySelector(`[data-container-id=Employee_Id__c]`);
            highlightedContainer.classList.add("warning-checkbox");
            scrollTo = highlightedContainer; 
            isValid = false;
        }

        for (const nextInput of obligatoryInputs) {
            if (this.valueFromInput(nextInput) === "") {
                let highlightedContainers = this.template.querySelectorAll(`[data-container-id=${nextInput}]`);
                highlightedContainers.forEach(function(nextContainer) {
                    nextContainer.classList.add("warning-checkbox");
                    if (!scrollTo) {
                        scrollTo = nextContainer;  
                    }
                });
                isValid = false;
            }
        }
        
        let lastDay = this.valueFromLWCInput("Last_Day_Of_Employment__c");
        if (!lastDay || lastDay.length < 10) {
            let highlightedContainer = this.template.querySelector(`[data-container-id=Last_Day_Of_Employment__c]`);
            highlightedContainer.classList.add("warning-checkbox");
            if (!scrollTo) {
                scrollTo = highlightedContainer;  
            }
            isValid = false;
        }
        
        for (const nextCheckbox of obligatoryCheckboxes) {
            if (this.valueFromCheckbox(nextCheckbox) === undefined) {
                let highlightedContainers = this.template.querySelectorAll(`[data-container-id=${nextCheckbox}]`);
                highlightedContainers.forEach(function(nextContainer) {
                    nextContainer.classList.add("warning-checkbox");
                    if (!scrollTo) {
                        scrollTo = nextContainer;  
                    }
                });
                isValid = false;
            }
        }

        if (!isValid) {
            scrollTo.scrollIntoView(true); 
        }
        return isValid;
    } 



    handleSelectionChange(event) {
        let selection = event.target.getSelection();
        let targetElement = this.template.querySelector(`[data-id=Job_Title__c]`);

        if (selection.length > 0) {
            targetElement.setState(selection[0].subtitle);
            let highlightedContainer = this.template.querySelector(`[data-container-id=Employee_Id__c]`);
            highlightedContainer.classList.remove("warning-checkbox");
            let highlightedContainer1 = this.template.querySelector(`[data-container-id=Job_Title__c]`);
            highlightedContainer1.classList.remove("warning-checkbox");
        } else {
            targetElement.setState("");
        }
        
    }

    handleLastDateUpdate(event) {
        const details = event.detail;
        let value = details.value;
        if (value && value.length == 10) {
            let highlightedContainer = this.template.querySelector(`[data-container-id=Last_Day_Of_Employment__c]`);
            highlightedContainer.classList.remove("warning-checkbox");
        }
    }
        
    handleSearch(event) {
        const lookupElement = event.target;
        search(event.detail)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.searchErrors = [error];
            });
    } 

    formatDateTime(datetime) {
        let options = {
            year: 'numeric', month: 'numeric', day: 'numeric',
            hour: 'numeric', minute: 'numeric',
            hour12: true
          };
          return datetime.toLocaleString(options);
    }

    get showEditIcon() {
        return !this.isEditForm && ((this.canEdit && !this.checklist.Form_Complete__c) || this.isSuper); 
    }

    get showConfirmationCheckbox() {
        return (this.canEdit && !this.checklist.Form_Complete__c); 
    }

    get showSendEmailsButton() {
        return (this.canEdit && !this.checklist.Form_Complete__c && this.isSigned && !this.isEditForm); 
    }

    get showSaveButton() {
        return ((this.canEdit && !this.checklist.Form_Complete__c && !this.isSigned) || (this.isSuper && !this.isSigned)); 
    }

    get showSaveAndSendEmailsButton() {
        return ((this.isSuper || this.canEdit) && !this.checklist.Form_Complete__c && this.isSigned); 
    }

    get showClearEmailsSentStatusCheckbox() {
        return this.isSuper && this.checklist.Form_Complete__c && this.isEditForm; 
    }

    get createdStatus() {
        let resultStatus = "";
        if (this.checklist.CreatedById) {
            resultStatus = " by " + this.checklist.CreatedBy.Name;
        }
        
        return resultStatus;
    } 

    get submittedDateTime() {
        return this.repairDateTime(this.checklist.Form_Completion_Date__c);
    }

    get createdDateTime() {
        if (this.isNewRecord) {
            return Date.now().valueOf().toString();
        }
        return this.repairDateTime(this.checklist.CreatedDate);
    }

    get modifiedDateTime() {
        return this.repairDateTime(this.checklist.LastModifiedDate);
    }

    get modifiedStatus() {
        let resultStatus = "";
        if (this.checklist.LastModifiedById) {
            resultStatus = " by " + this.checklist.LastModifiedBy.Name;
        }
        
        return resultStatus;
    }

    repairDateTime(flawed) {
        let parsed = new Date(flawed);
        return parsed.valueOf().toString();
    } 

    navigateToRecordPage() {
        window.location.assign('/' + this.recordId);
    } 
}