/**
 *	Represents an Encompass OAuth token
 */
public class EncompassToken {
	private String token;
    private String tokenType;
    private DateTime expirationDate;
    
    public EncompassToken(String token, String tokenType, DateTime expirationDate) {
        this.token = token;
        this.tokenType = tokenType;
        this.expirationDate = expirationDate;
    }
    
    public String getToken() {
        return this.token;
    }
    
    public String getTokenType() {
        return this.tokenType;
    }
    
    public DateTime getExpirationDate() {
        return this.expirationDate;
    }
}