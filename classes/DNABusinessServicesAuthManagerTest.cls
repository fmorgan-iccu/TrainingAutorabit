@isTest
private class DNABusinessServicesAuthManagerTest {

    @IsTest
    private static void testHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest(); 

        Date today = System.today();
        DNABusinessServicesAuthManager authManager = new DNABusinessServicesAuthManager();
        DNABusinessServicesAuthCredential authCredential = new DNABusinessServicesAuthCredential('user', 'password', 'cashbox', today, today, 'networknode');
        System.assertEquals('user', authCredential.getUsername());
        System.assertEquals('password', authCredential.getPassword());
        System.assertEquals('cashbox', authCredential.getCashBox());
        System.assertEquals(today, authCredential.getEffectiveDate());
        System.assertEquals(today, authCredential.getPostingDate());
        System.assertEquals('networknode', authCredential.getNetworkNodeName());

        Boolean didAuthenticate = authManager.authenticateUser(authCredential);
        System.assert(didAuthenticate);

        System.assertEquals(true, authManager.isUserAuthenticated());

        authManager.logOut();
        System.assertEquals(false, authManager.isUserAuthenticated());

        authCredential = new DNABusinessServicesAuthCredential(null, null, null, null, null, null);
        System.assertEquals(null, authCredential.getUsername());
        System.assertEquals(null, authCredential.getPassword());
        System.assertEquals(null, authCredential.getCashBox());
        System.assertEquals(null, authCredential.getEffectiveDate());
        System.assertEquals(null, authCredential.getPostingDate());
        System.assertEquals(null, authCredential.getNetworkNodeName());

        Test.stopTest();
    }

    @IsTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        DNABusinessServicesAuthManager authManager = new DNABusinessServicesAuthManager();

        try {
            boolean didAuthenticate = authManager.authenticateUser(null);
            System.assert(false, 'This should have thrown an exception!');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Correctly threw an exception.');
        }

        try {
            boolean didAuthenticate = authManager.authenticateUser(new DNABusinessServicesAuthCredential(null, null, null, null, null, null));
            System.assert(false, 'This should have thrown an exception!');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Correctly threw an exception.');
        }
    }

}