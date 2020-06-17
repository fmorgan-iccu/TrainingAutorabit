@isTest
private class MemberApplicationsControllerTest {
    @isTest
    private static void testHappyPath() {
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Name FROM User WHERE Id = : currentUserId];
        
        User testUser = null;
        
        // Have to create a test user as the current user so that we can run other things as a different user.
        System.runAs(currentUser) {
            UserRole testRole = new UserRole(
                DeveloperName = 'MyCustomRole',
                Name = 'FSC User'
            );
            insert testRole;
            
            testUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name='FSC User'].Id,
                FirstName = 'first',
                LastName = 'last',
                Email = 'testuser@iccu.com',
                Username = 'testuser@iccu.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Denver',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = testRole.Id
            );
            insert testUser;
        }

        Contact testContact = new Contact (
            Birthdate = Date.today(),  	
            MemberNumber__c = '234239878', 	
            Email = 'something@example.com',	
            FirstName = 'Jack', 
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555', 	
            TaxID__c = '666-66-6667', 
            PersonNumber__c = '123456A',             	 
            Phone = '(555) 555-5555'
        );
        insert testContact;

        ServiceAccounts__c encompassService = new ServiceAccounts__c(
            APIClientID__c = 'client id',
            APIClientSecret__c = 'secret',
            InstanceID__c = 'BE11167800',
            Name = 'Encompass',
            Password__c = 'password',
            ServiceName__c = 'Encompass',
            Username__c = 'sasalesforce'
        );
        insert encompassService;

        Test.setMock(HttpCalloutMock.class, new MockProductApplicationResponse());
        
        Test.startTest();
        
        ResourceOwnerCredential credential = new ResourceOwnerCredential('apiClientID', 'apiClientSecret', 'instanceID', 'username', 'password');
        EncompassAuthenticationManager mgr = new EncompassAuthenticationManager(credential, new EncompassTokenManager());
        INetworkFactory networkFactory = new ConcreteNetworkProvider(mgr);
        MemberApplicationsController.networkFactory = networkFactory;
        
        System.runAs(testUser) {
            Map<String, Object> response = MemberApplicationsController.getOpenApplications(testContact.Id);
            String error = (String)response.get('error');
            List<Map<String, Object>> rawApplications = (List<Map<String, Object>>)response.get('applications');
            boolean showApplicationDetails = (boolean)response.get('showApplicationDetails');
            
            System.assert(response != null);
            System.assert(error == null, 'Error: ' + error);
            System.assert(rawApplications != null);
            System.assert(showApplicationDetails != null);
            System.assert(showApplicationDetails == true); // This user is an FSC person, so it should be true

            for (Map<String, Object> rawApp : rawApplications) {
                List<Map<String, Object>> rawMilestones = (List<Map<String, Object>>)rawApp.get('milestones');
                System.assert(rawMilestones != null);
                
                for (Map<String, Object> milestone : rawMilestones) {
                    Map<String, Object> agent = (Map<String, Object>)milestone.get('agent');
                    
                    if (agent != null) {
                        System.assert(agent.get('name') != null);
                    }
                    
                    System.assert(milestone.get('displayName') != null);
                    System.assert(milestone.get('isComplete') != null);
                    System.assert(milestone.get('isCurrentMilestone') != null);
                }
                
                Map<String, Object> rawAgent = (Map<String, Object>)rawApp.get('agent');
                
                if (rawAgent != null) {
                    System.assert(rawAgent.get('name') != null);
                }
                
                System.assert(rawApp.get('applicationNumber') != null);
                System.assert(rawApp.get('milestones') != null);
                System.assert(rawApp.get('notes') != null);
                System.assert(rawApp.get('productName') != null);
                System.assert(rawApp.get('status') != null);
                System.assert(rawApp.get('systemName') != null);
                
                List<Map<String, Object>> rawNotes = (List<Map<String, Object>>)rawApp.get('notes');
                for (Map<String, Object> rawNote : rawNotes) {
                    System.assert(rawNote.get('createdDate') != null);
                    System.assert(rawNote.get('text') != null);
                    System.assert(rawNote.get('title') != null);
                }
            }
        }
        
        
        Test.stopTest();
    }
    
    @isTest
    private static void testUnhappyPath() {
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            TaxID__c = '666-66-6666'
        );
        insert contact;
        
        Test.startTest();
        
        ResourceOwnerCredential credential = new ResourceOwnerCredential('apiClientID', 'apiClientSecret', 'instanceID', 'username', 'password');
        EncompassAuthenticationManager mgr = new EncompassAuthenticationManager(credential, new EncompassTokenManager());
        INetworkFactory networkFactory = new ConcreteNetworkProvider(mgr);
        MemberApplicationsController.networkFactory = networkFactory;
        
        Map<String, Object> response = MemberApplicationsController.getOpenApplications(null);
        String nullError = (String)response.get('error');
        System.assert(nullError != null);

        response = MemberApplicationsController.getOpenApplications(null);
        String noSSNError = (String)response.get('error');
        System.assert(noSSNError != null, 'Should have errored out because no SSN.');
        
        test.stopTest();
    }
}