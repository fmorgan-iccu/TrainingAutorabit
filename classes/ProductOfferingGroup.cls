public with sharing class ProductOfferingGroup {
    private String title;
    private List<ProductOffering> offerings;
    
    public ProductOfferingGroup(String title, List<ProductOffering> offerings) {
    		this.title = title;
    		this.offerings = offerings;
    }
    
    public String getTitle() {
    		return this.title;
    }
    
    public List<ProductOffering> getOfferings() {
    		return this.offerings;
    }
    
}