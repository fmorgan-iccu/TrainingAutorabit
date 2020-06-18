public with sharing class RedactedOrganization implements IOrganization {
    private IOrganization originalOrganization = null;
    private String taxId = null;

    public RedactedOrganization(IOrganization organization) {
        this.originalOrganization = organization;
        this.taxId = organization.getTaxId();
    }

    public Account getAccount() {
        // Override the contact fields on the account, cloning to prevent the original
        // object from being modified.
        Account a = originalOrganization.getAccount().clone();
        a.OrganizationTaxID__c = getTaxId();

        return a;
    }

    public IAddress getAddress() {
        return originalOrganization.getAddress();
    }

    public String getEmailAddress() {
        return originalOrganization.getEmailAddress();
    }

    public Date getMembershipDate() {
        return originalOrganization.getMembershipDate();
    }

    public Date getBusinessEstablishmentDate() {
        return originalOrganization.getBusinessEstablishmentDate();
    }

    public String getName() {
        return originalOrganization.getName();
    }

    public String getOrgNumber() {
        return originalOrganization.getOrgNumber();
    }

    public String getOrgType() {
        return originalOrganization.getOrgType();
    }

    public String getPhoneNumber() {
        return originalOrganization.getPhoneNumber();
    }

    public IOrganization getRedactedOrganization() {
        return this;
    }

    public String getTaxId() {
        // Check if user has permission to see the full tax ID, if not redact it.
        if (!AccessUtils.checkPermission('Full_Tax_Id')) {
            String taxIdPart1 = this.taxId.left(2);
            String taxIdPart2 = this.taxId.right(3);
            String redactedTaxId = taxIdPart1 + '-XXXX' + taxIdPart2;
            this.taxId = redactedTaxId;
        }

        return this.taxId;
    }
}