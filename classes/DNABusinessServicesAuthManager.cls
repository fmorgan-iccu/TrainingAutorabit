public with sharing class DNABusinessServicesAuthManager implements IAuthenticationManager {

    // This bypass mode can be used in the development environment if there is ever an issue
    // connecting to the DNA system.  This will cause the data provider to use the appropriate
    // mock response.  The system will not be fully functional, but can allow development of
    // modifications to continue.  Enabling this will cause some of the unit tests to fail!  So,
    // don't try to deploy this enabled.
    public static final Boolean DNA_BUSSVC_BYPASS_MODE = false;

    public static final String API_CHANNEL_ID = '708F024B-6A94-4089-890D-C7F292C9A2FE';

    public DNABusinessServicesAuthManager() {
    }

    /**
     * Authenticates a user using the DNA Business Services API, and if successful, stores the
     * DNA Token in the cache.
     * @param credential The DNA credentials of the user
     * @return whether the user successfully authenticated, or not
     * @throws IllegalArgumentException when the passed in credentials are null in any way.
     * @throws DataServiceException for unexpected service errors/formats.
     */
    public Boolean authenticateUser(IAuthenticationCredential credential) {
        if (credential == null || !(credential instanceof DNABusinessServicesAuthCredential)) {
            throw new IllegalArgumentException('Credential must be an instance of DNABusinessServicesAuthCredential.');
        }

        DNABusinessServicesAuthCredential dnaCredential = (DNABusinessServicesAuthCredential) credential;
        String stsToken = null;
        String dnaToken = null;
        try {
            stsToken = getStsToken(dnaCredential);
            dnaToken = getDnaToken(dnaCredential, stsToken);
        } catch (DataServiceException e) {
            // Convert several DNA messages that mean the same thing to a single message that can
            // be understood by the end user.
            String message = e.getMessage();
            if (message == 'API initializing, please retry after some time.') {
                throw new DataServiceException('DNA service is starting.  Wait a few seconds and try again.');
            }
            throw e;
        }

        // The call above will throw errors if there are any issues.  If the execution has made
        // it this far, the login is complete and the DNA token can be stored.
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue(dnaToken, UserSessionCache.DNA_TOKEN);

        return true;
    }

    /**
     * Determines if the user is logged in or not.
     * @return whether the user is authenticated.
     */
    public Boolean isUserAuthenticated() {
        UserSessionCache sessionCache = new UserSessionCache();
        String dnaToken = sessionCache.getValue(UserSessionCache.DNA_TOKEN);
        Boolean isAuthenticated = dnaToken != null;

        return isAuthenticated;
    }

    /**
     * Logs the user out and destroys their cached ticket, if applicable
     */
    public void logOut() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue(null, UserSessionCache.DNA_TOKEN);
    }

    private String getStsToken(DNABusinessServicesAuthCredential credential) {
        if (credential == null) {
            throw new IllegalArgumentException('Credential must be provided.');
        }
        if (credential.getUsername() == null || credential.getPassword() == null) {
            throw new IllegalArgumentException('Credentials for authentication were null!');
        }

        // NOTE:  As tempting as this might be, it doesn't work!  It appears that the node must be
        // a valid machine on the network for this API!
        //String networkNodeName = new ServiceParameterManager().getDNANetworkNodeName();

        Map<String, String> stsTokenRequest = new Map<String, String> {
            'device_name' => credential.getNetworkNodeName(),
            'environment' => 'PRODUCTION',
            'user_id' => credential.getUsername(),
            'password' => credential.getPassword()
        };
        Map<String, Object> stsMessage = callStsTokenApi(stsTokenRequest);
        if (stsMessage == null || !stsMessage.containsKey('StsToken')) {
            if (stsMessage.containsKey('Message')) {
                String message = (String)stsMessage.get('Message');
                if (message == 'Invalid userId or password.') {
                    // Standardize the verbiage used across all login services.
                    throw new DataServiceException('Invalid username or password');
                } else {
                    throw new DataServiceException(message);
                }
            }
            throw new DataServiceException('StsToken missing in response.');
        }
        String stsToken = (String)stsMessage.get('StsToken');
        return stsToken;
    }

    private String getDnaToken(DNABusinessServicesAuthCredential credential, String stsToken) {
        Map<String, String> messageBody = new Map<String, String> {
            'EffectiveDate' => String.valueOf(credential.getEffectiveDate()),
            'PostingDate' => String.valueOf(credential.getPostingDate()),
            'CashBoxNumber' => String.valueOf(credential.getCashBox())
        };
        Map<String, Object> dnaTokenRequest = new Map<String, Object> {
            'MessageBody' => messageBody
        };
        Map<String, Object> dnaMessage = callDnaTokenApi(stsToken, dnaTokenRequest);
        if (!dnaMessage.containsKey('Dnatoken')) {
            if (dnaMessage.containsKey('BrokenRules')) {
                String errorMessage = '';
                List<Map<String, Object>> brokenRules = APIUtils.convertObjectList((List<Object>)dnaMessage.get('BrokenRules'));
                for (Map<String, Object> brokenRule : brokenRules) {
                    errorMessage += ' ' + (String)brokenRule.get('Message');
                }
                errorMessage = errorMessage.trim();
                throw new DataServiceException(errorMessage);
            }
            if (dnaMessage.containsKey('Message')) {
                throw new DataServiceException((String)dnaMessage.get('Message'));
            }
            throw new DataServiceException('Dnatoken missing in response.');
        }
        String dnaToken = (String)dnaMessage.get('Dnatoken');
        return dnaToken;
    }

    private Map<String, Object> callStsTokenApi(Map<String, Object> request) {
        String endpoint = new EndpointManager().getDNABusinessServicesSignOnEndpoint();

        Map<String, String> headers = new Map<String, String>();

        Map<String, Object> messageBody = DNABusinessServicesAuthManager.callApi(endpoint, '', headers, request);
        if (messageBody.containsKey('MessageBody')) {
            messageBody = (Map<String, Object>) messageBody.get('MessageBody');
        }
        return messageBody;
    }

    private Map<String, Object> callDnaTokenApi(String stsToken, Map<String, Object> request) {
        String endpoint = new EndpointManager().getDNABusinessServicesEndpoint();
        if (String.isBlank(endpoint)) {
            throw new DataServiceException('Unable to get the DNA Business Services API endpoint.');
        }

        Map<String, String> headers = new Map<String, String> {
            'Authorization' => 'Bearer ' + stsToken,
            'X-ApiChannelId' => DNABusinessServicesAuthManager.API_CHANNEL_ID,
            'X-MESSAGEID' => new Uuid().getValue(),
            'X-BusinessTaskId' => 'GFRM'
        };

        Map<String, Object> messageBody = DNABusinessServicesAuthManager.callApi(endpoint, '/Login/Execute?Include=Standard', headers, request);
        if (messageBody.containsKey('MessageBody')) {
            messageBody = (Map<String, Object>) messageBody.get('MessageBody');
        }
        return messageBody;
    }

    /**
     * A standardized method for making the underlying call to the DNA business services API.
     * This is public/static so that the business services data provider can also use this code.
     */
    public static Map<String, Object> callApi(String endpoint, String servicePath, Map<String, String> headers, Map<String, Object> request) {
        String body = JSON.serialize(request);

        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        httpRequest.setEndpoint(endpoint + servicePath);
        httpRequest.setClientCertificateName(proxyCertName);
        httpRequest.setMethod(EndpointManager.HTTP_METHOD_POST);
        httpRequest.setHeader('Content-Type', 'application/json');
        for (String headerName : headers.keySet()) {
            // System.debug(headerName + ' = ' + headers.get(headerName));
            httpRequest.setHeader(headerName, headers.get(headerName));
        }
        httpRequest.setBody(body);

        // LogUtils.debug(body, 'callApiBody:');

        HttpResponse response = null;
        if (DNA_BUSSVC_BYPASS_MODE) {
            response = (new MockDNAResponse()).respond(httpRequest);
        } else {
            response = http.send(httpRequest);
        }

        String responseBody = response.getBody();
        if (responseBody == null) {
            throw new DataServiceException('DNA business services API failed to return any content.');
        }

        // LogUtils.debug(responseBody, 'Response:');

        // When the user is not authenticated or not authorized to access a specific resource, it
        // returns an HTML page instead of a JSON page like other errors (e.g. service is starting
        // up - 503, posting dates are not in the correct format - 422, etc.)  This code creates
        // an error payload in the standard format used by these other errors.
        if (response.getStatusCode() == 401 && !endpoint.contains('/StsIdentityServices')) {
            Map<String, Object> unauthorizedMessage = new Map<String, Object> {
                'Message' => 'Invalid username or password',
                'Number' => 401000,
                'HttpError' => 401
            };
            responseBody = JSON.serialize(unauthorizedMessage);

            // The user is no longer logged in.  Reset the session state.
            UserSessionCache sessionCache = new UserSessionCache();
            sessionCache.setValue(null, UserSessionCache.DNA_TOKEN);
        }

        // The SAF token (STS) request doesn't conform with the rest of the APIs and only returns
        // a JSON payload with a single string (e.g. "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1Ni...") and
        // not an object.  Make this request conform with the way the DNA Token request is
        // structured.
        if (endpoint.contains('saftoken') && responseBody.left(1) == '"') {
            Map<String, Object> stsToken = new Map<String, Object> {
                'StsToken' => (String)JSON.deserializeUntyped(responseBody)
            };
            responseBody = JSON.serialize(stsToken);
        }

        Map<String, Object> jsonData = null;
        try {
            jsonData = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        } catch(Exception e) {
            throw new DataServiceException(e.getMessage());
        }

        return jsonData;
    }

}