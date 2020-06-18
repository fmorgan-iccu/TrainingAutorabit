@isTest
private class DNAProductOfferingDataProviderTest {
	@isTest
    private static void testGetOfferings() {  
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IPersonDataProvider provider = new DNAPersonDataProvider(new DNAAuthenticationManagerMock());
        IAuthenticationManager authManager = provider.getAuthenticationManager();
        System.assert(authManager != null);
        
        Boolean isAuthenticated = authManager.isUserAuthenticated();
        System.assert(isAuthenticated, 'User is not authenticated!');

        IPerson person = provider.getPersonDetails('355061');

        IProductOfferingDataProvider productOfferingDataProvider = new DNAProductOfferingDataProvider(authManager);
        List<ProductOfferingGroup> offeringGroups = productOfferingDataProvider.getProductOfferings(person);
        
        System.assert(offeringGroups.size() > 0);
        
        for (ProductOfferingGroup offeringGroup : offeringGroups) {
        		System.assert(offeringGroup.getTitle() != null);
        		System.assert(offeringGroup.getOfferings() != null);

			for (ProductOffering offering : offeringGroup.getOfferings()) {
				System.assert(offering.getTitle() != null);
				System.assert(offering.getAgentScript() != null);
				System.assert(offering.getIconName() != null);
				System.assert(offering.getWeight() >= 0.0);
				System.assert(offering.getColor() != null);
			}        	
		}
        
        ProductOffering last = new ProductOffering('title', 'script', 'iconName', 'green', Double.valueOf(0.1));
        ProductOffering first = new ProductOffering('title', 'script', 'iconName', 'green', Double.valueOf(1.0));
        ProductOffering middle = new ProductOffering('title', 'script', 'iconName', 'green', Double.valueOf(0.5));
        
        List<ProductOffering> sortedOfferings = new List<ProductOffering>();
        sortedOfferings.add(last);
        sortedOfferings.add(first);
        sortedOfferings.add(middle);
        
        sortedOfferings.sort();

        System.assert(sortedOfferings[0] == first);
        System.assert(sortedOfferings[1] == middle);
        System.assert(sortedOfferings[2] == last);
        
        DNAProductOfferingDataProvider defaultProvider = new DNAProductOfferingDataProvider();
        System.assert(defaultProvider != null);
    }
    
    @isTest
    private static void testAgreementParsing() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();

        DNAProductOfferingDataProvider productOfferingDataProvider = new DNAProductOfferingDataProvider(authManager);
        
        Map<String, Object> activeAgreement = new Map<String, Object>();
        activeAgreement.put('CurrentStatusCode', 'ACT');
        activeAgreement.put('TypeCode', 'WWW');
        
        Map<String, Object> inactiveAgreement = new Map<String, Object>();
        inactiveAgreement.put('CurrentStatusCode', 'IACT');
        inactiveAgreement.put('TypeCode', 'SST');
        
        List<Object> rawAgreements = new List<Object>();
        rawAgreements.add(activeAgreement);
        rawAgreements.add(inactiveAgreement);
        
        List<String> agreements = productOfferingDataProvider.parseAgreementTypes(rawAgreements);

        System.assert(agreements.size() == 1);
        System.assert(agreements[0].equals('WWW'));
    }
    
    @isTest
    private static void testUnhappyPathGetOfferings() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();

        DNAProductOfferingDataProvider productOfferingDataProvider = new DNAProductOfferingDataProvider(authManager);
        List<ProductOfferingGroup> groups = productOfferingDataProvider.getProductOfferings(null);

        System.assert(groups == null);
        
        // Test null agreements
        List<String> agreements = productOfferingDataProvider.parseAgreementTypes(null);
        System.assert(agreements != null);
    }
}