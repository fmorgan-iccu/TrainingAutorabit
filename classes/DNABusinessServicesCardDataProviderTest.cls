@IsTest
private class DNABusinessServicesCardDataProviderTest {

    @IsTest
    private static void testHappyPath() {
        String personNumber = '636423';

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
            PersonNumber__c = personNumber,
            Phone = '(555) 555-5555'
        );
        insert testContact;

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNABusinessServicesAuthManagerMock();
        DNABusinessServicesCardDataProvider provider = new DNABusinessServicesCardDataProvider(authManager);

        List<AccountCardInfo> cards = provider.getAccountCardInfo(personNumber);

        Test.stopTest();

        System.assert(cards != null, 'Cards was null!');
        System.assertEquals(1, cards.size());
        
        // Test the internal parsing
        AccountCardInfo card = cards[0];
        System.assertEquals('2042807', card.agreementNumber);
        System.assertEquals(false, card.canChangeStatus);
        System.assertEquals('4758691598502476', card.cardNumber);
        System.assertEquals(null, card.displayName);
        System.assertEquals(null, card.expirationDate);
        System.assertEquals('DNA', card.providerName);
        System.assertEquals(null, card.status);
        System.assertNotEquals(null, card.uniqueId);
    }

    @IsTest
    private static void testUnhappyPath() {
        String personNumber = '636423';

        // Code coverage
        new DNABusinessServicesCardDataProvider();

        IAuthenticationManager authManager = new DNABusinessServicesAuthManagerMock();
        DNABusinessServicesCardDataProvider provider = new DNABusinessServicesCardDataProvider(authManager);
        authManager.logOut();

        try {
            provider.getAccountCardInfo(personNumber);
            System.assert(false, 'getAccountCardInfo succeeded even though the user is not logged in.');
        } catch (UnauthenticatedException e) {
            // Expected behaviour
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception thrown. ' + e.getMessage());
        }

        try {
            provider.updateAccountCardStatuses(personNumber, null);
            System.assert(false, 'Expected DataServiceException not thrown.');
        } catch (DataServiceException e) {
            // Expected behaviour
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception thrown. ' + e.getMessage());
        }
    }

}