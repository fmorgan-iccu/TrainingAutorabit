/**
 * Class for interacting with Avoka Transact Manager
 * API documentation can be found at: https://support.avoka.com/kb/display/SDK51/Transact+REST+API+Reference
 */
public virtual class TMDataProvider {
    private ResourceOwnerCredential credential;
    
    public TMDataProvider(ResourceOwnerCredential credential) {
        this.credential = credential;
    }

    /**
     * Makes the API call to Avoka TM.
     * @param endpoint The endpoint to call.
     * @param method The HTTP method to use.
     * @param bodyData The body data, if applicable, to send.
     */
    @TestVisible
    protected Object callApi(String endpoint, String method, Map<String, Object> bodyData) {
        if (this.credential == null || this.credential.getUsername() == null || this.credential.getPassword() == null) {
            throw new UnauthenticatedException('Username and password for this resource may NOT be null.');
        }

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        Blob basicAuthValue = Blob.valueOf(this.credential.getUsername() + ':' + this.credential.getPassword());
		String authHeaderValue = 'Basic ' + EncodingUtil.base64Encode(basicAuthValue);

        integer timeout = 30 * 1000; // 30 seconds
        
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        
        httpRequest.setHeader('Authorization', authHeaderValue);
        httpRequest.setEndpoint(endpoint);
        httpRequest.setClientCertificateName(proxyCertName);
        httpRequest.setMethod(method);
        httpRequest.setTimeout(timeout);
        
        System.debug('>>>>>>>>>>> TM API ENDPOINT: ' + httpRequest.getEndpoint());
        
        if (bodyData != null) {
            String body = JSON.serialize(bodyData);

            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setBody(body);
        }

        HttpResponse response = http.send(httpRequest);
        integer statusCode = response.getStatusCode();
        
        if (statusCode != 200) {
            throw new DataServiceException('Request failed. Status code: ' + statusCode + ' Body: ' + response.getBody());
        }
        
        
        String responseBody = response.getBody();
        if (responseBody == null) {
            return null;
        }

        return JSON.deserializeUntyped(responseBody);
    }

    /**
     * Converts a List<Object> to a List<Map<String, Object>>
     * @param objectList The List<Object> to convert.
     * @return a new List<Map<String, Object>>.  Will return an empty list of the objectList is null.
     */
    @TestVisible
	protected List<Map<String, Object>> convertObjectList(List<Object> objectList) {
        if (objectList == null) {
            return new List<Map<String, Object>>();
        }

        List<Map<String, Object>> mapList = new List<Map<String, Object>>();

        for (Object obj : objectList) {
            mapList.add((Map<String, Object>)obj);
        }

        return mapList;
    }

    /**
     * Naive implementation to convert Avoka TM dates to SalesForce dates.  Since APEX date parsing support is pretty not much there unless you match EXACTLY their exepected format, this function exists.
     * @param avokaDate The string representation from Avoka TM to convert
     * @return A DateTime instance representing the Avoka TM String
     */
    @TestVisible
    protected DateTime parseAvokaDate(String avokaDate) {
        if (avokaDate == null) {
            return null;
        }
        
        integer year = integer.valueOf(avokaDate.substring(0, 4));
        integer month = integer.valueOf(avokaDate.substring(5, 7));
        integer day = integer.valueOf(avokaDate.substring(8, 10));
        integer hour = integer.valueOf(avokaDate.substring(11, 13));
        integer minute = integer.valueOf(avokaDate.substring(14, 16));
        integer second = integer.valueOf(avokaDate.substring(17, 19));
        integer offsetHour = integer.valueOf(avokaDate.substring(20, 22));

        DateTime newDate = DateTime.newInstance(year, month, day, hour, minute, second);
        newDate = newDate.addHours(offsetHour);

        return newDate;
    }
}