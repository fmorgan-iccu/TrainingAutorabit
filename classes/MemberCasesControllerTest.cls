@isTest
private class MemberCasesControllerTest {
	@isTest
    private static void testHappyPath() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            TaxID__c = '000-00-0000'
        );
        
        insert testContact;
        
        Profile p = [
            SELECT
            	Id 
            FROM Profile
            WHERE Name='Standard User'
        ]; 

        User testUser = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='tes5674567tuser@e34534xample.com'
        );

        insert testUser;

        Case testOpenCase = new Case(
            Description = 'Test Case',
            Priority = 'High',
            Status = 'New',
            ContactId = testContact.Id,
            OwnerId = testUser.Id
        );

        insert testOpenCase;

        Test.startTest();

        List<Case> openCases = MemberCasesController.getOpenMemberCases(testContact.Id);
        System.assert(openCases.size() == 1);
        
        Case openCase = openCases[0];
        System.assert(openCase.Owner.name != null);

        List<Case> closedCases = MemberCasesController.getClosedMemberCases(testContact.Id);
        System.assert(closedCases.size() == 0);

        Test.stopTest();
    }
    
    @isTest
    private static void testUnhappyPath() {
        try {
            MemberCasesController.getOpenMemberCases(null);
            System.assert(false, 'Should have thrown an exception.');
        } catch(Exception e) {
            System.assert(true);
        }

        try {
            MemberCasesController.getClosedMemberCases(null);
            System.assert(false, 'Should have thrown an exception.');
        } catch(Exception e) {
            System.assert(true);
        }
    }
}