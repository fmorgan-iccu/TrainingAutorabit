@isTest
private class EncompassAuthenticationManagerTest {
    @isTest
    private static void testHappyPath() {
        ResourceOwnerCredential credential = new ResourceOwnerCredential('apiClientID', 'apiClientSecret', 'instanceID', 'username', 'password');
        EncompassTokenManager tokenManager = new EncompassTokenManager();

        Test.setMock(HttpCalloutMock.class, new MockProductApplicationResponse());
        
        EncompassAuthenticationManager mgr = new EncompassAuthenticationManager(credential, tokenManager);
        boolean didAuth = mgr.authenticateUser(credential);

        System.assert(didAuth, 'Failed to authenticate the service.');
        System.assert(mgr.isUserAuthenticated(), 'The manager should have returned true for being authed.');
        
        mgr.logOut();
        
        System.assert(mgr.isUserAuthenticated() == false, 'User should have been logged out.');
        
        EncompassTokenManager.sharedToken = new EncompassToken('token', 'tokenType', System.now().addMinutes(-10));
        
        EncompassToken nullToken = tokenManager.getToken();
        System.assert(nullToken == null, 'Token should have been null because it was expired.');
    }
    
    @isTest
    private static void testUnhappyPath() {
        EncompassTokenManager tokenManager = new EncompassTokenManager();

        Test.setMock(HttpCalloutMock.class, new MockProductApplicationResponse());

        EncompassAuthenticationManager mgr = new EncompassAuthenticationManager(null, tokenManager);
        try {
            boolean didAuth = mgr.authenticateUser(null);
            System.assert(false, 'Should have throw exception.');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Should have throw exception.');
        }

        System.assert(mgr.isUserAuthenticated() == false, 'The manager should not have returned true for being authed.');
    }
}