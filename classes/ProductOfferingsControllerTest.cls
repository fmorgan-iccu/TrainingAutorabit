@isTest
private class ProductOfferingsControllerTest {
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
            Phone = '(555) 555-5555',
            CreditScore__c = 750
        );
        
        MarketingPromotion__c mPromotion = new MarketingPromotion__c(
            MaximumCreditScore__c = 1000,
            MinimumCreditScore__c = 0,
            StartDate__c = System.now().addDays(-60).date(),
            EndDate__c = (Date)System.now().addDays(60).date(),
            Name = 'Test Name'
        );

        insert testContact;
        insert mPromotion;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        ProductOfferingsController.networkFactory = networkFactory;

        String contactId = testContact.ID;

        Map<String, Object> response = ProductOfferingsController.getProductOfferings(contactId);
        System.assert(response != null);
        String error = (String)response.get('error');
        System.assert(error == null, error);

        List<MarketingPromotion__c> promotions = ProductOfferingsController.getMarketingPromotions(testContact.Id);
		System.assert(promotions != null);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testUnhappyPath() {
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
            Phone = '(555) 555-5555',
            CreditScore__c = 750
        );
        
        MarketingPromotion__c mPromotion = new MarketingPromotion__c(
            MaximumCreditScore__c = 1000,
            MinimumCreditScore__c = 0,
            StartDate__c = System.now().addDays(-60).date(),
            EndDate__c = (Date)System.now().addDays(60).date(),
            Name = 'Test Name'
        );
        
        insert mPromotion;
        insert testContact;
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest();
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        authManager.logout();

        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        ProductOfferingsController.networkFactory = networkFactory;

        Map<String, Object> response = ProductOfferingsController.getProductOfferings(null);
        System.assert(response != null);
        System.assert(response.get('error') != null);

        String contactId = testContact.ID;

        Map<String, Object> unauthResponse = ProductOfferingsController.getProductOfferings(contactId);
        System.assert(unauthResponse != null);
        System.assert(unauthResponse.get('error') != null);
        
        Test.stopTest();
    }
}