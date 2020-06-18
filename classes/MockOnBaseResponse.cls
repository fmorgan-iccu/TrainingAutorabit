// TODO:  This had to be removed to allow the OnBase bypass mode to be used in a production (non-test) context.
// @isTest
global class MockOnBaseResponse implements HttpCalloutMock {

    private String responseData { get; set; }
    private Integer statusCode { get; set; }

    public MockOnBaseResponse() {
    }

    public MockOnBaseResponse(String responseData, Integer statusCode) {
        this.responseData = responseData;
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        if (this.responseData != null) {
            return this.createResponse(this.responseData, 'application/json', this.statusCode);
        }

        String endpoint = req.getEndpoint();
        System.debug('MockOnBaseResponse endpoint: ' + endpoint);

        if (endpoint.contains('/titlerelease')) {
            return this.handleTitleRelease(req);
        }

        throw new DataServiceException('This request is not implemented: (' + endpoint + ') ');
    }

    private HTTPResponse createResponse(String body, String contentType, Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', contentType);
        res.setBody(body);
        res.setStatusCode(statusCode);

        return res;
    }

    private HTTPResponse handleTitleRelease(HTTPRequest req) {
        String body = '{"errors":[],"id":5844093}';
        return this.createResponse(body, 'application/json', 201);
    }
}