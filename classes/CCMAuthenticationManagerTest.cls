@IsTest
private class CCMAuthenticationManagerTest {
    @IsTest
    private static void testHappyPathAuthenticate() {
        String responseData = '{"authToken": "0d53f1ed4a400587345baf02cb20df99"}';
        Integer statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockCCMResponse(responseData, statusCode));
        AuthenticationCredential creds = new AuthenticationCredential('ausername', 'apassword');

        // Test authenticating with CCM
        CCMAuthenticationManager manager = new CCMAuthenticationManager();
        Boolean didAuthenticate = manager.authenticateUser(creds);
        System.assert(didAuthenticate == true, 'Expected a successful authentication.');

        // Test to make sure they are authenticated
        Boolean isAuthenticated = manager.isUserAuthenticated();
        System.assert(isAuthenticated == true, 'Expected a user to be authenticated.');

        // Test logging out
        manager.logOut();
        isAuthenticated = manager.isUserAuthenticated();
        System.assert(isAuthenticated == false, 'Expected the user to be logged out.');
    }

    @IsTest
    private static void testUnhappyPathAuthenticate() {
        String responseData = '{"message": "An error has occurred."}';
        Integer statusCode = 500;

        Test.setMock(HttpCalloutMock.class, new MockCCMResponse(responseData, statusCode));
        AuthenticationCredential creds = new AuthenticationCredential('ausername', 'apassword');
        CCMAuthenticationManager manager = new CCMAuthenticationManager();

        // Test authenticating with CCM
        try {
            Boolean didAuthenticate = manager.authenticateUser(creds);
            System.assert(false);  // Shouldn't get this
        } catch (DataServiceException e) {
            System.assertEquals('An error has occurred.', e.getMessage());
        }

        // Test to make sure they are authenticated
        Boolean isAuthenticated = manager.isUserAuthenticated();
        System.assertEquals(false, isAuthenticated);

        // Test missing creds
        try {
            Boolean didAuthenticate = manager.authenticateUser(null);
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected exception
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        // Test missing username or password
        try {
            Boolean didAuthenticate = manager.authenticateUser(new AuthenticationCredential(null, null));
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected exception
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
}