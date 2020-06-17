@isTest
private class AOAvailableProductsResponseTest {
	@isTest
    private static void testHappyPath() {
        List<AccountOpeningProductCategory> categories = new List<AccountOpeningProductCategory>();
        List<AccountOpeningProduct> products = new List<AccountOpeningProduct>();
        
        
        AccountOpeningAvailableProductsResponse response = new AccountOpeningAvailableProductsResponse(categories, products);
        System.assert(categories == response.getCategories());
        System.assert(products == response.getProducts());
    }
}