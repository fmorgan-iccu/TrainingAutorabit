/*
 * Master class for accessing data through Fiserv DNA. 
 */
public virtual class DNACoreDataProvider {

    // This bypass mode can be used in the development environment if there is ever an issue
    // connecting to the CCM system.  This will cause the data provider to use the appropriate
    // mock response.  The system will not be fully functional, but can allow development of
    // modifications to continue.  Enabling this will cause some of the unit tests to fail!  So,
    // don't try to deploy this enabled.
    public static final Boolean DNA_CORE_BYPASS_MODE = false;

    private IAuthenticationManager authenticationManager;

    public DNACoreDataProvider() {
        this.authenticationManager = new DNAAuthenticationManager();
    }

    // For testing only...
    public DNACoreDataProvider(IAuthenticationManager authenticationManager) {
        this.authenticationManager = authenticationManager;
    }

    public IAuthenticationManager getAuthenticationManager() {
        return this.authenticationManager;
    }

// Protected Methods

    /**
     *  Makes a call to the DNA API
     *  @param request Fully-formed DNA request payload.
     *  @return List of responses for the given requests.
     */
    protected List<Map<String, Object>> callApi(Map<String, Object> request) {
        String body = JSON.serialize(request);

        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getDNAServiceEndpoint();

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        httpRequest.setEndpoint(endpoint);
        httpRequest.setClientCertificateName(proxyCertName);
        httpRequest.setMethod(EndpointManager.HTTP_METHOD_POST);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody(body);

        // LogUtils.debug(body, 'callApiBody-');

        HTTPResponse response = null;
        if (DNA_CORE_BYPASS_MODE) {
            response = (new MockDNAResponse()).respond(httpRequest);
        } else {
            response = http.send(httpRequest);
        }

        String responseBody = response.getBody();
        if (responseBody == null) {
            return null;
        }

        // LogUtils.debug(responseBody, 'Response:');

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        if (jsonData == null) {
            return null;
        }

        List<Map<String, Object>> responses = this.parseResponse(jsonData);
        return responses;
    }

    /**
     *  Creates the request envelope for interacting with the DNA API.
     *  @param requests List of requests to send to DNA
     *  @return Fully formed service request to DNA.
     */
    protected Map<String, Object> createGenericRequest(List<Map<String, Object>> requests) {
        List<Map<String, Object>> requestsElement = new List<Map<String, Object>>();
        requestsElement.addAll(requests);

        Map<String, Object> input = new Map<String, Object> {
            'Requests' => requestsElement,
            'UserAuthentication' => this.createUserAuthentication()
        };

        Map<String, Object> request = new Map<String, Object> {
            'Input' => input
        };

        return request;
    }

    /**
     *  Convenience method for creating the request envelope for interacting with the DNA API.
     *  @param request The request to send to DNA
     *  @return Fully formed service request to DNA.
     */
    protected Map<String, Object> createGenericRequest(Map<String, Object> request) {
        List<Map<String, Object>> requestList = new List<Map<String, Object>> {
            request
        };

        return this.createGenericRequest(requestList);
    }

    /**
     *  Parses a DNA date string and returns a DateTime object
     *  @param dnaDate The DNA date to parse
     *  @return DateTime object corresponding to the DNA date, if valid.  Nullable.
     */
    @TestVisible
    protected DateTime parseDNADate(String dnaDate) {
        if (dnaDate == null) {
            return null;
        }

        // System.debug('passed Date: ' + dnaDate);

        Integer startIndex = dnaDate.indexOf('(');
        Integer endIndex = dnaDate.indexOf('-0');

        if (startIndex == -1 || endIndex == -1) {
            return null;
        }

        String substringDate = dnaDate.substring(startIndex + 1, endIndex);
        DateTime dateInstance = DateTime.newInstance(Long.valueOf(substringDate));

        return dateInstance;
    }

    /**
     *  Creates a DNA date string from a DateTime object
     *  @param sfDate The DateTime to convert
     *  @return DNA date string
     */
    @TestVisible
    protected String createDNADate(DateTime sfDate) {
        if (sfDate == null) {
            return null;
        }

        String dnaTime = '/Date('+ sfDate.getTime() + '-0700)/';
        return dnaTime;
    }

    /**
     *  Parses DNA errors
     *  @param errorList The list of errors that were given by DNA.
     *  @return An error messages that can be given to the client
     */
    @TestVisible
    protected String parseErrors(List<Object> errorList) {
        String errorMessages = '';

        List<Map<String, Object>> errors = APIUtils.convertObjectList(errorList);
        for (Map<String, Object> rawError : errors) {
            String message = (String)rawError.get('ErrorMessage');
            errorMessages += message + ' ';
        }

        return errorMessages;
    }

// Private Methods

    /**
     *  Does a first-pass validation and parsing of a DNA network response.
     *  @param response The map that was returned from a service call to DNA.
     *  @return List<Map<String, Object>> of responses given back by DNA
     */
    private List<Map<String, Object>> parseResponse(Map<String, Object> response) {
        if (response == null) {
            return null;
        }

        //System.debug('parsing Output');
        Map<String, Object> output = (Map<String, Object>)response.get('Output');

        if (output == null) {
            return null;
        }

        //System.debug('parsing UserAuthentication');
        Map<String, Object> userAuthentication = (Map<String, Object>)output.get('UserAuthentication');

        if (userAuthentication == null) {
            return null;
        }

        //System.debug('parsing WasSuccessful');
        List<Object> authErrors = (List<Object>)userAuthentication.get('Errors');

        if (authErrors != null) {
            throw new UnauthenticatedException('Please log into DNA.');
        }

        List<Map<String, Object>> responses = APIUtils.convertObjectList((List<Object>)output.get('Responses'));

        //System.debug('finished parsing responses...' + responses);
        return responses;
    }

    /**
     *  Convenience method that builds the authentication portion of a network request.
     *  @return Map containing all the authentication details for a network request.
     *  @throws UnauthenticatedException if the DNA ticket is NOT in the cache.
     */
    private Map<String, Object> createUserAuthentication() {
        UserSessionCache sessionCache = new UserSessionCache();
        String ticket = sessionCache.getValue(UserSessionCache.DNA_TICKET);

        if (ticket == null) {
            throw new UnauthenticatedException();
        }

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String applNumber = paramManager.getDNAApplNumber();
        String networkNode = paramManager.getDNANetworkNodeName();
        Integer authType = Integer.valueOf(paramManager.getDNAAuthorizationType());

        // This json object needs to get added to every request. The whoIsTicket is different per user.
        Map<String, Object> userAuthMap = new Map<String, Object> {
            'ApplNumber' => applNumber,
            'AuthorizationType' => authType,
            'NetworkNodeName' => networkNode,
            'Password' => ticket
        };

        return userAuthMap;
    }
}