public virtual class CCMDataProvider implements ICardDataProvider {

    // This bypass mode can be used in the development environment if there is ever an issue
    // connecting to the CCM system.  This will cause the data provider to use the appropriate
    // mock response.  The system will not be fully functional, but can allow development of
    // modifications to continue.  Enabling this will cause some of the unit tests to fail!  So,
    // don't try to deploy this enabled.
    public static final Boolean CCM_BYPASS_MODE = false;

    private static final String CARD_STATUS_ACTIVE              = 'Active';         // ON
    private static final String CARD_STATUS_EXPIRED             = 'Expired';        // OFF
    private static final String CARD_STATUS_FRAUD               = 'Fraud';          // OFF
    private static final String CARD_STATUS_INACTIVE            = 'Inactive';       // OFF
    private static final String CARD_STATUS_REPORTED_LOST       = 'ReportedLost';   // OFF <---- UI
    private static final String CARD_STATUS_REPORTED_STOLEN     = 'ReportedStolen'; // OFF
    private static final String CARD_STATUS_REVOKED             = 'Revoked';        // OFF
    private static final String CARD_STATUS_SCRATCHED           = 'Scratched';      // OFF
    private static final String CARD_STATUS_SENT_NOT_RECEIVED   = 'SentNotReceived';    // OFF
    private static final String CARD_STATUS_WAITING             = 'WaitingOnActivation';    // Waiting For Activation

    private IAuthenticationManager authManager;

    public CCMDataProvider() {
        this.authManager = new CCMAuthenticationManager();
    }

    // Typically used for testing, but any legitimate situation where we want to inject the auth manager.
    public CCMDataProvider(IAuthenticationManager authManager) {
        this.authManager = authManager;
    }

    /**
     * ICardDataProvider method to get a list of AccountCardInfo objects
     * @param personNumber The unique ID of a person
     * @return List of AccountCardInfo objects
     */
    public List<AccountCardInfo> getAccountCardInfo(String personNumber) {
        if (personNumber == null) {
            throw new IllegalArgumentException('Person number may NOT be null');
        }

        if (this.authManager.isUserAuthenticated() == false) {
            throw new UnauthenticatedException('Please sign into CCM.');
        }

        String endpointPath = '/api/v1/parties/' + personNumber + '/relationships?PageSize=100';
        String method = EndpointManager.HTTP_METHOD_GET;

        Map<String, Object> responseData = this.callApi(method, endpointPath, null);

        List<AccountCardInfo> cards = this.parsePartyResponse(responseData);

        return cards;
    }

    /**
     * ICardDataProvider method to update AccountCardInfo objects
     * @param personNumber The unique ID of a person
     * @param requests The list of UpdateAccountCardInfoRequest objects to update
     * @return List of AccountCardInfo objects
     */
    public void updateAccountCardStatuses(String personNumber, List<UpdateAccountCardInfoRequest> requests) {
        if (this.authManager.isUserAuthenticated() == false) {
            throw new UnauthenticatedException('Please sign into CCM.');
        }

        if (personNumber == null) {
            throw new IllegalArgumentException('PersonNumber may NOT be null.');
        }

        if (requests == null || requests.size() == 0) {
            throw new IllegalArgumentException('Requests may NOT be null nor empty.');
        }

        if (Limits.getCallouts() + requests.size() > Limits.getLimitCallouts()) {
            throw new IllegalArgumentException('Unable to process all requests due to governance limits. Submit a smaller batch.');
        }

        List<Map<String, Object>> payloads = new List<Map<String, Object>>();

        // Validate and build the payloads first, then we'll execute them.
        for (UpdateAccountCardInfoRequest request : requests) {

            if (request.status == null) {
                throw new IllegalArgumentException('Must provide a new status for the card.');
            }

            AccountCardInfo info = request.cardInfo;

            if (info == null) {
                throw new IllegalArgumentException('Card info cannot be null!');
            }

            if (info.cardNumber == null) {
                throw new IllegalArgumentException('Card number cannot be null!');
            }

            if (info.providerName == null) {
                throw new IllegalArgumentException('Missing provider name for card.');
            }

            if (!info.providerName.equals(this.getProviderName())) {
                throw new IllegalArgumentException('The provider name for this request (' + info.providerName + ') cannot be serviced by (' + this.getProviderName() + ').');
            }

            Map<String, Object> payload = new Map<String, Object>{
                'CardNumber' => info.cardNumber,
                'CardStatus' => request.status,
                'ForceTransaction' => 'true',
                'ChannelType' => 'ExternalInteractive',
                'Source' => 'API'
            };

            payloads.add(payload);
        }

        // All the payloads are validated and constructed, time to make the requests

        String method = EndpointManager.HTTP_METHOD_POST;
        String endpointPath = '/api/v1/cardDeactivations';

        for (Map<String, Object> payload : payloads) {
            Map<String, Object> responseData = this.callApi(method, endpointPath, payload);

            String responseCode = (String)responseData.get('responseCode');
            String expectedCode = 'Success';

            if (expectedCode != responseCode) {
                String error = (String)responseData.get('errorMessage');
                throw new DataServiceException('Unable to process card status update: ' + error);
            }

            // This request succeeded, so no need to do anything.
        }
    }

    /**
     * ICardDataProvider method to get the authentication manager of this system
     * @return IAuthenticationManager implementation of this instance
     */
    public IAuthenticationManager getAuthenticationManager() {
        return this.authManager;
    }

    public String getProviderName() {
        return 'CCM';
    }

    /**
     * Call the CCM API
     * @param method The HTTP method to use
     * @param endpointPath The URI of the endpoint to call.
     * @param bodyData JSON-compatible map of data to send to CCM
     * @return Map of data from the request
     */
    private Map<String, Object> callApi(String method, String endpointPath, Map<String, Object> bodyData) {
        HTTPRequest request = this.createRequest(method, endpointPath, bodyData);

        HTTP http = new HTTP();
        HTTPResponse response = null;
        if (CCM_BYPASS_MODE) {
            response = (new MockCCMResponse()).respond(request);
        } else {
            response = http.send(request);
        }

        Integer statusCode = response.getStatusCode();
        Boolean statusOK = statusCode >= 200 && statusCode < 400;

        if (statusCode == 401) { // Not authenticated
            // The user is no longer logged in.  Reset the session state.
            authManager.logOut();
            throw new UnauthenticatedException('Please sign into CCM.');
        }

        Map<String, Object> responseMap =  null;
        String body = response.getBody();
        if (body == null) {
            throw new DataServiceException('CCM did not return any data.');
        }

        try {
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        } catch(Exception e) {
            throw new DataServiceException('CCM returned non-JSON data.');
        }

        if (!statusOK) {
            String message = null;
            if (responseMap != null && responseMap.containsKey('errorMessage')) {
                message = (String)responseMap.get('errorMessage');
            } else if (responseMap != null && responseMap.containsKey('message')) {
                message = (String)responseMap.get('message');
            } else {
                message = 'Unable to make CCM call.';
            }

            throw new DataServiceException(message);
        }

        return responseMap;
    }

    /**
     * Create an HTTPRequest to interact with CCM
     * @param method The HTTP method to use
     * @param endpointPath The URI of the endpoint to call.
     * @param payload JSON-compatible map of data to send to CCM
     * @return Request to execute to CCM
     */
    private HTTPRequest createRequest(String method, String endpointPath, Map<String, Object> bodyData) {
        if (method == null) {
            method = EndpointManager.HTTP_METHOD_GET;
        }

        // Body data
        String body = null;
        if (bodyData != null) {
            body = JSON.serialize(bodyData);
        }

        // Client Certificate
        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        // Endpoint
        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getCCMAPIEndpoint() + endpointPath;

        // Authentication Header
        UserSessionCache sessionCache = new UserSessionCache();
        String authToken = sessionCache.getValue(UserSessionCache.CCM);
        String authHeaderValue = 'AuthToken ' + authToken;

        // Put it all together
        HTTPRequest request = new HTTPRequest();

        if (body != null) {
            request.setBody(body);
        }

        request.setClientCertificateName(proxyCertName);
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', authHeaderValue);
        request.setMethod(method);

        if (method == EndpointManager.HTTP_METHOD_POST) {
            request.setHeader('Content-Type', 'application/json; charset=utf-8');
        }

        return request;
    }

    /**
     * Convenience method for parsing dates from CCM
     * @param ccmDate The string date from CCM
     * @return SalesForce DateTime object
     */
    @TestVisible
    private DateTime parseDate(String ccmDate) {
        if (ccmDate == null) {
            return null;
        }

        String cleanedDate = ccmDate.replace('T', ' ');
        DateTime parsedDate = DateTime.valueOfGmt(cleanedDate);

        return parsedDate;
    }

    // Commenting this out because we don't (yet) have a need to construct dates for APIs...
    /**
     * Convenience method for creating dates for CCM
     * @param sfDate The DateTime date for CCM
     * @return CCM date string representation
     */
    /*@TestVisible
    private String createCCMDate(DateTime sfDate) {
        if (sfDate == null) {
            return null;
        }

        String dateFormatter = 'yyyy-MM-dd\'T\'HH:mm:ss';
        String formattedDate = sfDate.format(dateFormatter);

        return formattedDate;
    }*/

    /**
     * Parses the party response
     * @param response The map to parse information
     * @return Returns a List of AccountCardInfo instances
     */
    private List<AccountCardInfo> parsePartyResponse(Map<String, Object> response) {
        if (response == null) {
            return null;
        }

        List<Map<String, Object>> relationshipInfos = APIUtils.convertObjectList((List<Object>)response.get('relationshipInfos'));

        if (relationshipInfos == null) {
            return null;
        }

        List<AccountCardInfo> cards = new List<AccountCardInfo>();

        for (Map<String, Object> infoMap : relationshipInfos) {
            AccountCardInfo info = this.parseAccountInfo(infoMap);
            if (info != null) {
                cards.add(info);
            }
        }

        return cards;
    }

    /**
     * Parses card info from a map.
     * @param infoMap The map to parse information
     * @return Returns a new AccountCardInfo instance
     */
    private AccountCardInfo parseAccountInfo(Map<String, Object> infoMap) {
        if (infoMap == null) {
            return null;
        }

        // For performance reasons, only set the accountNumber.
        String accountNumber = String.valueOf((Long)infoMap.get('accountNumber'));
        DNAAccount account = new DNAAccount();
        account.setAccountNumber(accountNumber);

        String agreementNumber = null;
        String status = (String)infoMap.get('cardStatus');
        String userFriendlyStatus = this.userFriendlyStatusForStatus(status);
        List<AccountCardInfo.SelectionOption> changeReasons = new List<AccountCardInfo.SelectionOption>();
        List<AccountCardInfo.SelectionOption> applicableStatus = this.getApplicableStatuses(status);
        String cardNumber = (String)infoMap.get('cardNumber');
        String displayName = (String)infoMap.get('productName');
        String displayType = 'Credit';
        String nameOnCard = (String)infoMap.get('partyName');
        String expDateString = (String)infoMap.get('cardExpirationDate');
        DateTime expirationDate = null;
        if (expDateString != null) {
            expirationDate = this.parseDate(expDateString);
        }
        String providerName = this.getProviderName();
        Boolean canChangeStatus = this.canChangeCardStatus(status);
        String typeCode = null;

        AccountCardInfo info = new AccountCardInfo(account, agreementNumber, changeReasons, applicableStatus, canChangeStatus, cardNumber, displayName, displayType, expirationDate, nameOnCard, providerName, status, userFriendlyStatus, typeCode);
        return info;
    }

    /**
     * Determines if a card status can be changed.
     * @param currentStatus The current status of the card in question
     * @return true or false that the status can be changed.
     */
    private Boolean canChangeCardStatus(String currentStatus) {
        List<AccountCardInfo.SelectionOption> applicableStatuses = this.getApplicableStatuses(currentStatus);

        Boolean canChange = applicableStatuses.size() > 0;

        return canChange;
    }

    /**
     * Returns a list of potential statuses that a card can have.
     * @return a list of String objects representing all of the applicable statuses of a card.
     */
    private List<AccountCardInfo.SelectionOption> getApplicableStatuses(String currentStatus) {
        /**
         *  That's right! We only support changing cards that are active.  Otherwise, they can't change it.
         */
        if (currentStatus != CCMDataProvider.CARD_STATUS_ACTIVE) {
            return new List<AccountCardInfo.SelectionOption>();
        }

        List<AccountCardInfo.SelectionOption> applicableStatuses = new List<AccountCardInfo.SelectionOption> {
            new AccountCardInfo.SelectionOption(CARD_STATUS_REPORTED_LOST, AccountCardInfo.USER_FRIENDLY_STATUS_OFF)
        };

        return applicableStatuses;
    }

    /**
     * Converts the system status to a more user friendly version.
     * @param currentStatus The current system status of the card
     */
    private String userFriendlyStatusForStatus(String currentStatus) {
        if (currentStatus == CCMDataProvider.CARD_STATUS_ACTIVE) {
            return AccountCardInfo.USER_FRIENDLY_STATUS_ON;
        } else if (currentStatus == CCMDataProvider.CARD_STATUS_WAITING) {
            return AccountCardInfo.USER_FRIENDLY_STATUS_WAITING_ACTIVATION;
        } else {
            return AccountCardInfo.USER_FRIENDLY_STATUS_OFF;
        }
    }

}