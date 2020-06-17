@isTest
private class DNAPersonTest {
    @isTest
    static void testGetSet() {
        String personNumber = '123456';
		String memberNumber = '123456';
        String preferredName = 'Jon';
        String firstName = 'Jonathan';
        String middleName = 'Taylor';
        String lastName = 'Thomas';
        String ssn = '999-99-9999';
		Date dob = Date.today();
        String homePhone = '123-123-1234';
        String mobilePhone = '234-234-2345';
        String emailAddress = 'example@example.com';
        Date membershipDate = Date.today();
        String driversLicenseNumber = '123456789';
        String maidenName = 'Mother';


        String city = 'Chubbuck';
        String countryCode = 'USA';
        String postalCode = '83202';
        String stateCode = 'ID';
        String street = '4400 Central Way';
        DNAAddress address = new DNAAddress(city, countryCode, postalCode, stateCode, street);

        DNAPerson person = new DNAPerson(personNumber, memberNumber, preferredName, address, firstName, middleName, lastName, ssn, dob, homePhone, mobilePhone, emailAddress, membershipDate, driversLicenseNumber);
        person.setMotherMaidenName(maidenName);

        System.assert(personNumber.equals(person.getPersonNumber()));
        System.assert(memberNumber.equals(person.getMemberNumber()));
		System.assert(preferredName.equals(person.getPreferredName()));
        System.assert(firstName.equals(person.getFirstName()));
        System.assert(middleName.equals(person.getMiddleName()));
        System.assert(lastName.equals(person.getLastName()));
        System.assert(ssn.equals(person.getTaxId()));
        System.assert(dob == person.getDateOfBirth());
        System.assert(homePhone.equals(person.getHomePhone()));
        System.assert(mobilePhone.equals(person.getMobilePhone()));
        System.assert(emailAddress.equals(person.getEmailAddress()));
        System.assert(membershipDate == person.getMembershipDate());
        System.assert(driversLicenseNumber.equals(person.getDriversLicenseNumber()));
        System.assert(maidenName.equals(person.getMotherMaidenName()));

        System.assert(address == person.getPrimaryAddress());
        System.assert(city.equals(person.getPrimaryAddress().getCity()));
		System.assert(countryCode.equals(person.getPrimaryAddress().getCountryCode()));
        System.assert(postalCode.equals(person.getPrimaryAddress().getPostalCode()));
        System.assert(stateCode.equals(person.getPrimaryAddress().getStateCode()));
        System.assert(street.equals(person.getPrimaryAddress().getStreet()));

        person.setDriversLicenseNumber(driversLicenseNumber);
        System.assert(driversLicenseNumber.equals(person.getDriversLicenseNumber()));

        String addressString = person.getPrimaryAddress().toString();
		String referenceAddressString = '' + street + '\n' + city + ', ' + stateCode + '  ' + postalCode + ', ' + countryCode;
        System.assert(addressString.equals(referenceAddressString));
    }

	@isTest
    static void testMiscConstructors() {
        String personNumber = '123456';

        DNAPerson person1 = new DNAPerson();
        System.assert(person1 != null);
        DNAPerson person2 = new DNAPerson(personNumber);
        System.assert(personNumber.equals(person2.getPersonNumber()));
    }
}