/**
 *	Class for authenticating with the DNA core system.
 *
 */
public with sharing class DNAAuthenticationManager implements IAuthenticationManager {

    // This bypass mode can be used in the development environment if there is ever an issue
    // connecting to the CCM system.  This will cause the data provider to use the appropriate
    // mock response.  The system will not be fully functional, but can allow development of
    // modifications to continue.  Enabling this will cause some of the unit tests to fail!  So,
    // don't try to deploy this enabled.
    public static final Boolean DNA_CORE_AUTH_BYPASS_MODE = false;

    public DNAAuthenticationManager() {
    }
    
    /**
     *	Authenticates a user with DNA, and if successful, stores the ticket in the ticket cache.
     *  @param credential The DNA credentials of the user
     *	@return whether the user successfully authenticated, or not
     *  @throws IllegalArgumentException when the passed in credentials are null in any way.
     */
    public boolean authenticateUser(IAuthenticationCredential credential) {
        if (credential == null || !(credential instanceof IPasswordCredential)) {
            throw new IllegalArgumentException('Credential must be an instance of IPasswordCredential');
        }
        
        IPasswordCredential passwordCredential = (IPasswordCredential)credential;
        
        if (passwordCredential.getUsername() == null || passwordCredential.getPassword() == null) {
            throw new IllegalArgumentException('Credentials for authentication were null!');
        }

        String signOnBody = this.buildSignOnEnvelope(credential);

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getDNASignOnEndpoint();
        
        Http http = new Http();
        HttpRequest signOnRequest = this.createRequest('text/xml; charset=utf-8');
        signOnRequest.setEndpoint(endpoint);
        signOnRequest.setHeader('SOAPAction', 'http://www.opensolutions.com/DirectSignon');
        signOnRequest.setBody(signOnBody);

        HttpResponse signOnResponse = null;
        if (DNA_CORE_AUTH_BYPASS_MODE) {
            signOnResponse = (new MockDNAResponse()).respond(signOnRequest);
        } else {
            signOnResponse = http.send(signOnRequest);
        }

        Dom.Document doc = signOnResponse.getBodyDocument();
        String signOnResult = this.parseSignOnResponse(doc);

        if (signOnResult == null) {
            return false;
        }

        String whoIsBody = this.buildGetWhoisTicketEnvelope(signOnResult);

        HttpRequest ticketRequest = this.createRequest('text/xml; charset=utf-8');
        ticketRequest.setEndpoint(endpoint);
        ticketRequest.setHeader('SOAPAction', 'http://www.opensolutions.com/WhoIs');
        ticketRequest.setBody(whoIsBody);

        HttpResponse ticketResponse = null;
        if (DNA_CORE_AUTH_BYPASS_MODE) {
            ticketResponse = (new MockDNAResponse()).respond(ticketRequest);
        } else {
            ticketResponse = http.send(ticketRequest);
        }

        Dom.Document ticketDoc = ticketResponse.getBodyDocument();
        String ticket = this.parseWhoIsResponse(ticketDoc);

        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue(ticket, UserSessionCache.DNA_TICKET);

        return true;
    }

    /**
     *	Determines if the user is logged in or not.
     *	@return whether the user is authenticated.
     */
    public boolean isUserAuthenticated() {
        UserSessionCache sessionCache = new UserSessionCache();
        String ticket = sessionCache.getValue(UserSessionCache.DNA_TICKET);
        boolean isAuthenticated = ticket != null;

        return isAuthenticated;
    }

    /**
     *	Logs the user out and destroys their cached ticket, if applicable
     */
    public void logOut() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue(null, UserSessionCache.DNA_TICKET);
    }

