/**
 * Model object that represents a product category.
 */
public class AccountOpeningProductCategory {
    private List<AccountOpeningProductCategory> childCategories;
    private String displayName;
    private String id;
    private integer order;
    private String parentCategoryId;
    
    public AccountOpeningProductCategory(String displayName, String id, integer order, String parentCategoryId) {
        this.childCategories = new List<AccountOpeningProductCategory>();
        this.displayName = displayName;
        this.id = id;
        this.order = order;
        this.parentCategoryId = parentCategoryId;
    }
    
    public List<AccountOpeningProductCategory> getChildCategories() {
        return this.childCategories;
    }
    
    public String getDisplayName() {
        return this.displayName;
    }
    
    public String getId() {
        return this.id;
    }
    
    public integer getOrder() {
        return this.order;
    }
    
    public String getParentCategoryId() {
        return this.parentCategoryId;
    }
}