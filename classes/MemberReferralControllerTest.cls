@isTest
private class MemberReferralControllerTest {
	@isTest
    private static void testHappyPath() {
        Profile p = [
            SELECT
            	Id 
            FROM Profile
            WHERE Name='FSC User'
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
        
        Test.startTest();
        
        Map<String, Object> response = MemberReferralController.fetchFormData();
        System.assert(response.get('currentUserName') != null);
        System.assert(response.get('fscUsers') != null);
        
        Test.stopTest();
    }
}