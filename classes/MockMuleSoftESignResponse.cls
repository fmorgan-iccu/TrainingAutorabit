global class MockMuleSoftESignResponse implements HttpCalloutMock {
    
    private Boolean isHappy { get; private set; }
    
    global MockMuleSoftESignResponse(Boolean isHappy) {
        this.isHappy = isHappy;
    }
    
	global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = this.responseSigningRequest(req);
        
        return res;
    }
    
    private HTTPResponse responseSigningRequest(HttpRequest req) {
        HTTPResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json; charset=UTF-8');
        
        if (this.isHappy) {
            res.setStatusCode(200);
	        res.setBody('{"envelopeId":"0cbabc37-7a84-4b2b-b74e-d01ba6a823d8","uri":"/envelopes/0cbabc37-7a84-4b2b-b74e-d01ba6a823d8","statusDateTime":"2020-04-20T23:24:37.2030000Z","status":"sent"}');
        } else {
            res.setStatusCode(400);
            res.setBody('{"error_code":"invalid_request","message":null}');
        }
        
        return res;
    }
}