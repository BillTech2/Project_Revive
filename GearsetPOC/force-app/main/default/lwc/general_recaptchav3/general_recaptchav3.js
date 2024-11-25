import { LightningElement, track } from 'lwc';
import pageUrl from '@salesforce/resourceUrl/reCAPTCHAv2';

export default class General_recaptchav3 extends LightningElement {
    @track navigateTo;

    constructor() {
        super();
        this.navigateTo = pageUrl;
        window.addEventListener("message", this.listenForMessage.bind(this));
    }

    captchaLoaded(event) {
        if (event.target.getAttribute('src') == pageUrl) {
            console.log('Google reCAPTCHA is loaded.');
        }
    }

    listenForMessage(message) {
        if (message.data == 'success') {
            let captchaResponse = new CustomEvent('captchareceived', {
                detail: {
                    isVerified: true
                },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(captchaResponse);
        }
    }
}