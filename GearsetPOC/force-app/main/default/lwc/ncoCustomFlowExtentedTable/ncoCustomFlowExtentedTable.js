import LightningDatatable from 'lightning/datatable';
import picklistTemplate from './picklist.html';

export default class NcoCustomFlowExtentedTable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: picklistTemplate,
            typeAttributes: ['name', 'label', 'value', 'placeholder', 'options', 'variant', 'recordId']
        }
    };
}