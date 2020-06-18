@IsTest
private class AccessUtilsTest {

    @IsTest
    private static void testGetProfileNameFromId() {
        Test.startTest();
        
        String profileName = AccessUtils.getProfileName('00ei0000001i6p2');
        
        Test.stopTest();
        
        System.assertEquals(profileName, 'MRA User');
    }
}