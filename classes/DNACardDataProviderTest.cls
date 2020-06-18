@IsTest
private class DNACardDataProviderTest {

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

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest();

        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        DNACardDataProvider provider = new DNACardDataProvider(coreAuthManager, businessServicesAuthManager);

        List<AccountCardInfo> cards = provider.getAccountCardInfo(personNumber);

        System.assert(cards != null, 'Cards was null!');
        System.assertEquals(1, cards.size());

        // Test the internal parsing
        AccountCardInfo card = cards[0];
        System.assertEquals(true, card.canChangeStatus);
        System.assertEquals('4758691598502476', card.cardNumber);
        System.assertEquals('Visa Check Card', card.displayName);
        System.assertEquals('John Doe', card.nameOnCard);
        System.assertEquals(null, card.expirationDate);
        System.assertEquals('DNA', card.providerName);
        System.assertEquals('ACT', card.status);
        System.assertNotEquals(null, card.uniqueId);

        Test.stopTest();
    }

    @IsTest
    private static void testUnhappyPath() {
        String personNumber = '636423';

        // Code coverage
        new DNACardDataProvider();

        IAuthenticationManager coreAuthManager = new DNABusinessServicesAuthManagerMock();
        IAuthenticationManager businessServicesAuthManager = new DNABusinessServicesAuthManagerMock();
        DNACardDataProvider provider = new DNACardDataProvider(coreAuthManager, businessServicesAuthManager);

        coreAuthManager.logOut();
        businessServicesAuthManager.logout();

        // NOTE:  Since these are pass-through services, they will not be re-tested in a happy path.

        try {
            provider.getAccountCardInfo(personNumber);
            System.assert(false, 'getAccountCardInfo succeeded even though the user is not logged in.');
        } catch (UnauthenticatedException e) {
            // Expected behaviour
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception thrown. ' + e.getMessage());
        }

        try {
            AccountCardInfo cardInfo = new AccountCardInfo(null, '12345678', null, null, true, 'test card number', null, 'Debit', null, 'test name', 'DNA', null, null, 'DBT');
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(cardInfo, 'Some reason', 'LOST', 'HOT')
            };
            provider.updateAccountCardStatuses(personNumber, requests);
            System.assert(false, 'updateAccountCardStatuses succeeded even though the user is not logged in.');
        } catch (UnauthenticatedException e) {
            // Expected behaviour
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception thrown. ' + e.getMessage());
        }
    }

}