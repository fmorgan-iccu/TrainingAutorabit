/*
 *	Interface for describing a mailing address.
 */
public interface IAddress {
    String getCity();
    String getCountryCode();
    String getPostalCode();
    String getStateCode();
    String getStreet();
    String toString();
    AddressType getAddressType();
}