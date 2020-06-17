/*
 *	Interface for describing a person.
 */
public interface IPerson {
    Date getDateOfBirth();
    String getDriversLicenseNumber();
    String getEmailAddress();
    String getFirstName();
    String getMiddleName();    
    String getHomePhone();
    String getLastName();
    String getMemberNumber();
    Date getMembershipDate();
    String getMobilePhone();
    String getPersonNumber();
    String getPreferredName();
    IAddress getPrimaryAddress();
    String getTaxId();
}