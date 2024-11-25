public without sharing class  HashController {
    public static final Blob INIT_VECTOR = Blob.valueOf('7777777466099123');
    public static final Blob HASH_KEY = EncodingUtil.convertFromHex('f9b3dfed8287949cb4ad2bd0c87ee1f8');
    public static final String AlgorythmName = 'AES128';
    public static final String EMAIL_MESSAGE_STATUS_DRAFT = '5';

    public static String idToHash(Id objId){
       Blob encrypted = Crypto.encrypt(AlgorythmName, HASH_KEY, INIT_VECTOR, Blob.valueOf(objId));
       return EncodingUtil.urlEncode(EncodingUtil.base64Encode(encrypted), 'UTF-8');
    }

    public static Id hashToId(String hash){
        System.debug('hash = ' + hash);
        Blob decrypted = Crypto.decrypt(AlgorythmName, HASH_KEY, INIT_VECTOR, EncodingUtil.base64Decode(hash));
		return decrypted.toString();
    }

    public static String createLink(Id caseId){
        Boolean isSandBox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSandBox==true){
            String resultURL = URL.getSalesforceBaseUrl().toExternalForm();
            if(resultURL.contains('sites.com')){
                return resultURL + '/trackCase?id=' + idToHash(caseId) ;
            }
            else{
                return resultURL.removeEnd('.com') + '-sites.com/trackCase?id=' + idToHash(caseId) ;
            }
        }
        else{
            return 'https://eurostarhelp.secure.force.com/trackCase?id=' + idToHash(caseId) ;
        }

    }

    @AuraEnabled
    public static String createContactUsLink(){
        return URL.getSalesforceBaseUrl().toExternalForm() + '/contactus' ;
    }

    @AuraEnabled
    public static CaseWrapper getContactbyHash(String hash){
        Id caseId = hashToId(hash);
        try{
            return getContact(caseId);
        } catch (Exception e) {
            CaseWrapper cw = new CaseWrapper();
            cw.error = 'error';
            return cw;
        }
    }

    @AuraEnabled
    public static CaseWrapper getContact(Id caseId){

        Case record = selectCase(caseId);
        List<Account> accList = selectAccountById(record.AccountId);
        List<EmailMessage> messages = selectMessagesByParentId(caseId);

            CaseWrapper cw = new CaseWrapper();
            cw.customerName = accList.isEmpty() || String.isBlank(accList[0].FirstName) ? 'Guest' : accList[0].FirstName;
            cw.isClosed = record.status == 'Closed';
            cw.canAddDetails = record.ClosedDate == null || record.ClosedDate > Date.today().addDays(-70);
            cw.Description = record.Description;
            cw.messages = new List<EmailMessage>();

            for (EmailMessage m : messages) {
                cw.messages.add(m);
            }

            return cw;
    }

    @AuraEnabled
    public static String updateCase(String caseHash, String newDescription, List<Object> attachments){
        Id caseId = hashToId(caseHash);
        try{
            if(String.isNotBlank(newDescription))
				updateComment(caseId, newDescription);
            if(!attachments.isEmpty())
                saveFile(caseId, attachments);
            return string.valueOf(caseId);
        }catch (Exception e) {
            return e.getMessage()+caseId;
        }
    }

    @AuraEnabled
    public static void updateComment(id caseId, String newDescription){
        Case toUpdate =  selectCase(caseId);
        toUpdate.Status = DLT_CaseConstants.STATUS_REOPENED;
        toUpdate.Sub_Status__c = DLT_CaseConstants.SUB_STATUS_CASE_COMMENT_RECEIVED;
        toUpdate.Description = toUpdate.Description + '\n'
        + DLT_CaseConstants.STATUS_REOPENED + ' ' + Datetime.now() + '\n'
        + newDescription;
        update toUpdate;
    }

    @AuraEnabled
    public static void saveFile(string caseId,  List<Object> attachments) {
        Case toUpdate =  selectCase(caseId);
        toUpdate.Status = DLT_CaseConstants.STATUS_REOPENED;
        toUpdate.Sub_Status__c = DLT_CaseConstants.SUB_STATUS_CASE_COMMENT_RECEIVED;
        update toUpdate;

        List<ContentVersion> versionsToInsert = new List<ContentVersion>();
        for (Object file : attachments) {
            FileInfo fileData = (FileInfo) JSON.deserialize(JSON.serialize(file), FileInfo.class);
            ContentVersion contentVersionObj = new ContentVersion();
            contentVersionObj.PathOnClient = fileData.title;
            contentVersionObj.Title = fileData.title;
            contentVersionObj.VersionData = fileData.versionData;
            contentVersionObj.FirstPublishLocationId = caseId;
            contentVersionObj.IsMajorVersion = true;
            versionsToInsert.add(contentVersionObj);
        }
        insert versionsToInsert;

    }

    private static Case selectCase(Id caseId) {
        return [
            SELECT Id, Description, Status, Sub_Status__c, ClosedDate, AccountId
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
    }

    private static List<EmailMessage> selectMessagesByParentId(Id parentId) {
        return [
            SELECT Id, ParentId, HtmlBody
            FROM EmailMessage
            WHERE Status != :EMAIL_MESSAGE_STATUS_DRAFT
                AND ParentId = :parentId
            ORDER BY CreatedDate DESC
        ];
    }

    private static List<Account> selectAccountById (Id accountId) {
        return [
            SELECT FirstName
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }

    public class FileInfo {
        public String title;
        public Blob versionData;
    }

    public Class CaseWrapper {
        @AuraEnabled
        public String customerName { get; set; }
        @AuraEnabled
        public Boolean isClosed { get; set; }
        @AuraEnabled
        public Boolean canAddDetails { get; set; }
        @AuraEnabled
        public String Description { get; set; }
        @AuraEnabled
        public List<EmailMessage> messages { get; set; }
        @AuraEnabled
        public String error { get; set; }
    }

}