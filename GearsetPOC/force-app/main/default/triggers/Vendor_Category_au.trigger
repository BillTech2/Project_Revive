trigger Vendor_Category_au on Vendor_Category__c (after update) {
     Vendor_Category__c FinanceCat = [SELECT ApproverEmail__c FROM Vendor_Category__c where Type__c = 'Vendor_FINANCE' limit 1];
     List< Audit__c>  Audits = new List<Audit__c>();
    for(Vendor_Category__c cat : Trigger.new){
        Vendor_Category__c oldcat = Trigger.oldMap.get(cat.id);
        System.debug('oldcat.category_code__c :'+ oldcat.category_code__c+' Values '+cat.approveremail__c+' - '+oldcat.approveremail__c);
         List<Request__c> requests;
         Audit__c audit;
        if (oldcat.category_code__c =='PST' )
            requests=[select name,currentowner__c from request__c where currentowner__c =:oldcat.approverEmail__c and ( status__c in ('Approved by Deputy FTS') or (status__c in ('Submitted') and reqtype__c != 'Add Supplier' and reqtype__c != 'Amend Supplier') )  ];        
        else if(oldcat.category_code__c =='DeputyFTS' )
            requests=[select name,currentowner__c from request__c where currentowner__c =:oldcat.approverEmail__c and (status__c in ('Approved by Finance') or (reqtype__c = 'Amend Supplier' and status__c in ('Submitted') and submitter__c = :FinanceCat.ApproverEmail__c))];
        else if(oldcat.category_code__c =='FINANCE' )
            requests=[select name,currentowner__c from request__c where currentowner__c =:oldcat.approverEmail__c and (status__c in ('Approved by procurement') or (reqtype__c = 'Amend Supplier' and status__c in ('Submitted')))];
        else
             requests=[select name,currentowner__c from request__c where category__c=:oldcat.category_code__c and currentowner__c =:oldcat.approverEmail__c and status__c in ('Submitted') and reqtype__c = 'Add Supplier' ];
        for (Request__c r:requests){
            System.debug('BEFORE Request:'+r.name+',currentowner__c:'+r.currentowner__c);
            r.currentowner__c =cat.approveremail__c;
            System.debug('AFTER Request:'+r.name+',currentowner__c:'+r.currentowner__c);
            if ((oldcat.category_code__c <> 'PST') && (oldcat.category_code__c <> 'DeputyFTS') && (oldcat.category_code__c <> 'FINANCE'))
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