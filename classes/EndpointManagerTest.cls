@isTest
@TestVisible
private class EndpointManagerTest {    
    @isTest
    private static void testHappyPath() {
        EndpointManager mgr = new EndpointManager();
        
        String dnaSignOn = mgr.getDNASignOnEndpoint();
        System.assert(dnaSignOn != null, 'DNA Sign On was null!');
        String dnaService = mgr.getDNAServiceEndpoint();
        System.assert(dnaService != null, 'DNA Service was null!');
        
        String encompassOAuth = mgr.getEncompassOAuthEndpoint();
        System.assert(encompassOAuth != null, 'Encompass OAuth was null!');
        String encompassSSNSearch = mgr.getEncompassSSNSearchEndpoint();
        System.assert(encompassSSNSearch != null, 'Encompass SSN Search was null!');
        String encompassLoan = mgr.getEncompassLoanEndpoint();
        System.assert(encompassLoan != null, 'Encompass Loan was null!');
        String encompassMilestone = mgr.getEncompassLoanMilestonesEndpoint();
        System.assert(encompassMilestone != null, 'Encompass Milestones was null!');
        
        String ccm = mgr.getCCMAPIEndpoint();
        System.assert(ccm != null, 'CCM endpoint was null!');
    }
    
    @isTest
    private static void testUnhappyPath() {
        EndpointManager mgr = new EndpointManager();
        
        String nullName = mgr.getEndpointByName(null);
        System.assert(nullName == null);

        String emptyName = mgr.getEndpointByName('');
        System.assert(emptyName == null);

        boolean threwInvalidName = false;
        try {
            String invalidName = mgr.getEndpointByName('42');
        } catch(System.QueryException e) {
            threwInvalidName = true;
        }

        System.assert(threwInvalidName == true, 'Invalid name should have thrown an exception!');
    }
}