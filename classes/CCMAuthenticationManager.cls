public class CCMAuthenticationManager implements IAuthenticationManager {

    public boolean authenticateUser(IAuthenticationCredential credential) {
        if (credential == null) {
            throw new IllegalArgumentException('Credential must NOT be null.');
        }

        if (!(credential instanceof IPasswordCredential)) {
            throw new IllegalArgumentException('Credential is NOT an instance of IPasswordCredential');
        }

        IPasswordCredential passwordCredential = (IPasswordCredential)credential;

        if (passwordCredential.getPassword() == null || passwordCredential.getUsername() == null) {
            throw new IllegalArgumentException('The username nor password may be null.');
        }

        Map<String, Object> payload = new Map<String, Object>();
        payload.put('UserName', passwordCredential.getUsername());
        payload.put('Password', passwordCredential.getPassword());
        payload.put('Authentication', 'CCM');

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        EndpointManager mgr = new EndpointManager();

        String endpoint = mgr.getCCMAPIEndpoint() + '/api/v1/sessions';
        String body = JSON.serialize(payload);
        String method = EndpointManager.HTTP_METHOD_POST;

        System.debug('payload: ' + payload);
        System.debug('body: ' + body);

        HTTPRequest request = new HTTPRequest();
        request.setBody(body);
        request.setClientCertificateName(proxyCertName);
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setMethod(method);

        HTTP http = new HTTP();
        HTTPResponse response = null;
        if (CCMDataProvider.CCM_BYPASS_MODE) {
            response = (new MockCCMResponse()).respond(request);
        } else {
            response = http.send(request);
        }
        System.debug('http: ' + http);
        System.debug('request: ' + request);
        System.debug('response: ' + response);

        Map<String, Object> responseMap = null;
        try {
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        } catch(Exception e) {
            throw new DataServiceException('CCM returned non-JSON data.');
        }
        System.debug('response.getbody(): ' + response.getBody());

        Integer statusOK = 201;
        if (response.getStatusCode() != statusOK) {
            if (responseMap.containsKey('message')) {
                String message = (String)responseMap.get('message');

                // What a wonderful way of saying that your username or password is not valid!
                if (message == 'Object reference not set to an instance of an object.') {
                    message = 'Invalid username or password';
                }

                throw new DataServiceException(message);
            }
            return false;
        } else {
            String token = (String)responseMap.get('authToken');
            if (token == null) {
                return false;
            }

            UserSessionCache cache = new UserSessionCache();
            cache.setValue(token, UserSessionCache.CCM);

            return true;
        }
    }

    public Boolean isUserAuthenticated() {
        UserSessionCache cache = new UserSessionCache();

        Boolean isAuthenticated = cache.getValue(UserSessionCache.CCM) != null;

        return isAuthenticated;
    }

    public void logOut() {
        UserSessionCache cache = new UserSessionCache();

        cache.setValue(null, UserSessionCache.CCM);
    }

}