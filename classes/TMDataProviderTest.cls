@isTest
private class TMDataProviderTest {
    @isTest
    private static void testHappyPath() {
        
    }
    
    @isTest
    private static void testDateParsing() {
        Test.setMock(HttpCalloutMock.class, new MockAvokaTMResponse());

        ResourceOwnerCredential creds = new ResourceOwnerCredential(null, null, null, 'username', 'password');
        TMDataProvider provider = new TMDataProvider(creds);

        String avokaDate = '2018-01-13T09:12:45-0600';
        DateTime parsedDate = provider.parseAvokaDate(avokaDate);
        
        String dateComparison = avokaDate + ' ' + parsedDate;
        
        integer givenHour = 9;
        integer tzOffset = 6;
        integer expectedHour = givenHour + tzOffset;

        System.assert(parsedDate.hour() == expectedHour, dateComparison);
        System.assert(parsedDate.minute() == 12, dateComparison);
        System.assert(parsedDate.second() == 45, dateComparison);
        System.assert(parsedDate.year() == 2018, dateComparison);
        System.assert(parsedDate.month() == 1, dateComparison);
        System.assert(parsedDate.day() == 13, dateComparison);
    }
    
    @isTest
    private static void testUnhappyPath() {
        TMDataProvider nullCredProvider = new TMDataProvider(null);
        
        try {
            Object o = nullCredProvider.callApi('endpoint', 'method', null);
            System.assert(false, 'should have thrown an exception with null credentials');
        } catch (UnauthenticatedException e) {
            System.assert(true);
        }

        nullCredProvider = new TMDataProvider(new ResourceOwnerCredential(null, null, null, null, null));

        try {
            Object o = nullCredProvider.callApi('endpoint', 'method', null);
            System.assert(false, 'should have thrown an exception with null credentials');
        } catch (UnauthenticatedException e) {
            System.assert(true);
        }

        Object o = nullCredProvider.convertObjectList(null);
        System.assert(o != null, 'response to method should not have been null for a null input');
    }
}