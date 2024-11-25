import { LightningElement, api } from 'lwc';

export default class Eins_emailTemplatePopover extends LightningElement {
    @api showTemplate = false;
    @api htmlText;
}