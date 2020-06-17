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

    public Map<String, Object> callApi(String servicePath, Map<String, Object> request) {
        String endpoint = new EndpointManager().getDNABusinessServicesEndpoint();
        if (String.isBlank(endpoint)) {
            throw new DataServiceException('Unable to get the DNA Business Services API endpoint.');
        }

        UserSessionCache sessionCache = new UserSessionCache();
        String dnaToken = sessionCache.getValue(UserSessionCache.DNA_TOKEN);
        if (dnaToken == null) {
            throw new UnauthenticatedException();
        }

        Map<String, String> headers = new Map<String, String> {
            'Authorization' => 'Bearer ' + dnaToken,
            'X-ApiChannelId' => DNABusinessServicesAuthManager.API_CHANNEL_ID,
            'X-MESSAGEID' => new Uuid().getValue()
        };

        return DNABusinessServicesAuthManager.callApi(endpoint, servicePath, headers, request);
    }

}