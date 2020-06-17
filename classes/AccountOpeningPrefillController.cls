/**
 * Aura controller for serving up data to the front end.
 */
public class AccountOpeningPrefillController {
    private static INetworkFactory networkFactory;
    
	@AuraEnabled
    public static Map<String, Object> getAvailableProducts() {
        INetworkFactory networkFactory = AccountOpeningPrefillController.networkFactory;
        
        if (AccountOpeningPrefillController.networkFactory == null) {
            networkFactory = new ConcreteNetworkProvider();
        }
        
        Map<String, Object> response = new Map<String, Object>();

        try {
            IAccountOpeningProductDataProvider provider = networkFactory.getAccountOpeningProductDataProvider();
            AccountOpeningAvailableProductsResponse productResponse = provider.getAvailableAccountOpeningProducts();
            
            List<Map<String, Object>> rawCategories = new List<Map<String, Object>>();
            for (AccountOpeningProductCategory category : productResponse.getCategories()) {
                Map<String, Object> rawCategory = new Map<String, Object>();
                rawCategory.put('displayName', category.getDisplayName());
                rawCategory.put('id', category.getId());
                rawCategory.put('order', category.getOrder());
                rawCategory.put('parentCategoryId', category.getParentCategoryId());
                
                rawCategories.add(rawCategory);
            }

            List<Map<String, Object>> rawProducts = new List<Map<String, Object>>();
            for (AccountOpeningProduct product : productResponse.getProducts()) {
                Map<String, Object> rawProduct = new Map<String, Object>();
                rawProduct.put('categoryId', product.categoryId);
                rawProduct.put('description', product.description);
                rawProduct.put('displayName', product.displayName);
                rawProduct.put('majorTypeCode', product.majorTypeCode);
                rawProduct.put('minorTypeCode', product.minorTypeCode);

                rawProducts.add(rawProduct);
            }

            response.put('categories', rawCategories);
            response.put('products', rawProducts);
        } catch (Exception e) {
            response.put('error', 'Error fetching available products: ' + e);
        }

        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> submitPrefilledApplication(String contactId, Map<String, Object> productMap) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', 'Contact ID may NOT be null.');
            return response;
        }

        if (productMap == null) {
            response.put('error', 'Product may NOT be null.');
            return response;
        }
        
        String categoryId = (String)productMap.get('categoryId');
        String description = (String)productMap.get('description');
        String displayName = (String)productMap.get('displayName');
        String majorTypeCode = (String)productMap.get('majorTypeCode');
        String minorTypeCode = (String)productMap.get('minorTypeCode');
        
        if (majorTypeCode == null || minorTypeCode == null) {
            response.put('error', 'Major Type Code nor Minor Type Code may NOT be null.');
            return response;
        }

        Contact contact = ContactController.getContact(contactId);

        if (contact == null) {
            response.put('error', 'No contact ID found with the ID of ' + contactId);
            return response;
        }
        
        INetworkFactory networkFactory = AccountOpeningPrefillController.networkFactory;
        
        if (AccountOpeningPrefillController.networkFactory == null) {
            networkFactory = new ConcreteNetworkProvider();
        }

        AccountOpeningProduct product = new AccountOpeningProduct(categoryId, description, displayName, majorTypeCode, minorTypeCode);
		IPerson person = new SFPerson(contact);

        AccountOpeningApplication application = new AccountOpeningApplication(person, product);
        IAccountOpeningApplicationPrefiller prefiller = networkFactory.getAccountOpeningApplicationPrefillProvider();
        try {
            AccountOpeningApplicationPrefillResponse prefillResponse = prefiller.submitPrefilledApplication(application);

            response.put('prefillURL', prefillResponse.getPrefillURL());
        } catch (Exception e) {
            response.put('error', 'Error submitting prefilled application: ' + e);
        }

        return response;
    }
}