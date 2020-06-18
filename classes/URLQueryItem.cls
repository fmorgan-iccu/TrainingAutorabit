/*
 * Class for modeling a query parameter in a URL.  Since valid URL query items can repeat, we can't really use
 * a map for storing values.
 */
public class URLQueryItem {
	private String key;
    private String value;
    
    public URLQueryItem(String key, String value) {
        this.key = key;
        this.value = value;
    }
    
    public String getKey() {
        return this.key;
    }
    
    public String getValue() {
        return this.value;
    }
}