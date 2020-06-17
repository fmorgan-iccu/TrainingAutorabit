public class ResourceOwnerCredential implements IAuthenticationCredential {
	private String apiClientID;
    private String apiClientSecret;
    private String instanceID;
    private String username;
    private String password;

    public ResourceOwnerCredential(String apiClientID, String apiClientSecret, String instanceID, String username, String password) {
        this.apiClientID = apiClientID;
        this.apiClientSecret = apiClientSecret;
        this.instanceID = instanceID;
        this.username = username;
        this.password = password;
    }

    public String getApiClientID() {
        return this.apiClientID;
    }

    public String getApiClientSecret() {
        return this.apiClientSecret;
    }

    public String getInstanceID() {
        return this.instanceID;
    }

    public String getUsername() {
        return this.username;
    }

    public String getPassword() {
        return this.password;
    }
}