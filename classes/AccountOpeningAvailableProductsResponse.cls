/**
 * Model object representing the data returned by getting Account Opending Products
 */
public class AccountOpeningAvailableProductsResponse {
	private List<AccountOpeningProductCategory> categories;
    private List<AccountOpeningProduct> products;
    
    public AccountOpeningAvailableProductsResponse(List<AccountOpeningProductCategory> categories, List<AccountOpeningProduct> products) {
        this.categories = categories;
        this.products = products;
    }
    
    public List<AccountOpeningProductCategory> getCategories() {
        return this.categories;
    }
    
    public List<AccountOpeningProduct> getProducts() {
        return this.products;
    }
}