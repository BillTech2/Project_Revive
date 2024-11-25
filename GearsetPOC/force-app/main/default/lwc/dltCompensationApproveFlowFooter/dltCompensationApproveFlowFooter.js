import { LightningElement } from 'lwc';
import { FlowNavigationFinishEvent, FlowAttributeChangeEvent, FlowNavigationBackEvent, FlowNavigationNextEvent, FlowNavigationPauseEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class DltCompensationApproveFlowFooter extends NavigationMixin(LightningElement) {


    handleSaveData() {
        // navigate to the next screen
        const navigateNextEvent = new FlowNavigationNextEvent ();
        this.dispatchEvent(navigateNextEvent);
    }
    handleCancel() {

        window.history.back();

    }
    
}