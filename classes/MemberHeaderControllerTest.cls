@IsTest
private class MemberHeaderControllerTest {
    @IsTest
    private static void testHappyPath() {
        Contact testContact = getTestContact(false);

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        MemberHeaderController.updater = new SFCacheUpdater(networkFactory);
        MemberHeaderController.emailService = new SFEmailService(true, false);

        Test.startTest();

        Map<String, Object> response = MemberHeaderController.refreshContent(testContact.id, testContact.PersonNumber__c);

        Test.stopTest();

        System.assertNotEquals(null, response);
        String error = (String)response.get('error');
        System.assert(error == null, error);
        System.assertNotEquals(null, response.get('contact'));
    }

    @IsTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);
        MemberHeaderController.updater = new SFCacheUpdater(networkFactory);

        Test.startTest();

        Map<String, Object> response = MemberHeaderController.refreshContent(null, null);

        Test.stopTest();

        String error = (String)response.get('error');
        System.assertNotEquals(null, error);
    }

    @IsTest
    private static void testUpdateContact() {
        Contact testContact = getTestContact(false);

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        Test.startTest();

        Map<String, Object> response = MemberHeaderController.updateContact(testContact.id,
            'test@iccu.com',
            'some street',
            'apt 123',
            'Pocatello',
            'USA',
            '83204',
            'ID',
            '(800) 123-1234',
            '(800) 234-2345',
            true);

        Test.stopTest();

        System.assertEquals(1, response.keySet().size());

        LogUtils.debug(JSON.serialize(response), 'response-');

        Contact c = (Contact)response.get('contact');
        System.assertNotEquals(null, c);
        System.assertEquals('test@iccu.com', c.email);
        System.assert(c.mailingStreet.contains('some street'));
        System.assert(c.mailingStreet.contains('apt 123'));
        System.assertEquals('Pocatello', c.mailingCity);
        System.assertEquals('USA', c.mailingCountry);
        System.assertEquals('83204', c.mailingPostalCode);
        System.assertEquals('ID', c.mailingState);
        System.assertEquals('(800) 123-1234', c.mobilePhone);
        System.assertEquals('(800) 234-2345', c.phone);
        System.assertEquals(true, c.VerifiedIdentityPhone__c);
    }

    @IsTest
    static void resetVerifiedIdentityPhone() {
        Contact testContact = getTestContact(true);

        Test.startTest();

        Map<String, Object> response = MemberHeaderController.resetVerifiedIdentityPhone(testContact.id);

        Test.stopTest();

        Contact c = ContactController.getContact(testContact.id);

        System.assertEquals(1, response.keySet().size());
        System.assertEquals(true, response.get('success'));
        System.assertEquals(false, c.VerifiedIdentityPhone__c);
    }

    @IsTest
    static void resetVerifiedIdentityUnhappyPhone() {
        Contact testContact = getTestContact(true);

        // Delete the test contact to generate an error
        delete testContact;

        Test.startTest();

        Map<String, Object> response = MemberHeaderController.resetVerifiedIdentityPhone(testContact.id);
        Map<String, Object> nullResponse = MemberHeaderController.resetVerifiedIdentityPhone(null);

        Test.stopTest();

        System.assertEquals(2, response.keySet().size());
        System.assertEquals(false, (Boolean)response.get('success'));
        System.assert(response.containsKey('error'));

        System.assertEquals(2, nullResponse.keySet().size());
        System.assertEquals(false, (Boolean)nullResponse.get('success'));
        System.assert(nullResponse.containsKey('error'));
    }

    private static Contact getTestContact(Boolean verifiedIdentityPhone) {
        Contact testContact = new Contact (
            Birthdate = Date.today(),
            MemberNumber__c = '23423987',
            Email = 'something@example.com',
            FirstName = 'Jack',
            MiddleName = 'Joe',
            LastName = 'Johnson',
            MailingStreet = '123 Penny Lane',
            MailingCity = 'Chubbuck',
            MailingState = 'ID',
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxID__c = '000-00-0000',
            PersonNumber__c = '123456',
            Phone = '(555) 555-5555',
            VerifiedIdentityPhone__c = verifiedIdentityPhone
        );
        insert testContact;

        return testContact;
    }
}