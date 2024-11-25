import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVouchers from '@salesforce/apex/Eins_CreateVoucherController.getVouchers';
import getActionTypes from '@salesforce/apex/Eins_CreateVoucherController.getActionTypes';
import createCaseVoucher from '@salesforce/apex/Eins_CreateVoucherController.createCaseVoucher';

export default class Eins_createVoucherFromCase extends LightningElement {
    urlValue;
    commentValue;
    selectedVoucher;
    newVoucherAmount = 0;
    selectedVoucherAmount;
    selectedActionType;
    showSpinner = false;
    isReduce = false;

    @track vouchers = [];
    @track actionTypes = [];

    @api recordId;

    @wire(getVouchers, { recordId : '$recordId' })
    voucherValuesFromApex({error, data}) {
        if (data) {
            let voucherValues = [];
            for (let i = 0; i < data.length; i++) {
                voucherValues.push({
                    label: data[i].voucherName,
                    value: data[i].voucherId
                })
            }
            this.vouchers = voucherValues;
        }
        else if (error) {
            window.console.log('error ===> ' + JSON.stringify(error));
        }
    }

    @wire(getActionTypes, {})
    actionTypesFromApex({error, data}) {
        if (data) {
            let actionTypeValues = [];
            for (let i = 0; i < data.length; i++) {
                actionTypeValues.push({
                    label: data[i].actionTypelabel,
                    value: data[i].actionTypeValue
                })
            }
            this.actionTypes = actionTypeValues;
            console.log('recordId: ' + this.recordId);
        }
        else if (error) {
            window.console.log('error ===> ' + JSON.stringify(error));
        }
    }

    handleUrlChange(event) {
        this.urlValue = event.target.value;
    } 

    handleNewVoucherAmount(event) {
        this.newVoucherAmount = event.target.value;
    }

    handleCommmentChange(event) {
        this.commentValue = event.target.value;
    }

    handleEVoucherChange(event) {
        let selectedVoucherInfo = event.detail.value;
        this.selectedVoucher = selectedVoucherInfo.split(';')[0];
        this.selectedVoucherAmount = selectedVoucherInfo.split(';')[1] || 0;
    }

    handleActionTypeChange(event) {
        this.selectedActionType = event.detail.value;
        if (this.selectedActionType === 'Reduce in cost') {
            this.isReduce = true;
        } else {
            this.isReduce = false;
        }
    }

    createVoucher() {
        this.showSpinner = true;
        createCaseVoucher({
            caseId: this.recordId,
            voucherId: this.selectedVoucher,
            actionType: this.selectedActionType,
            comment: this.commentValue,
            url: this.urlValue,
            newAmount: this.newVoucherAmount
        })
            .then(data => {
                this.showMessage('Success', 'Voucher was created', 'success');
                this.showSpinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
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