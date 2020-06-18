/**
 * Convenience class for mapping DNA Account types codes to a display name.
 */
public class DNAAccountTypeCode {
	private String code;
    private String displayName;

    public DNAAccountTypeCode(String code, String displayName) {
        this.code = code;
        this.displayName = displayName;
    }
    
    public String getCode() {
        return this.code;
    }
    
    public String getDisplayName() {
        return this.displayName;
    }
}