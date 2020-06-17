/**
 * Class for getting account opening transactions from Transact Manager.
 */
public virtual class TMTransactionDataProvider extends TMDataProvider implements IAccountOpeningTransactionProvider, IAccountOpeningApplicationPrefiller {
    private static String MAJOR_TYPE_CODE_LOANS	= 'CRIF';
    private static String FORM_CODE_LOAN		= '';
    private static String FORM_CODE_DEPOSIT		= '';
    
    private IAccountOpeningProductDataProvider productDataProvider;
    
    /**
     * Create a new instance of a TMTransactionDataProvider.
     * @param credential Credential for accessing a Transact Manager resource
     */
    public TMTransactionDataProvider(ResourceOwnerCredential credential, IAccountOpeningProductDataProvider productDataProvider) {
        super(credential);
        
        this.productDataProvider = productDataProvider;
    }
	
    /**
     * Get transactions by their form status.
     * @param formStatus The status of the form of the transaction.
     * @return A list of Transactions that match the form status
     */
    public List<TMTransaction> getTransactionsByFormStatus(String formStatus) {
        if (formStatus == null) {
            throw new IllegalArgumentException('Form Status must NOT be null');
        }

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getAvokaTransactionEndpoint() + '/' + '?formStatus=' + formStatus;

        System.debug('>>>>>>>>> getTransactionsByFormStatus endpoing: ' + endpoint);
        
        List<Object> response = (List<Object>)this.callApi(endpoint, EndpointManager.HTTP_METHOD_GET, null);
        List<Map<String, Object>> rawTransactions = this.convertObjectList(response);
        List<TMTransaction> transactions = new List<TMTransaction>();

        Map<String, AccountOpeningProduct> products = this.fetchProducts();
        
        for (Map<String, Object> rawTransaction : rawTransactions) {
            TMTransaction trans = this.mapTransaction(rawTransaction, products);
            transactions.add(trans);
        }
        
        // Attach applicable case IDs to the transactions
        this.mapCaseIDToTransactions(transactions);
        
        return transactions;
    }
    
    /**
     * Returns transactions that are grouped together.
     */
    public List<AccountOpeningTransactionGroup> getGroupedTransactions() {
        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getAvokaTransactionEndpoint() + '/';

        List<Object> response = (List<Object>)this.callApi(endpoint, EndpointManager.HTTP_METHOD_GET, null);
        List<Map<String, Object>> rawTransactions = this.convertObjectList(response);
        List<TMTransaction> transactions = new List<TMTransaction>();
        
        Map<String, AccountOpeningProduct> products = this.fetchProducts();
        
        for (Map<String, Object> rawTransaction : rawTransactions) {
            TMTransaction trans = this.mapTransaction(rawTransaction, products);
            transactions.add(trans);
        }
        
        Map<String, List<IAccountOpeningTransaction>> groupedTransactions = new Map<String, List<IAccountOpeningTransaction>>();
        
        for (TMTransaction trans : transactions) {
            String status = trans.getFormStatus();
            
            List<IAccountOpeningTransaction> storedTransactions = groupedTransactions.get(status);
            
            if (storedTransactions == null) {
                storedTransactions = new List<IAccountOpeningTransaction>();
                groupedTransactions.put(status, storedTransactions);
            }

            storedTransactions.add(trans);
        }

        List<AccountOpeningTransactionGroup> groups = new List<AccountOpeningTransactionGroup>();

        for (String key : groupedTransactions.keySet()) {
            String title = StringUtils.toProperCase(key);
            List<IAccountOpeningTransaction> storedTransactions = groupedTransactions.get(key);

            // Attach applicable case IDs to the transactions
            this.mapCaseIDToTransactions(storedTransactions);

            AccountOpeningTransactionGroup transGroup = new AccountOpeningTransactionGroup(title, storedTransactions);
            groups.add(transGroup);
        }

        return groups;
    }
    
    /**
     * Get transaction by ID
     * @param transactionId The ID of the transaction requested
     * @return A transaction matching the ID requested
     */
    public TMTransaction getTransaction(String transactionId) {
        if (transactionId == null) {
            throw new IllegalArgumentException('Transaction ID must NOT be null');
        }

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getAvokaTransactionEndpoint() + '/' + transactionId;

        Map<String, Object> rawTransaction = (Map<String, Object>)this.callApi(endpoint, EndpointManager.HTTP_METHOD_GET, null);
        Map<String, AccountOpeningProduct> products = this.fetchProducts();
        TMTransaction trans = this.mapTransaction(rawTransaction, products);

        return trans;
    }
    
    /**
     * Update the status of a transaction
     * @param status The status for the transaction to change.
     * @param transactionId The ID of the transaction that is to be updated.
     * @return The updated transaction
     */
    public TMTransaction updateTransactionStatus(String status, String transactionId) {
        if (status == null) {
            throw new IllegalArgumentException('The form status CANNOT be null.');
        }

        if (transactionId == null) {
            throw new IllegalArgumentException('The transaction ID CANNOT be null.');
        }

        Map<String, Object> bodyData = new Map<String, Object>();
        bodyData.put('formStatus', status);

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getAvokaTransactionEndpoint() + '/' + transactionId;

        Map<String, Object> rawTransaction = (Map<String, Object>)this.callApi(endpoint, EndpointManager.HTTP_METHOD_PUT, bodyData);
        Map<String, AccountOpeningProduct> products = this.fetchProducts();
        TMTransaction trans = this.mapTransaction(rawTransaction, products);

        return trans;
    }
    
    /**
     * The list of applicable form statuses for transactions.
     * @return A list of the applicable statuses for a form.
     */
    public List<String> getUpdateTransactionFormStatuses() {
        List<String> statuses = new List<String>();

        //statuses.add('Assigned');
        //statuses.add('Opened');
        statuses.add('Saved');
        //statuses.add('Submitted');
        //statuses.add('Completed');
        //statuses.add('Expired');
        statuses.add('Abandoned');

        return statuses;
    }
    
    /**
     * Submites a prefilled application to Transact Manager.
     * @param application The prefilled application to send to TM.
     * @return A response from TM indicating if the submission was successfull or not.
     */
    public AccountOpeningApplicationPrefillResponse submitPrefilledApplication(AccountOpeningApplication application) {
        AccountOpeningProduct product = application.getProduct();
        IPerson person = application.getPerson();

        Date dateDOB = person.getDateOfBirth();
        Datetime dob = datetime.newInstance(dateDOB.year(), dateDOB.month(), dateDOB.day());

        String formattedDOB = dob.format('yyyy-MM-dd');

        List<URLQueryItem> items = new List<URLQueryItem>();

        // Member information
        items.add(new URLQueryItem('FirstName', person.getFirstName()));
        items.add(new URLQueryItem('LastName', person.getLastName()));
        items.add(new URLQueryItem('SSN', person.getTaxId()));
        items.add(new URLQueryItem('DOB', formattedDOB));
        items.add(new URLQueryItem('Address', person.getPrimaryAddress().getStreet()));
        items.add(new URLQueryItem('City', person.getPrimaryAddress().getCity()));
        items.add(new URLQueryItem('State', person.getPrimaryAddress().getStateCode()));
        items.add(new URLQueryItem('ZIP', person.getPrimaryAddress().getPostalCode()));
        items.add(new URLQueryItem('Email', person.getEmailAddress()));

        // Product Information
        items.add(new URLQueryItem('MajorProductId', product.majorTypeCode));
        items.add(new URLQueryItem('MinorProductId', product.minorTypeCode));

        // Form Code
        items.add(new URLQueryItem('formCode', this.getFormCodeForProduct(product)));

        EndpointManager endpointManager = new EndpointManager();
        String prefillEndpoint = endpointManager.getAvokaPrefillEndpoint();

        URLConstructor constructor = new URLConstructor(prefillEndpoint, items);
        String url = constructor.constructURL();

        return new AccountOpeningApplicationPrefillResponse(url);
    }
    
    /**
     * Gets the applicable form code for the specified product
     * @param product The product for which the form code is desired
     * @param Avoka form code that corresponds to the product.
     */
    private String getFormCodeForProduct(AccountOpeningProduct product) {
        if (product == null) {
            return null;
        }

        if (product.majorTypeCode.equals(TMTransactionDataProvider.MAJOR_TYPE_CODE_LOANS)) {
            return TMTransactionDataProvider.FORM_CODE_LOAN;
        } else {
            return TMTransactionDataProvider.FORM_CODE_DEPOSIT;
        }
    }
    
    /**
     * Map a list of raw transactions to TMTransaction instances
     * @param rawTransactions The map of raw transactions to map
     * @return A list of Transactions
     */
    private TMTransaction mapTransaction(Map<String, Object> rawTransaction, Map<String, AccountOpeningProduct> products) {
        if (rawTransaction == null) {
            return null;
        }

        String id = String.valueOf(rawTransaction.get('id'));
        String clientName = (String)rawTransaction.get('clientName');
        String contactEmail = (String)rawTransaction.get('contactEmailAddress');
        String deliveryStatus = (String)rawTransaction.get('deliveryStatus');
        String externalProfileId = (String)rawTransaction.get('externalProfileId');
        String formName = (String)rawTransaction.get('formName');
        String formStatus = (String)rawTransaction.get('formStatus');
        String formURL = (String)rawTransaction.get('formURL');
        AccountOpeningProduct product = null;
        DateTime timeLastUserActivity = this.parseAvokaDate((String)rawTransaction.get('timeLastUserActivity'));
        DateTime timeRequested = this.parseAvokaDate((String)rawTransaction.get('timeRequested'));
        DateTime timeSubmitted = this.parseAvokaDate((String)rawTransaction.get('timeSubmitted'));
        String trackingCode = (String)rawTransaction.get('trackingCode');
        
        TMTransactionApplicant applicant = null;
        
        Map<String, Object> dataExtracts = (Map<String, Object>)rawTransaction.get('dataExtracts');
        
        if (dataExtracts != null) {
            String email = (String)dataExtracts.get('email');
            String firstName = (String)dataExtracts.get('firstName');
            String lastName = (String)dataExtracts.get('lastName');
            String routeName = (String)dataExtracts.get('routeName');

            applicant = new TMTransactionApplicant(email, firstName, lastName, routeName);

            String majorTypeCd = (String)dataExtracts.get('MajorProductId');
            String minorTypeCd = (String)dataExtracts.get('MinorProductId');

            if (majorTypeCd != null && minorTypeCd != null) {
                String key = majorTypeCd + '_' + minorTypeCd;
                product = products.get(key);
            }
        }

        TMTransaction trans = new TMTransaction(id, applicant, clientName, contactEmail, deliveryStatus, externalProfileId, formName, formStatus, formURL, product, timeLastUserActivity, timeRequested, timeSubmitted, trackingCode);

        return trans;
    }
    
    /**
     * Fetches product information so that it can be colated with transactions
     * @return A map of AccountOpeningProduct objects where the key is the major type code + _ + minor type code.  For example: CK_FREE
     */
    private Map<String, AccountOpeningProduct> fetchProducts() {
        IAccountOpeningProductDataProvider productDataProvider = this.productDataProvider;
        AccountOpeningAvailableProductsResponse response = productDataProvider.getAvailableAccountOpeningProducts();
        List<AccountOpeningProduct> products = response.getProducts();

        Map<String, AccountOpeningProduct> productMap = new Map<String, AccountOpeningProduct>();

        for (AccountOpeningProduct product : products) {
            String key = product.majorTypeCode + '_' + product.minorTypeCode;
            productMap.put(key, product);
        }

        return productMap;
    }
    
    /**
     * Matches transactions to existing cases in SF.
     * @param transactions The list of transactions to map
     */
    private void mapCaseIDToTransactions(List<IAccountOpeningTransaction> transactions) {
        if (transactions == null || transactions.size() == 0) { // No sense to process further
            return;
        }
        
        List<String> transactionIDs = new List<String>();
        
        for (IAccountOpeningTransaction trans : transactions) {
            transactionIDs.add(trans.getId());
        }

        try {
            Case[] cases = [
                SELECT
                	Id,
                	AccountOpeningTransactionId__c
               	FROM
                	Case
                WHERE
                	AccountOpeningTransactionId__c IN :transactionIDs
            ];
            
            Map<String, String> transactionCaseMap = new Map<String, String>();
            
            // Build our map that joins the Transaction ID with the Case ID
            for (Case kase : cases) {
                transactionCaseMap.put(kase.AccountOpeningTransactionId__c, kase.Id);
            }
            
            // Cycle through the Transaction to set its case ID
            for (IAccountOpeningTransaction trans : transactions) {
                TMTransaction tmTrans = (TMTransaction)trans;
                tmTrans.setCaseId(transactionCaseMap.get(tmTrans.getId()));
            }
        } catch (Exception e) {
            System.debug('Unable to fetch cases: ' + e);
        }
    }
}