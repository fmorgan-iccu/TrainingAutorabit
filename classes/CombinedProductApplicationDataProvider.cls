/*
 *	Class for combining all of the systems that can have open productApplications
 */
public with sharing class CombinedProductApplicationDataProvider implements IProductApplicationDataProvider, IAuthenticationManager {
	private List<IProductApplicationDataProvider> providers;
	
	public CombinedProductApplicationDataProvider(List<IProductApplicationDataProvider> productApplicationProviders)  {
		this.providers = productApplicationProviders;
	} 

// IProductApplicationDataProvider
    public ProductApplicationResponse getOpenProductApplications(IPerson person, DateTime startDate, DateTime endDate) {
        if (person == null || person.getTaxId() == null) {
            throw new IllegalArgumentException('IPerson nor tax ID cannot be null!');
        }

    	List<IProductApplication> allApplications = new List<IProductApplication>();
        List<String> errors = new List<String>();

		for (IProductApplicationDataProvider provider : this.providers) {
            try {
                ProductApplicationResponse productResponse = provider.getOpenProductApplications(person, startDate, endDate);
                allApplications.addAll(productResponse.getApplications());
            } catch (Exception e) {
                errors.add(provider.getSystemName() + ': ' + e.getMessage() + ' line: ' + e.getLineNumber());
            }
		}

        ProductApplicationResponse response = new ProductApplicationResponse(allApplications, errors);

		return response;
    }
    
    public IAuthenticationManager getAuthenticationManager() {
    		return this;
    }
    
    public String getSystemName() {
        return '';
    }

// IAuthenticationManager
    public boolean authenticateUser(IAuthenticationCredential credential) {
    		// TODO: implement
    		return true;
    }

	public boolean isUserAuthenticated() {
		// TODO: implement
		return true;
	}
	
	public void logOut() {
		// TODO: implement
	}
}