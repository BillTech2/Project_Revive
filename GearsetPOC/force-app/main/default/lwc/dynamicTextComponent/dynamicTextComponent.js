import { LightningElement, api } from 'lwc';
import { getTranslatedLabel } from 'c/generic_utils';


export default class DynamicTextComponent extends LightningElement {
    @api dynamicTextDevName;

    @api langCode;

    @api dynamicStyle;

    get dynamicTextOutput() {
        if (this.dynamicTextDevName && this.dynamicTextDevName.includes(',')) {
            return this.dynamicTextDevName.split(',').reduce(
                (prev, curr) => prev.concat(getTranslatedLabel(curr, this.langCode)),
                '<p style="text-align:center;">'
            ).concat('</p>');
        } else {
            return `<p style="text-align:center;">${getTranslatedLabel(this.dynamicTextDevName, this.langCode)}</p>`;
        }
    }

    get dynamicStyle(){
        if (this.dynamicTextDevName && this.dynamicTextDevName == 'cu_LoungeMeetingRoomBookingText'){
            return 'font-size: 18px;'
        }else{
            return '';
        }
    }

}