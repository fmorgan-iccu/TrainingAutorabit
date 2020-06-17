@isTest
private class SimpleMemberVerificationControllerTest {
    
    @isTest
    private static void testHappyPath() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),  	
            MemberNumber__c = '23423987', 	
            Email = 'something@example.com',	
            FirstName = 'Jack', 
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555', 	
            TaxID__c = '000-00-0000', 
            PersonNumber__c = 'HELIX1',             	 
            Phone = '(555) 555-5555'
        );
        
        insert testContact;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        IPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();
        System.assert(gottenAuthManager != null);
        
        SimpleMemberVerificationController.networkFactory = new ConcreteNetworkProvider(authManager);

        Map<String, Object> questionMap = SimpleMemberVerificationController.getMemberVerificationQuestions(testContact.Id);
        List<Object> identQuestions = (List<Object>)questionMap.get('identifyingQuestions');
        List<Object> walletQuestions = (List<Object>)questionMap.get('walletQuestions');
        List<Object> passwordQuestions = (List<Object>)questionMap.get('phonePasswordQuestions');

		String error = (String)questionMap.get('error');

        System.assert(error == null, error);
        System.assert(identQuestions != null);
        System.assert(walletQuestions != null);
        System.assert(passwordQuestions != null);

        String password = 'password';
        String passwordHint = 'passwordHint';
        SimpleMemberVerificationController.updateMemberPhonePassword(testContact.Id, password, passwordHint);

        try {
            Map<String, Object> phonePasswordQuestions = SimpleMemberVerificationController.getMemberPassword(testContact.Id);
            passwordQuestions = (List<Object>)questionMap.get('phonePasswordQuestions');
            
            System.assert(passwordQuestions != null);
            
            Integer expectedSize = 2;
            Integer actualSize = passwordQuestions.size();
            
            System.assertEquals(expectedSize, actualSize);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void testUnhappyPath() {
        Contact insertedContact = new Contact (
            Birthdate = Date.today(),  	
            MemberNumber__c = '23423987', 	
            Email = 'something@example.com',	
            FirstName = 'Jack', 
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555', 	
            TaxID__c = '000-00-0000', 
            PersonNumber__c = 'HELIX1',             	 
            Phone = '(555) 555-5555'
        );
        
        insert insertedContact;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        authManager.logout();

        SimpleMemberVerificationController.networkFactory = new ConcreteNetworkProvider(authManager);

        Map<String, Object> nullQuestionMap = SimpleMemberVerificationController.getMemberVerificationQuestions(null);        
        System.assert(nullQuestionMap.get('error') != null);
        
        Contact testContact = [
            SELECT 
                Birthdate,  	
                MemberNumber__c, 	
                Email,	
                FirstName, 
                LastName, 
                MailingStreet, 
                MailingCity, 
                MailingState, 
                MailingPostalCode,
                MobilePhone, 	
                TaxID__c, 
                PersonNumber__c,             	 
                Phone	
            FROM Contact
            LIMIT 1
        ];
        
        // Testing unauthenticated exception thrown.
        Map<String, Object> questionMap = SimpleMemberVerificationController.getMemberVerificationQuestions(testContact.Id);
        List<Object> identQuestions = (List<Object>)questionMap.get('identifyingQuestions');
        List<Object> walletQuestions = (List<Object>)questionMap.get('walletQuestions');

        System.assert(questionMap.get('error') != null);
        System.assert(identQuestions == null);
        System.assert(walletQuestions == null);
        
		Map<String, Object> nullPersonPasswordResponse = SimpleMemberVerificationController.updateMemberPhonePassword(null, 'password', 'passwordHint');
        System.assert(nullPersonPasswordResponse.get('error') != null);
        Map<String, Object> nullPasswordResponse = SimpleMemberVerificationController.updateMemberPhonePassword(testContact.Id, null, 'passwordHint');
        System.assert(nullPasswordResponse.get('error') != null);
        Map<String, Object> nullPasswordHintResponse = SimpleMemberVerificationController.updateMemberPhonePassword(testContact.Id, 'password', null);
        System.assert(nullPasswordHintResponse.get('error') != null);
        Map<String, Object> emptyPasswordResponse = SimpleMemberVerificationController.updateMemberPhonePassword(testContact.Id, '', 'passwordHint');
        System.assert(emptyPasswordResponse.get('error') != null);
        Map<String, Object> emptyPasswordHintResponse = SimpleMemberVerificationController.updateMemberPhonePassword(testContact.Id, 'password', '');
        System.assert(emptyPasswordHintResponse.get('error') != null);
        
        Test.stopTest();
    }
}