public interface IAccountOpeningProductDataProvider {
	AccountOpeningAvailableProductsResponse getAvailableAccountOpeningProducts();
    List<AccountOpeningProduct> getAllProducts();
}