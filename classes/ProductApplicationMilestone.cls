public class ProductApplicationMilestone {
    private ProductApplicationAgent agent;
    private String displayName;
    private boolean isComplete;
    private boolean isCurrentMilestone;
    private DateTime statusDate;
    
    public ProductApplicationMilestone(ProductApplicationAgent agent, String displayName, boolean isComplete, boolean isCurrentMilestone, DateTime statusDate) {
        this.agent = agent;
        this.displayName = displayName;
        this.isComplete = isComplete;
        this.isCurrentMilestone = isCurrentMilestone;
        this.statusDate = statusDate;
    }

    public boolean getIsComplete() {
        return this.isComplete;
    }

    public ProductApplicationAgent getAgent() {
        return this.agent;
    }
    
    public String getDisplayName() {
        return this.displayName;
    }
    
    public boolean getIsCurrentMilestone() {
        return this.isCurrentMilestone;
    }
    
    public void setIsCurrentMilestone(boolean isCurrentMilestone) {
        this.isCurrentMilestone = isCurrentMilestone;
    }
    
    public DateTime getStatusDate() {
        return this.statusDate;
    }
}