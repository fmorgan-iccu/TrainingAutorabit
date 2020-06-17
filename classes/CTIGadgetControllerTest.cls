@isTest(SeeAllData=false)
private class CTIGadgetControllerTest {

    @isTest
    private static void testInBoundCallMatchMobile() {
        // For a case to be created, this must be run as an MCC user!
        User testUser = getTestUser();

        Contact testContact = getTestContact();

        CTIGadgetController ctiGadgetController = new CTIGadgetController();
        ctiGadgetController.ani = '+15555555555';

        Test.startTest();

        System.runAs(testUser) {
            ctiGadgetController.findInboundCallContact();
        }

        Test.stopTest();

        // Validate that the match was made on the mobile number
        System.assertEquals(ctiGadgetController.contactId, testContact.Id);

        // Validate that a new case was created for the call.
        List<Case> callCase = [SELECT Id FROM Case WHERE ContactId = :testContact.Id];
        System.assertEquals(1, callCase.size());
    }

    @isTest
    private static void testInBoundCallMatchMemberNumber() {
        Contact testContact = getTestContact();

        // Create an open case for the user to prevent the creation of a new call case.
        Case testCase = getTestCase(testContact.Id);

        // Create a task to test when a user is matched only on member number that the activity is associated
        // in the simulated work item wrap-up process.
        Task testTask = getTestTask();

        CTIGadgetController ctiGadgetController = new CTIGadgetController();
        ctiGadgetController.ani = '+19999999999';
        ctiGadgetController.lookup = '23423987';

        Test.startTest();

        ctiGadgetController.findInboundCallContact();

        // Simulate the onActivitySave assignment.
        ctiGadgetController.callId = testTask.Id;

        // Simulate the work item wrap-up.
        ctiGadgetController.updateActivityWithCustomerId();

        Test.stopTest();

        // Validate that the contact was found by member number.
        System.assertEquals(ctiGadgetController.contactId, testContact.Id);

        // Valdiate that the activity was properly updated to the contact.
        testTask = [SELECT Id, WhoId FROM Task WHERE Id = :testTask.Id];
        System.assertEquals(testContact.Id, testTask.WhoId);

        // Validate that an additional case was not created since one is already "Open".
        List<Case> callCase = [SELECT Id FROM Case WHERE ContactId = :testContact.Id];
        System.assertEquals(callCase.size(), 1);
    }

    @isTest
    private static void testInBoundCallMatchEmployeeExtension() {
        User testUser = getTestUser();
        String testPhoneNumber = testUser.Phone;

        CTIGadgetController ctiGadgetController = new CTIGadgetController();
        ctiGadgetController.ani = testPhoneNumber;

        Test.startTest();

        ctiGadgetController.findInboundCallContact();

        Test.stopTest();

        // Get the admin user by extension to validate behavior.
        User adminUser = [SELECT Id FROM User WHERE Phone = :testPhoneNumber];
        System.assertNotEquals(adminUser, null);

        // Validate that the match was made on the mobile number
        System.assertEquals(ctiGadgetController.userId, adminUser.Id);
    }

    @isTest
    private static void testInBoundCallNoMatch() {
        Contact testContact = getTestContact();

        CTIGadgetController ctiGadgetController = new CTIGadgetController();
        ctiGadgetController.ani = '+18008008000';

        Test.startTest();

        // Code coverage of the getter initialization
        List<Contact> emptyContacts = ctiGadgetController.contacts;
        System.assertEquals(emptyContacts.size(), 0);

        ctiGadgetController.findInboundCallContact();

        Test.stopTest();

        // Validate that the match was made on the mobile number
        System.assertEquals(ctiGadgetController.contactId, null);
        System.assertEquals(ctiGadgetController.newCaseId, null);
    }

    private static Contact getTestContact() {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
        Contact testContact = new Contact (
            RecordTypeId = contactRecordTypeId,
            Birthdate = Date.today(),
            MemberNumber__c = '23423987',
            Email = 'something@example.com',
            FirstName = 'Jack',
            LastName = 'Johnson',
            MailingStreet = '123 Penny Lane',
            MailingCity = 'Chubbuck',
            MailingState = 'ID',
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxId__c = '000-00-0000',
            PersonNumber__c = '123456',
            Phone = '8001231234'
        );

        insert testContact;
        return testContact;
    }

    private static Case getTestCase(Id contactId) {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        Case testCase = new Case(
            ContactId=contactId,
            Status='Open',
            RecordTypeId=caseRecordTypeId
        );
        insert testCase;
        return testCase;
    }

    private static Task getTestTask() {
        Task testTask = new Task(
            Type='Call',
            Subject='Test Task'
        );
        insert testTask;
        return testTask;
    }

    private static User getTestUser() {
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Name FROM User WHERE Id = : currentUserId];

        String testPhoneNumber = '99999';

        User testUser = null;
        System.runAs(currentUser) {
            UserRole testRole = new UserRole(
                DeveloperName = 'MyCustomRole',
                Name = 'MCC User'
            );
            insert testRole;

            testUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name='RUL - MCC'].Id,
                FirstName = 'first',
                LastName = 'last',
                Email = 'testuser@iccu.com',
                Username = 'testuser@iccu.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Denver',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = testRole.Id,
                Phone = testPhoneNumber
            );
            insert testUser;
        }

        return testUser;
    }

}