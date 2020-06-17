/**
 *	Adapter class for a SalesForce Contact so that it can conform to IPerson
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
		return this.contact.personNumber__c;
    }

    public String getPreferredName() {
    		return this.contact.preferredName__c;
    }

    public String getMemberNumber() {
    		return this.contact.memberNumber__c;
    }

    public IAddress getPrimaryAddress() {
        SFAddress address = new SFAddress(this.contact, AddressType.PRIMARY);
		return address;
    }

    public String getFirstName() {
    		return this.contact.firstName;
    }

	public String getMiddleName() {
    		return this.contact.middleName;
    }

    public String getLastName() {
    		return this.contact.lastName;
    }

    public String getTaxId() {
    		return this.contact.taxID__c;
    }

    public Date getDateOfBirth() {
    		return this.contact.birthdate;
    }

    public String getHomePhone() {
    		return this.contact.phone;
    }

    public String getMobilePhone() {
    		return this.contact.mobilePhone;
    }

    public String getEmailAddress() {
    		return this.contact.email;
    }

    public Date getMembershipDate() {
		return this.contact.memberSince__c;
    }

    public String getDriversLicenseNumber() {
    		return this.contact.identificationNumber__c;
    }
}