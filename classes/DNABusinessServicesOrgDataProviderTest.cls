@IsTest
private with sharing class DNABusinessServicesOrgDataProviderTest {

    @IsTest
    private static void testHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest();

        IAuthenticationManager authManager = new DNABusinessServicesAuthManagerMock();
        DNABusinessServicesOrgDataProvider provider = new DNABusinessServicesOrgDataProvider(authManager);
        List<IWarningFlag> flags = provider.getWarningFlags('12345');

        String providerName = provider.getProviderName();

        Test.stopTest();

        System.assertNotEquals(null, flags);
        System.assertEquals(2, flags.size());
        System.assertEquals('DNA', providerName);

        // Test the internal parsing
        IWarningFlag flag = flags[0];
        System.assertEquals('BADD', flag.getFlagCode());
        System.assertEquals('Bad Address', flag.getFlagCodeDescription());
        System.assertEquals(Datetime.newInstance(2015, 5, 26, 0, 0, 0), flag.getEffectiveDate());
        System.assertEquals(Datetime.newInstance(2015, 8, 28, 0, 0, 0), flag.getInactiveDate());
    }

    @IsTest
    private static void testUnhappyPath() {

        IAuthenticationManager authManager = new DNABusinessServicesAuthManagerMock();
        DNABusinessServicesOrgDataProvider provider = new DNABusinessServicesOrgDataProvider(authManager);
        authManager.logOut();

        try {
            provider.getWarningFlags('12345');
            System.assert(false, 'getWarningFlags succeeded even though the user is not logged in.');
        } catch (UnauthenticatedException e) {
            // Expected behavior
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception thrown. ' + e.getMessage());
        }

        try {
            provider.getOrganizationDetails('12345');
            System.assert(false, 'This function should not be supported.');
        } catch (DataServiceException e) {
            // Expected behavior
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception thrown. ' + e.getMessage());
        }
    }
}