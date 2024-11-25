global class Create_Case_Comment 
{
    webService static void Create_A_CaseComment(Id Parent_Id, String content)
    {	
        CaseComment comment = new CaseComment(ParentId = Parent_Id,CommentBody = content);
        insert comment;
    }
    
    @InvocableMethod
	public static void Track_The_Price_Details_Field (list<Id> Parent_Id)
    {
        Case SelectedCase = [SELECT Id, Group_Booking_Price_Details__c FROM Case WHERE Id =: Parent_Id[0] ];
        String PriceDetails = SelectedCase.Group_Booking_Price_Details__c;
        CaseComment comment = new CaseComment(ParentId = Parent_Id[0],CommentBody = 'The price details have been changed to: \r\n' + PriceDetails);
        insert comment;
    }
}