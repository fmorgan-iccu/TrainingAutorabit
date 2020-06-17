/**
 * Class for managing information in session on a per-user basis. 
 * 
 * Technical design notes:
 * It might be a bit curious why we are wrapping String keys to the cache with a `CacheKey` object.  From the 
 * outset this may appear that it isn't buying us a whole bunch and increasing complexity: new entries will 
 * require new values to be added to this class. And therein lies the reason: session cache is not something 
 * we should be adding items to haphazardly.  It really should be added scrutiny and oversight.  This exists 
 * as a 'review gate' that should invite further discussion before implementing.
 * 
 */
public class UserSessionCache {

    @TestVisible
    private static String CACHE_KEY_CCM = 'CCMToken';
    private static String CACHE_KEY_DNA_TICKET = 'DNATicket';
    private static String CACHE_KEY_DNA_TOKEN = 'DNAToken';
    @TestVisible
    private static String CACHE_KEY_OFFLINE_MODE = 'OfflineMode';
    
    public static final CacheKey CCM = new CacheKey(CACHE_KEY_CCM, true, 28800, false);
    public static final CacheKey DNA_TICKET = new CacheKey(CACHE_KEY_DNA_TICKET, true, 28800, true);
    public static final CacheKey DNA_TOKEN = new CacheKey(CACHE_KEY_DNA_TOKEN, true, 3600, false);
    public static final CacheKey OFFLINE_MODE = new CacheKey(CACHE_KEY_OFFLINE_MODE, false, 28800, false);

    private static final String PARTITION_NAME = 'local.UserCache';
    
    @TestVisible
    private Cache.SessionPartition cachePartition;


    public UserSessionCache() {
        this.cachePartition = Cache.Session.getPartition(UserSessionCache.PARTITION_NAME);
    }

    public void setValue(String value, CacheKey cacheKey) {
        if (cacheKey == null || cacheKey.keyName == null) { // Sanity check
            return;
        }
        
        if (value == null) { // Null == remove
            this.cachePartition.remove(cacheKey.keyName);
            return;
        }

        String processedToken = cacheKey.encrypted ? CryptoUtils.encrypt(value) : value;
        if (processedToken == null) { // Sanity check
            System.debug('Unable to encrypt token...');
            return;
        }

        this.cachePartition.put(cacheKey.keyName, processedToken, cacheKey.timeToLive);
    }
    
    public String getValue(CacheKey cacheKey) {
        if (cacheKey == null || cacheKey.keyName == null) { // Sanity check
            return null;
        }

        String token = String.valueOf(this.cachePartition.get(cacheKey.keyName));

        // Auto refreshing the value stored in the platform cache can allow for values to remain
        // in the cache for longer than the 8 hour maximum.
        if (cacheKey.autoRefreshTTL && token != null) {
            this.cachePartition.put(cacheKey.keyName, token, cacheKey.timeToLive);
        }

        if (cacheKey.encrypted && token != null) {
            token = CryptoUtils.decrypt(token);
        }

        return token;
    }

    /**
     * Helper class
     */

    public class CacheKey {
        public String keyName { get; private set; }
        Boolean encrypted { get; private set; }
        Integer timeToLive { get; private set; }
        Boolean autoRefreshTTL { get; private set; }

        private CacheKey(String keyName, Boolean encrypted, Integer timeToLive, Boolean autoRefreshTTL) {
            this.keyName = keyName;
            this.encrypted = encrypted;
            this.timeToLive = timeToLive;
            this.autoRefreshTTL = autoRefreshTTL;
        }
    }

}