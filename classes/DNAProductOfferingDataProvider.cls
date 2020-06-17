/*
 *	Class that implements the IProductOfferingDataProvider interface
 */
public with sharing class DNAProductOfferingDataProvider extends DNACoreDataProvider implements IProductOfferingDataProvider {
	
	public DNAProductOfferingDataProvider() {
		super();
	}
	
	/*
	 *	Constructor for specifying the IAuthenticationManager.  Primarily to facilitate unit testing.
	 *	@authManager The IAuthenticationManager to use
	 */
	public DNAProductOfferingDataProvider(IAuthenticationManager authManager) {
		super(authManager);
	}
	
	/*
 	 *	Get the product offerings for a person
 	 *	@param person The IPerson for whom we should get their product offerings
 	 *	@return List of ProductOffering objects to present to the user.a
     */
    public List<ProductOfferingGroup> getProductOfferings(IPerson person) {
        if (person == null) {
            return null;
        }

		DNAPersonAccountDataProvider accountProvider = new DNAPersonAccountDataProvider(super.getAuthenticationManager()); 

        List<IAccount> accounts = accountProvider.getAccounts(person);

        List<ProductOffering> depositOfferings = new List<ProductOffering>();
        List<ProductOffering> loanOfferings = new List<ProductOffering>();
        List<ProductOffering> serviceOfferings = new List<ProductOffering>();

        Map<String, IAccount> accountMap = new Map<String, IAccount>();

        // Create a map for easily finding of the specific products to offer
        for (IAccount account : accounts) {
            accountMap.put(account.getMajorType(), account);
        }

        if (accountMap.get(DNAAccount.MJR_ACCT_CODE_SAVINGS) == null) {
            Double weight = 0.1;
            depositOfferings.add(new ProductOffering('Savings', 'A sample script.', 'utility:moneybag', 'green', weight));
        }

        if (accountMap.get(DNAAccount.MJR_ACCT_CODE_CHECKING) == null) {
            Double weight = 0.2;
            depositOfferings.add(new ProductOffering('Checking', 'A sample script.', 'custom:custom40', 'green', weight));
        }

        if (accountMap.get(DNAAccount.MJR_ACCT_CODE_CD) == null) {
            Double weight = 0.25;
            depositOfferings.add(new ProductOffering('CD', 'A sample script.', 'utility:moneybag', 'green', weight));
        }

        if (accountMap.get(DNAAccount.MJR_ACCT_CODE_MORTGAGE) == null) {
            Double weight = 0.3;
            loanOfferings.add(new ProductOffering('Mortgage', 'A sample script.', 'utility:home', 'purple', weight));
        }

        if (accountMap.get(DNAAccount.MJR_ACCT_CODE_USED_AUTO_LOAN) == null) {
            Double weight = 0.5;
            loanOfferings.add(new ProductOffering('Auto Loan', 'A sample script.', 'utility:travel_and_places', 'darkBlue', weight));
        }

        if (accountMap.get(DNAAccount.MJR_ACCT_CODE_CREDIT_CARD) == null) {
            Double weight = 0.6;
            loanOfferings.add(new ProductOffering('Credit Card', 'A sample script.', 'custom:custom40', 'darkGrey', weight));
        }

        // Get their agreement types and put them in a map for quick lookup
        List<String> agreementTypes = this.getAgreementTypes(person);
        Map<String, String> agreementsMap = new Map<String, String>();
        for (String agreementType : agreementTypes) {
            agreementsMap.put(agreementType, agreementType);
        }

        String onlineAgreement = 'WWW';

        if (agreementsMap.get(onlineAgreement) == null) {
            Double weight = 1.0;
            serviceOfferings.add(new ProductOffering('eBranch', 'A sample script.', 'utility:phone_portrait', 'blue', weight));
        }

        depositOfferings.sort();
        loanOfferings.sort();
        serviceOfferings.sort();

        ProductOfferingGroup deposits = new ProductOfferingGroup('Deposits', depositOfferings);
        ProductOfferingGroup loans = new ProductOfferingGroup('Loans', loanOfferings);
        ProductOfferingGroup services = new ProductOfferingGroup('Services', serviceOfferings);

        List<ProductOfferingGroup> offeringGroups = new List<ProductOfferingGroup>();
        offeringGroups.add(deposits);
        offeringGroups.add(services);
        offeringGroups.add(loans);

        return offeringGroups;
    }
    
    /**
     *  Fetches the *active* agreement types that a person has with ICCU.
     *  @param person The person for whom the request should be made.
     *  @return List of agreement types
     */
    @TestVisible
    private List<String> getAgreementTypes(IPerson person) {
        if (person == null || person.getPersonNumber() == null) {
            return new List<String>();
        }

        Map<String, Object> accountRequest = new Map<String, Object>();
        accountRequest.put('EntityTypeCode', 'PERS');
        accountRequest.put('EntityNumber', person.getPersonNumber());
        accountRequest.put('__type', 'PersonAgreementInquiryRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(accountRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> agreementsMap = responses[0];
        List<Object> errors = (List<Object>)agreementsMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new DataServiceException(message);
        }

        List<Object> objects = (List<Object>)agreementsMap.get('Agreements');
        List<String> agreementTypes = this.parseAgreementTypes(objects);

        return agreementTypes;
    }
    
    /*
     *	Parses the list of objects to get the active agreements.
     *	@param objects The objects to parse
     *  @param List of active agreement types
     */
    @TestVisible
    private List<String> parseAgreementTypes(List<Object> objects) {
        List<String> agreementTypes = new List<String>();
        
        if (objects == null) {
            return agreementTypes;
        }

        for (Object obj : objects) {
            Map<String, Object> agreement = (Map<String, Object>)obj;

            String status = (String)agreement.get('CurrentStatusCode');
            Boolean isActive = status.equals('ACT');

            if (!isActive) {
                continue;
            }

            String typeCode = (String)agreement.get('TypeCode');
            agreementTypes.add(typeCode);
        }
        
        return agreementTypes;
    }
}