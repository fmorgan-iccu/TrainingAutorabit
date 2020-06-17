// TODO:  This had to be removed to allow the COOP bypass mode to be used in a production (non-test) context.
// @isTest
global class MockCOOPResponse implements HttpCalloutMock {

    private String responseData { get; set; }
    private Integer statusCode { get; set; }

    public MockCOOPResponse() {
    }

    public MockCOOPResponse(String responseData, Integer statusCode) {
        this.responseData = responseData;
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        if (this.responseData != null) {
            return this.createResponse(this.responseData, 'application/json', this.statusCode);
        }

        String endpoint = req.getEndpoint();
        System.debug('MockCOOPResponse endpoint: ' + endpoint);
        
        if (endpoint.contains('/travelNotificationCancellation')) {
            return this.handleCancellationRequest(req);
        }
        
        if (endpoint.contains('/travelNotificationInquiry')) {
            return this.handleInquiryRequest(req);
        }
        
        if (endpoint.contains('/travelnotification')) {
            return this.handleUpdateRequest(req);
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

    private HTTPResponse handleCancellationRequest(HTTPRequest req) {
        String body = '{"response":{"status":"OK"}}';
        return this.createResponse(body, 'application/json', 200);
    }

    private HTTPResponse handleInquiryRequest(HTTPRequest req) {
        String body = '{"response":{"status":"OK","count":"1","results":[{"notification":{"vip":"N","institution":{"rtn":"324173626"},"cardholder":{"cardNumber":"Card number ending in 9136","plasticNumber":"","firstName":"John","lastName":"Doe","primaryPhone":"12089991234","primaryPhoneType":"home","secondaryPhone":"","secondaryPhoneType":"","email":"","sharedCard":" "},"alternateContact":{"firstName":"","lastName":"","phone":"","email":""},"authorizedContact":{"firstName":"","lastName":"","phone":"","relationshipToCardholder":"","contactReasonId":"","otherReasonDesc":""},"blockingInstructions":{"code":"BI02","callCardholder":" ","comment":""},"cuContact":{"name":"","phone":"","extension":"","email":""},"details":[{"id":"99999","fromDate":"2019-08-01 00:00:00.0","toDate":"2019-08-10 00:00:00.0","state":"CA","country":"US","phone":"12089991234","purpose":"OTH","note":"On vacation in California."},{"id":"99999","fromDate":"2019-08-01 00:00:00.0","toDate":"2019-08-10 00:00:00.0","state":"OR","country":"US","phone":"12089991234","purpose":"OTH","note":"On vacation in California."},{"id":"99999","fromDate":"2019-08-01 00:00:00.0","toDate":"2019-08-10 00:00:00.0","state":"","country":"MX","phone":"12089991234","purpose":"OTH","note":"On vacation in California."}]}}]}}';
        return this.createResponse(body, 'application/json', 200);
    }

    private HTTPResponse handleUpdateRequest(HTTPRequest req) {
        String body = '{"response":{"status":"OK"}}';
        return this.createResponse(body, 'application/json', 200);
    }
}