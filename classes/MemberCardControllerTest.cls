@IsTest
private class MemberCardControllerTest {

    @IsTest
    private static void testHappyPathGetCards() {
        Contact testContact = getTestContact();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockCardResponse());

        IAuthenticationManager ccmAuthManager = new CCMAuthenticationManagerMock();
        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(ccmAuthManager, coreAuthManager, businessServicesAuthManager);

        MemberCardController.networkFactory = networkFactory;

        try {
            Map<String, Object> response = MemberCardController.fetchCardData(testContact.Id);
            System.assert(response != null, 'Card response was null!');

            // TODO:  Ensure that the cardNumber is redacted!

            String error = (String)response.get('error');
            System.assert(error == null, 'Unexpected error: ' + error);
        } catch(Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e.getMessage() + e.getStackTraceString());
        }

        Test.stopTest();
    }

    @IsTest
    private static void testHappyPathUpdateStatus() {
        Contact testContact = getTestContact();

        // Determine the uniqueId for the test card.
        AccountCardInfo info = new AccountCardInfo(null, null, null, null, true, '4869382267100638', null, null, null, 'Ann Smith', null, null, null, null);
        String uniqueId = info.uniqueId;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockCardResponse());

        IAuthenticationManager ccmAuthManager = new CCMAuthenticationManagerMock();
        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(ccmAuthManager, coreAuthManager, businessServicesAuthManager);

        MemberCardController.networkFactory = networkFactory;

        String json = '[{"agreementNumber" : "1234567", "changeReason" : "some reason", "changeReasonCode" : "STLN", "status" : "ACT", "providerName" : "DNA", "typeCode" : "DBT", "uniqueId" : "' + uniqueId + '" }]';

        try {
            Map<String, Object> response = MemberCardController.updateCardStatuses(testContact.Id, json);
            System.assert(response != null, 'Card response was null!');

            String error = (String)response.get('error');
            System.assert(error == null, 'Unexpected error: ' + error);
        } catch(Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e.getMessage() + e.getStackTraceString());
        }

        Test.stopTest();
    }

    @IsTest
    private static void testHappyPathUpdateTravelNotifications() {
        Contact testContact = getTestContact();
        createTestServiceAccount();

        // Determine the uniqueId for the test card.
        AccountCardInfo info = new AccountCardInfo(null, null, null, null, true, '4869382267100638', null, null, null, 'Ann Smith', null, null, null, null);
        String uniqueId = info.uniqueId;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockCardResponse());

        IAuthenticationManager ccmAuthManager = new CCMAuthenticationManagerMock();
        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(ccmAuthManager, coreAuthManager, businessServicesAuthManager);

        MemberCardController.networkFactory = networkFactory;

        String json = '[{"countryCodes" : ["USA"], "fromDate" : "2019-08-01 00:00:00", "note" : "test note", "providerName" : "DNA", "stateCodes" : [], "toDate" : "2019-08-05 00:00:00", "uniqueId" : "' + uniqueId + '"}]';
        try {
            Map<String, Object> response = MemberCardController.updateTravelNotifications(testContact.Id, json);
            System.assert(response != null, 'Card response was null!');

            String error = (String)response.get('error');
            System.assert(error == null, 'Unexpected error: ' + error);

            System.assert(response.containsKey('success'));
            System.assertEquals(true, response.get('success'));
        } catch(Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e.getMessage() + e.getStackTraceString());
        }

        Test.stopTest();
    }

    @IsTest
    private static void testUnhappyPathGetCards() {
        Contact testContact = getTestContact();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockCardResponse());

        IAuthenticationManager ccmAuthManager = new CCMAuthenticationManagerMock();
        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(ccmAuthManager, coreAuthManager, businessServicesAuthManager);


        MemberCardController.networkFactory = networkFactory;

        // Null person number
        Map<String, Object> response = MemberCardController.fetchCardData(null);
        System.assert(response != null, 'Response was null!');

        String error = (String)response.get('error');
        System.assert(error != null, 'Expected an error to be given, but none was specified.');

        // Simulate an unauthenticated state
        ccmAuthManager.logOut();
        coreAuthManager.logOut();
        businessServicesAuthManager.logOut();

        // Not authenticated
        response = MemberCardController.fetchCardData(testContact.Id);
        System.assert(response != null, 'Response was null!');

        error = (String)response.get('error');
        System.assert(error != null, 'Expected an error to be given, but none was specified.');

        Test.stopTest();
    }

    @IsTest
    private static void testUnhappyPathUpdateStatus() {
        Contact testContact = getTestContact();

        // Determine the uniqueId for the test card.
        AccountCardInfo info = new AccountCardInfo(null, null, null, null, true, '4869382267100638', null, null, null, 'Ann Smith', null, null, null, null);
        String uniqueId = info.uniqueId;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockCardResponse());

        IAuthenticationManager ccmAuthManager = new CCMAuthenticationManagerMock();
        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(ccmAuthManager, coreAuthManager, businessServicesAuthManager);

        MemberCardController.networkFactory = networkFactory;

        // Null contactId
        Map<String, Object> response = MemberCardController.updateCardStatuses(null, null);
        String error = (String)response.get('error');
        System.assert(error != null, 'Expected an error, but did not get one.');

        // Null JSON
        response = MemberCardController.updateCardStatuses(testContact.id, null);
        error = (String)response.get('error');
        System.assert(error != null, 'Expected an error, but did not get one.');

        // Bad JSON
        response = MemberCardController.updateCardStatuses(testContact.id, 'blue');
        error = (String)response.get('error');
        System.assert(error != null, 'Expected an error, but did not get one.');

        // Missing Provider name
        String json = '[{"changeReason" : "some reason", "changeReasonCode" : "STLN", "status" : "ACT", "typeCode" : "DBT", "uniqueId" : "' + uniqueId + '" }]';
        response = MemberCardController.updateCardStatuses(testContact.id, json);
        error = (String)response.get('error');
        System.assert(error != null, 'Expected an error, but did not get one.');

        // Bad Provider name
        json = '[{"changeReason" : "some reason", "changeReasonCode" : "STLN", "status" : "ACT", "providerName" : "BAD NAME!", "typeCode" : "DBT", "uniqueId" : "' + uniqueId + '" }]';
        response = MemberCardController.updateCardStatuses(testContact.id, json);
        error = (String)response.get('error');
        System.assert(error != null, 'Expected an error, but did not get one.');

        Test.stopTest();
    }

    private static Contact getTestContact() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),
            MemberNumber__c = '23423987aa',
            Email = 'something@example.com',
            FirstName = 'Ann',
            LastName = 'Smith',
            MailingStreet = '123 Penny Lane',
            MailingCity = 'Chubbuck',
            MailingState = 'ID',
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxID__c = '000-00-0000',
            PersonNumber__c = '123432a',
            Phone = '(555) 555-5555'
        );

        insert testContact;
        return testContact;
    }

    private static void createTestServiceAccount() {
        List<ServiceAccounts__c> serviceAccounts = new List<ServiceAccounts__c> {
            new ServiceAccounts__c(
                APIClientSecret__c = 'secret',
                Name = 'CO-OP',
                ServiceName__c = 'CO-OP'
            )
        };
        insert serviceAccounts;
    }

}