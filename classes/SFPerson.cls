/**
 * Adapter class for a SalesForce Contact so that it can conform to IPerson
 */
public with sharing class SFPerson implements IPerson {
    private Contact contact;

    public SFPerson(Contact contact) {
        this.contact = contact;
    }

    public Contact getContact() {
        return this.contact;
    }

    public String getPersonNumber() {
        return this.contact != null ? this.contact.personNumber__c : null;
    }

    public String getPreferredName() {
        return this.contact != null ? this.contact.preferredName__c : null;
    }

    public String getMemberNumber() {
        return this.contact != null ? this.contact.memberNumber__c : null;
    }

    public IAddress getPrimaryAddress() {
        SFAddress address = new SFAddress(this.contact, AddressType.PRIMARY);
        return address;
    }

    public String getFirstName() {
        return this.contact != null ? this.contact.firstName : null;
    }

    public String getMiddleName() {
        return this.contact != null ? this.contact.middleName : null;
    }

    public String getLastName() {
        return this.contact != null ? this.contact.lastName : null;
    }

    public String getTaxId() {
        return this.contact != null ? this.contact.taxID__c : null;
    }

    public Date getDateOfBirth() {
        return this.contact != null ? this.contact.birthdate : null;
    }

    public String getHomePhone() {
        return this.contact != null ? this.contact.phone : null;
    }

    public String getMobilePhone() {
        return this.contact != null ? this.contact.mobilePhone : null;
    }

    public String getEmailAddress() {
        return this.contact != null ? this.contact.email : null;
    }

    public Date getMembershipDate() {
        return this.contact != null ? this.contact.memberSince__c : null;
    }

    public String getDriversLicenseNumber() {
        return this.contact != null ? this.contact.identificationNumber__c : null;
    }

    public IPerson getRedactedPerson() {
        return new RedactedPerson(this);
    }

    /**
     * A general method that can be used to query the basic information for a Person contact in Salesforce.
     * Chaining this method with the getContact function can provide a convenient way to get a reference to a contact.
     */
    public static SFPerson getInstance(Id contactId) {
        if (contactId == null) {
            return new SFPerson(null);
        }

        List<Contact> contacts = [
            SELECT
                Birthdate,
                CreditScore__c,
                Email,
                FirstName,
                IdentificationNumber__c,
                IsEmployee__c,
                MiddleName,
                LastName,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry,
                MemberNumber__c,
                MemberSince__c,
                MobilePhone,
                Name,
                PersonNumber__c,
                Phone,
                PreferredName__c,
                TaxID__c,
                VerifiedIdentityPhone__c
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        if (contacts.size() == 0) {
            return new SFPerson(null);
        }

        Contact c = contacts[0];
        SFPerson p = new SFPerson(c);
        return p;
    }

    /**
     * This method will find the first person associated with an account.
     */
    public static SFPerson getInstanceByAccount(Id accountId) {
        if (accountId == null) {
            return new SFPerson(null);
        }

        List<Contact> contacts = [
            SELECT
                Birthdate,
                CreditScore__c,
                Email,
                FirstName,
                IdentificationNumber__c,
                IsEmployee__c,
                MiddleName,
                LastName,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry,
                MemberNumber__c,
                MemberSince__c,
                MobilePhone,
                Name,
                PersonNumber__c,
                Phone,
                PreferredName__c,
                TaxID__c,
                VerifiedIdentityPhone__c
            FROM Contact
            WHERE AccountId = :accountId
            LIMIT 1
        ];

        if (contacts.size() == 0) {
            return new SFPerson(null);
        }

        Contact c = contacts[0];
        SFPerson p = new SFPerson(c);
        return p;
    }
}