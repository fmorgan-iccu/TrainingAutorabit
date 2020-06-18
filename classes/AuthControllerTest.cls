@isTest
private class AuthControllerTest {
    @IsTest
    private static void testAuthController() {
        AuthController userSession = new AuthController();
        System.assertNotEquals(null, userSession);
    }

    @IsTest
    private static void testMultiDnaLoginHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(coreAuthManager, businessServicesAuthManager);
        AuthController.networkFactory = networkFactory;

        Test.startTest();

        Map<String, Object> response = AuthController.authenticateDna('username', 'password', '1234', '2019-01-01', '2019-01-01', 'NetworkNode');
        boolean isAuthedCore = (boolean)response.get('isAuthedCore');
        boolean isAuthedBusinessServices = (boolean)response.get('isAuthedBusinessServices');
        String error = (String)response.get('error');
        System.assertEquals(true, isAuthedCore);
        System.assertEquals(true, isAuthedBusinessServices);
        System.assert(String.isBlank(error));

        AuthController.logout();

        Test.stopTest();

        UserSessionCache sessionCache = new UserSessionCache();
        String dnaTicket = sessionCache.getValue(UserSessionCache.DNA_TICKET);
        String dnaToken = sessionCache.getValue(UserSessionCache.DNA_TOKEN);
        System.assertEquals(null, dnaTicket);
        System.assertEquals(null, dnaToken);
    }

    @IsTest
    private static void testMultiDnaLoginSadPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(coreAuthManager, businessServicesAuthManager);
        AuthController.networkFactory = networkFactory;

        Test.startTest();

        Map<String, Object> response = AuthController.authenticateDna('', '', '1234', '2019-01-01', '2019-01-01', 'NetworkNode');

        Test.stopTest();

        boolean isAuthedCore = (boolean)response.get('isAuthedCore');
        boolean isAuthedBusinessServices = (boolean)response.get('isAuthedBusinessServices');
        String error = (String)response.get('error');
        System.assertEquals(false, isAuthedCore);
        System.assertEquals(false, isAuthedBusinessServices);
        System.assertEquals('Missing required credentials.', error);
    }

    @IsTest
    private static void testCcmLoginHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockCCMResponse());

        IAuthenticationManager authManager = new CCMAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager, null, null);
        AuthController.networkFactory = networkFactory;

        Test.startTest();

        Map<String, Object> response = AuthController.authenticateCcm('username', 'password');

        Test.stopTest();

        boolean isAuthed = (boolean)response.get('isAuthedCcm');
        String error = (String)response.get('error');
        System.assertEquals(true, isAuthed);
        System.assert(String.isBlank(error));

        AuthController.logout();
        UserSessionCache sessionCache = new UserSessionCache();
        String ccmToken = sessionCache.getValue(UserSessionCache.CCM);
        System.assertEquals(null, ccmToken);
    }

    @IsTest
    private static void testCcmLoginSadPath() {
        Test.setMock(HttpCalloutMock.class, new MockCCMResponse());

        IAuthenticationManager authManager = new CCMAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager, null, null);
        AuthController.networkFactory = networkFactory;

        Test.startTest();

        Map<String, Object> response = AuthController.authenticateCcm('', '');

        Test.stopTest();

        boolean isAuthed = (boolean)response.get('isAuthedCcm');
        String error = (String)response.get('error');
        System.assertEquals(false, isAuthed);
        System.assertEquals('Missing required credentials.', error);
    }

    @IsTest
    private static void testGetAuthInfoHappyPath() {
        // Have to create a test user as the current user so that we can run other things as a different user.
        User testUser = null;
        UserRole testRole = new UserRole(
            developerName = 'MyCustomRole',
            name = 'FSC User'
        );
        insert testRole;

        testUser = new User(
            alias = 'alias',
            email = 'testuser@iccu.com',
            emailEncodingKey = 'UTF-8',
            firstName = 'first',
            cashBox__c = '9999',
            companyName = 'TEST',
            languageLocaleKey = 'en_US',
            lastName = 'last',
            localeSidKey = 'en_US',
            networkNodeName__c = 'SomeNetworkNode',
            profileId = [SELECT Id FROM Profile WHERE Name='FSC User'].Id,
            title = 'title',
            timeZoneSidKey = 'America/Denver',
            username = 'testuser@iccu.com' + System.currentTimeMillis(),
            userRoleId = testRole.Id
        );
        insert testUser;

        System.runAs(testUser) {
            IAuthenticationManager ccmAuthManager = new CCMAuthenticationManagerMock();
            IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
            IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
            INetworkFactory networkFactory = new ConcreteNetworkProvider(ccmAuthManager, coreAuthManager, businessServicesAuthManager);
            AuthController.networkFactory = networkFactory;

            Map<String, Object> response = AuthController.getAuthenticationInfo();
            System.assertNotEquals(null, response);
            System.assertEquals('testuser', (String)response.get('username'));
            System.assertEquals('testuser@iccu.com', (String)response.get('email'));
            System.assertEquals('9999', (String)response.get('cashBox'));
            System.assertEquals('SomeNetworkNode', (String)response.get('networkNodeName'));
            System.assertEquals(true, (Boolean)response.get('isAuthedCore'));
            System.assertEquals(true, (Boolean)response.get('isAuthedBusinessServices'));
            System.assertEquals(true, (Boolean)response.get('isAuthedCcm'));
        }
    }
}