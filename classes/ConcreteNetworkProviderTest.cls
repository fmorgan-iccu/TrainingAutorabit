@IsTest
private class ConcreteNetworkProviderTest {

    @IsTest
    private static void testGetters() {
        List<ServiceAccounts__c> serviceAccounts = new List<ServiceAccounts__c> {
            new ServiceAccounts__c(
                APIClientID__c = 'client2',
                APIClientSecret__c = 'secret2',
                InstanceID__c = 'instance2',
                Name = 'AvokaTM',
                Password__c = 'password2',
                ServiceName__c = 'AvokaTM',
                Username__c = 'username2'
            ),
            new ServiceAccounts__c(
                APIClientSecret__c = 'secret',
                Name = 'CO-OP',
                ServiceName__c = 'CO-OP'
            ),
            new ServiceAccounts__c(
                APIClientID__c = 'client',
                APIClientSecret__c = 'secret',
                InstanceID__c = 'instance',
                Name = 'Encompass',
                Password__c = 'password',
                ServiceName__c = 'Encompass',
                Username__c = 'username'
            )
        };
        insert serviceAccounts;

        Test.startTest();

        ConcreteNetworkProvider provider = new ConcreteNetworkProvider();
        IPersonDataProvider personDataProvider = provider.getPersonDataProvider();
        IPersonAccountDataProvider accountDataProvider = provider.getPersonAccountDataProvider();
        IProductApplicationDataProvider appDataProvider = provider.getProductApplicationDataProvider();
        IProductOfferingDataProvider productOfferingDataProvider = provider.getProductOfferingDataProvider();
        IAccountOpeningTransactionProvider aoTransactionProvider = provider.getAccountOpeningTransactionProvider();
        IAccountOpeningApplicationPrefiller prefillProvider = provider.getAccountOpeningApplicationPrefillProvider();
        ICardDataProvider debitCardProvider = provider.getDebitCardDataProvider();
        ICardDataProvider creditCardProvider = provider.getCreditCardDataProvider();
        ICardTravelNotificationDataProvider cardTravelNotificationProvider = provider.getCardTravelNotificationDataProvider();
        IOrganizationDataProvider orgDataProvider = provider.getOrganizationDataProvider();
        IOrganizationDataProvider orgWarningDataProvider = provider.getOrgWarningDataProvider();

        System.assertNotEquals(null, personDataProvider);
        System.assertNotEquals(null, accountDataProvider);
        System.assertNotEquals(null, appDataProvider);
        System.assertNotEquals(null, productOfferingDataProvider);
        System.assertNotEquals(null, aoTransactionProvider);
        System.assertNotEquals(null, prefillProvider);
        System.assertNotEquals(null, debitCardProvider);
        System.assertNotEquals(null, creditCardProvider);
        System.assertNotEquals(null, cardTravelNotificationProvider);
        System.assertNotEquals(null, orgDataProvider);
        System.assertNotEquals(null, orgWarningDataProvider);

        Test.stopTest();
    }

}