/**
 *	Data provider for obtaining open product applications from Encompass.
 */
public with sharing class EncompassProductApplicationDataProvider implements IProductApplicationDataProvider {    
	private IAuthenticationManager authenticationManager;
    private IEncompassTokenManager tokenManager;

	public EncompassProductApplicationDataProvider(IAuthenticationManager authenticationManager, IEncompassTokenManager tokenManager) {
		this.authenticationManager = authenticationManager;
        this.tokenManager = tokenManager;
	}

    public ProductApplicationResponse getOpenProductApplications(IPerson person, DateTime startDate, DateTime endDate) {
        if (person == null || person.getTaxId() == null) {
            throw new IllegalArgumentException('Person must not be null, nor the taxID of the person.');
        }

        if (endDate == null) {
            endDate = System.now();
        }

        if (startDate == null) {
            startDate = endDate.addDays(-60); // Default to two months into the past
        }

        EncompassToken token = this.tokenManager.getToken();

        if (token == null) {
            this.authenticationManager.authenticateUser(null);
        }

        List<String> loanIDs = this.getLoanIDs(person, startDate, endDate);

        if (loanIDs.size() == 0) {
            return new ProductApplicationResponse(new List<EncompassProductApplication>(), null);
        }
        
        List<EncompassProductApplication> applications = new List<EncompassProductApplication>();
        
        for (String loanId : loanIDs) {
            EncompassProductApplication application = this.getLoan(loanId);
            
            applications.add(application);
        }

        ProductApplicationResponse response = new ProductApplicationResponse(applications, null);

		return response;
	}
    
    public IAuthenticationManager getAuthenticationManager() {
		return this.authenticationManager;
	}
    
    public String getSystemName() {
        return 'Encompass';
    }
    
    /**
     * Gets the loan IDs associated with a person.
     * @param person The IPerson for whom the search should be made.
     * @param startDate The start date for the query
     * @param endDate The start date for the query
     * @return A list of loan IDs associated with the person.
     */
    private List<String> getLoanIDs(IPerson person, DateTime startDate, DateTime endDate) {
        Http http = new Http();
        HttpRequest cursorRequest = this.createCursorRequest(person, startDate, endDate);
        
        HttpResponse response = http.send(cursorRequest);
        
        if (response.getStatusCode() != 200) {
            throw new DataServiceException('There was a problem getting the cursor request. ');
        }

        List<Object> objects = (List<Object>)JSON.deserializeUntyped(response.getBody());
        List<String> loanIDs = new List<String>();

        for (Object obj : objects) {
            Map<String, Object> rawLoanID = (Map<String, Object>)obj;

            String loanID = (String)rawLoanID.get('loanGuid');
	
            if (loanID != null) {
                loanIDs.add(loanID);
            }
        }

		return loanIDs;
    }
    
    /**
	 *	Fetches a loan based on its Encompass ID
	 *	@param loanID The ID of the loan to fetch
	 *	@return A corresponding EncompassProductApplication instance that matches the ID
	 */
    private EncompassProductApplication getLoan(String loanID) {
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();
        
        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getEncompassLoanEndpoint() + loanID;

		HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(EndpointManager.HTTP_METHOD_GET);
        request.setClientCertificateName(proxyCertName);

        this.addSecurityToRequest(request);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 200) {
            throw new DataServiceException('Unable to get loan. HTTP Status: ' + response.getStatusCode() + ' Data: ' + response.getBody());
        }

        Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        
        List<ProductApplicationMilestone> milestones = this.getMilestonesForLoan(loanID);
        ProductApplicationMilestone currentMilestone = null;
        ProductApplicationAgent currentAgent = null;
        ProductApplicationAgent loanOfficer = null;
        
        boolean isComplete = true;
        
        for (ProductApplicationMilestone milestone : milestones) {
            currentMilestone = milestone;
            currentAgent = milestone.getAgent();
            
            if (currentAgent != null && currentAgent.isLoanOfficer()) {
                loanOfficer = currentAgent;
            }

            // break on the first milestone that isn't complete
            if (!milestone.getIsComplete()) {
                milestone.setIsCurrentMilestone(true);
                isComplete = false;
                break;
            }
        }

        String status = 'Unknown';
        if (currentMilestone != null) {
            status = currentMilestone.getDisplayName();
        }

        boolean isFunded = false;
        

        Map<String, Object> funding = (Map<String, Object>)responseData.get('funding');
        if (funding != null) {
            String fundingDate = (String)funding.get('fundsSentDate');

            if (fundingDate != null && fundingDate.length() > 0) {
                isFunded = true;
            }
        }

        String applicationNumber = (String)responseData.get('loanIdNumber');
        String productName = (String)responseData.get('loanProgramName');
        integer creditScore = null;

        List<ProductApplicationNote> notes = new List<ProductApplicationNote>();
        EncompassProductApplication application = new EncompassProductApplication(currentAgent, applicationNumber, creditScore, isComplete, isFunded, loanOfficer, milestones, notes, productName, status);

        return application;
    }
    
    /**
     *	Gets the loan milestones from Encompass
	 *	@param loanID The ID of the loan
	 *	@return List of ProductApplicationMilestone for the loan
     */
    @TestVisible
    private List<ProductApplicationMilestone> getMilestonesForLoan(String loanID) {
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();
        
        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getEncompassLoanMilestonesEndpoint();
        endpoint = endpoint.replace('%@', loanID);
        
        HttpRequest request = new HttpRequest();
        request.setMethod(EndpointManager.HTTP_METHOD_GET);
        request.setEndpoint(endpoint);
        request.setClientCertificateName(proxyCertName);
        
        this.addSecurityToRequest(request);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 200) {
            throw new DataServiceException('There was a problem getting the loan milestones.');
        }
        
        List<ProductApplicationMilestone> milestones = new List<ProductApplicationMilestone>();
        
        List<Object> objects = (List<Object>)JSON.deserializeUntyped(response.getBody());
        
        for (Object obj : objects) {
            
            Map<String, Object> rawMilestone = (Map<String, Object>)obj;
            Map<String, Object> rawAssociate = (Map<String, Object>)rawMilestone.get('loanAssociate');
            
            String displayName = (String)rawMilestone.get('milestoneName');
            boolean isComplete = (boolean)rawMilestone.get('doneIndicator');
            
            if (isComplete == null) {
                isComplete = false;
            }

            ProductApplicationAgent agent = null;

            if (rawAssociate != null) {
                String name = (String)rawAssociate.get('name');
                String phone = (String)rawAssociate.get('phone');
                String email = (String)rawAssociate.get('email');
                
                boolean isLoanOfficer = false;
                String roleName = (String)rawAssociate.get('roleName');
                if (roleName != null && roleName.equals('Loan Officer')) {
                    isLoanOfficer = true;
                }

                // Sanity check
                if (name != null) {
                    agent = new ProductApplicationAgent(email, isLoanOfficer, name, phone);
                }
            }

            String rawDate = (String)rawMilestone.get('startDate');
            if (rawDate != null) {
                rawDate = rawDate.replace('T', ' ');
            }
            
            DateTime statusDate = DateTime.valueOfGmt(rawDate);

            ProductApplicationMilestone milestone = new ProductApplicationMilestone(agent, displayName, isComplete, false, statusDate);
            milestones.add(milestone);
        }

        return milestones;
    }
    
    /*
     * 	Adds the Authorization header to an HttpRequest
     *	@param request The HttpRequest for adding authentication headers.
     */
    private void addSecurityToRequest(HttpRequest request) {
        // Adding in authentication.
        if (this.authenticationManager instanceof EncompassAuthenticationManager) {
            EncompassAuthenticationManager mgr = (EncompassAuthenticationManager)this.authenticationManager;

            // Making sure we are authenticated...
            if (!mgr.isUserAuthenticated()) {
                throw new UnauthenticatedException('Service not authenticated.');
            }
            
            ServiceParameterManager paramManager = new ServiceParameterManager();
            String proxyCertName = paramManager.getProxyCertificateName();

            EncompassToken encompassToken = this.tokenManager.getToken();
            String tokenType = encompassToken.getTokenType();
            String token = encompassToken.getToken();
            String authValue = tokenType + ' ' + token;

            request.setHeader('Authorization', authValue);
            request.setClientCertificateName(proxyCertName);
        }
    }
    
    /**
     * Creates an HTTPRequest for getting a loan cursor for a member.  Will perform a search by SSN.
     * @param person The person for which the search should be performed.
     * @param startDate The start date for the query
     * @param endDate The start date for the query
     * @return HttpRequest for searching
     */
    private HttpRequest createCursorRequest(IPerson person, DateTime startDate, DateTime endDate) {        
        String ssn = person.getTaxId();
        
        Map<String, Object> borrowerTerm = this.createTermNode('Fields.65', 'exact', ssn);
        Map<String, Object> coborrowerTerm = this.createTermNode('Fields.97', 'exact', ssn);
        
        List<Map<String, Object>> borrowerTermsList = new List<Map<String, Object>>();
        borrowerTermsList.add(borrowerTerm);
        borrowerTermsList.add(coborrowerTerm);
        
        Map<String, Object> borrowerTerms = this.createOperatorTermsNode('or');
        borrowerTerms.put('terms', borrowerTermsList);

        String formattedStart = this.formatDateForRequest(startDate);
        String formattedEnd = this.formatDateForRequest(endDate);
        Map<String, Object> startDateTerm = this.createTermNode('Loan.LastModified', 'greaterThanOrEquals', formattedStart);
        Map<String, Object> endDateTerm = this.createTermNode('Loan.LastModified', 'lessThanOrEquals', formattedEnd);
        
        List<Map<String, Object>> dateTermsList = new List<Map<String, Object>>();
        dateTermsList.add(startDateTerm);
        dateTermsList.add(endDateTerm);
        
        Map<String, Object> dateTerms = this.createOperatorTermsNode('and');
        dateTerms.put('terms', dateTermsList);
        
        List<Map<String, Object>> filterTerms = new List<Map<String, Object>>();
        filterTerms.add(borrowerTerms);
        filterTerms.add(dateTerms);

        Map<String, Object> filterBody = this.createOperatorTermsNode('and');
        filterBody.put('terms', filterTerms);

        Map<String, Object> dataRoot = new Map<String, Object>();
        dataRoot.put('filter', filterBody);

        String jsonRequestBody = JSON.serialize(dataRoot);
        
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getEncompassSSNSearchEndpoint();
        
        HttpRequest request = new HttpRequest();
        request.setMethod(EndpointManager.HTTP_METHOD_GET);
        request.setEndpoint(endpoint);
        request.setBody(jsonRequestBody);
        request.setClientCertificateName(proxyCertName);

        this.addSecurityToRequest(request);

        return request;
    }
    
    private Map<String, Object> createOperatorTermsNode(String operatorValue) {
        Map<String, Object> node = new Map<String, Object>();
        node.put('operator', operatorValue);
        
        return node;
    }
    
    private Map<String, Object> createTermNode(String canonicalName, String matchType, String value) {
        Map<String, Object> node = new Map<String, Object>();
        node.put('canonicalName', canonicalName);
        node.put('matchType', matchType);
        node.put('value', value);
        
        return node;
    }

    @TestVisible
    private String formatDate(DateTime dateToFormat) {
        String formattedDate = dateToFormat.format('M/d/yyyy');
        return formattedDate;
    }

    @TestVisible
    private String formatDateForRequest(DateTime dateToFormat) {
        String formattedDate = dateToFormat.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        return formattedDate;
    }
}