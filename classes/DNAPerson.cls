/*
 *	Class that represents a DNA person.
 *	NOTE: This class has additional methods not exposed through the IPerson interface that are used for other internal purposes.
 */
public class DNAPerson implements IPerson {
    private String personNumber;
    private String memberNumber;
    private String preferredName;
    private IAddress primaryAddress;
    private String firstName;
    private String middleName;
    private String lastName;
    private String taxId;
    private Date dateOfBirth;
    private String homePhoneNumber;
    private String mobilePhoneNumber;
    private String emailAddress;
    private Date membershipDate;
    private String driversLicenseNumber;
    private String phonePassword;
    private String phonePasswordHint;

    // Internal ivars
    private String motherMaidenName;

    public DNAPerson() {

    }

    // For convenience in testing only...
    public DNAPerson(String personNumber) {
        this.personNumber = personNumber;
    }

    // For convenience in testing only...
    public DNAPerson(String personNumber, String firstName, String lastName) {
        this.personNumber = personNumber;
        this.firstName = firstName;
        this.lastName = lastName;
    }

    public DNAPerson(String personNumber, String memberNumber, String preferredName, IAddress primaryAddress, String firstName, String middleName, String lastName, String taxId, Date dateOfBirth, String homePhoneNumber, String mobilePhoneNumber, String emailAddress, Date membershipDate, String driversLicenseNumber) {
		this.personNumber = personNumber;
		this.memberNumber = memberNumber;
		this.preferredName = preferredName;
		this.primaryAddress = primaryAddress;
		this.firstName = firstName;
        this.middleName = middleName;
		this.lastName = lastName;
		this.taxId = taxId;
		this.dateOfBirth = dateOfBirth;
		this.homePhoneNumber = homePhoneNumber;
		this.mobilePhoneNumber = mobilePhoneNumber;
		this.emailAddress = emailAddress;
		this.membershipDate = membershipDate;
		this.driversLicenseNumber = driversLicenseNumber;
    }

    public String getPersonNumber() {
        return personNumber;
    }

    public String getMemberNumber() {
        return memberNumber;
    }

    public IAddress getPrimaryAddress(){
        return this.primaryAddress;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getMiddleName() {
        return middleName;
    }

    public String getLastName() {
        return lastName;
    }

    public String getPreferredName() {
        return preferredName;
    }

    public String getTaxId() {
        return taxId;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public String getHomePhone() {
        return homePhoneNumber;
    }

    public String getMobilePhone() {
        return mobilePhoneNumber;
    }

    public String getEmailAddress() {
        return emailAddress;
    }

    public Date getMembershipDate() {
    		return this.membershipDate;
    }

    public String getMotherMaidenName() {
    		return this.motherMaidenName;
    }

	public String getDriversLicenseNumber() {
		return this.driversLicenseNumber;
	}

	public void setMotherMaidenName(String motherMaidenName) {
    		this.motherMaidenName = motherMaidenName;
    }

	public void setDriversLicenseNumber(String driversLicenseNumber) {
		this.driversLicenseNumber = driversLicenseNumber;
	}

    public String getPhonePassword() {
        return this.phonePassword;
    }

    public String getPhonePasswordHint() {
        return this.phonePasswordHint;
    }

    public void setPhonePassword(String phonePassword) {
        this.phonePassword = phonePassword;
    }

    public void setPhonePasswordHint(String phonePasswordHint) {
        this.phonePasswordHint = phonePasswordHint;
    }
}