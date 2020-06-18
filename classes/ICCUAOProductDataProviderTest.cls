@isTest
private class ICCUAOProductDataProviderTest {
	@isTest
    private static void testHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockProductDataResponse());

        ICCUAccountOpeningProductDataProvider provider = new ICCUAccountOpeningProductDataProvider();
        
        try {
            AccountOpeningAvailableProductsResponse response = provider.getAvailableAccountOpeningProducts();
            
            System.assert(response != null);
            System.assert(response.getCategories() != null);
            System.assert(response.getCategories().size() > 0);
            System.assert(response.getProducts().size() > 0);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e + ' line:' + e.getLineNumber());
        }

        try {
            // Verifying that the data is NOT in the cache
            ICacheManager cacheManager = CacheManagerFactory.getOrgInstance();
            String cacheKey = ICCUAccountOpeningProductDataProvider.ALL_PRODUCTS_CACHE_KEY;
            List<AccountOpeningProduct> cachedProducts = (List<AccountOpeningProduct>)cacheManager.getCachedData(cacheKey);
            System.assert(cachedProducts == null, 'Unexpectedly found products in the cache.');
            
            List<AccountOpeningProduct> products = provider.getAllProducts();

            System.assert(products != null);
            System.assert(products.size() > 0);

            for (AccountOpeningProduct product : products) {
                System.assert(product.categoryId != null, 'categoryId was null!');
                System.assert(product.description != null, 'description was null!');
                System.assert(product.displayName != null, 'displayName was null!');
                System.assert(product.majorTypeCode != null, 'majorTypeCode was null!');
                System.assert(product.minorTypeCode != null, 'minorTypeCode was null!');
            }
            
            // Verifying that the data is in the cache
            cachedProducts = (List<AccountOpeningProduct>)cacheManager.getCachedData(cacheKey);

            System.assert(cachedProducts != null, 'Cached products was null!');
            System.assert(cachedProducts.size() == products.size(), 'Cached products size was not equal to regular call size');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e + ' line:' + e.getLineNumber());
        }

    }
}