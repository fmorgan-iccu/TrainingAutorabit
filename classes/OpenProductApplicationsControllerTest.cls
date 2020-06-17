@isTest
private class OpenProductApplicationsControllerTest {
	@isTest
    private static void testHappyPath() {
        ServiceAccounts__c avokaTMServiceAccount = new ServiceAccounts__c(
            APIClientID__c = 'client2',
            APIClientSecret__c = 'secret2',
            InstanceID__c = 'instance2',
            Name = 'AvokaTM',
            Password__c = 'password2',
            Username__c = 'username2',
            ServiceName__c = 'AvokaTM'
        );

        insert avokaTMServiceAccount;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockAvokaTMResponse());
        
        Map<String, Object> response = OpenProductApplicationsController.fetchApplicationsByStatus('Opened');
        String error = (String)response.get('error');
        
        System.assert(error == null, error);
        
        List<Map<String, Object>> groups = (List<Map<String, Object>>)response.get('groups');
        System.assert(groups != null, 'Groups were null!');
        
        for (Map<String, Object> transGroup : groups) {
            String title = (String)transGroup.get('title');
            System.assert(title != null);
            
            System.debug('TRANSACTIONS: ' + transGroup.get('transactions'));
            
            List<Map<String, Object>> transactions = (List<Map<String, Object>>)transGroup.get('transactions');
            System.assert(transactions != null);
            
            for (Map<String, Object> trans : transactions) {
                String formStatus = (String)trans.get('formStatus');
                String id = (String)trans.get('id');
                String trackingCode = (String)trans.get('trackingCode');
                
                System.assert(id != null, trans);
                System.assert(formStatus != null, trans);
                System.assert(trackingCode != null, trans);
            }
        }
        
        // Test getting all of them.
        response = OpenProductApplicationsController.fetchApplicationsByStatus(null);
        
        groups = (List<Map<String, Object>>)response.get('groups');
        System.assert(groups != null, 'Groups were null!');
        
        for (Map<String, Object> transGroup : groups) {
            String title = (String)transGroup.get('title');
            System.assert(title != null);

            List<Map<String, Object>> transactions = (List<Map<String, Object>>)transGroup.get('transactions');
            System.assert(transactions != null);
            
            for (Map<String, Object> trans : transactions) {
                String formStatus = (String)trans.get('formStatus');
                String id = (String)trans.get('id');
                String trackingCode = (String)trans.get('trackingCode');
                
                System.assert(id != null, trans);
                System.assert(formStatus != null, trans);
                System.assert(trackingCode != null, trans);
            }
        }
        
        Test.stopTest(); 
    }

    @isTest
    private static void testUnhappyPath() {
        
    }
}