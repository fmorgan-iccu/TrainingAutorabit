@isTest
global class MockAvokaTMResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();

        boolean isTransactionListRequest = endpoint.contains('formStatus=');
        if (isTransactionListRequest) {
            return this.handleTransactionsByStatusRequest(req);
        }

        // Pattern for matching getting a specific transaction
        String transactionRegex = '.*transactions/\\d+';
        Pattern transactionPattern = Pattern.compile(transactionRegex);
        Matcher transactionMatcher = transactionPattern.matcher(endpoint);
        boolean isTransactionRequest = transactionMatcher.matches();

        if (isTransactionRequest) {
            String method = req.getMethod();
            
            if (method.equals(EndpointManager.HTTP_METHOD_GET)) {
                return this.handleGetTransaction(req);
            } else if (method.equals(EndpointManager.HTTP_METHOD_PUT)) {
                return this.handleUpdateTransaction(req);
            }
        }

        // Pattern for matching getting all transactions
        String allTransRegex = '.*transactions/$';
        Pattern allTransPattern = Pattern.compile(allTransRegex);
        Matcher allTransMatcher = allTransPattern.matcher(endpoint);
        boolean isAllTransactionRequest = allTransMatcher.matches();

        if (isAllTransactionRequest) {
            return this.handleAllTransactionsRequest(req);
        }

        // We have co-integration with the products service, so we're instantiating this to handle anything else.
        MockProductDataResponse productResponse = new MockProductDataResponse();
        return productResponse.respond(req);
    }
    
    private HTTPResponse createResponse(String body, String contentType) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', contentType);
        res.setBody(body);
        res.setStatusCode(200);

        return res;
    }
    
    private HTTPResponse handleTransactionsByStatusRequest(HTTPRequest req) {
        String body = '[{"id":61381,"trackingCode":"FFD8F2Z","submitKey":"9d7f9734a5ffcb8be2632a42b7155f08","taskFlag":false,"formCode":"triage","formName":"Triage","formVersion":"1.9.3","clientCode":"personal","clientName":"Personal","portalName":"Apps","fieldWorkerFlag":false,"testMode":false,"contactEmailAddress":"smarshburn@iccu.com","formStatus":"Saved","timeRequest":"2018-05-22T07:16:13-06:00","timeSubmission":"2018-05-22T07:16:36-06:00","timeLastUserActivity":"2018-05-22T07:17:35-06:00","ipAddress":"65.121.129.2","requestCookie":"JSESSIONID=BJdcsPcdUtaXrk_C0VXDcVWBFuUjFwW3UBlHJpjP.1; AWSELB=F5C5B727122402F47FEF068CAFEBC5A8C36A58A8E623D9E1450C652E2C343B2B1F40E3B83B4D087F76D14851E4D94528311FA7D54776B381F5BBFA8E7AECFE9B49F9E605F0FD2DA944382DE78C8888E9FB49C68F64; _bcvm_vrid_3535619737041707416=878145959563459844T91BD8C6E6014F1EAAA8990D8B3276D3507AA2276BA4FDB9328D693141D96FE6024D81534AF63548C1CDAA3232AFFCAF94B48D1CF3B47CA576486F81CB7EBF4B2; _bcvm_vid_3535619737041707416=878146565933679342T0216E464EF2CCE60951ED6BB9C455E9BC79A1B76FB840715A50603A298C7747CC91CEEB6FAA59525CA7B7802BA5888F5FCF4F2B8EAA17A51AC5FE194F4BA7697; bc_pv_end=878146568257591045T1ACE628351636108403F173F30DE366EBACC7C360C739BB052D8603C3BE368E287E416161D11E67DC373A0DD45AA8E8B1CF6A2F5DF34D42BC35FC889F8AB4209","userAgent":"Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36","userAgentBrowser":"Chrome 65","userAgentBrowserType":"Chrome","userAgentBrowserVersion":"65","userAgentDeviceType":"Desktop","userAgentOs":"Windows 7","userAgentOsType":"Windows","userAgentOsVersion":"7","dataExtracts":{"MajorProductId":"unknown","MinorProductId":"unknown","NewMembership":"false","ApplicantPersona":"member","debugEmail":"smarshburn@iccu.com"},"deliveryStatus":"Not Ready","dataDeleted":false,"formURL":"https://uat.iccu.avoka-transact.com/apps/servlet/SmartForm.html?submitKey=9d7f9734a5ffcb8be2632a42b7155f08"}]';
        String contentType = 'application/json';

        return this.createResponse(body, contentType);
    }
    
    private HTTPResponse handleAllTransactionsRequest(HTTPRequest req) {
        String body = '[{"id":61381,"trackingCode":"FFD8F2Z","submitKey":"9d7f9734a5ffcb8be2632a42b7155f08","taskFlag":false,"formCode":"triage","formName":"Triage","formVersion":"1.9.3","clientCode":"personal","clientName":"Personal","portalName":"Apps","fieldWorkerFlag":false,"testMode":false,"contactEmailAddress":"smarshburn@iccu.com","formStatus":"Saved","timeRequest":"2018-05-22T07:16:13-06:00","timeSubmission":"2018-05-22T07:16:36-06:00","timeLastUserActivity":"2018-05-22T07:17:35-06:00","ipAddress":"65.121.129.2","requestCookie":"JSESSIONID=BJdcsPcdUtaXrk_C0VXDcVWBFuUjFwW3UBlHJpjP.1; AWSELB=F5C5B727122402F47FEF068CAFEBC5A8C36A58A8E623D9E1450C652E2C343B2B1F40E3B83B4D087F76D14851E4D94528311FA7D54776B381F5BBFA8E7AECFE9B49F9E605F0FD2DA944382DE78C8888E9FB49C68F64; _bcvm_vrid_3535619737041707416=878145959563459844T91BD8C6E6014F1EAAA8990D8B3276D3507AA2276BA4FDB9328D693141D96FE6024D81534AF63548C1CDAA3232AFFCAF94B48D1CF3B47CA576486F81CB7EBF4B2; _bcvm_vid_3535619737041707416=878146565933679342T0216E464EF2CCE60951ED6BB9C455E9BC79A1B76FB840715A50603A298C7747CC91CEEB6FAA59525CA7B7802BA5888F5FCF4F2B8EAA17A51AC5FE194F4BA7697; bc_pv_end=878146568257591045T1ACE628351636108403F173F30DE366EBACC7C360C739BB052D8603C3BE368E287E416161D11E67DC373A0DD45AA8E8B1CF6A2F5DF34D42BC35FC889F8AB4209","userAgent":"Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36","userAgentBrowser":"Chrome 65","userAgentBrowserType":"Chrome","userAgentBrowserVersion":"65","userAgentDeviceType":"Desktop","userAgentOs":"Windows 7","userAgentOsType":"Windows","userAgentOsVersion":"7","dataExtracts":{"MajorProductId":"unknown","MinorProductId":"unknown","NewMembership":"false","ApplicantPersona":"member","debugEmail":"smarshburn@iccu.com"},"deliveryStatus":"Not Ready","dataDeleted":false,"formURL":"https://uat.iccu.avoka-transact.com/apps/servlet/SmartForm.html?submitKey=9d7f9734a5ffcb8be2632a42b7155f08"}]';
        String contentType = 'application/json';

        return this.createResponse(body, contentType);
    }
    
    private HTTPResponse handleGetTransaction(HTTPRequest req) {
        String body = '{"id":61381,"trackingCode":"FFD8F2Z","submitKey":"9d7f9734a5ffcb8be2632a42b7155f08","taskFlag":false,"formCode":"triage","formName":"Triage","formVersion":"1.9.3","clientCode":"personal","clientName":"Personal","portalName":"Apps","fieldWorkerFlag":false,"testMode":false,"contactEmailAddress":"smarshburn@iccu.com","formStatus":"Saved","timeRequest":"2018-05-22T07:16:13-06:00","timeSubmission":"2018-05-22T07:16:36-06:00","timeLastUserActivity":"2018-05-22T07:17:35-06:00","ipAddress":"65.121.129.2","requestCookie":"JSESSIONID=BJdcsPcdUtaXrk_C0VXDcVWBFuUjFwW3UBlHJpjP.1; AWSELB=F5C5B727122402F47FEF068CAFEBC5A8C36A58A8E623D9E1450C652E2C343B2B1F40E3B83B4D087F76D14851E4D94528311FA7D54776B381F5BBFA8E7AECFE9B49F9E605F0FD2DA944382DE78C8888E9FB49C68F64; _bcvm_vrid_3535619737041707416=878145959563459844T91BD8C6E6014F1EAAA8990D8B3276D3507AA2276BA4FDB9328D693141D96FE6024D81534AF63548C1CDAA3232AFFCAF94B48D1CF3B47CA576486F81CB7EBF4B2; _bcvm_vid_3535619737041707416=878146565933679342T0216E464EF2CCE60951ED6BB9C455E9BC79A1B76FB840715A50603A298C7747CC91CEEB6FAA59525CA7B7802BA5888F5FCF4F2B8EAA17A51AC5FE194F4BA7697; bc_pv_end=878146568257591045T1ACE628351636108403F173F30DE366EBACC7C360C739BB052D8603C3BE368E287E416161D11E67DC373A0DD45AA8E8B1CF6A2F5DF34D42BC35FC889F8AB4209","userAgent":"Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36","userAgentBrowser":"Chrome 65","userAgentBrowserType":"Chrome","userAgentBrowserVersion":"65","userAgentDeviceType":"Desktop","userAgentOs":"Windows 7","userAgentOsType":"Windows","userAgentOsVersion":"7","dataExtracts":{"MajorProductId":"unknown","MinorProductId":"unknown","NewMembership":"false","ApplicantPersona":"member","debugEmail":"smarshburn@iccu.com"},"deliveryStatus":"Not Ready","dataDeleted":false,"formURL":"https://uat.iccu.avoka-transact.com/apps/servlet/SmartForm.html?submitKey=9d7f9734a5ffcb8be2632a42b7155f08"}';
        String contentType = 'application/json';

        return this.createResponse(body, contentType);
    }
    
    private HTTPResponse handleUpdateTransaction(HTTPRequest req) {
        String body = '{"id":61381,"trackingCode":"FFD8F2Z","submitKey":"9d7f9734a5ffcb8be2632a42b7155f08","taskFlag":false,"formCode":"triage","formName":"Triage","formVersion":"1.9.3","clientCode":"personal","clientName":"Personal","portalName":"Apps","fieldWorkerFlag":false,"testMode":false,"contactEmailAddress":"smarshburn@iccu.com","formStatus":"Saved","timeRequest":"2018-05-22T07:16:13-06:00","timeSubmission":"2018-05-22T07:16:36-06:00","timeLastUserActivity":"2018-05-22T07:17:35-06:00","ipAddress":"65.121.129.2","requestCookie":"JSESSIONID=BJdcsPcdUtaXrk_C0VXDcVWBFuUjFwW3UBlHJpjP.1; AWSELB=F5C5B727122402F47FEF068CAFEBC5A8C36A58A8E623D9E1450C652E2C343B2B1F40E3B83B4D087F76D14851E4D94528311FA7D54776B381F5BBFA8E7AECFE9B49F9E605F0FD2DA944382DE78C8888E9FB49C68F64; _bcvm_vrid_3535619737041707416=878145959563459844T91BD8C6E6014F1EAAA8990D8B3276D3507AA2276BA4FDB9328D693141D96FE6024D81534AF63548C1CDAA3232AFFCAF94B48D1CF3B47CA576486F81CB7EBF4B2; _bcvm_vid_3535619737041707416=878146565933679342T0216E464EF2CCE60951ED6BB9C455E9BC79A1B76FB840715A50603A298C7747CC91CEEB6FAA59525CA7B7802BA5888F5FCF4F2B8EAA17A51AC5FE194F4BA7697; bc_pv_end=878146568257591045T1ACE628351636108403F173F30DE366EBACC7C360C739BB052D8603C3BE368E287E416161D11E67DC373A0DD45AA8E8B1CF6A2F5DF34D42BC35FC889F8AB4209","userAgent":"Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36","userAgentBrowser":"Chrome 65","userAgentBrowserType":"Chrome","userAgentBrowserVersion":"65","userAgentDeviceType":"Desktop","userAgentOs":"Windows 7","userAgentOsType":"Windows","userAgentOsVersion":"7","dataExtracts":{"MajorProductId":"unknown","MinorProductId":"unknown","NewMembership":"false","ApplicantPersona":"member","debugEmail":"smarshburn@iccu.com"},"deliveryStatus":"Not Ready","dataDeleted":false,"formURL":"https://uat.iccu.avoka-transact.com/apps/servlet/SmartForm.html?submitKey=9d7f9734a5ffcb8be2632a42b7155f08"}';
        String contentType = 'application/json';

        return this.createResponse(body, contentType);
    }

}