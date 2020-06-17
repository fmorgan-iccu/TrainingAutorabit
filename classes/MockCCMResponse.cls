// TODO:  This had to be removed to allow the CCM bypass mode to be used in a production (non-test) context.
// @isTest
global class MockCCMResponse implements HttpCalloutMock {
    private String responseData { get; set; }
    private Integer statusCode { get; set; }
    
    public MockCCMResponse() {
        // Default constructor for happy path situations
    }

    /**
     * Custom input for a response
     */
    public MockCCMResponse(String responseData, Integer statusCode) {
        this.responseData = responseData;
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        if (this.responseData != null) {
            return this.createResponse(this.responseData, 'application/json', this.statusCode);
        }

        String endpoint = req.getEndpoint();
        System.debug('MockCCMResponse endpoint: ' + endpoint);

        if (endpoint.contains('/api/v1/sessions')) {
            return this.handleAuthenticateRequest(req);
        }

        if (endpoint.contains('/relationships')) {
            return this.handlePartyRelationshipRequest(req);
        }

        if (endpoint.contains('/cardDeactivations')) {
            return this.handleStatusChange(req);
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

    private HTTPResponse handleAuthenticateRequest(HTTPRequest req) {
        String body = '{"authToken":"522462c8fc21802602793bbe1e2db66c"}';
        String contentType = 'application/json';

        return this.createResponse(body, contentType, 201);
    }

    private HTTPResponse handlePartyRelationshipRequest(HTTPRequest req) {
        String body = '{"pageSize":100,"relationshipInfos":[{"accountId":517270009,"accountNumber":517270009,"isMaster":false,"masterAccountId":null,"masterAccountNumber":null,"productName":"Visa Platinum","accountStatus":"Active","partyName":"Kevin Smith","accountRelationshipType":"Owner","isTaxOwner":true,"cardId":null,"cardNumber":null,"cardExpirationDate":null,"cardStatus":null,"partyId":"2921","partyType":"Person","cardHolderName":null,"otherName":null},{"accountId":517270009,"accountNumber":517270009,"isMaster":false,"masterAccountId":null,"masterAccountNumber":null,"productName":"Visa Platinum","accountStatus":"Active","partyName":"Ann Smith","accountRelationshipType":"Owner","isTaxOwner":false,"cardId":123319,"cardNumber":"4869382267100638","cardExpirationDate":"2019-07-31T00:00:00","cardStatus":"Active","partyId":"92932","partyType":"Person","cardHolderName":"Ann Smith","otherName":null},{"accountId":1181990009,"accountNumber":1181990009,"isMaster":false,"masterAccountId":null,"masterAccountNumber":null,"productName":"Visa Classic","accountStatus":"Closed","partyName":"Marjorie Smith","accountRelationshipType":"Owner","isTaxOwner":true,"cardId":null,"cardNumber":null,"cardExpirationDate":null,"cardStatus":null,"partyId":"22253","partyType":"Person","cardHolderName":null,"otherName":null},{"accountId":1181990009,"accountNumber":1181990009,"isMaster":false,"masterAccountId":null,"masterAccountNumber":null,"productName":"Visa Classic","accountStatus":"Closed","partyName":"Kevin Smith","accountRelationshipType":"Owner","isTaxOwner":false,"cardId":null,"cardNumber":null,"cardExpirationDate":null,"cardStatus":null,"partyId":"2921","partyType":"Person","cardHolderName":null,"otherName":null}],"pageNumber":1,"pageCount":1,"totalItemCount":4,"links":[{"rel":"CurrentPage","href":"https://podv-tstccmapi1.iccu.com/tstccmapiws/api/v1/parties/2921/relationships?pagenumber=1&pagesize=100","method":"GET"}]}';
        String contentType = 'application/json';

        return this.createResponse(body, contentType, 200);
    }

    private HTTPResponse handleStatusChange(HTTPRequest req) {
        String body = '{"responseCode":"Success","responseData":{"cardId":440709,"cardNumber":"4869382212353175","expirationDate":"2020-07-31T00:00:00","status":"Inactive","cardHolderName":"Kevin Smith","issueDate":"2015-07-14T09:51:48.18","activationDate":null,"inactiveDate":"2018-07-18T15:50:31.977","partyId":2921,"partyType":"Person","accountId":517270009}}';
        String contentType = 'application/json';
        Integer statusCode = 200;

        return this.createResponse(body, contentType, 200);
    }
}