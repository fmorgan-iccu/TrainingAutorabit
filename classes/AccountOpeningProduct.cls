/**
* Model object that represents a product that is available to be acquired online.
*/
public class AccountOpeningProduct {
    public String categoryId {get; private set;}
    public String description {get; private set;}
    public String displayName {get; private set;}
    public String majorTypeCode {get; private set;}
    public String minorTypeCode {get; private set;}
    
    public AccountOpeningProduct(String categoryId, String description, String displayName, String majorTypeCode, String minorTypeCode) {
        this.categoryId = categoryId;
        this.description = description;
        this.displayName = displayName;
        this.majorTypeCode = majorTypeCode;
        this.minorTypeCode = minorTypeCode;
    }
}