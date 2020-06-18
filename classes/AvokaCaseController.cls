/**
 * Lightning controller for getting product for an Avoka Case Header
 */
public class AvokaCaseController {
	
    @AuraEnabled
    public static Map<String, Object> getProduct(String productMajorType, String productMinorType) {
        Map<String, Object> response = new Map<String, Object>();
        
        if (productMajorType == null || productMinorType == null) {
            response.put('error', 'Product major and minor type cannot be null.');
            return response;
        }
        
        INetworkFactory factory = new ConcreteNetworkProvider();
        IAccountOpeningProductDataProvider provider = factory.getAccountOpeningProductDataProvider();
        
        try {
            List<AccountOpeningProduct> products = provider.getAllProducts();
            AccountOpeningProduct foundProduct = null;
            
            for (AccountOpeningProduct product : products) {
                if (product.majorTypeCode == productMajorType && product.minorTypeCode == productMinorType) {
                    foundProduct = product;
                    break;
                }
            }

            if (foundProduct != null) {
                Map<String, Object> rawProduct = AvokaCaseController.mapProduct(foundProduct);
                response.put('product', rawProduct);
            } else {
                response.put('error', 'Product not found with major/minor type code: ' + productMajorType + '/' + productMinorType + '.');
            }
            
        } catch (Exception e) {
          	response.put('error', 'Unable to get product: ' + e.getMessage());
        }
        
        return response;
    }
    
    private static Map<String, Object> mapProduct(AccountOpeningProduct product) {
        Map<String, Object> mappedProduct = new Map<String, Object>();

        mappedProduct.put('categoryId', product.categoryId);
        mappedProduct.put('description', product.description);
        mappedProduct.put('displayName', product.displayName);
        mappedProduct.put('majorTypeCode', product.majorTypeCode);
        mappedProduct.put('minorTypeCode', product.minorTypeCode);

        return mappedProduct;
    }
}