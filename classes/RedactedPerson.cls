public class RedactedPerson implements IPerson {

    private IPerson originalPerson = null;
    private String taxId = null;

    public RedactedPerson(IPerson person) {
        this.originalPerson = person;
        this.taxId = person.getTaxId();
    }

    public Contact getContact() {
        // Override the contact fields on the contact, cloning to prevent the original
        // object from being modified.
        Contact c = originalPerson.getContact().clone();
        c.TaxId__c = getTaxId();

        return c;
    }

    public Date getDateOfBirth() {
        return originalPerson.getDateOfBirth();
    }

    public String getDriversLicenseNumber() {
        return originalPerson.getDriversLicenseNumber();
    }

    public String getEmailAddress() {
        return originalPerson.getEmailAddress();
    }

    public String getFirstName() {
        return originalPerson.getFirstName();
    }

    public String getMiddleName() {
        return originalPerson.getMiddleName();
    }

    public String getHomePhone() {
        return originalPerson.getHomePhone();
    }

    public String getLastName() {
        return originalPerson.getLastName();
    }

    public String getMemberNumber() {
        return originalPerson.getMemberNumber();
    }

    public Date getMembershipDate() {
        return originalPerson.getMembershipDate();
    }

    public String getMobilePhone() {
        return originalPerson.getMobilePhone();
    }

    public String getPersonNumber() {
        return originalPerson.getPersonNumber();
    }

    public String getPreferredName() {
        return originalPerson.getPreferredName();
    }

    public IAddress getPrimaryAddress() {
        return originalPerson.getPrimaryAddress();
    }

    public IPerson getRedactedPerson() {
        return this;
    }

    public String getTaxId() {
        // Check if user has permission to see the full tax ID, if not redact it.
        if (!AccessUtils.checkPermission('Full_Tax_Id')) {
            List<String> taxIdParts = this.taxId.split('-');
            String redactedTaxId = 'XXX-XX-' + taxIdParts[2];
            this.taxId = redactedTaxId;
        }

        return this.taxId;
    }

}