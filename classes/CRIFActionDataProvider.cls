/**
 *	Data provider for obtaining open product applications from CRIF Action.
 */
public class CRIFActionDataProvider implements IProductApplicationDataProvider {
    private static String APP_META_STATUS = 'APP_META_STATUS';
    private static String APP_META_PRODUCT_NAME = 'APP_META_PRODUCT_NAME';
    private static String APP_META_ID = 'APP_META_ID';

    private IAuthenticationManager authManager;
    
    @TestVisible
    private CRIFActionDataProvider(IAuthenticationManager authManager) {
        this.authManager = authManager;
    }
    
    public CRIFActionDataProvider() {
        this.authManager = new CRIFActionAuthenticationManager();
    }
    
    public IAuthenticationManager getAuthenticationManager() {
		return this.authManager;
	}

	public ProductApplicationResponse getOpenProductApplications(IPerson person, DateTime startDate, DateTime endDate) {
        if (endDate == null) {
            endDate = System.now();
        }
        
        if (startDate == null) {
            startDate = endDate.addDays(-60); // Default to two months into the past
        }

        String requestPayload = this.buildApplicationSearchPayload(person, startDate, endDate);

        HttpRequest searchRequest = this.createReqestWithPayload(requestPayload);

        Http http = new Http();
        HttpResponse searchResponse = http.send(searchRequest);

        if (searchResponse.getStatusCode() != 200) {
            throw new DataServiceException('Error response sent by server: ' + searchResponse.getStatusCode());
        }

        String searchResponseBody = searchResponse.getBody();
        List<Dom.XmlNode> searchResponseNodes = this.parseActionResponse(searchResponseBody, 'searchApplication');

        if (searchResponseNodes.size() == 0) {
            return new ProductApplicationResponse(new List<IProductApplication>(), null);
        }

        Dom.XmlNode searchResponseNode = searchResponseNodes[0]; // Only should be one...
        List<String> searchErrors = this.parseErrorsFromResponse(searchResponseNode);
        if (searchErrors.size() > 0) {
            throw new DataServiceException('Error searching for applications: ' + searchErrors);
        }

        Map<String, Map<String, String>> metadata = this.parseApplicationMetadataFromResponse(searchResponseNode);
        Set<String> keys = metadata.keySet();
        List<String> appIDs = new List<String>();
        appIDs.addAll(keys);

        // Take our IDs and let's get the details for all of them:  
        String appPayload = this.buildApplicationDetailsPayload(appIDs);
        HttpRequest appDetailsRequest = this.createReqestWithPayload(appPayload);
        HttpResponse appDetailsResponse = http.send(appDetailsRequest);
        
        // Response check
        if (appDetailsResponse.getStatusCode() != 200) {
            throw new DataServiceException('Error getting app details: ' + appDetailsResponse.getStatusCode());
        }
        
        String appDetailsResponseBody = appDetailsResponse.getBody();
        List<Dom.XmlNode> appDetailsResponseNodes = this.parseActionResponse(appDetailsResponseBody, 'getApplication');
        
        // Iterate through the response nodes and check for errors
        for (Dom.XmlNode node : appDetailsResponseNodes) {
            List<String> detailsErrors = this.parseErrorsFromResponse(node);
            if (detailsErrors.size() > 0) {
                throw new DataServiceException('Error getting application details: ' + searchErrors);
            }
        }

        // At this point, we don't have any errors, so let's start parsing for data...
		List<CRIFActionProductApplication> applications = this.parseProductApplicationsFromResponses(appDetailsResponseNodes, metadata);
        
        ProductApplicationResponse response = new ProductApplicationResponse(applications, null);
        
		return response;
	}
    
    public String getSystemName() {
        return 'CRIF Action';
    }
    
