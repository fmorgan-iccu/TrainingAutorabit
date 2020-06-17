public interface IProductApplication {
	ProductApplicationAgent getAgent();
	String getApplicationNumber();
    integer getCreditScore();
    boolean getIsFunded();
    boolean getIsComplete();
    ProductApplicationAgent getLoanOfficer();
    List<ProductApplicationMilestone> getMilestones();
    List<ProductApplicationNote> getNotes();
    String getProductName();
    String getStatus();
    String getSystemName();
}