@IsTest
private class MemberWarningFlagsControllerTest {

    @IsTest
    private static void testFetchMemberWarningFlags() {
        Contact testContact = TestDataFactory.createContact(true, true);

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);
        MemberWarningFlagsController.networkFactory = networkFactory;

        Test.startTest();

        Map<String, Object> response = MemberWarningFlagsController.fetchMemberWarningFlags(testContact.Id);

        Test.stopTest();

        System.assertNotEquals(null, response);
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

    @IsTest
    private static void testFetchOrganizationWarningFlags() {
        Account testAccount = TestDataFactory.createAccount(true, true);

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(coreAuthManager, businessServicesAuthManager);
        MemberWarningFlagsController.networkFactory = networkFactory;

        Test.startTest();

        Map<String, Object> response = MemberWarningFlagsController.fetchOrganizationWarningFlags(testAccount.Id);

        Test.stopTest();

        System.assertNotEquals(null, response);
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

    @IsTest
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