import { LightningElement, api } from 'lwc';

export default class Generic_breadcrumbs extends LightningElement {
 @api
 breadcrumbElements = [];

 @api
 loadElements(elements) {
   this.breadcrumbElements = elements;
 }
}