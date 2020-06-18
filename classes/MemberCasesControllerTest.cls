@IsTest
private class MemberCasesControllerTest {

    @IsTest
    private static void testAccountCases() {
        Account a = TestDataFactory.createAccount(true, true);

        Id supportTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        TestDataFactory.createCases(1, supportTypeId, null, a.Id, 'New', true);

        Test.startTest();

        List<Case> openCases = MemberCasesController.getOpenAccountCases(a.Id);

        Test.stopTest();

        System.assertEquals(1, openCases.size());
        System.assertNotEquals(null, openCases[0].CaseNumber);
    }

    @IsTest
    private static void testMemberCases() {
        Account a = TestDataFactory.createAccount(true, true);

        Contact c = TestDataFactory.createContact(true, false);
        c.AccountId = a.Id;
        insert c;

        Id supportTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        TestDataFactory.createCases(1, supportTypeId, c.Id, a.Id, 'New', true);

        Test.startTest();

        List<Case> openCases = MemberCasesController.getOpenMemberCases(c.Id);
        List<Case> closedCases = MemberCasesController.getClosedMemberCases(c.Id);

        Test.stopTest();

        System.assertEquals(1, openCases.size());
        System.assertNotEquals(null, openCases[0].CaseNumber);
        System.assertEquals(0, closedCases.size());
    }

    @IsTest
    private static void testUnhappyPath() {
        try {
            MemberCasesController.getOpenAccountCases(null);
            System.assert(false, 'Should have thrown an exception.');
        } catch(Exception e) {
            System.assert(true);
        }

        try {
            MemberCasesController.getOpenMemberCases(null);
            System.assert(false, 'Should have thrown an exception.');
        } catch(Exception e) {
            System.assert(true);
        }

        try {
            MemberCasesController.getClosedMemberCases(null);
            System.assert(false, 'Should have thrown an exception.');
        } catch(Exception e) {
            System.assert(true);
        }
    }

}