/**
 * Model object that encapsulates a SalesForce Account object
 */
public class SFOrganization implements IOrganization {
    private Account account;

    public SFOrganization(Account account) {
        this.account = account;
    }

    public Account getAccount() {
        return this.account;
    }

    public SFAddress getAddress() {
        return new SFAddress(this.account, AddressType.PRIMARY);
    }

    public String getEmailAddress() {
        return this.account != null ? this.account.Email__c : null;
    }

    public Date getMembershipDate() {
        return this.account != null ? this.account.MembershipDate__c : null;
    }

    public Date getBusinessEstablishmentDate() {
        return this.account != null ? this.account.Business_Establishment_Date__c : null;
    }

    public String getName() {
        return this.account != null ? this.account.Name : null;
    }

    public String getOrgNumber() {
        return this.account != null ? this.account.OrganizationNumber__c : null;
    }

    public String getOrgType() {
        return this.account != null ? this.account.OrganizationType__c : null;
    }

    public String getPhoneNumber() {
        return this.account != null ? this.account.Phone : null;
    }

    public IOrganization getRedactedOrganization() {
        return new RedactedOrganization(this);
    }

    public String getTaxId() {
        return this.account != null ? this.account.OrganizationTaxID__c : null;
    }

    public static SFOrganization getInstance(Id accountId) {
        if (accountId == null) {
            return new SFOrganization(null);
        }

        List<Account> accounts = [
            SELECT
                Email__c,
                Name,
                OrganizationNumber__c,
                OrganizationTaxID__c,
                OrganizationType__c,
                MembershipDate__c,
                Business_Establishment_Date__c,
                PersonNumber__c,
                Phone,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                VerifiedIdentityPhone__c

            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        if (accounts.size() == 0) {
            return new SFOrganization(null);
        }

        Account a = accounts[0];
        SFOrganization o = new SFOrganization(a);
        return o;
    }
}