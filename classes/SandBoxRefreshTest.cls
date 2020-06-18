@IsTest
public class SandBoxRefreshTest {

    @IsTest
    private static void testRefresh() {

        // Setup a test user to ensure that it is updated properly.
        Id sysAdminId = [SELECT id FROM Profile WHERE Name = 'System Administrator'][0].id;
        User adminUser = new User(
            alias='dbunique',
            email='dbarnett@iccu.com.invalid',
            emailEncodingKey='ISO-8859-1',
            isActive=false,
            lastName='Barnett',
            languageLocaleKey='en_US',
            localeSidKey='en_US',
            profileId=sysAdminId,
            timeZoneSidKey='America/Denver',
            username='dbarnett@iccu.com.sandbox'
        );
        System.debug(adminUser);
        insert adminUser;


        Test.startTest();
        SandBoxRefresh sbr = new SandBoxRefresh();
        sbr.runApexClass(null);
        Test.stopTest();

        // Assert the behavior
        List<User> admins = [
            SELECT id,
                email,
                isActive
            FROM User
            WHERE username = 'dbarnett@iccu.com.sandbox'
        ];
        System.assertEquals(1, admins.size());
        //System.assertEquals('dbarnett@iccu.com', admins[0].email); // This can't be done because Salesforce requires email confirmation
        System.assertEquals(true, admins[0].isActive);
    }

}