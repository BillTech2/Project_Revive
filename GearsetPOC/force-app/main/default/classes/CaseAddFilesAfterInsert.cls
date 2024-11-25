public without sharing class CaseAddFilesAfterInsert {
    
    public static void addFilesToCase(List<Case> cases) {       
        addFilesToCase(cases, null);
    }

    public static void addFilesToCase(List<Case> cases, Map<Id,Case> oldCases) {
        List<ContentDocumentLink> attachedFiles = new List<ContentDocumentLink>();
        for (Case caseItem : cases) {
            if (String.isNotBlank(caseItem.Files_Ids_System__c) 
                && ( oldCases == null 
                    || (oldCases != null 
                        && caseItem.Files_Ids_System__c != oldCases.get(caseItem.Id).Files_Ids_System__c))){
                List<String> fileIds = caseItem.Files_Ids_System__c.split(',');
                List<ContentVersion> versionsFromCase = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id IN :fileIds
                ];
                for (ContentVersion conVersion : versionsFromCase) {
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = conVersion.ContentDocumentId;
                    cDocLink.LinkedEntityId = caseItem.Id;
                    cDocLink.ShareType = 'I';
                    cDocLink.Visibility = 'AllUsers';
                    attachedFiles.add(cDocLink);
                }
            }
        }
        insert attachedFiles;
    }
}