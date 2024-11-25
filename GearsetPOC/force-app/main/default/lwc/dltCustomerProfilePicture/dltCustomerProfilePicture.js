import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { logError } from 'c/dltUtils'
import { FIELD } from './constants';

const ELIGIBLE_AMOUNT_OF_DAYS_SINCE_LAST_SUBSCRIPTION = 180;

export default class DltCustomerProfilePicture extends LightningElement {
    @api recordId;
    @api title;

    imageData;

    @wire(getRecord, { recordId: '$recordId', fields : Object.values(FIELD) })
    getProfilePicture({ error, data }) {
        this.imageData = undefined;

        if (data) {
            const pic = getFieldValue(data, FIELD.ACCOUNT_BASE64_PROFILE_PIC);

            if (pic && this.isEligibleToShowPicture(
                getFieldValue(data, FIELD.ACCOUNT_HAS_ACTIVE_SUBSCRIPTION),
                getFieldValue(data, FIELD.ACCOUNT_LATEST_SUBSCRIPTION_END_DATE)
            )) {
                this.imageData = pic.startsWith('data:image') ? pic : 'data:image/jpeg;base64,' + pic;
            }
        } else if (error) {
            logError(error);
        }
    }

    isEligibleToShowPicture(hasActiveSubscription, latestSubscriptionEndDate) {
        const currentDate = Date.now();
        const latestEligibleSubscriptionDate =  new Date(latestSubscriptionEndDate).setDate(
            new Date(latestSubscriptionEndDate).getDate() + ELIGIBLE_AMOUNT_OF_DAYS_SINCE_LAST_SUBSCRIPTION
        );

        return hasActiveSubscription || (latestSubscriptionEndDate && latestEligibleSubscriptionDate >= currentDate)
    }
}