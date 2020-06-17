@isTest
private class CustomInsightControllerTest {
    @isTest
    private static void testHappyPath() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),  	
            MemberNumber__c = '23423987', 	
            Email = 'something@example.com',	
            FirstName = 'Jack', 
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555', 	
            TaxID__c = '000-00-0000', 
            PersonNumber__c = '123456',             	 
            Phone = '(555) 555-5555'
        );
        
        insert testContact;
        
        MemberInsight__c insight= new MemberInsight__c(
            Name = 'Test Insight',
            ExtraDetails__c = 'some extra details',
            InsightType__c = 'Medical',
            ContactID__c = testContact.id
        );
        
        insert insight;

        Test.startTest();

        List<Map<String, Object>> insights = CustomInsightController.getMemberInsights(testContact.Id);
        System.assert(insights.size() != 0);

        List<Map<String, Object>> insightTypes = CustomInsightController.getInsightTypes();
        System.assert(insightTypes.size() != 0);

        Test.stopTest();
    }
    
    @isTest
    private static void testUnhappyPath() {
        List<Map<String, Object>> insights = CustomInsightController.getMemberInsights(null);
        System.assert(insights != null);
    }
}