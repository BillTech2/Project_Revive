import { LightningElement, api } from 'lwc';

export default class Generic_breadcrumbItem extends LightningElement {
    @api
    label;

  /*  @api
    eventDetails;
*/
    @api
    step;

    handleItemClick() {
        this.dispatchEvent(
            new CustomEvent('bcitemclick', {detail: this.step, bubbles: true, composed: true})
        );
    }
}