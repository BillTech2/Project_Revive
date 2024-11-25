public without sharing class JiraConnectorUtils {
    public static final String JIRA_REST_SOURCE = RestServiceAccess__c.getAll().values()[0].Jira_Issue_Endpoint__c; // = 'https://eurostar.atlassian.net/rest/api/2/issue';
    public static final String JIRA_CREATE_BODY = '\'{\'"fields":\'{\'"summary": "{0}","description": "{1}","issuetype":\'{\'"id":"4"\'}\',"project":\'{\'"id": "15647"\'}\',"reporter":\'{\'"id":"5fe45e6a4d2179006e3f3a92"\'}}}\'';
    public static final String JIRA_TRANSIT_BODY ='\'{\'"transition":\'{\'"id": "{0}"\'}}\'';
    public static final String JIRA_GET_ENDPOINT = '/SFDC-';
    public static final String JIRA_GET_ALL_PARAMS = '?fields=comment,customfield_10500,customfield_10401,status,assignee,issuetype,project&expand=names,renderedFields';
    public static final String JIRA_GET_SUMMARY_ONLY_PARAMS = '?fields=summary&expand=names,renderedFields';
    public static final String USER_EMAIL = RestServiceAccess__c.getAll().values()[0].Jira_User_Email__c; // = 'salesforce.support@eurostar.com';
    public static final String API_TOKEN = RestServiceAccess__c.getAll().values()[0].Jira_Api_Token__c; // = 'mDU1FF8eU5ouTmWJSR8f426F';
    public static final String OPERATION_FAILED = 'failed';

    public static HttpRequest createRequest(String endpoint, String method) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(JIRA_REST_SOURCE + endpoint);
        request.setMethod(method);
        Blob headerValue = Blob.valueOf(USER_EMAIL + ':' + API_TOKEN);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        //"Content-Type: application/json" maybe + ';charset=UTF-8'
        request.setHeader('Content-Type', 'application/json');

        return request;
    }

    public static String createIssue(Salesforce_Support_Request__c supportRequest) {
        String bodyJSON = String.format(
                JIRA_CREATE_BODY,
                new List<String>{
                        supportRequest.Subject__c.escapeUnicode(),
                        supportRequest.Description__c.escapeUnicode()
                });
        HttpRequest request = createRequest('', 'POST');
        request.setBody(bodyJSON);
        Http http = new Http();
        HTTPResponse response;
        response = http.send(request);
        return parseCreateRequestResponse(response.getBody());
    }
/*
    public static String transitIssue(String issueId, String stateId) {
        String bodyJSON = String.format(
                JIRA_TRANSIT_BODY,
                new List<String>{
                        stateId
                });

        HttpRequest request = createRequest('/' + issueId + '/transitions', 'POST');
        request.setBody(bodyJSON);
        Http http = new Http();
        HTTPResponse response;
        response = http.send(request);

        return response.getBody();
    }
*/
    public static String requestIssueData(String issueId, Boolean full) {
        HttpRequest request = createRequest('/' + issueId + (full ? JIRA_GET_ALL_PARAMS : JIRA_GET_SUMMARY_ONLY_PARAMS), 'GET');
        Http http = new Http();
        HTTPResponse response;
        response = http.send(request);

        return response.getBody();
    }


    public static String parseCreateRequestResponse(String data) {
        Map<String, Object> rootMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        List<Object> errorMessages = (List<Object>)rootMap.get('errorMessages');

        if (errorMessages != null) {
            return OPERATION_FAILED;
        }

        return (String)rootMap.get('id');
    }

    public static JiraInformationLayoutController.JiraTicketData parseGetRequestResponse(String data) {
        JiraInformationLayoutController.JiraTicketData result = new JiraInformationLayoutController.JiraTicketData();
        Map<String, Object> rootMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        List<Object> errorMessages = (List<Object>)rootMap.get('errorMessages');

        if (errorMessages != null) {
            result.errorMessage = (String)errorMessages[0];
            return result;
        }

        Map<String, Object> fields = (Map<String, Object>)rootMap.get('fields');
        result.jiraIssueNumber = (String)rootMap.get('key');

        Map<String, Object> project = (Map<String, Object>)fields.get('project');
        result.project = (String)project.get('name');

        Map<String, Object> assignee = (Map<String, Object>)fields.get('assignee');
        if (assignee != null) {
            result.assignee = (String) assignee.get('displayName');
        }

        Map<String, Object> status = (Map<String, Object>)fields.get('status');
        result.status = (String)status.get('name');

        Map<String, Object> statusCategory = (Map<String, Object>)status.get('statusCategory');
        result.statusCategory = (String)statusCategory.get('name');

        Map<String, Object> issueType = (Map<String, Object>)fields.get('issuetype');
        result.issueType = (String)issueType.get('name');

        List<Object> sprint = (List<Object>)fields.get('customfield_10401');
        if (sprint != null) {
            Map<String, Object> sprintData = (Map<String, Object>) sprint[0];
            result.sprint = (String) sprintData.get('name');
        }

        result.epicLink = (String) fields.get('customfield_10500');

        Map<String, Object> renderedFields = (Map<String, Object>)rootMap.get('renderedFields');
        Map<String, Object> comment = (Map<String, Object>)renderedFields.get('comment');
        Map<String, Object> lastComment;
        if (comment != null && comment.size() > 0) {
            List<Object> comments = (List<Object>)comment.get('comments');
            if (comments != null && comments.size() > 0) {
                lastComment = (Map<String, Object>)comments[comments.size()-1];
            }
        }

        if(lastComment != null) {
            String lastCommentBody = (String)lastComment.get('body');
            result.lastJiraComment = lastCommentBody;
            //continued
            Map<String, Object> author = (Map<String, Object>)lastComment.get('author');
            String authorName = (String)author.get('displayName');
            String createdDateTime = (String)lastComment.get('created');
            Map<String, Object> avatarUrls = (Map<String, Object>)author.get('avatarUrls');
            String avatarUrl = (String)avatarUrls.get('48x48');
            result.authorName = authorName;
            result.createdDateTime = createdDateTime;
            result.avatarUrl = avatarUrl;
        }

        return result;
    }

    public static String extractSummaryName(String data) {
        String result;
        Map<String, Object> rootMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        List<Object> errorMessages = (List<Object>)rootMap.get('errorMessages');

        if (errorMessages != null) {
            result = (String)errorMessages[0];
            return result;
        }

        Map<String, Object> fields = (Map<String, Object>)rootMap.get('fields');
        result = (String)fields.get('summary');

        return result;
    }

}