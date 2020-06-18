/**
 *    Adapter class for a SalesForce Contact so that it can conform to IAddress
 */
public with sharing class SFAddress implements IAddress {

    private String street;
    private String city;
    private String stateCode;
    private String postalCode;
    private String countryCode;

    private AddressType type;

    /**
        * Creates a new Salesforce address object.
        *
        * @param  contact Contact provides the address fields that will be accessed
        * @param  type    The type of the address to return.
        */
    public SFAddress(Contact contact, AddressType type) {
        this.type = type;
        if (this.type == AddressType.PRIMARY) {
            this.street = contact.MailingStreet;
            this.city = contact.MailingCity;
            this.stateCode = contact.MailingState;
            this.postalCode = contact.MailingPostalCode;
            this.countryCode = contact.MailingCountry;
        }
    }

    public SFAddress(Account account, AddressType type) {
        this.type = type;
        if (this.type == AddressType.PRIMARY) {
            this.street = account.BillingStreet;
            this.city = account.BillingCity;
            this.stateCode = account.BillingState;
            this.postalCode = account.BillingPostalCode;
            this.countryCode = account.BillingCountry;
        }
    }

    public String getCity() {
        return this.city;
    }

    public String getCountryCode() {
        return this.countryCode;
    }

    public String getPostalCode() {
        return this.postalCode;
    }

    public String getStateCode() {
        return this.stateCode;
    }

    public String getStreet() {
        return this.street;
    }

    override public String toString() {
        String address = getStreet() + '\n' + getCity() + ', ' + getStateCode() + '  ' + getPostalCode() + ', ' + getCountryCode();
        return address;
    }

    public AddressType getAddressType() {
        return this.type;
    }

}