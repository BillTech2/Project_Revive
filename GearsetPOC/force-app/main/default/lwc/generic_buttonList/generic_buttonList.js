import { LightningElement, api, track } from 'lwc';
import { getButtonList, createButtonsFromData, getTranslatedLabel } from 'c/generic_utils';
//import getRecordsList from '@salesforce/apex/cu_Utils.getRecordsList';

export default class Generic_buttonList extends LightningElement {
    @api
    btnListType;

    @api
    btnListLabel;
    btnListLabelTranslated;

    @api
    langCode;

    @api
    pnrItem;

    @track
    btnList = [];

    connectedCallback() {
        this.loadButtons(this.btnListType, this.btnListLabel);
    }

    get hasBtnList() {
        return this.btnList?.length > 0 ? true : false;
    }

    get sldsGrigClass() {
        if (this.btnList.length < 5) {
            return 'slds-col slds-size_1-of-1 slds-medium-size_1-of-1 slds-large-size_1-of-1 slds-text-align_center'; // slds-text-align_center
        } else if (this.btnList.length < 10) {
            return 'slds-col slds-size_1-of-1 slds-medium-size_1-of-1 slds-large-size_1-of-2';
        } else if (this.btnList.length < 15) {
            return 'slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-3';
        } else {
            return 'slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-4';
        }
    }

    @api
    loadButtons(btnListType, btnListLabel) {
        this.btnList = this.pnrItem
            ? this.overrideStandardBehavior(this.filterButtons(getButtonList(btnListType)))
            : getButtonList(btnListType);
        this.btnListLabel = btnListLabel;
        this.btnListLabelTranslated = getTranslatedLabel(this.btnListLabel, this.langCode);
    }

    @api
    loadButtonsWithData(objectName, lang) {
        getRecordsList({objectName: objectName, lang: lang})
        .then((result) => {
            this.btnList = createButtonsFromData(objectName, result);
        })
        .catch((error) => {
            console.log(`LoadButtons error: ${error}`);
            this.btnList = undefined;
        });
    }

    filterButtons(btnList) {
        return btnList.filter( btn => {
            return btn.visibilitySettings && this.pnrItem
                ? btn.visibilitySettings.some(setting => {
                    return Object.keys(setting).every(settingName => {
                        return this.pnrItem[settingName] === setting[settingName];
                    });
                })
                : true;
        });
    }

    overrideStandardBehavior(btnList) {
        return btnList.map(btn => {
            if (this.pnrItem.isLastMinuteTicket) {
                switch (btn.label) {
                    case 'cu_Question':
                        btn.eventDetails = {
                            formType: 'formType',
                            subtitle: 'cu_PleaseEnterYourQuestionBelow', 
                            showUploader: true,
                            selectedAction: 'createElseQuestionCase'
                        };
                        break;
                }
            }

            return btn;
        });
    }

}