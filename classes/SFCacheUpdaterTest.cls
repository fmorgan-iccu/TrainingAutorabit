@isTest
private class SFCacheUpdaterTest {
    @isTest
    private static void testHappyPath() {
        String personNumber = '355061';
        String orcNumber = '1453';

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        SFCacheUpdater updater = new SFCacheUpdater(networkFactory);
        IPerson person = updater.fetchPerson(personNumber);
        IOrganization orc = updater.fetchOrganization(orcNumber);

        Contact testContact = new Contact (
            FirstName = 'Test',
            MiddleName = 'TestMiddle',
            LastName = 'User',
            PreferredName__c = null,
            TaxID__c = '888-88-8888',
            PersonNumber__c = personNumber,
            MemberNumber__c = '09876545',
            IdentificationNumber__c = '2983475'
        );

        insert testContact;

        Contact updatedContact = updater.persistPerson(person, testContact);

        System.assert(updatedContact != null);
        System.assert(updatedContact.FirstName.equals('Wayne'));
        System.assert(updatedContact.MiddleName.equals('Maurice'));
        System.assert(updatedContact.LastName.equals('Hartman'));
        System.assert(updatedContact.PreferredName__c.equals('Jake'));
        System.assert(updatedContact.TaxID__c.equals('999-99-9999'));
        System.assert(updatedContact.MemberNumber__c.equals('20'));
        System.assert(updatedContact.IdentificationNumber__c != null, 'Drivers License is null!');

        String basePhone = '2085555555';
        String formattedPhone = '(208) 555-5555';

        System.assert(PhoneUtils.format(basePhone).equals(formattedPhone));
        System.assert(PhoneUtils.format(formattedPhone).equals(formattedPhone));

        // Purely for code coverage...
        SFCacheUpdater defaultUpdater = new SFCacheUpdater();
        System.assert(defaultUpdater != null);

        Account testAccount = new Account (
            Email__c = 'email@example.com',
            Name = 'Test',
            OrganizationNumber__c = '9876',
            OrganizationTaxID__c = '666-99-9999',
            OrganizationType__c = 'XXXX',
            Phone = '555-555-5555'
        );

        insert testAccount;

        Account updatedAccount = updater.persistOrganization(orc, testAccount);
        System.assertNotEquals(null, updatedAccount);
        System.assertEquals('admin@sprockets.space', updatedAccount.Email__c);
        System.assertEquals('O1453 - Spacely\'s Sprockets', updatedAccount.Name);
        System.assertEquals('1453', updatedAccount.OrganizationNumber__c);
        System.assertEquals('999-99-9999', updatedAccount.OrganizationTaxID__c);
        System.assertEquals('CORP', updatedAccount.OrganizationType__c);
        System.assertEquals('(208) 886-7860', updatedAccount.Phone);
    }

    @isTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);

        SFCacheUpdater updater = new SFCacheUpdater(networkFactory);

        String invalidPhone = '7843';
        String nullPhone = null;
        String badCharsPhone = 'as12345ldkjhfakl6sdjhf78asdfa90';

        System.assert(PhoneUtils.format(invalidPhone).equals(invalidPhone));
        System.assert(PhoneUtils.format(nullPhone) == null);
        System.assert(PhoneUtils.format(badCharsPhone).equals('(123) 456-7890'));

        try {
            IPerson person = updater.fetchPerson(null);
            System.assert(false, 'Should not have reached this point...');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Expectedly threw an exception');
        }

        try {
            IOrganization orc = updater.fetchOrganization(null);
            System.assert(false, 'Should not have reached this point...');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Expectedly threw an exception');
        }
    }
}