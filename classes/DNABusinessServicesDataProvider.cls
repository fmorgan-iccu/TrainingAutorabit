public virtual class DNABusinessServicesDataProvider {

    private IAuthenticationManager authenticationManager;

    public DNABusinessServicesDataProvider() {
        this.authenticationManager = new DNABusinessServicesAuthManager();
    }

    public DNABusinessServicesDataProvider(IAuthenticationManager businessServicesAuthManager) {
        this.authenticationManager = businessServicesAuthManager;
    }

    public IAuthenticationManager getAuthenticationManager() {
        return this.authenticationManager;
    }

    /**
     * For backwards compatibility, this code ommits the http method and defaults to POST.
     */
    public Map<String, Object> callApi(String servicePath, Map<String, Object> request) {
        return callApi(servicePath, EndpointManager.HTTP_METHOD_POST, request);
    }

    public Map<String, Object> callApi(String servicePath, String httpMethod, Map<String, Object> request) {
        String endpoint = new EndpointManager().getDNABusinessServicesEndpoint();
        if (String.isBlank(endpoint)) {
            throw new DataServiceException('Unable to get the DNA Business Services API endpoint.');
        }

        UserSessionCache sessionCache = new UserSessionCache();
        String dnaToken = sessionCache.getValue(UserSessionCache.DNA_TOKEN);
        if (dnaToken == null) {
            throw new UnauthenticatedException('Please log into DNA.');
        }

        Map<String, String> headers = new Map<String, String> {
            'Authorization' => 'Bearer ' + dnaToken,
            'X-ApiChannelId' => DNABusinessServicesAuthManager.API_CHANNEL_ID,
            'X-MESSAGEID' => new Uuid().getValue()
        };

        Map<String, Object> response = DNABusinessServicesAuthManager.callApi(endpoint, servicePath, httpMethod, headers, request);
        if (response != null && response.containsKey('Message')) {
            throw new DataServiceException((String)response.get('Message'));
        }
        if (response == null || !response.containsKey('MessageBody')) {
            throw new DataServiceException('Response missing the expected MessageBody.');
        }

        return response;
    }

}