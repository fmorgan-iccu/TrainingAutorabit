global with sharing class ProductOffering implements Comparable {
    private String title;
    private String agentScript;
    private String iconName;
    private String color;
    private Double weight;
    
    public ProductOffering(String title, String agentScript, String iconName, String color, Double weight) {
    		this.title = title;
    		this.agentScript = agentScript;
    		this.iconName = iconName;
    		this.weight = weight;
        	this.color = color;
    }
    
    public String getTitle() {
    		return this.title;
    }
    
	public String getAgentScript() {
    		return this.agentScript;
    }
    
    public String getIconName() {
    		return this.iconName;
    }
    
    public String getColor() {
    		return this.color;
    }
    
    public Double getWeight() {
    		return this.weight;
    }
    
    // Comparable Interface

    global Integer compareTo(Object compareTo) {
		ProductOffering comparable = (ProductOffering)compareTo;

		if (comparable.weight == this.weight) {
			return 0;
		}

		if (comparable.weight > this.weight) {
			return 1;
		}

		return -1;
	}

}