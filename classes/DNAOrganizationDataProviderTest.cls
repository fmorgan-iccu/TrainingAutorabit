@IsTest
private with sharing class DNAOrganizationDataProviderTest {

    @IsTest
    private static void testGetOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAOrganizationDataProvider provider = new DNAOrganizationDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();

        System.assert(gottenAuthManager != null);

        try {
            IOrganization orc = provider.getOrganizationDetails('355061');
            System.assert(orc.getAddress() != null, 'Orc address was null!');
            System.assert(orc.getEmailAddress() != null, 'Orc email was null!');
            System.assert(orc.getOrgNumber() != null, 'Orc number was null!');
            System.assert(orc.getEmailAddress() != null, 'Orc email was null!');
            System.assert(orc.getOrgType() != null, 'Orc type was null!');
            System.assert(orc.getPhoneNumber() != null, 'Orc phone # was null!');
            System.assert(orc.getTaxId() != null, 'Orc tax ID was null!');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        try {
            IOrganization orc = provider.getOrganizationDetails(null);
            System.assert(false, 'Expected an exception to be thrown.');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        try {
            provider.getWarningFlags('12345');
            System.assert(false, 'This function should be unsupported and throw an exception.');
        } catch (DataServiceException e) {
            // Expected
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

}