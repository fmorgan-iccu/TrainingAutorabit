@isTest
private class MemberInsightsControllerTest {
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

        Profile p = [
            SELECT
                Id 
            FROM Profile
            WHERE Name='Standard User'
        ]; 

        User testUser = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='tes5674567tuser@e34534xample.com'
        );

        insert testUser;

        Case testOpenCase = new Case(
            Description = 'Test Case',
            Priority = 'High',
            Status = 'New',
            ContactId = testContact.Id,
            OwnerId = testUser.Id
        );

        insert testOpenCase;

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);
        MemberAccountsController.networkFactory = networkFactory;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Contact contact = MemberInsightsController.getContact(testContact.Id);
        System.assert(contact != null);

        Map<String, Object> cases = MemberInsightsController.fetchCaseInsights(testContact.Id);
        System.assert(cases != null);
        System.assert(cases.get('open') != null);
        System.assert(cases.get('closed') != null);

        Map<String, Object> accountInsights = MemberInsightsController.fetchAccountInsights(testContact.Id);
        System.assert(accountInsights != null);
        System.assert(accountInsights.get('hasOverdrawnAccount') != null);
        System.assert(accountInsights.get('hasPastDueAccount') != null);

        List<Map<String, Object>> insights = MemberInsightsController.fetchMemberInsights(testContact.Id);
        System.assert(insights.size() > 0);

        Test.stopTest();
    }
}