// ===========================
// PRIVATE API
// ===========================

    private HTTPRequest createRequest(String contentType) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        request.setClientCertificateName(proxyCertName);
        request.setMethod(EndpointManager.HTTP_METHOD_POST);
        request.setHeader('Content-Type', contentType);

        return request;
    }

    private String buildSignOnEnvelope(IAuthenticationCredential credential) {
        if (!(credential instanceof IPasswordCredential)) {
            throw new IllegalArgumentException('Credential must be an instance of IPasswordCredential');
        }
        
        IPasswordCredential passwordCredential = (IPasswordCredential)credential;
        
        String request =
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soap:Body>' +
            '<DirectSignon xmlns="http://www.opensolutions.com/">' +
            '<xmlRequest>' +
            '&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;' +
            '&lt;DirectSSORequest MessageDateTime=&quot;2017-04-06T11:35:30.9939169-06:00&quot; TrackingId=&quot;31f38d6b-2789-4e67-86f9-b5c14b873d8b&quot;&gt;' +
            '&lt;DeviceId&gt;MSCIS1030&lt;/DeviceId&gt;' +
            '&lt;UserId&gt;' + passwordCredential.getUsername().toUppercase() + '&lt;/UserId&gt;' +
            '&lt;Password&gt;' + passwordCredential.getPassword() + '&lt;/Password&gt;' +
            '&lt;ProdEnvCd&gt;PRODUCTION&lt;/ProdEnvCd&gt;' +
            '&lt;ProdDefCd&gt;SAF2006&lt;/ProdDefCd&gt;' +
            '&lt;/DirectSSORequest&gt;' +
            '</xmlRequest>' +
            '</DirectSignon>' +
            '</soap:Body>' +
            '</soap:Envelope>';

        return request;
    }

    private String buildGetWhoisTicketEnvelope(String ssoTicket) {
        String innerEnvelopeBody =
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soap:Body>' +
            '<WhoIs xmlns="http://www.opensolutions.com/">' +
            '<xmlRequest></xmlRequest>'+
            '</WhoIs>' +
            '</soap:Body>' +
            '</soap:Envelope>';

        String whoIsRequest =
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<WhoIsRequest MessageDateTime="2017-04-06T13:08:40.0047621-06:00" TrackingId="0a7c3856-1284-40e9-ab90-702c92427c69" SSOTicket="' + ssoTicket +'">' +
            '<LookupSSOTicket>'+ ssoTicket + '</LookupSSOTicket>' +
            '</WhoIsRequest>';

        Dom.Document document = new Dom.Document();
        document.load(innerEnvelopeBody);

        Dom.XMLNode rootNode = document.getRootElement();
        Dom.XMLNode body = rootNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode whoIs = body.getChildElement('WhoIs', 'http://www.opensolutions.com/');
        Dom.XMLNode xmlRequest = whoIs.getChildElement('xmlRequest', 'http://www.opensolutions.com/');
        xmlRequest.addTextNode(whoIsRequest);

        return document.toXmlString();
    }

    private String parseSignOnResponse(Dom.Document doc) {
        //Retrieve the root element for this document.
        Dom.XMLNode rootNode = doc.getRootElement();
        Dom.XMLNode body = rootNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode response = body.getChildElement('DirectSignonResponse', 'http://www.opensolutions.com/');
        Dom.XMLNode result = response.getChildElement('DirectSignonResult', 'http://www.opensolutions.com/');

        boolean successful = false;

        Dom.Document responseDoc = new Dom.Document();
        responseDoc.load(result.getText());

        Dom.XMLNode responseRoot = responseDoc.getRootElement();

        for (integer i = 0; i < responseRoot.getAttributeCount(); i++) {
            String attributeKey = responseRoot.getAttributeKeyAt(i);
            String attributeNamespace = responseRoot.getAttributeKeyNsAt(i);

            if (attributeKey == 'Successful') {
                String attributeValue = responseRoot.getAttributeValue(attributeKey, attributeNamespace);
                successful = attributeValue == 'true';
                break;
            }
        }

        if (!successful) {
            System.debug('authentication failed!');
            return null;
        }

        //System.debug('authentication succeeded!');

        String ssoTicket = responseRoot.getChildElement('SSOTicket', null).getText();

        //System.debug('ticket: ' + ssoTicket);

        return ssoTicket;
    }

    private String parseWhoIsResponse(Dom.Document doc) {
        Dom.XMLNode rootNode = doc.getRootElement();
        Dom.XMLNode body = rootNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode response = body.getChildElement('WhoIsResponse', 'http://www.opensolutions.com/');
        Dom.XMLNode result = response.getChildElement('WhoIsResult', 'http://www.opensolutions.com/');

        return result.getText();
    }

    private void printChildNodes(Dom.XMLNode node) {
        System.debug('printing children of ' + node.getName() + ':');
        for (Dom.XMLNode child : node.getChildElements()) {
            System.debug(child.getNamespace() + ':' + child.getName() + ' : ' + child.getText());
        }
    }
}