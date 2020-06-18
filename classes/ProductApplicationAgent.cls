/*
 * Class modeling a person assigned as a contact for a product application.
 */
public class ProductApplicationAgent {
    private String emailAddress;
    private String extension;
    private String name;
    private String phone;
    private boolean isLoanOfficer;
    
    public ProductApplicationAgent(String emailAddress, boolean isLoanOfficer, String name, String phone) {
        this.emailAddress = emailAddress;
        this.isLoanOfficer = isLoanOfficer;
        this.name = name;
        this.phone = phone;
    }
    
    public ProductApplicationAgent(String emailAddress, String extension, boolean isLoanOfficer, String name, String phone) {
        this.emailAddress = emailAddress;
        this.extension = extension;
        this.isLoanOfficer = isLoanOfficer;
        this.name = name;
        this.phone = phone;
    }
    
    public String getName() {
        return this.name;
    }
    
    public String getPhone() {
        return this.phone;
    }
    
    public String getEmailAddress() {
        return this.emailAddress;
    }
    
    public String getExtension() {
        return this.extension;
    }
    
    public boolean isLoanOfficer() {
        return this.isLoanOfficer;
    }
}