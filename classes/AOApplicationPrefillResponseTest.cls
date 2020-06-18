@isTest
private class AOApplicationPrefillResponseTest {
	@isTest
    private static void testHappyPath() {
        String url = 'https://iccu.com';
        AccountOpeningApplicationPrefillResponse response = new AccountOpeningApplicationPrefillResponse(url);
        
        System.assert(url.equals(response.getPrefillURL()));
    }
}