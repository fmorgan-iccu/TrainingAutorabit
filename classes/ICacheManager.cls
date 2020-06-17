public interface ICacheManager {
	void cacheData(String key, Object data, DateTime expiration);
    Object getCachedData(String key);
    void removeCachedData(String key);
    void removeAll();
    Set<String> getAllCacheKeys();
}