    /**
     * 	Constructs an HTTPRequest for sending to CRIF Action
     *  @param payload The XML payload to send
     * 	@return The HttpRequest to be sent
     */
    private HttpRequest createReqestWithPayload(String payload) {
        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getCRIFActionApplicationSearchEndpoint();
        
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setClientCertificateName(proxyCertName);
        request.setMethod(EndpointManager.HTTP_METHOD_POST);
        request.setHeader('Content-Type', 'text/xml; charset=utf-8');
        request.setHeader('SOAPAction', 'http://tempuri.org/IConnectorService/SubmitEx');
        request.setBody(payload);
        
        return request;
    }

    /**
     * 	Builds a request to search applications by person
     * 	@param person The person for which we are searching for loans
     * 	@return The body payload for sending to Action
     */
    @TestVisible
    private String buildApplicationSearchPayload(IPerson person, DateTime startDate, DateTime endDate) {
        String searchXmlString = 
			'<searchApplication> ' +
				'<applicationSearchQO xmlns:qo="QO"> ' +
                     '<qo:criterion> ' +
                           // Search parameters go in here.
                     '</qo:criterion> ' +
              '</applicationSearchQO> ' +
	       '</searchApplication>';

        Dom.Document searchApp = new Dom.Document();
        searchApp.load(searchXmlString);

        Dom.XmlNode searchNode = searchApp.getRootElement();
        Dom.XmlNode applicationSearchNode = searchNode.getChildElement('applicationSearchQO', null);
        Dom.XmlNode criterionNode = applicationSearchNode.getChildElement('criterion', 'QO');

        // Create all of the nodes
        // Starting with SSN; We have to strip the hyphens out because Action *can't handle the hyphens*!
        String ssn = person.getTaxId().replace('-', '');
        Dom.XmlNode ssnNode = this.createNode('qo:ssn', null, null);
        ssnNode.setAttribute('qo:value', ssn);

        String dateFormatter = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        String formattedEndDate = endDate.format(dateFormatter);
        String formattedStartDate = startDate.format(dateFormatter);

        // Create the begin date
        Dom.XmlNode beginDateNode = this.createNode('qo:beginDate', null, null);
        beginDateNode.setAttribute('qo:value', formattedStartDate);
        
        // Create the end date
        Dom.XmlNode endDateNode = this.createNode('qo:endDate', null, null);
        endDateNode.setAttribute('qo:value', formattedEndDate);

        criterionNode.insertBefore(beginDateNode, null);
        criterionNode.insertBefore(endDateNode, null);
        criterionNode.insertBefore(ssnNode, null);
        

        List<Dom.XmlNode> nodes = new List<Dom.XmlNode>();
        nodes.add(searchNode);

        Dom.Document payload = this.buildRequest(nodes);
        String payloadString = payload.toXmlString();

        return payloadString;
    }

    /**
     * 	Builds a request to search applications by person
     * 	@param person The person for which we are searching for loans
     * 	@return The body payload for sending to Action
     */
    @TestVisible
    private String buildApplicationDetailsPayload(List<String> applicationIDs) {
        List<Dom.XmlNode> appNodes = new List<Dom.XmlNode>();

        for (String appID : applicationIDs) {
            Dom.XmlNode appNode = this.createNode('getApplication', null, null);
            appNode.setAttribute('applicationID', appID);

            appNodes.add(appNode);
        }
        
        Dom.Document doc = this.buildRequest(appNodes);
		String payload = doc.toXmlString();

        return payload;
    }
    
    /**
     *	Constructs an XML node with the given attributes.
     *	@param nodeName The name of the node to create
     *	@param attributes 
     */
    @TestVisible
    private Dom.XmlNode createNode(String name, String namespace, String prefix) {
        Dom.Document doc = new Dom.Document();
        doc.createRootElement(name, namespace, prefix);
        Dom.XmlNode node = doc.getRootElement();

        return node;
    }
    
