import LightningDatatable from 'lightning/datatable';
import selectRecordButton from './templates/eins_SelectRecordButton.html';

export default class Eins_LightningDataTable extends LightningDatatable {
    static customTypes = {
        selectRecordButton: {
            template: selectRecordButton,
            typeAttributes: ['buttonLabel']
        }
    }
}