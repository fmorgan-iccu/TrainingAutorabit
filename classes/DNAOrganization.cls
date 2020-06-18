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

    public Account getAccount() {
        Account a = new Account();
        a.Email__c = this.emailAddress;
        a.MembershipDate__c = null;
        a.Business_Establishment_Date__c = null;
        a.Name = this.name;
        a.OrganizationNumber__c = this.orgNumber;
        a.OrganizationTaxID__c = this.taxId;
        a.OrganizationType__c = this.orgType;
        a.PersonNumber__c = null;
        a.Phone = this.phoneNumber;
        a.BillingStreet = this.address.getStreet();
        a.BillingCity = this.address.getCity();
        a.BillingState = this.address.getStateCode();
        a.BillingPostalCode = this.address.getPostalCode();
        a.BillingCountry = this.address.getCountryCode();

        return a;
    }

    public DNAAddress getAddress() {
        return this.address;
    }

    public String getEmailAddress() {
        return this.emailAddress;
    }

    public Date getMembershipDate() {
        return null;
    }

    public Date getBusinessEstablishmentDate() {
        return null;
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

    public IOrganization getRedactedOrganization() {
        return new RedactedOrganization(this);
    }

    public String getTaxId() {
        return this.taxId;
    }
}