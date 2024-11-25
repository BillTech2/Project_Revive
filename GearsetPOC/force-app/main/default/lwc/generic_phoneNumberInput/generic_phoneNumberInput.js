import { LightningElement,api,track } from 'lwc';
import { getTranslatedLabel } from 'c/generic_utils';
import intlTellinputjs from '@salesforce/resourceUrl/intlTellinputjs';
import utils from '@salesforce/resourceUrl/utils';
import intlTellinputcss from '@salesforce/resourceUrl/intlTellinputcss';
import democss from '@salesforce/resourceUrl/democss';
import flags from '@salesforce/resourceUrl/flags';
import { loadScript,loadStyle} from  'lightning/platformResourceLoader';
 
export default class Generic_phoneNumberInput extends LightningElement {
    @api CountryName = '';
    @track inputElem ;
    @track iti ;
    @api langCode;


    @api
    get isValid(){
        let telInput = this.template.querySelector('input[name="country"]');
        if(!iti.isValidNumber()){
            telInput.setCustomValidity(getTranslatedLabel('cu_PhoneNumberIsNotValid', this.langCode));
            telInput.reportValidity();
        }else{
            telInput.setCustomValidity('');
        }
        return iti.isValidNumber();
    }

    @api
    get phoneNumber(){
        return iti.getNumber();
    }


    connectedCallback() {
        loadStyle(this, democss)
         .then(() => {
              
        });
        loadStyle(this, intlTellinputcss)
         .then(() => {
            
        });
        loadScript(this, utils)
         .then(() => {
            
        });
         loadScript(this, intlTellinputjs)
         .then(() => {
            this.inputElem = this.template.querySelector("[data-id=country]")
            this.iti = window.intlTelInput(this.inputElem, {
            utilsScript: utils,
            initialCountry: "GB",
            preferredCountries: ['BE','FR','DE','NL','GB'],
            })  
            window.iti = this.iti;
        })
    }
     
}