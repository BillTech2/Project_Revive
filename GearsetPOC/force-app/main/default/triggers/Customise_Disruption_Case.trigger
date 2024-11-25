// This trigger has been created as a workaround after the Auto-response issue
// Those actions were done by Process Builder but when active, it creates a sort of conflict which disable the Auto-response
trigger Customise_Disruption_Case on Case (before insert) {
    if (DLT_Automation_Settings__c.getOrgDefaults().Disable_Case_Automation__c || DLT_CaseTriggerHandler.isDisabled) { return; }

    Case[] cases = Trigger.new; // We get the record that is being inserted
    if(cases[0].Origin == 'Disruption Web') // We check that its origin is 'Disruption Web'
    {
        // We force Reason Codes
        cases[0].Reason_1__c = 'Already have a booking';
        cases[0].Reason_2__c = 'Amending a booking';
        cases[0].Reason_3__c = 'Refund / exchange on flexible ticket';
        // We force the Record type to 'Disruption Case'
        cases[0].RecordTypeId = '012b0000000M78U';
        // We force the subject
        cases[0].Subject = 'Disruption Case';
        // We force the type of the case
        cases[0].Type = 'Disruption';
    }

}