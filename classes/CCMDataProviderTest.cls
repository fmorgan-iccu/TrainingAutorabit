@IsTest
private class CCMDataProviderTest {
    /**
     * Mock auth manager class
     */
    private class MockAuthManager implements IAuthenticationManager {
        private Boolean isAuthed { get; set; }

        private MockAuthManager(Boolean isAuthed) {
            this.isAuthed = isAuthed;
        }

        public Boolean authenticateUser(IAuthenticationCredential credential) {
            return this.isAuthed;
        }

        public Boolean isUserAuthenticated() {
            return this.isAuthed;
        }

        public void logOut() {
            this.isAuthed = false;
        }
    }

    @IsTest
    private static void testHappyGetRelationships() {
        Test.setMock(HttpCalloutMock.class, new MockCCMResponse());

        try {
            String personNumber = '22253';

            CCMDataProvider testCoverage = new CCMDataProvider(); // :D
            CCMDataProvider provider = new CCMDataProvider(new MockAuthManager(true));
            
            System.assert(provider.getAuthenticationManager() != null, 'Auth manager was null!');
            
            List<AccountCardInfo> cards = provider.getAccountCardInfo(personNumber);

            System.assert(cards != null, 'Card info was null!');

            Integer expectedSize = 4;
            Integer actualSize = cards.size();
            System.assertEquals(expectedSize, actualSize);

            AccountCardInfo info = cards.get(1);

            DateTime expectedDate = DateTime.newInstanceGmt(2019, 7, 31, 0, 0, 0);
            DateTime actualDate = info.expirationDate;
            System.assert(actualDate != null, 'Expected expiration date to NOT be null');
            System.assertEquals(expectedDate, actualDate, 'Expiration dates do NOT match.');

            String expectedCardNumber = '4869382267100638';
            String actualCardNumber = info.cardNumber;
            System.assert(actualCardNumber != null, 'Expected card number to NOT be null');
            System.assertEquals(expectedCardNumber, actualCardNumber, 'Card numbers do NOT match.');

            String expectedDisplayName = 'Visa Platinum';
            String actualDisplayName = info.displayName;
            System.assert(actualDisplayName != null, 'Expected display name to NOT be null');
            System.assertEquals(expectedDisplayName, actualDisplayName, 'Display names do NOT match.');

            System.assert(info.nameOnCard != null);
            System.assertEquals('Ann Smith', info.nameOnCard);

            String expectedStatus = 'Active';
            String actualStatus = info.status;
            System.assert(expectedStatus != null, 'Expected status to NOT be null');
            System.assertEquals(expectedStatus, actualStatus, 'Statuses do NOT match.');

            String expectedUniqueId = '4869382267100638';
            String actualUniqueId = info.uniqueId;
            System.assert(expectedUniqueId != null, 'Expected unique ID to NOT be null');
            System.assertNotEquals(null, actualUniqueId);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    @IsTest
    private static void testHappyUpdateCardStatus() {
        Test.setMock(HttpCalloutMock.class, new MockCCMResponse());

        try {
            String personNumber = '22253';

            AccountCardInfo info = new AccountCardInfo(null, null, null, new List<AccountCardInfo.SelectionOption>(), true, '1234567890', 'Visa Platinum', 'Credit', System.now(), 'John Doe', 'CCM', 'Active', 'Active', null);

            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest> {
                new UpdateAccountCardInfoRequest(info, 'Member lost their card.', null, 'Inactive')
            };

            CCMDataProvider provider = new CCMDataProvider(new MockAuthManager(true));
            provider.updateAccountCardStatuses(personNumber, requests);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    @IsTest
    private static void testUnhappyUnauthed() {
        try {
            Test.setMock(HttpCalloutMock.class, new MockCCMResponse());

            String personNumber = '22253';

            CCMDataProvider provider = new CCMDataProvider(new MockAuthManager(false));
            List<AccountCardInfo> cards = provider.getAccountCardInfo(personNumber);
            System.assert(false, 'Expected an unauthenticated exception, but it did not.');
        } catch (UnauthenticatedException e) {
            
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception was thrown: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        // Use case where you have an expired token
        try {
            Integer statusCode = 401;
            String responseData = 'hello world'; // That's right, folks: this is the response when you're 401'd (>_<)

            Test.setMock(HttpCalloutMock.class, new MockCCMResponse(responseData, statusCode));

            String personNumber = '22253';

            CCMDataProvider provider = new CCMDataProvider(new MockAuthManager(true));
            List<AccountCardInfo> cards = provider.getAccountCardInfo(personNumber);
            System.assert(false, 'Expected an unauthenticated exception, but it did not.');
        } catch (UnauthenticatedException e) {
            
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception was thrown: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    @IsTest
    private static void testUnhappyBadUpdateRequest() {
        String responseData = '{"message": "Requested value \'BLARG\' was not found."}';
        Integer statusCode = 400;
        Test.setMock(HttpCalloutMock.class, new MockCCMResponse(responseData, statusCode));

        try {
            String personNumber = '22253';
            
            String badStatus = 'BLARG';
            AccountCardInfo info = new AccountCardInfo(null, null, null, new List<AccountCardInfo.SelectionOption>(), true, '1234567890', 'Visa Platinum', 'Credit', System.now(), 'John Doe', 'CCM', badStatus, badStatus, null);

            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest> {
                new UpdateAccountCardInfoRequest(info, 'Lost', null, 'Inactive')
            };

            CCMDataProvider provider = new CCMDataProvider(new MockAuthManager(true));
            provider.updateAccountCardStatuses(personNumber, requests);

            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (DataServiceException e) {
            // Supposed to throw this exception
            
            String expectedMessage = 'Requested value \'BLARG\' was not found.';
            System.assert(e.getMessage().contains(expectedMessage), 'Expected error message to contain (' + expectedMessage + ') got: (' + e.getMessage() +').');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    @IsTest
    private static void testUnhappyMissingInfo() {
        Test.setMock(HttpCalloutMock.class, new MockCCMResponse());

        CCMDataProvider provider = new CCMDataProvider(new MockAuthManager(true));

        // Null person number        
        try {
            provider.updateAccountCardStatuses(null, null);
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        // Null request
        try {
            provider.updateAccountCardStatuses('123456', null);
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        // Empty request
        try {
            provider.updateAccountCardStatuses('123456', new List<UpdateAccountCardInfoRequest>());
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        // Null new status
        try {
            provider.updateAccountCardStatuses('123456', new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, null, null, null)
            });
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        // Null change reason
        try {
            provider.updateAccountCardStatuses('123456', new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, null, null, 'Active')
            });
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        // Null card info
        try {
            provider.updateAccountCardStatuses('123456', new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, null, 'because', 'Active')
            });
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        // Null card number
        try {
            AccountCardInfo info = new AccountCardInfo(null, null, null, null, false, null, null, null, null, null, null, null, null, null);

            provider.updateAccountCardStatuses('123456', new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(info, null, 'because', 'Active')
            });
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        // Null card status
        try {
            AccountCardInfo info = new AccountCardInfo(null, null, null, null, false, null, '1232334534534', null, null, null, 'CCM', null, null, null);

            provider.updateAccountCardStatuses('123456', new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(info, null, 'because', 'Active')
            });
            System.assert(false, 'Expected exception, but one was not thrown');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
    }
}