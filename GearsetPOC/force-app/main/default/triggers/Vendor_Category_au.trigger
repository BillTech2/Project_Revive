trigger Vendor_Category_au on Vendor_Category__c (after update) {
     List< Audit__c>  Audits = new List<Audit__c>();
    for(Vendor_Category__c cat : Trigger.new){
        Vendor_Category__c oldcat = Trigger.oldMap.get(cat.id);
        System.debug('oldcat.category_code__c :'+ oldcat.category_code__c+' Values '+cat.approveremail__c+' - '+oldcat.approveremail__c);
         List<Request__c> requests;
         Audit__c audit;
        if (oldcat.category_code__c =='PST' )
            requests=[select name,currentowner__c from request__c where currentowner__c =:oldcat.approverEmail__c and ( status__c in ('Approved by procurement') or (status__c = 'Submitted' and reqtype__c != 'Add Supplier') )  ];
         else
             requests=[select name,currentowner__c from request__c where category__c=:oldcat.category_code__c and currentowner__c =:oldcat.approverEmail__c and status__c in ('Submitted') and reqtype__c = 'Add Supplier' ];
        for (Request__c r:requests){
            r.currentowner__c =cat.approveremail__c;
            System.debug('Request '+r.suppname__c);
            if (oldcat.category_code__c <> 'PST' )
                r.approver__c =cat.approveremail__c;    
            update r;
            audit =new Audit__c();
             Audit.Action__c = 'Re-Assigned';
             Audit.Actioned_By__c = userInfo.getusername();
             Audit.Actioned_By_User__c = Userinfo.getUserId();
             Audit.Actioned_Date__c = datetime.now();
             Audit.Assigned_To__c = cat.approveremail__c;//dict.get(categoryCode);
             Audit.long_Comment__c =  'Assigned to ' + cat.approveremail__c ;
             audit.requestid__c = r.name;
             audits.add(Audit);
        }
    }
    insert  Audits;

}