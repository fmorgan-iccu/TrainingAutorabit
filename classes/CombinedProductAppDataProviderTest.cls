@isTest
private class CombinedProductAppDataProviderTest {
    @isTest
    private static void testHappyPath() {
        ServiceAccounts__c serviceAccount = new ServiceAccounts__c(
            APIClientID__c = 'client',
            APIClientSecret__c = 'secret',
            InstanceID__c = 'instance',
            Name = 'Encompass',
            Password__c = 'password',
            Username__c = 'username',
            ServiceName__c = 'Encompass'
        );
        
        insert serviceAccount;
        
        Test.startTest();
        
        IAuthenticationManager crifAuthManager = new CRIFActionAuthenticationManager();
        CRIFActionDataProvider crifProvider = new CRIFActionDataProvider(crifAuthManager);

        boolean didCrifAuth = crifAuthManager.authenticateUser(null);
        System.assert(didCrifAuth);
        System.assert(crifAuthManager.isUserAuthenticated());
        crifAuthManager.logOut();

        ResourceOwnerCredential credential = new ResourceOwnerCredential('apiClientID', 'apiClientSecret', 'instanceID', 'username', 'password');
        Test.setMock(HttpCalloutMock.class, new MockProductApplicationResponse());
        EncompassTokenManager.sharedToken = new EncompassToken('token', 'tokenType', System.now().addMinutes(10));

        IAuthenticationManager encompassAuthManager = new EncompassAuthenticationManager(credential, new EncompassTokenManager());
        EncompassProductApplicationDataProvider encompassProvider = new EncompassProductApplicationDataProvider(encompassAuthManager, new EncompassTokenManager());
        
        List<IProductApplicationDataProvider> providers = new List<IProductApplicationDataProvider>();
        providers.add(crifProvider);
        providers.add(encompassProvider);

        DNAPerson person = new DNAPerson('personNumber', 'String memberNumber', 'String preferredName', null, 'String firstName', 'String middleName', 'String lastName', 'String taxId', Date.today(), 'String homePhoneNumber', 'String mobilePhoneNumber', 'String emailAddress', Date.today(), 'String driversLicenseNumber');

        CombinedProductApplicationDataProvider combinedProvider = new CombinedProductApplicationDataProvider(providers);
        ProductApplicationResponse response = combinedProvider.getOpenProductApplications(person, null, null);
        List<IProductApplication> applications = response.getApplications();
        
        System.assert(applications != null, 'Applications was null!');
        
        IAuthenticationManager combinedManager = combinedProvider.getAuthenticationManager();
        System.assert(combinedManager != null);

        boolean didCombinedAuth = combinedProvider.authenticateUser(null);
        
        System.assert(didCombinedAuth);
        System.assert(combinedProvider.isUserAuthenticated());

        String tokenValue = 'value';
        String tokenType = 'tokenType';
        DateTime expiration = System.now().addMinutes(5);
        EncompassToken encompassToken = new EncompassToken(tokenValue, tokenType, expiration);
        
        System.assert(encompassToken.getToken().equals(tokenValue));
        System.assert(encompassToken.getTokenType().equals(tokenType));
        System.assert(encompassToken.getExpirationDate() == expiration);
        
        EncompassTokenManager tokenManager = new EncompassTokenManager();
        tokenManager.setToken(encompassToken);
        System.assert(tokenManager.getToken() != null);
        
        tokenManager.clearToken();
        System.assert(tokenManager.getToken() == null);
        
        // For coverage... ^_^
        System.assert(combinedProvider.getSystemName() != null);
        combinedProvider.logOut();

        Test.stopTest();
    }
    
