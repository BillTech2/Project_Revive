public class ThreadingOutboundPostContext {
    
    @InvocableMethod
    Public static void threadpost(List<SocialPost> post){
        
        List<SocialPost> plist = new List<SocialPost>();
        
        for(Integer i=0; i<post.size(); i++){
        
            String context = post[i].ResponseContextExternalId;
            String externalId = post[i].ExternalPostId;
            
            List<SocialPost> listPosts1 = [SELECT Id, ParentId From SocialPost WHERE ExternalPostId=:context AND Id!=:post[i].Id ];
            system.debug('Size of list with posts ExternalId=Context' + listPosts1.size());
            If (listPosts1.size()==0){
             List<SocialPost> listPosts2 = [SELECT Id, ParentId From SocialPost WHERE ResponseContextExternalId=:context AND Id!=:post[i].Id AND ParentID!=:post[i].ParentId ];
            system.debug('Size of list with posts ContextId=Context' + listPosts2.size());
                
                If (listPosts2.size()>0){
                    SocialPost postcopy = [SELECT Id FROM SocialPost WHERE Id =: post[i].Id];
                    postcopy.parentId = listPosts2[0].ParentId;
                    plist.add(postcopy);
                }
            }
            
            If (listPosts1.size()==1){
            	SocialPost postcopy = [SELECT Id FROM SocialPost WHERE Id =: post[i].Id];
                postcopy.parentId = listPosts1[0].ParentId;
                plist.add(postcopy);    
            }
         } 
        update plist;
    }
}