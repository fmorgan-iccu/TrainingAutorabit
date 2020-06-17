@IsTest
private class CacheManagerFactoryTest {
    @IsTest
    private static void testOrgImpl() {
        ICacheManager cacheManager = CacheManagerFactory.getOrgInstance();
        
        String dataObjectKey = 'somekey';
        String data = 'Hello!';
        
        DateTime expiration = System.now().addDays(2);
        
        // Testing adding something and pulling it back out
        String cacheKey = 'cacheKey';
        cacheManager.cacheData(cacheKey, data, expiration);
        
        String cachedData = (String)cacheManager.getCachedData(cacheKey);
        
        System.assert(cachedData != null, 'Cached data was null!');
        
        String expectedDataObject = data;
        
        System.assert(expectedDataObject != null, 'Expected data object was null!');
        System.assert(cachedData.equals(expectedDataObject));
        
        /*
            NOTE: removing this test case because SF's minimum cache duration is 300 seconds (5 minutes), so really can't be tested in a unit test...
            // Testing old data not getting returned
            DateTime testExpiration = System.now().addSeconds(2);
            
            cacheManager.cacheData(cacheKey, data, testExpiration);
            
            DateTime sleepExpiration = testExpiration.addSeconds(1);
            
            while (sleepExpiration >= System.now()) {
            // Poor man's thread.sleep()
            }

            String expiredData = (String)cacheManager.getCachedData(cacheKey);
            System.assert(expiredData == null, 'Expected null data because it should be expired.  It was not. Expiration: ' + testExpiration + ' Now: '+ System.now());
        */
        
        // Testing removing data
        expiration = System.now().addDays(2);
        cacheManager.cacheData(cacheKey, data, expiration);
        cacheManager.removeCachedData(cacheKey);
        
        String removedData = (String)cacheManager.getCachedData(cacheKey);
        System.assert(removedData == null, 'Expected null data because it was removed.  It was not.');
        
        // Testing removing ALL data
        cacheManager.cacheData(cacheKey, data, expiration);
        cacheManager.removeAll();
        
        String clearedData = (String)cacheManager.getCachedData(cacheKey);
        System.assert(clearedData == null, 'Expected null data because it was removed.  It was not.');
        
        // Testing getting all cache keys
        cacheManager.cacheData(cacheKey, data, expiration);
        Set<String> keys = cacheManager.getAllCacheKeys();
        
        System.assert(keys != null, 'Keys were null!');
        System.assert(keys.size() == 1);
        System.assert(keys.contains(cacheKey), 'Key set does not contain key (' + cacheKey + ').');
    }
}