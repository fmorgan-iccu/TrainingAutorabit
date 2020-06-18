public with sharing abstract class OnBaseDataProvider {

    // This bypass mode can be used in the development environment if there is ever an issue
    // connecting to the OnBase system.  This will cause the data provider to use the appropriate
    // mock response.  The system will not be fully functional, but can allow development of
    // modifications to continue.  Enabling this will cause some of the unit tests to fail!  So,
    // don't try to deploy this enabled.
    public static final Boolean ONBASE_BYPASS_MODE = false;

    public OnBaseDataProvider() {
    }

    protected Map<String, Object> callApi(String servicePath, String requestBody) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getOnBaseEndpoint() + servicePath;

        ServiceAccounts__c serviceAccount = [
            SELECT
                apiClientSecret__c,
                apiClientId__c
            FROM ServiceAccounts__c
            WHERE serviceName__c = 'OnBase'
            LIMIT 1
        ];
        Blob authHeaderValueBlob = Blob.valueOf(serviceAccount.apiClientId__c + ':' + serviceAccount.apiClientSecret__c);
        String authHeaderValue = EncodingUtil.base64Encode(authHeaderValueBlob);

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getOnBaseProxyCertName();
        request.setClientCertificateName(proxyCertName);

        request.setEndpoint(endpoint);
        request.setMethod(EndpointManager.HTTP_METHOD_POST);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Basic ' + authHeaderValue);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(50000);
        request.setBody(requestBody);

        // LogUtils.debug(requestBody, 'callApiBody-');

        HttpResponse response = null;
        if (ONBASE_BYPASS_MODE) {
            response = (new MockOnBaseResponse()).respond(request);
        } else {
            response = http.send(request);
        }

        String responseBody = response.getBody();
        if (responseBody == null) {
            throw new DataServiceException('OnBase response is empty.');
        }

        // LogUtils.debug(responseBody, 'Response:');
        Integer statusCode = response.getStatusCode();
        if (statusCode == 500) {
            String message = 'Service is starting, please wait a few minutes and try again.';
            throw new DataServiceException(message);
        }

        if (statusCode == 502) {
            String message = 'OnBase is not currently running. Please wait a few minutes and try again.';
            throw new DataServiceException(message);
        }

        Map<String, Object> responseMap = null;
        try {
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        } catch(Exception e) {
            throw new DataServiceException('OnBase returned non-JSON data.');
        }

        if (statusCode != 201) {
            String message = responseMap.containsKey('errors') ? (String)responseMap.get('errors') : 'OnBase failed to return an error message.';
            throw new DataServiceException(message);
        }

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        if (jsonData == null) {
            throw new DataServiceException('OnBase response is not well formed.');
        }

        return jsonData;
    }

}