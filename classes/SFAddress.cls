/**
 *	Adapter class for a SalesForce Contact so that it can conform to IAddress
 */
public with sharing class SFAddress implements IAddress {
	private Contact contact;
	private AddressType type;

	/**
		* Creates a new Salesforce address object.
		*
		* @param  contact Contact provides the address fields that will be accessed
		* @param  type    The type of the address to return.
		*/
	public SFAddress(Contact contact, AddressType type) {
		this.contact = contact;
		this.type = type;
	}

	public String getCity() {
		if (this.type == AddressType.PRIMARY) {
			return this.contact.MailingCity;
		}
		return null;
	}

	public String getCountryCode() {
		if (this.type == AddressType.PRIMARY) {
			return this.contact.MailingCountry;
		}
		return null;
	}

	public String getPostalCode() {
		if (this.type == AddressType.PRIMARY) {
			return this.contact.MailingPostalCode;
		}
		return null;
	}

	public String getStateCode() {
		if (this.type == AddressType.PRIMARY) {
			return this.contact.MailingState;
		}
		return null;
	}

	public String getStreet() {
		if (this.type == AddressType.PRIMARY) {
			return this.contact.MailingStreet;
		}
		return null;
	}

	override public String toString() {
		String address = getStreet() + '\n' + getCity() + ', ' + getStateCode() + '  ' + getPostalCode() + ', ' + getCountryCode();
		return address;
	}

	public AddressType getAddressType() {
		return this.type;
	}

	public void setAddressType(AddressType type) {
		this.type = type;
	}
}