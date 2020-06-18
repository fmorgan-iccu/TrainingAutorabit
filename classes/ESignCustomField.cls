/**
 * Model object representing custom data associated with an envelope.
 */
public class ESignCustomField {
	/**
     * key The key of the text data.
     */
    public String key { get; private set; }
        
    /**
     * value The value of the text data.
     */
    public String value { get; private set; }
        
    public ESignCustomField(String key, String value) {
        this.key = key;
        this.value = value;
    }
}