@isTest
private class COOPTravelNotificationDataProviderTest {

    @IsTest
    private static void testHappyPathTravelInquiry() {
        createTestServiceAccount();
        Test.setMock(HttpCalloutMock.class, new MockCOOPResponse());

        Test.startTest();

        COOPTravelNotificationDataProvider travelDataProvider = new COOPTravelNotificationDataProvider();
        List<CardTravelNotificationInfo> travelNotifications = travelDataProvider.getTravelNotification('4758691723569136');

        Test.stopTest();

        System.assertNotEquals(null, travelNotifications);
        System.assertEquals(1, travelNotifications.size());

        CardTravelNotificationInfo info = travelNotifications[0];
        System.assertEquals('4758691723569136', info.cardNumber);
        System.assertEquals('John', info.firstName);
        System.assertEquals('Doe', info.lastName);
        System.assertEquals('12089991234', info.primaryPhone);

        List<CardTravelNotificationInfo.Detail> details = info.details;
        System.assertEquals(3, details.size());
        System.assertEquals('8/1/2019', details[0].fromDate.format());
        System.assertEquals('8/10/2019', details[0].toDate.format());
        System.assertEquals('On vacation in California.', details[0].note);
        System.assertEquals('CA', details[0].stateCode);
        System.assertEquals('USA', details[0].countryCode);

        System.assertEquals('8/1/2019', details[1].fromDate.format());
        System.assertEquals('8/10/2019', details[1].toDate.format());
        System.assertEquals('On vacation in California.', details[1].note);
        System.assertEquals('OR', details[1].stateCode);
        System.assertEquals('USA', details[1].countryCode);

        System.assertEquals('8/1/2019', details[2].fromDate.format());
        System.assertEquals('8/10/2019', details[2].toDate.format());
        System.assertEquals('On vacation in California.', details[2].note);
        System.assert(String.isBlank(details[2].stateCode));
        System.assertEquals('MEX', details[2].countryCode);
    }

     @IsTest
    private static void testHappyCancelTravelNotification() {
        createTestServiceAccount();

        Test.setMock(HttpCalloutMock.class, new MockCOOPResponse());

        Test.startTest();

        COOPTravelNotificationDataProvider travelDataProvider = new COOPTravelNotificationDataProvider();
        Boolean result = travelDataProvider.cancelTravelNotification('4758691723569136', '2050');

        Test.stopTest();

        System.assert(true, result);
    }

     @IsTest
    private static void testHappyUpdateTravelNotification() {
        createTestServiceAccount();

        Test.setMock(HttpCalloutMock.class, new MockCOOPResponse());

        Test.startTest();

        Date today = System.today();
        CardTravelNotificationInfo.Detail detail = new CardTravelNotificationInfo.Detail(today, today.addDays(1), 'WA', 'USA', 'test');
        List<CardTravelNotificationInfo.Detail> details = new List<CardTravelNotificationInfo.Detail>();
        details.add(detail);
        CardTravelNotificationInfo info = new CardTravelNotificationInfo('4758691723569136', 'John', 'Doe', '12089991234', details);
        COOPTravelNotificationDataProvider travelDataProvider = new COOPTravelNotificationDataProvider();
        Boolean result = travelDataProvider.updateTravelNotification(info);

        Test.stopTest();

        System.assert(true, result);
    }

    @IsTest
    private static void testUnhappyPathUpdateNotification() {
        createTestServiceAccount();

        String responseBody = '{"response":{"exceptions":[{"errorCode":2007,"detail":"Cardholder first name is missing"},{"errorCode":2008,"detail":"Cardholder last name is missing"}],"count":2,"status":"FAILED"}}';
        Test.setMock(HttpCalloutMock.class, new MockCOOPResponse(responseBody, 200));

        Test.startTest();

        Date today = System.today();
        CardTravelNotificationInfo.Detail detail = new CardTravelNotificationInfo.Detail(today, today.addDays(1), 'WA', 'USA', 'test');
        List<CardTravelNotificationInfo.Detail> details = new List<CardTravelNotificationInfo.Detail>();
        details.add(detail);
        CardTravelNotificationInfo info = new CardTravelNotificationInfo('4758691723569136', 'John', 'Doe', '12089991234', details);
        COOPTravelNotificationDataProvider travelDataProvider = new COOPTravelNotificationDataProvider();
        try {
            Boolean result = travelDataProvider.updateTravelNotification(info);
            System.assert(false); // An exception should be thrown
        } catch(DataServiceException dse) {
            System.assert(dse.getMessage().contains('Cardholder first name is missing'));
            System.assert(dse.getMessage().contains('Cardholder last name is missing'));
        }

        Test.stopTest();
    }

    private static void createTestServiceAccount() {
        List<ServiceAccounts__c> serviceAccounts = new List<ServiceAccounts__c> {
            new ServiceAccounts__c(
                APIClientSecret__c = 'secret',
                Name = 'CO-OP',
                ServiceName__c = 'CO-OP'
            )
        };
        insert serviceAccounts;
    }

}