/**
 *	Authentication manager for authenticating with Encompass.
 */
public with sharing class EncompassAuthenticationManager implements IAuthenticationManager {
    private IEncompassTokenManager tokenManager;
    private ResourceOwnerCredential resourceOwnerCredential;
    
    public EncompassAuthenticationManager(ResourceOwnerCredential resourceOwnerCredential, IEncompassTokenManager tokenManager) {
        this.tokenManager = tokenManager;
        this.resourceOwnerCredential = resourceOwnerCredential;
    }

	public boolean authenticateUser(IAuthenticationCredential credential) {
        if (this.resourceOwnerCredential != null) {
            credential = this.resourceOwnerCredential;
        } else if (credential == null || !(credential instanceof ResourceOwnerCredential)) {
            throw new IllegalArgumentException('The credential MUST NOT be null and MUST be an instance of ResourceOwnerCredential');
        }

        ResourceOwnerCredential resourceCred = (ResourceOwnerCredential)credential;

        Blob basicAuthValue = Blob.valueOf(resourceCred.getApiClientID() + ':' + resourceCred.getApiClientSecret());
		String authHeaderValue = 'BASIC ' + EncodingUtil.base64Encode(basicAuthValue);

        String encoding = 'UTF-8';
        String username = resourceCred.getUsername() + '@encompass:' + resourceCred.getInstanceID();
        String encodedUsername = EncodingUtil.urlEncode(username, encoding);
        String encodedPassword = EncodingUtil.urlEncode(resourceCred.getPassword(), encoding);
        String body = 'grant_type=password&username=' + encodedUsername + '&password=' + encodedPassword;

        EndpointManager endpointMgr = new EndpointManager();
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointMgr.getEncompassOAuthEndpoint());
        req.setMethod(EndpointManager.HTTP_METHOD_POST);
        req.setHeader('Authorization', authHeaderValue);
        req.setBody(body);
        req.setClientCertificateName(proxyCertName);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() != 200) {

            try {
                Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String error = (String)jsonData.get('error');
                String description = (String)jsonData.get('error_description');
                    
                System.debug('Encompass error info: ' + error + ' ' + description);
            } catch(Exception e) {
                System.debug('Unable to get Encompass error info: ' + e);
            }
            
            return false;
        }

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String token = (String)jsonData.get('access_token');
        String tokenType = (String)jsonData.get('token_type');

        if (token == null || tokenType == null) {
            return false;
        }

        DateTime expirationTime = System.now().addMinutes(10);

        EncompassToken encompassToken = new EncompassToken(token, tokenType, expirationTime);

        this.tokenManager.setToken(encompassToken);

		return true;
	}

	public boolean isUserAuthenticated() {
        EncompassToken token = this.tokenManager.getToken();
        boolean isAuthenticated = token != null;

        return isAuthenticated;
	}

	public void logOut() {
		this.tokenManager.clearToken();
	}
}