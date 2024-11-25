import { LightningElement, api } from 'lwc';

export default class ModalRelatedListCmp extends LightningElement {
    @api options = [];
    @api titleModal = 'Modal Window';
    @api bodyMessage = 'Body Message';
    @api styleBody;

    handleOptionClick(event) {
        const id = event.currentTarget.getAttribute("data-id");
        const selectEvent = new CustomEvent('select', {
            detail: id
        });
        this.dispatchEvent(selectEvent);
    }
}