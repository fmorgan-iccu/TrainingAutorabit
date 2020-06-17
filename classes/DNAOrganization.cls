/**
 * Model object representing a DNA organization
 */
public class DNAOrganization implements IOrganization {
    private DNAAddress address;
    private String emailAddress;
    private String name;
    private String orgNumber;
    private String orgType;
    private String phoneNumber;
    private String taxId;

    public DNAOrganization(DNAAddress address, String emailAddress, String name, String orgNumber, String orgType, String phoneNumber, String taxId) {
        this.address = address;
        this.emailAddress = emailAddress;
        this.name = name;
        this.orgNumber = orgNumber;
        this.orgType = orgType;
        this.phoneNumber = phoneNumber;
        this.taxId = taxId;
    }
    
    public DNAAddress getAddress() {
        return this.address;
    }

    public String getEmailAddress() {
        return this.emailAddress;
    }
    
    public String getName() {
        return this.name;
    }
    
    public String getOrgNumber() {
        return this.orgNumber;
    }
    
    public String getOrgType() {
        return this.orgType;
    }
    
    public String getPhoneNumber() {
        return this.phoneNumber;
    }
    
    public String getTaxId() {
        return this.taxId;
    }
}