    /**
     * 	Builds an XML request payload with the necessary parameters to make a CRIF Action service call.
     * 	@param nodes The XML nodes that are unique to a request that should be added to the base XML call.
     *	@return An XML document with the full request.
     */
    @TestVisible
    public Dom.Document buildRequest(List<Dom.XmlNode> nodes) {
        ServiceParameterManager parameterManager = new ServiceParameterManager();
        String interfaceID = parameterManager.getCRIFInterfaceID();
        String user = parameterManager.getCRIFUser();
        
        String envelopeBody = 
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:biz="BizTalkMessage"> ' +
                '<soapenv:Header/> ' +
                '<soapenv:Body> ' +
                    '<tem:SubmitEx> ' +
                        '<tem:theXML> ' +
                        	'<biz:routing> ' +
                                '<biz:org orgID="4" orgCode="ICCU" /> ' +
                                '<biz:action transactionType="API" /> ' +
                                '<biz:user userName="' + user + '" /> ' +
                                '<biz:interface interfaceID="' + interfaceID + '" interfaceIDSpecified="true" /> ' +
                                '<biz:system /> ' +
                                '<biz:approResult /> ' +
                            '</biz:routing> ' +
                            '<biz:body> ' +
                                '<actionAPI version="1"> ' +

            					//	This is where stuff needs to get inserted.

                                '</actionAPI> ' +
                            '</biz:body> ' +
                        '</tem:theXML> ' +
                    '</tem:SubmitEx> ' +
                '</soapenv:Body> ' +
			'</soapenv:Envelope>';
        
        
        Dom.Document document = new Dom.Document();
        document.load(envelopeBody);

        Dom.XMLNode rootNode = document.getRootElement();
        Dom.XMLNode body = rootNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode submitEx = body.getChildElement('SubmitEx', 'http://tempuri.org/');
        Dom.XMLNode theXML = submitEx.getChildElement('theXML', 'http://tempuri.org/');
        Dom.XMLNode bizBody = theXML.getChildElement('body', 'BizTalkMessage');
        Dom.XmlNode actionAPI = bizBody.getChildElement('actionAPI', null);

        for (Dom.XmlNode node : nodes) {
            actionAPI.insertBefore(node, null);
        }

        return document;
    }
    
    /**
     * 	Parses an Action result for the actual underlying response
     * 	@param response The response from Action
     *  @param The name of the result node requested
     * 	@return The XML node result.  Note: The result may contain errors.
     */
    @TestVisible
    private List<Dom.XmlNode> parseActionResponse(String response, String requestNodeName) {
        Dom.Document doc = new Dom.Document();
        doc.load(response);

        Dom.XmlNode envelope = doc.getRootElement();
        Dom.XmlNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XmlNode submitExResponse = body.getChildElement('SubmitExResponse', 'http://tempuri.org/');
        Dom.XmlNode submitExResult = submitExResponse.getChildElement('SubmitExResult', 'http://tempuri.org/');
		Dom.XmlNode bizBody = submitExResult.getChildElement('body', 'BizTalkMessage');
        Dom.XmlNode actionAPI = bizBody.getChildElement('actionAPI', '');
        
        List<Dom.XmlNode> nodes = new List<Dom.XmlNode>();

        for (Dom.XmlNode resultNode : actionAPI.getChildElements()) {
            String resultNodeName = resultNode.getName();

            if (resultNodeName.equals(requestNodeName)) {
                nodes.add(resultNode);
            }
        }

        return nodes;
    }
    
    /**
     * 	Parses an Action result node for application data. Note: Because Action doesn't include certain things in its application details
     *	response, we're having to package off some of this info so that we can use it for the real response.  Instead of creating Yet 
	 *	Another Apex Class, we're just going to toss it into a Map.
     * 	@param resultNode The searchApplication result node from Action
     * 	@return Map of maps.  The Application ID is the key in the returned Map that will then give another Map containing keys corresponding to the static Strings at the beginning of this file.
     */
    @TestVisible
    private Map<String, Map<String, String>> parseApplicationMetadataFromResponse(Dom.XmlNode responseNode) {
        Map<String, Map<String, String>> data = new Map<String, Map<String, String>>();

        Dom.XmlNode appSearchResponse = responseNode.getChildElement('appSearchResponse', 'Messages');
        Dom.XmlNode appSearchResults = appSearchResponse.getChildElement('appSearchResults', 'Messages');

        for (Dom.XmlNode child : appSearchResults.getChildElements()) {
            Map<String, String> values = APIUtils.parseXMLNodeAttributes(child);

            String appID = values.get('appID');
            String productName = values.get('productName');
            String status = values.get('workflowStatusName');

            Map<String, String> metadata = new Map<String, String>();
            metadata.put(APP_META_ID, appID);
            metadata.put(APP_META_STATUS, status);

            data.put(appID, metadata);
        }

        return data;
    }
    
