@IsTest
private class ContactControllerTest {
    @IsTest
    private static void testHappyPath() {
        Contact testContact = getTestContact();

        Test.startTest();

        Contact fetchedContact = ContactController.getContact(testContact.id);

        Test.stopTest();

        System.assertNotEquals(null, fetchedContact);
        System.assertEquals('23423987', fetchedContact.memberNumber__c);
    }

    @IsTest
    private static void testUnhappyPath() {
        Test.startTest();

        Contact fetchedContact = ContactController.getContact(null);

        Test.stopTest();

        System.assertEquals(null, fetchedContact);
    }

    private static Contact getTestContact() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),
            MemberNumber__c = '23423987',
            Email = 'something@example.com',
            FirstName = 'Jack',
            MiddleName = 'Joe',
            LastName = 'Johnson',
            MailingStreet = '123 Penny Lane',
            MailingCity = 'Chubbuck',
            MailingState = 'ID',
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxID__c = '000-00-0000',
            PersonNumber__c = '123456',
            Phone = '(555) 555-5555'
        );
        insert testContact;

        return testContact;
    }
}