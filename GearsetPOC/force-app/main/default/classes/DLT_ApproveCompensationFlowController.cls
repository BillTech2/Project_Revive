public without sharing class DLT_ApproveCompensationFlowController {

    public static final String APPROVAL_MESSAGE = 'Approving request via Approve button on list view';
    public static final String APPROVE_ACTION = 'Approve';
    
    @InvocableMethod
    public static void approveCompensations(List<List<String>> compensationsIds){

        List<Id> workItemIds = getWorkItemIds(compensationsIds[0]);

        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

        for(Id workItemId : workItemIds){
            Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();
            approvalRequest.setComments(APPROVAL_MESSAGE);
            approvalRequest.setAction(APPROVE_ACTION);
            approvalRequest.setWorkitemId(workItemId);
            requests.add(approvalRequest);
        }

        Approval.ProcessResult[] processResults = null;
       	try {
            processResults = Approval.process(requests, true);
        }catch (System.DmlException e) {
            System.debug(e.getMessage());
        }

    }

    public static List<Id> getWorkItemIds(List<Id> objectIds) {
        List<Id> workItemIds  = new List<Id>();

        if(objectIds.size() == 0) return workItemIds;

        for (ProcessInstanceWorkitem workItem  : [
                SELECT Id
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId IN :objectIds]
        ) {
            workItemIds.add(workItem.Id);
        }
        
        return workItemIds;
    }
}