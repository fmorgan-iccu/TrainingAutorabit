/**
 * For tests that require the use of several systems (e.g. DNA, CCM, COOP), this mock acts as a
 * proxy to each of these.
 */
@isTest
global class MockCardResponse implements HttpCalloutMock {

    public MockCardResponse() {
    }

    global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();

        if (endpoint.contains('/dna_sf')) {
            MockDNAResponse dnaResponse = new MockDNAResponse();
            return dnaResponse.respond(req);
        }

        if (endpoint.contains('/ccm_sf')) {
            MockCCMResponse ccmResponse = new MockCCMResponse();
            return ccmResponse.respond(req);
        }

        if (endpoint.contains('/coop_sf')) {
            MockCOOPResponse coopResponse = new MockCOOPResponse();
            return coopResponse.respond(req);
        }

        throw new DataServiceException('This request is not implemented: (' + endpoint + ') ');
    }
}