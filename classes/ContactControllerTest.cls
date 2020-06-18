@IsTest
private class ContactControllerTest {
    @IsTest
    private static void testHappyPath() {
        Contact contact = TestDataFactory.createContact(true, true);

        Test.startTest();

        Contact fetchedContact = ContactController.getContact(contact.Id);

        Test.stopTest();

        System.assertNotEquals(null, fetchedContact);
        System.assertEquals('1000', fetchedContact.memberNumber__c);
    }

    @IsTest
    private static void testHappyPathAccount() {
        List<Account> accts = TestDataFactory.createAccountsWithContacts(1, 1, true);
        Account account = accts[0];
        Test.startTest();

        Contact fetchedContact = ContactController.getContactByAccount(account.Id);

        Test.stopTest();

        System.assertNotEquals(null, fetchedContact);
        System.assertEquals('1000', fetchedContact.memberNumber__c);
    }

    @IsTest
    private static void testHappyPathOwner() {

        User testUser = TestDataFactory.createUser('Member Contact Center Agent', 'RUL - MCC', null);
        List<Contact> contacts = TestDataFactory.createContacts(1, true, false);
        Contact contact = contacts[0];
        contact.OwnerId = testUser.Id;

        insert contact;

        Test.startTest();

        Map<String,Object> fetchedOwner = ContactController.fetchContactOwner(contact.Id);

        Test.stopTest();

        System.assertNotEquals(null, fetchedOwner);
        System.assertEquals('9999', fetchedOwner.get('extension'));
        System.assertEquals('Test User', fetchedOwner.get('name'));
        System.assertEquals('Test Title', fetchedOwner.get('title'));
        System.assertEquals('testuser@iccu.com.invalid', fetchedOwner.get('email'));
    }

    @IsTest
    private static void testUnhappyPath() {
        Test.startTest();

        Contact fetchedContact = ContactController.getContact(null);

        Test.stopTest();

        System.assertEquals(null, fetchedContact);
    }

    @IsTest
    private static void testUnhappyPathAccount() {
        Test.startTest();

        Contact fetchedContact = ContactController.getContactByAccount(null);

        Test.stopTest();

        System.assertEquals(null, fetchedContact);
    }

     @IsTest
    private static void testUnhappyPathOwner() {

        User testUser = TestDataFactory.createUser('Member Contact Center Agent', 'RUL - MCC', null);
        List<Contact> contacts = TestDataFactory.createContacts(1, true, false);
        Contact contact = contacts[0];
        contact.OwnerId = testUser.Id;

        insert contact;

        Test.startTest();

        Map<String,Object> fetchedOwner = ContactController.fetchContactOwner(null);

        Test.stopTest();

        System.assert(fetchedOwner.isEmpty());
    }
}