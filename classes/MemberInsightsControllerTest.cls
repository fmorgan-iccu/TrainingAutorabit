@IsTest

private class MemberInsightsControllerTest {

    @IsTest
    private static void testContactInsights() {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        Contact c = TestDataFactory.createContact(true, true);
        TestDataFactory.createCase(caseRecordTypeId, c.Id, null, 'New', true);
        TestDataFactory.createMemberInsight(c.Id, true);

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);
        MemberAccountsController.networkFactory = networkFactory;

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest();

        Map<String, Object> insights = MemberInsightsController.fetchInsights(c.Id);

        Test.stopTest();

        System.assertNotEquals(null, insights.get('financialAccountInsights'));
        System.assertNotEquals(null, insights.get('generalInsights'));

        List<Map<String, Object>> financialAccountInsights = (List<Map<String, Object>>)insights.get('financialAccountInsights');
        System.assertEquals(0, financialAccountInsights.size());

        List<Map<String, Object>> generalInsights = (List<Map<String, Object>>)insights.get('generalInsights');
        System.assertEquals(3, generalInsights.size());
    }

    @IsTest
    private static void testAccountInsights() {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        Account a = TestDataFactory.createAccount(true, true);
        TestDataFactory.createCase(caseRecordTypeId, null, a.Id, 'New', true);

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        INetworkFactory networkFactory = new ConcreteNetworkProvider(authManager);
        MemberAccountsController.networkFactory = networkFactory;

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest();

        Map<String, Object> insights = MemberInsightsController.fetchInsights(a.Id);

        Test.stopTest();

        System.assertNotEquals(null, insights.get('financialAccountInsights'));
        System.assertNotEquals(null, insights.get('generalInsights'));

        List<Map<String, Object>> financialAccountInsights = (List<Map<String, Object>>)insights.get('financialAccountInsights');
        System.assertEquals(0, financialAccountInsights.size());

        List<Map<String, Object>> generalInsights = (List<Map<String, Object>>)insights.get('generalInsights');
        System.assertEquals(1, generalInsights.size());
    }

}