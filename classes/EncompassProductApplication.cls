/*
 * Encompass implementation of an IProductApplication
 */
public with sharing class EncompassProductApplication implements IProductApplication {

	private ProductApplicationAgent agent;
	private String applicationNumber;
    private integer creditScore;
    private boolean isComplete;
    private boolean isFunded;
    private ProductApplicationAgent loanOfficer;
    List<ProductApplicationMilestone> milestones;
	private String productName;
	private String status;
	private String systemName;
    private List<ProductApplicationNote> notes;

	public EncompassProductApplication(ProductApplicationAgent agent, String applicationNumber, integer creditScore, boolean isComplete, boolean isFunded, ProductApplicationAgent loanOfficer, List<ProductApplicationMilestone> milestones, List<ProductApplicationNote> notes, String productName, String status) {
		this.agent = agent;
		this.applicationNumber = applicationNumber;
        this.creditScore = creditScore;
        this.isComplete = isComplete;
        this.isFunded = isFunded;
        this.loanOfficer = loanOfficer;
        this.milestones = milestones;
        this.notes = notes;
		this.productName = productName;
		this.status = status;
        this.systemName = 'Encompass';
	}
	
    public ProductApplicationAgent getAgent() {
		return this.agent;
    }
	
	public String getApplicationNumber() {
		return this.applicationNumber;
    }
    
    public integer getCreditScore() {
        return this.creditScore;
    }
    
    public boolean getIsComplete() {
        return this.isComplete;
    }
    
    public boolean getIsFunded() {
        return this.isFunded;
    }
    
    public ProductApplicationAgent getLoanOfficer() {
        return this.loanOfficer;
    }
    
    public List<ProductApplicationMilestone> getMilestones() {
        if (this.milestones == null) {
            return new List<ProductApplicationMilestone>();
        }

		return this.milestones;
    }
    
    public List<ProductApplicationNote> getNotes() {
        return this.notes;
    }

	public String getProductName() {
		return this.productName;
    }
	
	public String getStatus() {
		return this.status;
    }

	public String getSystemName() {
		return this.systemName;
	}
}