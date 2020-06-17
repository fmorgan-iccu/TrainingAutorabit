/**
 * Utility class for constructing urls
 */
public class URLConstructor {
	private String endpoint;
    private List<URLQueryItem> queryItems;
    
    public URLConstructor(String endpoint, List<URLQueryItem> queryItems) {
        this.endpoint = endpoint;
        this.queryItems = queryItems;
    }
    
    public String getEndpoint() {
        return this.endpoint;
    }
    
    public List<URLQueryItem> getQueryItems() {
        return this.queryItems;
    }
    
    public String constructURL() {
        if (this.endpoint == null) {
            return null;
        }
        
        String url = endpoint;
        
        if (this.queryItems != null && this.queryItems.size() > 0) {
            url = url + '?';

            integer count = 0;
            for (URLQueryItem item : this.queryItems) {
                String key = item.getKey();
                String value = item.getValue();
                
                if (key == null || value == null) { // No need to add this query item if it is null
                    continue;
                }

                String queryKey = EncodingUtil.URLENCODE(key, 'UTF-8');
                String queryValue = EncodingUtil.URLENCODE(value, 'UTF-8');

                if (count != 0) { // Need to prefix the next parameter with an ampersand
                    url = url + '&';
                }

                String kvpair = queryKey + '=' + queryValue;
                
                url = url + kvpair;
                
                count++;
            }
        }

        return url;
    }
}