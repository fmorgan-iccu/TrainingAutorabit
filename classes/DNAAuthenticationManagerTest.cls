@isTest
private class DNAAuthenticationManagerTest {
    @isTest
    private static void testHappyPath() {
        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        DNAAuthenticationManager authManager = new DNAAuthenticationManager();
        
        DNAAuthenticationCredential authCredential = new DNAAuthenticationCredential('user', 'password');
        System.assert(authCredential.getUsername().equals('user'));
        System.assert(authCredential.getPassword().equals('password'));
            
        Boolean didAuthenticate = authManager.authenticateUser(authCredential);
        System.assert(didAuthenticate);
        
        System.assert(authManager.isUserAuthenticated() == true);
        
        authManager.logOut();
        System.assert(authManager.isUserAuthenticated() == false);
        
        AuthenticationCredential authenticationCredential = new AuthenticationCredential('user', 'password');
		System.assert(authenticationCredential.getUsername().equals('user'));
        System.assert(authenticationCredential.getPassword().equals('password'));

		authenticationCredential = new AuthenticationCredential(null, null);
        System.assert(authenticationCredential.getUsername() == null);
        System.assert(authenticationCredential.getPassword() == null);
        
        Test.stopTest();
    }

    @isTest  
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        DNAAuthenticationManager authManager = new DNAAuthenticationManager();
        
        try {
            boolean didAuthenticate = authManager.authenticateUser(null);
            System.assert(false, 'This should have thrown an exception!');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Correctly threw an exception.');
        }
        
        try {
            boolean didAuthenticate = authManager.authenticateUser(new DNAAuthenticationCredential(null, null));
            System.assert(false, 'This should have thrown an exception!');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Correctly threw an exception.');
        }
    }
}