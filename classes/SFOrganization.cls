/**
 * Model object that encapsulates a SalesForce Account object
 */
public class SFOrganization implements IOrganization {
    private Account account;

    public SFOrganization(Account account) {
        this.account = account;
    }
    
    public SFAddress getAddress() {
        return null;
    }
    
    public String getEmailAddress() {
        return this.account.Email__c;
    }

    public String getName() {
        return this.account.Name;
    }
    
    public String getOrgNumber() {
        return this.account.OrganizationNumber__c;
    }
    
    public String getOrgType() {
        return this.account.OrganizationType__c;
    }
    
    public String getPhoneNumber() {
        return this.account.Phone;
    }

    public String getTaxId() {
        return this.account.OrganizationTaxID__c;
    }
}