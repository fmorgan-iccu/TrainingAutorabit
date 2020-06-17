public class CacheManagerFactory {
    private static String ORG_PARTITION_NAME = 'local.OrgCache';
    
    public static ICacheManager getOrgInstance() {
        OrgCacheManager orgCacheManager = new OrgCacheManager(CacheManagerFactory.ORG_PARTITION_NAME);
        return orgCacheManager;
    }
    
    private class OrgCacheManager implements ICacheManager {
        private String partitionName;
        
        public OrgCacheManager(String partitionName) {
            this.partitionName = partitionName;
        }
        
        public void cacheData(String key, Object data, DateTime expiration) {
            Long milliseconds = (expiration.getTime() - System.now().getTime());
            Integer seconds = (Integer)(milliseconds / 1000);
            
            Integer minimumCacheDuration = 300; // SalesForce minimum duration
            
            if (seconds < minimumCacheDuration) {
                seconds = minimumCacheDuration;
            }
            
            Cache.OrgPartition orgPart = this.getPartition();
            orgPart.put(key, data, seconds, Cache.Visibility.ALL, false);
        }
        
        public Object getCachedData(String key) {
            Cache.OrgPartition orgPart = this.getPartition();
            Object data = orgPart.get(key);
            
            return data;
        }
        
        public void removeCachedData(String key) {
            Cache.OrgPartition orgPart = this.getPartition();
            orgPart.remove(key);
        }
        
        public void removeAll() {
            Set<String> keys = this.getAllCacheKeys();
            
            for (String key : keys) {
                this.removeCachedData(key);
            }
        }
        
        public Set<String> getAllCacheKeys() {
            Cache.OrgPartition orgPart = this.getPartition();
            Set<String> keys = orgPart.getKeys();
            
            return keys;
        }
        
        private Cache.OrgPartition getPartition() {
            Cache.OrgPartition orgPart = Cache.Org.getPartition(this.partitionName);
            return orgPart;
        }
    }
}