import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import initDataMethod from '@salesforce/apex/SubscriptionRelatedListController.initData';
import { deleteRecord } from 'lightning/uiRecordApi';
import Utils from 'c/utils';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

export default class CustomRelatedListComponent extends NavigationMixin(LightningElement) {

    @track state = {};
    @api recordId;
    @api numberOfRecords;
    @api sortedBy;
    @api sortedDirection;
    indexIncludes;
    changeApiNameList;
    pageNumber = 1;
    isMoreThanZero = false;
    isFirstPage = false;
    isLastPage = false;
    isNeedPageInfo = true;
    titleModal;
    modalQuestion;
    recordForDelete;
    confirmationPage = false;
    styleModal = 'font-size:16pt;text-align:center;color:red;';
    options = [
        { id: '1', label: 'Delete', variant: 'destructive', icon: 'utility:delete', style: 'slds-p-right_x-small' },
        { id: '2', label: 'Cancel', variant: 'brand-outline', style: 'slds-p-right_x-small' }
    ];

    connectedCallback() {
        this.init();
    }

    async init() {
        this.state = {};
        this.state.showRelatedList = this.recordId != null;
        this.state.records = [];
        this.indexIncludes = [];
        this.changeApiNameList = [];
        this.state.numberOfRecords = this.numberOfRecords;
        this.state.sortedBy = this.sortedBy;
        this.state.sortedDirection = this.sortedDirection;
        this.state.recordId = this.recordId;
        const data = await this.fetchData(this.state);

        if (data !== undefined) {
            this.state.iconName = data.iconName;
            this.state.sObjectName = data.sObjectName;
            this.state.title = data.sObjectName.split('__')[0];
            this.state.titleRelatedList = this.state.title + ' (' + data.recordValues?.length + ')';
            this.isMoreThanZero = data.recordValues.length > 0;
            this.isLastPage = data.recordValues.length > this.state.numberOfRecords;
            this.state.columns = this.state.columns === undefined ? this.configureColumns(data.labels, data.apiNames) : this.state.columns;
            let resultValues = [];
            for (let i = 0; i < data.recordValues.length; i++) {
                let item = data.recordValues[i];
                for (let index = 0; index < this.indexIncludes.length; index++) {
                    item[this.indexIncludes[index]] = item[this.indexIncludes[index]] != undefined ? `/${item[this.indexIncludes[index]]}` : '';
                }
                for (let index = 0; index < this.changeApiNameList.length; index++) {
                    let key = Object.keys(this.changeApiNameList[index])[0];
                    let value = Object.values(this.changeApiNameList[index])[0].split('.');
                    item[key] = value.length > 1 && item[value[0]] != undefined ? item[value[0]][value[1]] : '';

                }
                resultValues.push(item);
            }
            this.state.records = [...resultValues];
            this.state.totalRecords = data.recordValues.length;
            this.titleModal = 'Delete ' + this.state.title;
            this.modalQuestion = 'Are you sure you want to delete this ' + this.state.title + '?';
            this.paginationHelper();
        }
    }

    async fetchData(state) {
        let jsonData = Object.assign({}, state);
        jsonData.numberOfRecords = state.numberOfRecords + 1;
        jsonData = JSON.stringify(jsonData);
        return initDataMethod({ jsonData })
            .then(response => {
                return JSON.parse(response);
            })
            .catch(error => {
                console.log(error);
            });
    }

    configureColumns(labels, apiNames) {
        let columns = [];
        for (let index = 0; index < apiNames.length; index++) {
            let oneColumn;
            if (apiNames[index].includes('Id')) {
                oneColumn = {
                    label: labels[index + 1], fieldName: apiNames[index], type: 'url', sortable: true, title: labels[index], wrapText: true,
                        typeAttributes: {
                            label: { fieldName: apiNames[index + 1] },
                            target: '_blank'
                        },
                }
                this.indexIncludes.push(apiNames[index]);
                ++index;
            } else if (apiNames[index].includes('.')) {
                let fieldApiName = 'apiName' + index;
                oneColumn = {
                    label: labels[index + 1], fieldName: apiNames[index + 1], type: 'url', sortable: true, title: labels[index], wrapText: true,
                        typeAttributes: {
                            label: { fieldName: fieldApiName },
                            target: '_blank'
                        },
                }
                this.indexIncludes.push(apiNames[index + 1]);
                this.changeApiNameList.push({[fieldApiName] : apiNames[index] });
                ++index;
            } else {
                oneColumn = { label: labels[index], fieldName: apiNames[index], sortable: true, title: labels[index], wrapText: true};
            }
            columns.push(oneColumn);
        }
        columns.push({ type: 'action', typeAttributes: { rowActions: actions }});
        return columns;
    }

    handleSortValues(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.state.records];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'desc' ? -1 : 1));
        this.state.records = cloneData;
        this.state.sortedDirection = sortDirection;
        this.state.sortedBy = sortedBy;
        this.pageNumber = 1;
        this.paginationHelper();
    }

    sortBy(field, reverse, primer) {
        const key = primer ?
                function (x) {
                    return primer(x[field]);
                } :
                function (x) {
                    return x[field];
                };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
            switch (actionName) {
                case "delete":
                    this.handleDeleteRecord(row);
                    break;
                case "edit":
                    this.handleEditRecord(row);
                    break;
                default:
            }
        }
    }

    handleCreateRecord() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: this.state.sObjectName,
                actionName: "new"
            },
            state: {
                count: 2,
                nooverride: 1,
                useRecordTypeCheck: 1,
                navigationLocation: 'RELATED_LIST',
            }
        });
    }

    handleEditRecord(row) {
        let recordId = row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId.slice(1),
                objectApiName: this.state.sObjectName,
                actionName: 'edit',
            }
        });
    }

    handleDeleteRecord(row) {
        this.recordForDelete = row.Id.slice(1);
        this.confirmationPage = true;
    }

    handleProceedDeleteRecord(event) {
        event.stopPropagation();
        const result = this.options.filter((option) => event.detail === option.id)[0].label;
        if (result === 'Delete') {
            deleteRecord(this.recordForDelete)
                .then(() => {
                    Utils.handleSuccess(this, this.state.title + ' was deleted successfully.');
                    this.init();
                })
                .catch(error => {
                    Utils.handleError(this, error);
                });
        }
        this.confirmationPage = false;
    }

    handlePreviousPage() {
        --this.pageNumber;
        this.paginationHelper();
    }

    handleNextPage() {
        ++this.pageNumber;
        this.paginationHelper();
    }

    paginationHelper() {
        this.state.recordsToDisplay = [];
        this.isFirstPage = false;
        this.isLastPage = false;
        this.totalPages = Math.ceil(this.state.totalRecords / this.numberOfRecords);
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
            this.isFirstPage = true;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        for (let i = (this.pageNumber - 1) * this.numberOfRecords; i < this.pageNumber * this.numberOfRecords; i++) {
            if (i === this.state.totalRecords) {
                this.isLastPage = true;
                break;
            }
            this.state.recordsToDisplay.push(this.state.records[i]);
        }
    }

    async onRefresh() {
        this.init();
    }
}