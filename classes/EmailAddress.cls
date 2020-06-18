public class EmailAddress {
    private String address;
    public EmailAddressType emailType;
    
    public EmailAddress(String address, EmailAddressType emailType) {
        this.address = address;
        this.emailType = emailType;
    }
    
    public String getAddress() {
        return this.address;
    }
    
    public EmailAddressType getEmailType() {
        return this.emailType;
    }
}