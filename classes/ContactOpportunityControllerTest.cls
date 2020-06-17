@IsTest
private class ContactOpportunityControllerTest {

    @IsTest
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
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        
        insert testAccount;

        Contact testContact = new Contact (
            AccountId = testAccount.Id,
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
        
        Opportunity openOpt = new Opportunity(
            AccountId = testAccount.Id,
            CloseDate = System.now().addDays(5).date(),
            Name = 'Test Opportunity',
            StageName = 'FSC - LM 1'
        );
        
        insert openOpt;
        
        OpportunityContactRole optContactRole = new OpportunityContactRole(
            ContactId = testContact.Id,
            OpportunityId = openOpt.Id
        );
        optContactRole.IsPrimary = true;

        insert optContactRole;

        Test.startTest();

        Map<String, Object> response = ContactOpportunityController.getContactOpportunities(testContact.id);
        System.assert(response != null, 'Response was null!');

        String error = (String)response.get('error');
        System.assert(error == null, 'Unexpected error : ' + error);

        List<Opportunity> opps = (List<Opportunity>)response.get('opportunities');
        System.assert(opps != null, 'Opportunities were null!');
        System.assert(opps.size() > 0, 'Opportunities size() was 0, expected > 0.');
        
        openOpt.StageName = 'FSC - Complete';
        update openOpt;
        
        response = ContactOpportunityController.getContactOpportunities(testContact.id);
        System.assert(response != null, 'Response was null!');

        error = (String)response.get('error');
        System.assert(error == null, 'Unexpected error : ' + error);

        opps = (List<Opportunity>)response.get('opportunities');
        System.assert(opps != null, 'Opportunities were null!');
        System.assert(opps.size() == 0, 'Opportunities size() == 0, was ' + opps.size());
        
        Test.stopTest();
    }
}