    @isTest
    private static void testProductApplications() {
        Test.setMock(HttpCalloutMock.class, new MockProductApplicationResponse());
        
        String agentName = 'Agent';
        String agentPhone = '555-555-5555';
        String agentEmail = 'e@example.com';
        String agentExtension = 'x2343';
        boolean isLoanOfficer = true;

        ProductApplicationAgent agent = new ProductApplicationAgent(agentEmail, isLoanOfficer, agentName, agentPhone);

        System.assert(agent.getName().equals(agentName));
        System.assert(agent.getEmailAddress().equals(agentEmail));
        System.assert(agent.getPhone().equals(agentPhone));
        System.assert(agent.isLoanOfficer());
        
        agent = new ProductApplicationAgent(agentEmail, agentExtension, isLoanOfficer, agentName, agentPhone);
        
        System.assert(agent.getName().equals(agentName));
        System.assert(agent.getExtension().equals(agentExtension));
        System.assert(agent.getEmailAddress().equals(agentEmail));
        System.assert(agent.isLoanOfficer());
        System.assert(agent.getPhone().equals(agentPhone));

        String applicationNumber = '1234565';
        String productName = 'asdfasdf';
        String status = 'status';
        
        /*private ProductApplicationAgent agent;
	private DateTime createdDate;
    private String text;
    private String title;
    private DateTime updatedDate;*/

		DateTime noteCreatedDate = System.now().addMinutes(5);
        String text = 'text';
        String title = 'title';
        DateTime noteUpdatedDate = System.now().addMinutes(-5);
        
        List<ProductApplicationNote> notes = new List<ProductApplicationNote>();
        ProductApplicationNote note = new ProductApplicationNote(agent, noteCreatedDate, text, title, noteUpdatedDate);
        notes.add(note);
        
        System.assert(agent == note.getAgent());
        System.assert(noteCreatedDate == note.getCreatedDate());
        System.assert(text.equals(note.getText()));
        System.assert(title.equals(note.getTitle()));
        System.assert(noteUpdatedDate == note.getUpdatedDate());

        String milestoneName = 'completed';
        boolean isComplete = true;
        boolean isCurrentMilestone = true;
        DateTime statusDate = System.now();
        ProductApplicationMilestone milestone = new ProductApplicationMilestone(agent, milestoneName, isComplete, isCurrentMilestone, statusDate);

        System.assert(milestone.getAgent() != null);
        System.assert(milestone.getDisplayName().equals(milestoneName));
        System.assert(milestone.getIsComplete() == isComplete);
        System.assert(milestone.getIsCurrentMilestone() == isCurrentMilestone);
        System.assert(milestone.getStatusDate() == statusDate);
        
        milestone.setIsCurrentMilestone(!isCurrentMilestone);
        System.assert(milestone.getIsCurrentMilestone() == !isCurrentMilestone);

        List<ProductApplicationMilestone> milestones = new List<ProductApplicationMilestone>();
        milestones.add(milestone);
        
        boolean isFunded = true;
        boolean isAppComplete = true;
        integer creditScore = 750;

        IProductApplication crifApp = new CRIFActionProductApplication(agent, applicationNumber, creditScore, isAppComplete, isFunded, agent, milestones, notes, productName, status);
        IProductApplication encompassApp = new EncompassProductApplication(agent, applicationNumber, creditScore, isAppComplete, isFunded, agent, milestones, notes, productName, status);

        List<IProductApplication> applications = new List<IProductApplication>();
        applications.add(crifApp);
        applications.add(encompassApp);

        for (IProductApplication app : applications) {
            System.assert(app.getAgent() != null);
            System.assert(app.getApplicationNumber().equals(applicationNumber));
            System.assert(app.getCreditScore() == creditScore);
            System.assert(app.getIsComplete() == isAppComplete);
            System.assert(app.getIsFunded() == isFunded);
            System.assert(app.getMilestones() != null);
            System.assert(app.getProductName().equals(productName));
            System.assert(app.getStatus().equals(status));
            System.assert(app.getSystemName() != null);
            System.assert(app.getLoanOfficer() != null);
        }
        
        List<String> errors = new List<String>();

        ProductApplicationResponse response = new ProductApplicationResponse(applications, errors);
        System.assert(response.getApplications() == applications);
        System.assert(response.getErrors() == errors);
    }
    
    @isTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockProductApplicationResponse());

        IAuthenticationManager crifAuthManager = new CRIFActionAuthenticationManager();
        CRIFActionDataProvider crifProvider = new CRIFActionDataProvider(crifAuthManager);

        boolean didCrifAuth = crifAuthManager.authenticateUser(null);
        System.assert(didCrifAuth);
        System.assert(crifAuthManager.isUserAuthenticated());
        crifAuthManager.logOut();

        ResourceOwnerCredential credential = new ResourceOwnerCredential('apiClientID', 'apiClientSecret', 'instanceID', 'username', 'password');
        
        EncompassTokenManager.sharedToken = new EncompassToken('token', 'tokenType', System.now().addMinutes(10));
        
        IAuthenticationManager encompassAuthManager = new EncompassAuthenticationManager(credential, new EncompassTokenManager());
        EncompassProductApplicationDataProvider encompassProvider = new EncompassProductApplicationDataProvider(encompassAuthManager, new EncompassTokenManager());
        
        List<IProductApplicationDataProvider> providers = new List<IProductApplicationDataProvider>();
        providers.add(crifProvider);
        providers.add(encompassProvider);

        DNAPerson nullTaxIdPerson = new DNAPerson('personNumber', 'String memberNumber', 'String preferredName', null, 'String firstName', 'String middleName', 'String lastName', null, Date.today(), 'String homePhoneNumber', 'String mobilePhoneNumber', 'String emailAddress', Date.today(), 'String driversLicenseNumber');

        CombinedProductApplicationDataProvider combinedProvider = new CombinedProductApplicationDataProvider(providers);

        try {
            ProductApplicationResponse response = combinedProvider.getOpenProductApplications(null, null, null);
            System.assert(false, 'Should have thrown an exception.');
        } catch (IllegalArgumentException e) {
            System.assert(true);
        }
        
        try {
			ProductApplicationResponse response = combinedProvider.getOpenProductApplications(nullTaxIdPerson, null, null);
            System.assert(false, 'Should have thrown an exception.');
        } catch (IllegalArgumentException e) {
            System.assert(true);
        }
        
        ProductApplicationResponse response = new ProductApplicationResponse(null, null);
        System.assert(response.getApplications() != null);
        System.assert(response.getErrors() != null);
        
    }
}