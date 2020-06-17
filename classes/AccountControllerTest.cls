@IsTest
private class AccountControllerTest {
    @IsTest
    private static void testHappyPath() {
        Account testAccount = new Account (
            Email__c = 'email@example.com',
            Name = 'Test',
            OrganizationNumber__c = '12345',
            OrganizationTaxID__c = '666-99-9999',
            OrganizationType__c = 'XXXX',
            Phone = '555-555-5555'
        );
        
        insert testAccount;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        AccountController.updater = new SFCacheUpdater(networkFactory);

        System.assert(testAccount.OrganizationNumber__c != null, 'This account\'s orc number is null! ' + testAccount);

        Map<String, Object> response = AccountController.refreshContent(testAccount.OrganizationNumber__c);
        System.assert(response != null);
        String error = (String)response.get('error');
        System.assert(error == null, error);
        System.assert(response.get('account') != null, 'Missing account: ' + response);

        Account fetchedAccount = AccountController.getAccount(testAccount.id);
        System.assert(fetchedAccount != null);
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        AccountController.updater = new SFCacheUpdater(networkFactory);

        Map<String, Object> response = AccountController.refreshContent(null);
        System.assert(response.get('error') != null);

        Account fetchedAccount = AccountController.getAccount(null);
        System.assert(fetchedAccount == null);
    }
}