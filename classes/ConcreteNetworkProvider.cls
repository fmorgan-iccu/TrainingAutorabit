/*
*	Class for implementing INetworkFactory.  Hides all the API concrete classes from consumers.
*/
public class ConcreteNetworkProvider implements INetworkFactory {
    private IAuthenticationManager ccmAuthenticationManager;
    private IAuthenticationManager dnaCoreAuthenticationManager;
    private IAuthenticationManager dnaBusinessServicesAuthManager;
    private IAuthenticationManager encompassAuthenticationManager;

    public ConcreteNetworkProvider() {
    }

    /*
     *	Constructor to aid in unit testing for DNA...
     */
    @TestVisible
    private ConcreteNetworkProvider(IAuthenticationManager dnaCoreAuthenticationManager)
    {
        this.dnaCoreAuthenticationManager = dnaCoreAuthenticationManager;
    }
    
    @TestVisible
    private ConcreteNetworkProvider(IAuthenticationManager dnaCoreAuthenticationManager,
                                    IAuthenticationManager dnaBusinessServicesAuthManager)
    {
        this.dnaCoreAuthenticationManager = dnaCoreAuthenticationManager;
        this.dnaBusinessServicesAuthManager = dnaBusinessServicesAuthManager;
    }
    
    /*
     *	Constructor to aid in unit testing card changes
     */
    @TestVisible
    private ConcreteNetworkProvider(IAuthenticationManager ccmAuthManager,
                                    IAuthenticationManager dnaCoreAuthenticationManager,
                                    IAuthenticationManager dnaBusinessServicesAuthManager)
    {
        this.ccmAuthenticationManager = ccmAuthManager;
        this.dnaCoreAuthenticationManager = dnaCoreAuthenticationManager;
        this.dnaBusinessServicesAuthManager = dnaBusinessServicesAuthManager;
    }
    
    public IPersonDataProvider getPersonDataProvider() {
        if (this.dnaCoreAuthenticationManager != null) {
            return new DNAPersonDataProvider(this.dnaCoreAuthenticationManager);
        } else {
            return new DNAPersonDataProvider();
        }
    }
    
    public IOrganizationDataProvider getOrganizationDataProvider() {
        if (this.dnaCoreAuthenticationManager != null) {
            return new DNAPersonDataProvider(this.dnaCoreAuthenticationManager);
        } else {
            return new DNAPersonDataProvider();
        }
    }
    
    public IPersonAccountDataProvider getPersonAccountDataProvider() {
        if (this.dnaCoreAuthenticationManager != null) {
            return new DNAPersonAccountDataProvider(this.dnaCoreAuthenticationManager);
        } else {
            return new DNAPersonAccountDataProvider();
        }
    }
    
    public IProductApplicationDataProvider getProductApplicationDataProvider() {
        if (this.encompassAuthenticationManager == null) {
            ServiceAccounts__c encompassServiceAccount = [
                SELECT 
                    APIClientID__c,
                    APIClientSecret__c,
                    InstanceID__c,
                    Password__c,
                    Username__c
                FROM ServiceAccounts__c
                WHERE ServiceName__c = 'Encompass'
                LIMIT 1
            ];
            
            String apiClientID = encompassServiceAccount.APIClientID__c;
            String apiClientSecret = encompassServiceAccount.APIClientSecret__c;
            String instanceId = encompassServiceAccount.InstanceID__c;
            String username = encompassServiceAccount.Username__c;
            String password = encompassServiceAccount.Password__c;
            
            ResourceOwnerCredential credential = new ResourceOwnerCredential(apiClientID, apiClientSecret, instanceID, username, password);
            
            this.encompassAuthenticationManager = new EncompassAuthenticationManager(credential, new EncompassTokenManager());
        }
        
        IProductApplicationDataProvider encompassProvider = new EncompassProductApplicationDataProvider(this.encompassAuthenticationManager, new EncompassTokenManager());
        IProductApplicationDataProvider actionProvider = new CRIFActionDataProvider();
        
        List<IProductApplicationDataProvider> applicationProviders = new List<IProductApplicationDataProvider>();
        applicationProviders.add(encompassProvider);
        applicationProviders.add(actionProvider);
        
        return new CombinedProductApplicationDataProvider(applicationProviders);
    }
    
    public IProductOfferingDataProvider getProductOfferingDataProvider() {
        if (this.dnaCoreAuthenticationManager != null) {
            return new DNAProductOfferingDataProvider(this.dnaCoreAuthenticationManager);
        } else {
            return new DNAProductOfferingDataProvider();
        }
    }
    
    public IAccountOpeningTransactionProvider getAccountOpeningTransactionProvider() {
        ResourceOwnerCredential credential = this.getAvokaCredentials();
        IAccountOpeningProductDataProvider productDataProvider = this.getAccountOpeningProductDataProvider();
        
        TMTransactionDataProvider provider = new TMTransactionDataProvider(credential, productDataProvider);
        
        return provider;
    }
    
    public IAccountOpeningApplicationPrefiller getAccountOpeningApplicationPrefillProvider() {
        ResourceOwnerCredential credential = this.getAvokaCredentials();
        IAccountOpeningProductDataProvider productDataProvider = this.getAccountOpeningProductDataProvider();
        
        TMTransactionDataProvider prefiller = new TMTransactionDataProvider(credential, productDataProvider);
        
        return prefiller;
    }
    
    public IAccountOpeningProductDataProvider getAccountOpeningProductDataProvider() {
        ICCUAccountOpeningProductDataProvider provider = new ICCUAccountOpeningProductDataProvider();
        
        return provider;
    }
    
    public ICardDataProvider getDebitCardDataProvider() {
        if (this.dnaCoreAuthenticationManager != null) {
            return new DNACardDataProvider(this.dnaCoreAuthenticationManager, this.dnaBusinessServicesAuthManager);
        } else {
            return new DNACardDataProvider();
        }
    }

    public ICardDataProvider getCreditCardDataProvider() {
        if (this.ccmAuthenticationManager != null) {
            return new CCMDataProvider(this.ccmAuthenticationManager);
        } else {
            return new CCMDataProvider();
        }
    }

    public ICardTravelNotificationDataProvider getCardTravelNotificationDataProvider() {
        return new COOPTravelNotificationDataProvider();
    }
    
    private ResourceOwnerCredential getAvokaCredentials() {
        ServiceAccounts__c avokaServiceAccount = [
            SELECT 
                Password__c,
                Username__c
            FROM ServiceAccounts__c
            WHERE ServiceName__c = 'AvokaTM'
            LIMIT 1
        ];

        String username = avokaServiceAccount.Username__c;
        String password = avokaServiceAccount.Password__c;

        ResourceOwnerCredential credential = new ResourceOwnerCredential(null, null, null, username, password);

        return credential;
    }
}