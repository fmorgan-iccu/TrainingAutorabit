@IsTest
private class UserSessionCacheTest {
	@IsTest
    private static void tesHappyPath() {
        UserSessionCache cache = new UserSessionCache();
        
        // Test setting an encrypted token
        String token = 'secret token';
        cache.setValue(token, UserSessionCache.CCM);
        String fetchedToken = cache.getValue(UserSessionCache.CCM);
        System.assertEquals(token, fetchedToken);

        // Test a that the token is stored encrypted
        fetchedToken = String.valueOf(cache.cachePartition.get(UserSessionCache.CACHE_KEY_CCM));
        System.assertNotEquals(token, fetchedToken);

        // Test clearing the token
        cache.setValue(null, UserSessionCache.CCM);
		fetchedToken = cache.getValue(UserSessionCache.CCM);
        System.assert(fetchedToken == null, 'Expected token to be null, but it was not!');

        // Test adding it back after clearing it
        cache.setValue(token, UserSessionCache.CCM);
        fetchedToken = cache.getValue(UserSessionCache.CCM);
        System.assertEquals(token, fetchedToken);

        // Test a non-encrypted token
        cache.setValue(token, UserSessionCache.OFFLINE_MODE);
        fetchedToken = String.valueOf(cache.cachePartition.get(UserSessionCache.CACHE_KEY_OFFLINE_MODE));
        System.assertEquals(token, fetchedToken);
    }
}