import { LightningElement, api, track, wire } from 'lwc';
import { doRequest } from 'c/dltUtils'
import getRelatedClientsList from '@salesforce/apex/DLT_RelatedClientsController.getRelatedClientsList';
import getFieldLableAndFieldAPI from '@salesforce/apex/DLT_RelatedClientsController.getFieldLableAndFieldAPI';

export default class RelatedClients extends LightningElement {
    
    @api recordId;

    @track data = [];
    @track columns = [];
    
    title = "Related Clients "
    tableVisible = false;

    connectedCallback(){
        this.handleRelatedClients();
    }


    @wire(getRelatedClientsList, {recordId: '$recordId'})
    relatedClients({data}){
        if(data){
            this.data = data;
            this.title += "(" + this.data.length + ")";
            this.tableVisible = this.data.length > 0 ? true : false;
        }
        else {
            this.tableVisible = false;
        }
    }


    handleRelatedClients(){
        doRequest(getFieldLableAndFieldAPI, null, null, false)
        .then((result) =>{
            let fieldSet = JSON.parse(result);
            for (const fieldLabel in fieldSet) {
                this.columns.push({label : `${fieldLabel}`, fieldName : `${fieldSet[fieldLabel]}`, hideDefaultActions :"true"});
            }
        })
        .catch(() => {
            this.tableVisible = false;
        });
    }
}