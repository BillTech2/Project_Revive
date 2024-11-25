// just to create a dependency
import TECH_B64Profile_Picture__pc from '@salesforce/schema/Account.TECH_B64Profile_Picture__c';
import Has_an_active_subscription__pc from '@salesforce/schema/Account.Has_an_active_subscription__c';
import Latest_Subscription_End_Date__pc from '@salesforce/schema/Account.Latest_Subscription_End_Date__c';

// we have to use string literals because the LDS works incorrectly with __pc fields
const ACCOUNT_BASE64_PROFILE_PIC_FIELD = 'Account.TECH_B64Profile_Picture__pc';
const ACCOUNT_HAS_ACTIVE_SUBSCRIPTION_FIELD = 'Account.Has_an_active_subscription__pc';
const ACCOUNT_LATEST_SUBSCRIPTION_END_DATE_FIELD = 'Account.Latest_Subscription_End_Date__pc';

export const FIELD = {
    ACCOUNT_BASE64_PROFILE_PIC: ACCOUNT_BASE64_PROFILE_PIC_FIELD,
    ACCOUNT_HAS_ACTIVE_SUBSCRIPTION: ACCOUNT_HAS_ACTIVE_SUBSCRIPTION_FIELD,
    ACCOUNT_LATEST_SUBSCRIPTION_END_DATE: ACCOUNT_LATEST_SUBSCRIPTION_END_DATE_FIELD,
};