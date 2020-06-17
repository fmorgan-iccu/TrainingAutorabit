/*
 *	Class that represents a mailing address in DNA 
 */
public with sharing class DNAAddress implements IAddress {
    private String city;
    private String countryCode;
    private String postalCode;
    private String stateCode;
    private String street;
    private AddressType addressType;
    
    public DNAAddress(String city, String countryCode, String postalCode, String stateCode, String street) {
        this.city = city;
        this.countryCode = countryCode;
        this.postalCode = postalCode;
        this.stateCode = stateCode;
        this.street = street;
    }
    
    public AddressType getAddressType() {
        return this.addressType;
    }
    
    public void setAddressType(AddressType addressType) {
        this.addressType = addressType;
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
    
    public override String toString() {
        String address = '' + this.street + '\n' + this.city + ', ' + this.stateCode + '  ' + this.postalCode + ', ' + this.countryCode;
        return  address;
    }
}