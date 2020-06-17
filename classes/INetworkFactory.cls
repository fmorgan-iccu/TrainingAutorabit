/*
 *	Interface for describing a class that returns data providers.
 */
public interface INetworkFactory {
    IPersonDataProvider getPersonDataProvider();
    IPersonAccountDataProvider getPersonAccountDataProvider();
    IProductApplicationDataProvider getProductApplicationDataProvider();
    IProductOfferingDataProvider getProductOfferingDataProvider();
    
    IOrganizationDataProvider getOrganizationDataProvider();
    
    IAccountOpeningTransactionProvider getAccountOpeningTransactionProvider();
    IAccountOpeningApplicationPrefiller getAccountOpeningApplicationPrefillProvider();
    
    IAccountOpeningProductDataProvider getAccountOpeningProductDataProvider();
    
    ICardDataProvider getCreditCardDataProvider();
    ICardDataProvider getDebitCardDataProvider();

    ICardTravelNotificationDataProvider getCardTravelNotificationDataProvider();
}