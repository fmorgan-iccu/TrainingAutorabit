@isTest
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

        System.assert(personDataProvider != null);
        System.assert(accountDataProvider != null);
        System.assert(appDataProvider != null);
        System.assert(productOfferingDataProvider != null);
        System.assert(aoTransactionProvider != null);
        System.assert(prefillProvider != null);
        System.assert(debitCardProvider != null);
        System.assert(creditCardProvider != null);
        System.assert(cardTravelNotificationProvider != null);
        
        Test.stopTest();
    }

}