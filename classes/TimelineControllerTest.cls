@IsTest
public with sharing class TimelineControllerTest {

    @IsTest
    private static void testContactTimeline() {
        List<Account> accts = TestDataFactory.createAccountsWithContacts(1, 1, true);
        Account a = accts[0];

        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE AccountId = :a.Id
        ];
        Contact c = contacts[0];

        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT).getRecordTypeId();
        List<Opportunity> opps = TestDataFactory.createOppsWithPrimaryRoles(2, oppRecordTypeId, RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT, 'New', a, c);
        opps[1].StageName = 'Complete';
        update opps[1];
        Test.setCreatedDate(opps[0].Id, DateTime.newInstance(2020, 2, 2));
        Test.setCreatedDate(opps[1].Id, DateTime.newInstance(2020, 1, 1));

        Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        List<Case> cases = TestDataFactory.createCases(1, supportCaseRecordTypeId, c.Id, a.Id, 'Open', true);
        Test.setCreatedDate(cases[0].Id, DateTime.newInstance(2020, 2, 1));

        Test.startTest();

        Map<String, Object> response = TimelineController.getTimeline(c.Id, null, null);

        Test.stopTest();

        System.assert(response.containsKey('openEntries'));
        System.assert(response.containsKey('closedEntries'));

        System.assertEquals(1, (Integer)response.get('pageCount'));
        System.assertEquals(1, (Integer)response.get('pageNumber'));

        List<Map<String, Object>> openEntries = (List<Map<String, Object>>)response.get('openEntries');
        System.assertEquals(2, openEntries.size());
        System.assertEquals('opportunity', (String)openEntries[0].get('type'));
        System.assertEquals(Datetime.newInstance(2020, 2, 2), (Datetime)openEntries[0].get('createdDate'));
        System.assertEquals('case', (String)openEntries[1].get('type'));
        System.assertEquals(Datetime.newInstance(2020, 2, 1), (Datetime)openEntries[1].get('createdDate'));

        List<Map<String, Object>> closedEntries = (List<Map<String, Object>>)response.get('closedEntries');
        System.assertEquals(1, closedEntries.size());
        System.assertEquals('opportunity', (String)closedEntries[0].get('type'));
    }

    @IsTest
    private static void testAccountTimeline() {
        List<Account> accts = TestDataFactory.createAccounts(1, true, true);
        Account a = accts[0];

        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT).getRecordTypeId();
        List<Opportunity> opps = TestDataFactory.createOpportunities(2, oppRecordTypeId, RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT, 'New', a, true);
        opps[1].StageName = 'Complete';
        update opps[1];
        Test.setCreatedDate(opps[0].Id, DateTime.newInstance(2020, 2, 2));
        Test.setCreatedDate(opps[1].Id, DateTime.newInstance(2020, 1, 1));

        Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        List<Case> cases = TestDataFactory.createCases(1, supportCaseRecordTypeId, null, a.Id, 'Open', true);
        Test.setCreatedDate(cases[0].Id, DateTime.newInstance(2020, 2, 1));

        Test.startTest();

        Map<String, Object> response = TimelineController.getTimeline(a.Id, null, null);

        Test.stopTest();

        System.assert(response.containsKey('openEntries'));
        System.assert(response.containsKey('closedEntries'));

        System.assertEquals(1, (Integer)response.get('pageCount'));
        System.assertEquals(1, (Integer)response.get('pageNumber'));

        List<Map<String, Object>> openEntries = (List<Map<String, Object>>)response.get('openEntries');
        System.assertEquals(2, openEntries.size());
        System.assertEquals('opportunity', (String)openEntries[0].get('type'));
        System.assertEquals(Datetime.newInstance(2020, 2, 2), (Datetime)openEntries[0].get('createdDate'));
        System.assertEquals('case', (String)openEntries[1].get('type'));
        System.assertEquals(Datetime.newInstance(2020, 2, 1), (Datetime)openEntries[1].get('createdDate'));

        List<Map<String, Object>> closedEntries = (List<Map<String, Object>>)response.get('closedEntries');
        System.assertEquals(1, closedEntries.size());
        System.assertEquals('opportunity', (String)closedEntries[0].get('type'));
    }

    @IsTest
    private static void testTimelinePaging() {
        List<Account> accts = TestDataFactory.createAccountsWithContacts(1, 1, true);
        Account a = accts[0];

        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE AccountId = :a.Id
        ];
        Contact c = contacts[0];

        Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        List<Case> cases = TestDataFactory.createCases(10, supportCaseRecordTypeId, c.Id, a.Id, 'Closed', true);

        Test.startTest();

        Map<String, Object> response = TimelineController.getTimeline(c.Id, 2, 2);

        Test.stopTest();

        System.assert(response.containsKey('openEntries'));
        System.assert(response.containsKey('closedEntries'));

        System.assertEquals(5, (Integer)response.get('pageCount'));
        System.assertEquals(2, (Integer)response.get('pageNumber'));

        List<Map<String, Object>> openEntries = (List<Map<String, Object>>)response.get('openEntries');
        System.assertEquals(0, openEntries.size());

        List<Map<String, Object>> closedEntries = (List<Map<String, Object>>)response.get('closedEntries');
        System.assertEquals(2, closedEntries.size());
        System.assertEquals('case', (String)closedEntries[0].get('type'));
        System.assertEquals('case', (String)closedEntries[1].get('type'));
    }


    @IsTest
    private static void unhappyPath() {
        Map<String, Object> response = TimelineController.getTimeline(null, null, null);
        System.assertEquals('The `recordId` cannot be null.', (String)response.get('error'));
    }

}