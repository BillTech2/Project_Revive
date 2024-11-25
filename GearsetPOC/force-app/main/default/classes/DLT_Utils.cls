public inherited sharing class DLT_Utils {
    
    public static List<Schema.FieldSetMember> getFieldSetMembers(String objectTypeName, String fieldSetName){
        DescribeSObjectResult[] describes = Schema.describeSObjects(new String[] {objectTypeName});

        if (describes != null && describes.size() > 0) {
            // There should only be the one match for the one object type name
            Schema.FieldSet fs = describes[0].fieldSets.getMap().get(fieldSetName);

            return fs.fields;
        } else {
            return null;
        }
    }

    public static Boolean isAsyncCtx() {
        return System.isBatch() || System.isFuture() || System.isScheduled() || System.isQueueable();
    } 

}