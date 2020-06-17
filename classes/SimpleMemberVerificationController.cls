public class SimpleMemberVerificationController {
    @TestVisible
	private static INetworkFactory networkFactory;
    
    @AuraEnabled
    public static Map<String, Object> getMemberVerificationQuestions(String contactId) {
        if (contactId == null) {

            Map<String, Object> response = new Map<String, Object>();
            response.put('identifyingQuestions', null);
            response.put('walletQuestions', null);
            response.put('error', 'The contact ID cannot be null.');

            return response;
        }
        
        if (SimpleMemberVerificationController.networkFactory == null) {
            SimpleMemberVerificationController.networkFactory = new ConcreteNetworkProvider();
        }
        
        INetworkFactory networkFactory = SimpleMemberVerificationController.networkFactory;
        IPersonDataProvider personDataProvider = networkFactory.getPersonDataProvider();
        
        Contact contact = [
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
            WHERE ID = :contactId
            LIMIT 1
        ];

        List<String> acceptableJointRoleCodes = new List<String>();
        acceptableJointRoleCodes.add('OWN');
        acceptableJointRoleCodes.add('POD');
        integer merchantFrequencyThresholdCount = 4;
        integer numberOfRecentTransactions = 5;
        DateTime transactionEndDate = System.now();
        DateTime transactionStartDate = transactionEndDate.addDays(-30);

        PersonVerificationConfiguration config = new PersonVerificationConfiguration(acceptableJointRoleCodes, merchantFrequencyThresholdCount, numberOfRecentTransactions, transactionEndDate, transactionStartDate);
        
        try {
            PersonVerificationQuestionGroup questionGroup = personDataProvider.getVerificationQuestions(new SFPerson(contact), config);
            
            Map<String, Object> response = new Map<String, Object>();
            List<Map<String, Object>> identQuestions = new List<Map<String, Object>>();
            List<Map<String, Object>> walletQuestions = new List<Map<String, Object>>();
            List<Map<String, Object>> passwordQuestions = new List<Map<String, Object>>();
            
            for (PersonVerificationQuestion question : questionGroup.getIdentifyingQuestions()) {
                Map<String, Object> mappedQuestion = SimpleMemberVerificationController.mapVerificationQuestion(question);
                identQuestions.add(mappedQuestion);
            }
            
            for (PersonVerificationQuestion question : questionGroup.getOutOfWalletQuestions()) {
                Map<String, Object> mappedQuestion = SimpleMemberVerificationController.mapVerificationQuestion(question);
                walletQuestions.add(mappedQuestion);
            }
            
            for (PersonVerificationQuestion question : questionGroup.getPhonePasswordQuestions()) {
                Map<String, Object> mappedQuestion = SimpleMemberVerificationController.mapVerificationQuestion(question);
                passwordQuestions.add(mappedQuestion);
            }

            response.put('identifyingQuestions', identQuestions);
            response.put('walletQuestions', walletQuestions);
            response.put('phonePasswordQuestions', passwordQuestions);
            response.put('error', null);
            
            return response;
        } catch (UnauthenticatedException e) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('identifyingQuestions', null);
            response.put('walletQuestions', null);
            response.put('phonePasswordQuestions', null);
            response.put('error', 'Please log into DNA.');
            
            return response;
        } catch (Exception e) {
            System.debug('Error getting questions: ' + e + e.getStackTraceString());
            
            Map<String, Object> response = new Map<String, Object>();
            response.put('identifyingQuestions', null);
            response.put('walletQuestions', null);
            response.put('phonePasswordQuestions', null);
            response.put('error', 'There was a problem getting verfication questions. Please try again later.');

            return response;
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> getMemberPassword(String contactId) {
        if (contactId == null) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('phonePasswordQuestions', null);
            response.put('error', 'The contact ID cannot be null.');

            return response;
        }
        
        if (SimpleMemberVerificationController.networkFactory == null) {
            SimpleMemberVerificationController.networkFactory = new ConcreteNetworkProvider();
        }
        
        INetworkFactory networkFactory = SimpleMemberVerificationController.networkFactory;
        IPersonDataProvider personDataProvider = networkFactory.getPersonDataProvider();
        
        Contact contact = [
            SELECT 
                PersonNumber__c
            FROM Contact 
            WHERE ID = :contactId
            LIMIT 1
        ];

        try {
            List<PersonVerificationQuestion> questions = personDataProvider.getPhonePassword(contact.PersonNumber__c);
            
            Map<String, Object> response = new Map<String, Object>();
            List<Map<String, Object>> passwordQuestions = new List<Map<String, Object>>();

            for (PersonVerificationQuestion question : questions) {
                Map<String, Object> mappedQuestion = SimpleMemberVerificationController.mapVerificationQuestion(question);
                passwordQuestions.add(mappedQuestion);
            }
			
            response.put('phonePasswordQuestions', passwordQuestions);
            response.put('error', null);
            
            return response;
        } catch (UnauthenticatedException e) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('phonePasswordQuestions', null);
            response.put('error', 'Please log into DNA.');
            
            return response;
        } catch (Exception e) {
            System.debug('Error getting phone password: ' + e + e.getStackTraceString());
            
            Map<String, Object> response = new Map<String, Object>();
            response.put('phonePasswordQuestions', null);
            response.put('error', 'There was a problem getting verfication questions. Please try again later.');
			
            return response;
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> updateMemberPhonePassword(String contactId, String password, String passwordHint) {
        Map<String, Object> response = new Map<String, Object>();
        
        if (contactId == null) {
            response.put('error', 'Contact ID is missing.');
            return response;
        }
        
        if (password == null || passwordHint == null) {
            response.put('error', 'Password nor password hint can be null.');
            return response;
        }
        
        if (password.length() == 0 || passwordHint.length() == 0) {
            response.put('error', 'Password nor password hint can be empty.');
            return response;
        }
        
        if (SimpleMemberVerificationController.networkFactory == null) {
            SimpleMemberVerificationController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = SimpleMemberVerificationController.networkFactory;
        IPersonDataProvider personDataProvider = networkFactory.getPersonDataProvider();

        Contact contact = [
            SELECT	
                FirstName, 
                LastName, 
                PersonNumber__c
            FROM Contact 
            WHERE ID = :contactId
            LIMIT 1
        ];

        SFPerson person = new SFPerson(contact);

        try {
            personDataProvider.updatePersonPhonePassword(person, password, passwordHint);
        } catch(Exception e) {
            response.put('error', 'Error updating phone password: ' + e);
            return response;
        }

        return response;
    }
    
    private static Map<String, Object> mapVerificationQuestion(PersonVerificationQuestion question) {
        Map<String, Object> mappedQuestion = new Map<String, Object>();
        mappedQuestion.put('question', question.getQuestion());
		mappedQuestion.put('answers', question.getAnswers());

        return mappedQuestion;
    }
}