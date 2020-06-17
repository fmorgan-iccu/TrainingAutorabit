/*
 * Class for managing an Encompass OAuth token.
 */
public class EncompassTokenManager implements IEncompassTokenManager {
    @TestVisible
    private static EncompassToken sharedToken;

    public EncompassTokenManager() {
        
    }

    /*
     * Store the OAuth token.
     * @param token The EncompassToken to store
     * Note: Because the token has short life, we're not going to put it in session or anything.  We'll fetch it and share it amongst all clients, renewing when necessary.
     */
    public void setToken(EncompassToken token) {
        EncompassTokenManager.sharedToken = token;
    }

    /*
     * Retrieves the stored token.
     */
    public EncompassToken getToken() {
        EncompassToken token = EncompassTokenManager.sharedToken;
        
        if (token == null) {
            return null;
        }
        
        DateTime now = System.now();
        DateTime tokenExpiration = token.getExpirationDate();
        
        if (now > tokenExpiration) {
            this.clearToken();
            return null;
        }
        
        return token;
    }

    /*
     * Clears the token.
     */
    public void clearToken() {
        EncompassTokenManager.sharedToken = null;
    }
}