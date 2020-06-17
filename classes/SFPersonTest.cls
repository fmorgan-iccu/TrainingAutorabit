@isTest
private class SFPersonTest {
    @isTest
    private static void testHappyPath() {
        DateTime membershipDateTime = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);
        DateTime dobDateTime = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);

        Date birthdate = dobDateTime.addSeconds(1519928100).date();
        String dlNumber = '2983475';
        String email = 'test@test.com';
        String firstName = 'Test';
        String middleName = 'TestMiddle';
        String homePhone = '(208) 555-5555';
        String lastName = 'User';
        String memberNumber = '09876545';
        Date membershipDate = membershipDateTime.addSeconds(1519928151).date();
        String mobilePhone = '(208) 555-5556';
        String personNumber = '123456';
        String preferredName = 'Pref';
        String ssn = '888-88-8888';
        String street = '123 Penny Lane';
        String city = 'Chubbuck';
        String stateCode = 'ID';
        String postalCode = '83202';
        String countryCode = 'USA';

        Contact testContact = new Contact(
			BirthDate = birthdate,
			IdentificationNumber__c = dlNumber,
			Email = email,
			FirstName = firstName,
            MiddleName = middleName,
			Phone = homePhone,
			LastName = lastName,
			MemberNumber__c = memberNumber,
			MemberSince__c = membershipDate,
			MobilePhone = mobilePhone,
			PersonNumber__c = personNumber,
			PreferredName__c = preferredName,
			TaxID__c = ssn,

            MailingCity = city,
			MailingCountry = countryCode,
			MailingPostalCode = postalCode,
			MailingState = stateCode,
			MailingStreet = street
        );

        System.assert(testContact != null, 'Newly created contact is null!');

        SFPerson person = new SFPerson(testContact);

        System.assert(person != null, 'SFPerson is null!');
        System.assert(person.getContact() == testContact);

        System.assert(String.valueOf(person.getDateOfBirth()).equals(String.valueof(birthdate)));
        System.assert(person.getDriversLicenseNumber() != null, 'Drivers license is null!');
        System.assert(person.getDriversLicenseNumber().equals(dlNumber));
        System.assert(person.getEmailAddress().equals(email));
        System.assert(person.getFirstName().equals(firstName));
        System.assert(person.getMiddleName().equals(middleName));
        System.assert(person.getHomePhone().equals(homePhone));
        System.assert(person.getLastName().equals(lastName));
        System.assert(person.getMemberNumber().equals(memberNumber));
        System.assert(String.valueOf(person.getMembershipDate()).equals(String.valueOf(membershipDate)));
        System.assert(person.getMobilePhone().equals(mobilePhone));
        System.assert(person.getPersonNumber().equals(personNumber));
        System.assert(person.getPreferredName().equals(preferredName));
        System.assert(person.getTaxId().equals(ssn));

		IAddress address = person.getPrimaryAddress();

        System.assert(address.toString() != null);

        System.assert(address != null);
        System.assert(address.getCity().equals(city));
        System.assert(address.getStreet().equals(street));
        System.assert(address.getCountryCode().equals(countryCode));
        System.assert(address.getPostalCode().equals(postalCode));
        System.assert(address.getStateCode().equals(stateCode));
    }
}