public class ICCUAccountOpeningProductDataProvider implements IAccountOpeningProductDataProvider {
    @TestVisible
    private static String ALL_PRODUCTS_CACHE_KEY = 'AllAOProducts';
    
    public ICCUAccountOpeningProductDataProvider() {
        
    }
    
    public AccountOpeningAvailableProductsResponse getAvailableAccountOpeningProducts() {
        Map<String, Object> apiResponse = this.callAPI('/active');
        
        List<Map<String, Object>> rawCategories = this.convertObjectList((List<Object>)apiResponse.get('categories'));
        List<Map<String, Object>> rawProducts = convertObjectList((List<Object>)apiResponse.get('products'));
        
        List<AccountOpeningProductCategory> categories = this.buildCategories(rawCategories);
		List<AccountOpeningProduct> products = this.mapProducts(rawProducts);
        
        AccountOpeningAvailableProductsResponse response = new AccountOpeningAvailableProductsResponse(categories, products);
        
        return response;
    }

    public List<AccountOpeningProduct> getAllProducts() {
        
        ICacheManager cacheManager = CacheManagerFactory.getOrgInstance();
        String cacheKey = ICCUAccountOpeningProductDataProvider.ALL_PRODUCTS_CACHE_KEY;
        List<AccountOpeningProduct> cachedProducts = (List<AccountOpeningProduct>)cacheManager.getCachedData(cacheKey);

        if (cachedProducts != null) {
            return cachedProducts;
        }

        Map<String, Object> apiResponse = this.callAPI('/active');

        List<Map<String, Object>> rawProducts = convertObjectList((List<Object>)apiResponse.get('products'));
        
		List<AccountOpeningProduct> products = this.mapProducts(rawProducts);

        cacheManager.cacheData(cacheKey, products, System.now().addHours(8));

        return products;
    }
    
    /**
     * Converts a List<Object> to a List<Map<String, Object>>
     * @param objectList The List<Object> to convert.
     * @return a new List<Map<String, Object>>.  Will return an empty list of the objectList is null.
     */
	private List<Map<String, Object>> convertObjectList(List<Object> objectList) {
        if (objectList == null) {
            return new List<Map<String, Object>>();
        }

        List<Map<String, Object>> mapList = new List<Map<String, Object>>();

        for (Object obj : objectList) {
            mapList.add((Map<String, Object>)obj);
        }

        return mapList;
    }

    /**
     * Calls the backend API to get product data
     * @return A Map of product information.
     */
    private Map<String, Object> callAPI(String endpoint) {
        EndpointManager endpointMgr = new EndpointManager();
        endpoint = endpointMgr.getProductsAPIEndpoint() + endpoint;
        String method = EndpointManager.HTTP_METHOD_GET;
        
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setEndpoint(endpoint);
        httpRequest.setClientCertificateName(proxyCertName);
        httpRequest.setMethod(method);
        httpRequest.setHeader('Accept', 'application/json');
        
        HttpResponse response = http.send(httpRequest);
        integer statusCode = response.getStatusCode();

        if (statusCode != 200) {
            throw new DataServiceException('Request failed. Status code: ' + statusCode + ' Body: ' + response.getBody());
        }

        String responseBody = response.getBody();
        if (responseBody == null) {
            return null;
        }

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        return responseMap;
    }

    /**
     * Maps raw product data from service and returns a list of products.
     * @param rawProducts The raw data to map to AccountOpeningProduct objects
     * @return The list of AccountOpeningProduct objects
     */
    private List<AccountOpeningProduct> mapProducts(List<Map<String, Object>> rawProducts) {
        List<AccountOpeningProduct> products = new List<AccountOpeningProduct>();

        for (Map<String, Object> rawProduct : rawProducts) {
            String categoryId = String.valueOf(rawProduct.get('category'));
            Map<String, Object> productInfo = (Map<String, Object>)rawProduct.get('product_info');
            Map<String, Object> productDescription = (Map<String, Object>)productInfo.get('product_description');
            String description = (String)productDescription.get('en');
            Map<String, Object> nameMap = (Map<String, Object>)productInfo.get('display_name');
            String displayName = (String)nameMap.get('en');
            String majorTypeCode = (String)rawProduct.get('mjaccttypcd');
            String minorTypeCode = (String)rawProduct.get('miaccttypcd');

            AccountOpeningProduct product = new AccountOpeningProduct(categoryId, description, displayName, majorTypeCode, minorTypeCode);

            products.add(product);
        }

        return products;
    }
    
    /**
     * Maps raw category data from service and returns a list of categories.
     * @param rawCategories The list of maps of raw data
     * @return a List of AccountOpeningProductCategory objects
     */
    private List<AccountOpeningProductCategory> buildCategories(List<Map<String, Object>> rawCategories) {
        List<AccountOpeningProductCategory> categories = new List<AccountOpeningProductCategory>();

        for (Map<String, Object> rawCategory : rawCategories) {
            Map<String, Object> nameMap = (Map<String, Object>)rawCategory.get('display_name');
            String displayName = (String)nameMap.get('en');
            String id = String.valueOf(rawCategory.get('id'));
            integer order = (integer)rawCategory.get('order');
            integer parentCategoryId = (integer)rawCategory.get('parent_category');
            String parentCategory = null;
            
            if (parentCategoryId != null) {
                parentCategory = String.valueOf(parentCategoryId);
            }

            AccountOpeningProductCategory category = new AccountOpeningProductCategory(displayName, id, order, parentCategory);

            categories.add(category);
        }

        return categories;
    }
}