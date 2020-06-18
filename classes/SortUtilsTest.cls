@IsTest
public with sharing class SortUtilsTest {

    @IsTest
    static void testSortListByCreatedDate() {
        List<Contact> listToSort = TestDataFactory.createContacts(4, true, true);
        Test.setCreatedDate(listToSort[0].id, DateTime.newInstance(2018,1,2));
        Test.setCreatedDate(listToSort[1].id, DateTime.newInstance(2017,10,3));
        Test.setCreatedDate(listToSort[2].id, DateTime.newInstance(2018,1,1));
        Test.setCreatedDate(listToSort[3].id, DateTime.newInstance(2019,12,25));

        // Must query the objects to get the created date set properly.
        listToSort = [SELECT id, createdDate FROM CONTACT];

        Test.startTest();

        List<Contact> sortedList = (List<Contact>)SortUtils.sortListByCreatedDate((List<sObject>)listToSort);

        Test.stopTest();

        System.assertEquals(sortedList[0].id, listToSort[1].id);
        System.assertEquals(sortedList[1].id, listToSort[2].id);
        System.assertEquals(sortedList[2].id, listToSort[0].id);
        System.assertEquals(sortedList[3].id, listToSort[3].id);
    }

    @IsTest
    static void testSortListByDate() {
        createTestCases();

        // Must query the objects to get the created date set properly.
        List<Case> listToSort = [SELECT id, createdDate, closedDate, isClosed FROM Case];

        Test.startTest();

        List<Case> sortedList = (List<Case>)SortUtils.sortListByDate((List<sObject>)listToSort);

        Test.stopTest();

        System.assertEquals(sortedList[0].id, listToSort[0].id);
        System.assertEquals(sortedList[1].id, listToSort[2].id);
        System.assertEquals(sortedList[2].id, listToSort[1].id);
    }

    @IsTest
    static void testSortListByDateDesc() {
        createTestCases();

        // Must query the objects to get the created date set properly.
        List<Case> listToSort = [SELECT id, createdDate, closedDate, isClosed FROM Case];

        Test.startTest();

        List<Case> sortedList = (List<Case>)SortUtils.sortListByDate((List<sObject>)listToSort, Metadata.SortOrder.DESC_X);

        Test.stopTest();

        System.assertEquals(sortedList[0].id, listToSort[1].id);
        System.assertEquals(sortedList[1].id, listToSort[2].id);
        System.assertEquals(sortedList[2].id, listToSort[0].id);
    }

    private static void createTestCases() {
        List<Account> accts = TestDataFactory.createAccountsWithContacts(1, 1, true);
        Account a = accts[0];

        List<Contact> contacts = [
            SELECT id
            FROM Contact
            WHERE AccountId = :a.Id
        ];
        Contact c = contacts[0];

        Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        List<Case> cases = TestDataFactory.createCases(3, supportCaseRecordTypeId, c.Id, a.Id, 'Open', false);
        cases[1].Status = 'Closed';
        insert cases;
        Test.setCreatedDate(cases[0].id, DateTime.newInstance(2020,1,2));
        Test.setCreatedDate(cases[1].id, DateTime.newInstance(2020,1,12));
        Test.setCreatedDate(cases[2].id, DateTime.newInstance(2020,1,15));
    }

}