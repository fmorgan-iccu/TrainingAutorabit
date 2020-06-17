@isTest
private class MemberWarningFlagsControllerTest {
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
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);
        
        MemberWarningFlagsController.networkFactory = networkFactory;
        Map<String, Object> response = MemberWarningFlagsController.fetchMemberWarningFlags(testContact.Id);
        
        System.assert(response != null);
        String error = (String)response.get('error');
        System.assert(error == null, error);
        
        List<Map<String, Object>> responseFlags = (List<Map<String, Object>>)response.get('warningFlags');
        System.assert(responseFlags != null);
        
        for (Map<String, Object> flag : responseFlags) {
            System.assert(flag.get('effectiveDate') != null);
            System.assert(flag.get('flagCode') != null);
            System.assert(flag.get('flagCode') != null);
        }
        
    }
    
    @isTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);
        
        MemberWarningFlagsController.networkFactory = networkFactory;
        
        Map<String, Object> response = MemberWarningFlagsController.fetchMemberWarningFlags(null);
        String error = (String)response.get('error');
        System.assert(error != null, 'Should have failed');
    }
}