    /**
     * Parses application information from the provided nodes.
     * @param responseNodes The nodes from which to parse the applicationd details
     * @return List of CRIFActionProductApplication objects
     */
    private List<CRIFActionProductApplication> parseProductApplicationsFromResponses(List<Dom.XmlNode> responseNodes, Map<String, Map<String, String>> metadata) {
        List<CRIFActionProductApplication> applications = new List<CRIFActionProductApplication>();
        
        for (Dom.XmlNode responseNode : responseNodes) {
            Dom.XmlNode appExportResponse = responseNode.getChildElement('appExportResponse', 'Messages');
            Dom.XmlNode applicationNodes = appExportResponse.getChildElement('applications', 'Messages');
            
            for (Dom.XmlNode applicationNode : applicationNodes.getChildElements()) {
                ProductApplicationAgent loanOfficer = null;
                
                /*
                 * First, we have to parse out all the parties to the loan so that we can ref them later.
                 */
                Map<String, ProductApplicationAgent> agents = new Map<String, ProductApplicationAgent>();
                List<String> orderedPartyIds = new List<String>();

                Dom.XmlNode partiesNode = applicationNode.getChildElement('parties', 'App');
                List<Dom.XmlNode> partiesNodeChildren = partiesNode.getChildElements();
                
                for (Dom.XmlNode partyChild : partiesNodeChildren) {
                    if (partyChild.getName().equals('user')) {
                        Map<String, String> partyValues = APIUtils.parseXMLNodeAttributes(partyChild);
                        
                        String partyID = partyValues.get('id');
                        String firstName = partyValues.get('firstName');
                        String lastName = partyValues.get('lastName');
                        String fullName = firstName + ' ' + lastName;
                        boolean isLoanOfficer = false;

                        String email = null;
                        String phone = null;

                        Dom.XmlNode contactMechanisms = partyChild.getChildElement('contactMechanisms', partyChild.getNamespace());

                        // Sometimes the contactMechanisms can be null.  In the test data it seems like the system can auto-decision 
                        // loans and it is listed as the user for the loan milestone.
                        if (contactMechanisms != null) {
                            List<Dom.XmlNode> childMechanisms = contactMechanisms.getChildElements();
                            
                            for (Dom.XmlNode mechanism : childMechanisms) {
                                Map<String, String> attribs = APIUtils.parseXMLNodeAttributes(mechanism);
                                String contactType = attribs.get('contactMechanismType');
                                
                                if (contactType.equals('WorkPhone')) {
                                    String phoneNumber = attribs.get('contactString');

                                    // Yay! Manual formatting!
                                    if (phoneNumber != null && phoneNumber.length() == 10) {
                                        phone = phoneNumber.substring(0, 3) + '-' + phoneNumber.substring(3, 6) + '-' + phoneNumber.substring(6);
                                    }
                                } else if (contactType.equals('EMail')) {
                                    email = attribs.get('contactString');
                                }
                            }
                        }
                        
                        Dom.XmlNode partyTypes = partyChild.getChildElement('partyTypes', partyChild.getNamespace());
                        
                        if (partyTypes != null) {
                            List<Dom.XmlNode> childPartyTypes = partyTypes.getChildElements();
                            
                            for (Dom.XmlNode partyType : childPartyTypes) {
                                if (partyType.getText().equals('LoanOfficer')) {
                                    isLoanOfficer = true;
                                    break;
                                }
                            }
                        }

                        ProductApplicationAgent agent = new ProductApplicationAgent(email, isLoanOfficer, fullName, phone);
                        agents.put(partyID, agent);
                        orderedPartyIds.add(partyID);
                    }
                }
                
                // Get the specific application details
                Map<String, String> appValues = APIUtils.parseXMLNodeAttributes(applicationNode);
                String applicationNumber = appValues.get('appNum'); 
                
                // Now let's parse the milestones...
                List<ProductApplicationMilestone> milestones = new List<ProductApplicationMilestone>();
                
                /*
                 * Fun note about `appDetails`: This node will be named differently for each product type.  So we can't depend on a specific element to be present.
                 * Based on my research, there may be more than one element in here
                 */
                Dom.XmlNode appDetails = applicationNode.getChildElement('appDetails', 'App');
                List<Dom.XmlNode> appProducts = appDetails.getChildElements();
                String productName = '';
                
                for (Dom.XmlNode appProduct : appproducts) {
                    Dom.XmlNode appStatuses = appProduct.getChildElement('appDetailStatuses', 'App');
                    Dom.XmlNode appNotes = applicationNode.getChildElement('appNotes', 'App');
                    Dom.XmlNode appScores = applicationNode.getChildElement('scores', 'App');
                    Dom.XmlNode appProductNode = appProduct.getChildElement('product', 'App');

					Map<String, String> productDetails = APIUtils.parseXMLNodeAttributes(appProductNode);
                    if (productDetails.get('name') != null) {
                        productName = productDetails.get('name');
                    }

                    List<Dom.XmlNode> appStatusChildren = appStatuses.getChildElements();
                    
                    // Let's parse notes first!
                    List<ProductApplicationNote> notes = new List<ProductApplicationNote>();
                    for (DOM.XmlNode appNote : appNotes.getChildElements()) {
                        Map<String, String> noteValues = APIUtils.parseXMLNodeAttributes(appNote);
                        DateTime createdDate = this.parseDate(noteValues.get('creationDate'));
                        DateTime updatedDate = this.parseDate(noteValues.get('updatedDate'));
                        String text = noteValues.get('noteEntry');
                        String title = noteValues.get('noteTypeDisplayName');
                        
                        // Parse out the agent
                        DOM.XmlNode agentNode = appNote.getChildElement('noteAuthor', 'App');
                        Map<String, String> agentValues = APIUtils.parseXMLNodeAttributes(agentNode);
                        String agentId = agentValues.get('idRef');
                        ProductApplicationAgent agent = agents.get(agentId);
                        
                        ProductApplicationNote note = new ProductApplicationNote(agent, createdDate, text, title, updatedDate);
                        notes.add(note);
                    }

                    Dom.XmlNode appDetailParties = appProduct.getChildElement('appDetailParties', 'App');
                    for (DOM.XmlNode appDetailParty : appDetailParties.getChildElements()) {
                        Map<String, String> values = APIUtils.parseXMLNodeAttributes(appDetailParty);
                        
                        String appPartyType = values.get('appPartyType');
                        String idRef = values.get('idRef');
                        
                        // Sanity check that we got the party type and id of the party
                        if (appPartyType != null && idRef != null && appPartyType.equals('LoanOfficer')) {
                            loanOfficer = agents.get(idRef);
                        }
                    }
                    
                    integer creditScore = null;
                    
                    if (appScores != null) {
                        for (DOM.XmlNode scoreNode : appScores.getChildElements()) {
                            Map<String, String> scoreMap = APIUtils.parseXMLNodeAttributes(scoreNode);
                            String strScore = scoreMap.get('totalScore');
                            
                            if (strScore != null) {
                                creditScore = Integer.valueOf(strScore);
                            }
                        }
                    }
                    
                    ProductApplicationAgent currentAgent = null;
                    String currentStatus = '';
                    boolean isFunded = false;
                    boolean isAppComplete = false;
                    
                    for (Dom.XmlNode appStatus : appStatusChildren) {
                        Dom.XmlNode statusObj = appStatus.getChildElement('statusObj', 'App');
                        
                        Map<String, String> appStatusValues = APIUtils.parseXMLNodeAttributes(appStatus);
                        Map<String, String> statusObjValues = APIUtils.parseXMLNodeAttributes(statusObj);
                        
                        String finalStatusValue = statusObjValues.get('isFinalStatus');
                        boolean isFinalStatus = finalStatusValue.equals('true');
                        String status = appStatusValues.get('status');
                        
                        // This is the CRIF Action status that lets us know if it is funded.
                        if (status.equals('ContractStatus_Contracted')) {
                            isFunded = true;
                        }
                        
                        // Making these statuses a little more user friendly...                    
                        List<String> prefixes = new List<String>();
                        prefixes.add('DecisionStatus_');
                        prefixes.add('WorkflowStatus_');
                        prefixes.add('ContractReviewStatus_');
                        prefixes.add('ContractStatus_');
                        
                        for (String prefix : prefixes) {
                            if (status.contains(prefix)) {
                                status = status.replace(prefix, '');
                                break;
                            }
                        }
                        
                        currentStatus = status.replace('_', ' ');
                        
                        /**
                         * 	CRIF Action doesn't tell us anything about milestones being complete...sadly.  We're going to have to fudge some things...
                         * 	Without more information there are a lot of assumptions being made about these...
                         */
                        integer index = appStatusChildren.indexOf(appStatus);
                        integer lastIndex = appStatusChildren.size() - 1;

                        // It is complete if it is isn't the last step.
                        boolean isComplete = index != lastIndex;
                        boolean isCurrentMilestone = index == lastIndex; 

                        // It can also be considered complete if isFinalStatus="true"
                        if (!isComplete && isFinalStatus) {
                            isComplete = true;
                            isAppComplete = true;
                        }

                        Dom.XmlNode createdByUserNode = appStatus.getChildElement('lastUpdatedByUser', 'App');
                        Map<String, String> createdAttributes = APIUtils.parseXMLNodeAttributes(createdByUserNode);
                        String userID = createdAttributes.get('idRef');

                        DateTime statusDate = this.parseDate(appStatusValues.get('dateUpdated'));

                        ProductApplicationAgent agent = agents.get(userID);
                        ProductApplicationMilestone milestone = new ProductApplicationMilestone(agent, status, isComplete, isCurrentMilestone, statusDate);
                        
                        milestones.add(milestone); 

                        if (isCurrentMilestone) {
                            currentAgent = milestone.getAgent();
                        }
                    }

                    CRIFActionProductApplication application = new CRIFActionProductApplication(currentAgent, applicationNumber, creditScore, isAppComplete, isFunded, loanOfficer, milestones, notes, productName, currentStatus);
                    applications.add(application);
                }
            }
        }
        
        return applications;
    }
    
    /**
     * 	Parses an Action result for errors
     * 	@param result The result node from an Action response
     * 	@return List of applicable errors from the response.
     */
    @TestVisible
    private List<String> parseErrorsFromResponse(Dom.XmlNode result) {
        List<String> errors = new List<String>();
        
        for (Dom.XMLNode child : result.getChildElements()) {
            if (child.getName().equals('errors')) {
                Dom.XMLNode errorsChild = result.getChildElement('errors', null);
                
                for (Dom.XmlNode badChild : errorsChild.getChildElements()) {
                    String text = badChild.getText();
                    if (text != null) { // Sanity check
                        errors.add(text);
                    }
                }
            }
        }

        return errors;
    }
    
    /**
     * Parses a GMT date and creates a DateTime object.
     * @param strDate The string date to convert to DateTime
     * @return A DateTime instance that corresponds to the 
     */ 
    private DateTime parseDate(String strDate) {
        if (strDate == null) {
            return null;
        }

        strDate = strDate.replace('T', ' ');
        DateTime newDate = DateTime.valueOfGmt(strDate);
        return newDate;
    }

}