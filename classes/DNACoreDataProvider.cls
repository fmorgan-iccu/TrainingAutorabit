/*
 * Master class for accessing data through Fiserv DNA.
 */
public virtual class DNACoreDataProvider {

    // This bypass mode can be used in the development environment if there is ever an issue
    // connecting to the CCM system.  This will cause the data provider to use the appropriate
    // mock response.  The system will not be fully functional, but can allow development of
    // modifications to continue.  Enabling this will cause some of the unit tests to fail!  So,
    // don't try to deploy this enabled.
    public static final Boolean DNA_CORE_BYPASS_MODE = false;

    private IAuthenticationManager authenticationManager;

    public DNACoreDataProvider() {
        this.authenticationManager = new DNAAuthenticationManager();
    }

    // For testing only...
    public DNACoreDataProvider(IAuthenticationManager authenticationManager) {
        this.authenticationManager = authenticationManager;
    }

    public IAuthenticationManager getAuthenticationManager() {
        return this.authenticationManager;
    }

// Protected Methods

    /**
     *  Makes a call to the DNA API
     *  @param request Fully-formed DNA request payload.
     *  @return List of responses for the given requests.
     */
    protected List<Map<String, Object>> callApi(Map<String, Object> request) {
        String body = JSON.serialize(request);

        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getDNAServiceEndpoint();

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();

        httpRequest.setEndpoint(endpoint);
        httpRequest.setClientCertificateName(proxyCertName);
        httpRequest.setMethod(EndpointManager.HTTP_METHOD_POST);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody(body);

        // LogUtils.debug(body, 'callApiBody-');

        HTTPResponse response = null;
        if (DNA_CORE_BYPASS_MODE) {
            response = (new MockDNAResponse()).respond(httpRequest);
        } else {
            response = http.send(httpRequest);
        }

        String responseBody = response.getBody();
        if (responseBody == null) {
            return null;
        }

        // LogUtils.debug(responseBody, 'Response:');

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        if (jsonData == null) {
            return null;
        }

        List<Map<String, Object>> responses = this.parseResponse(jsonData);
        return responses;
    }

    /**
     *  Creates the request envelope for interacting with the DNA API.
     *  @param requests List of requests to send to DNA
     *  @return Fully formed service request to DNA.
     */
    protected Map<String, Object> createGenericRequest(List<Map<String, Object>> requests) {
        List<Map<String, Object>> requestsElement = new List<Map<String, Object>>();
        requestsElement.addAll(requests);

        Map<String, Object> input = new Map<String, Object> {
            'Requests' => requestsElement,
            'UserAuthentication' => this.createUserAuthentication()
        };

        Map<String, Object> request = new Map<String, Object> {
            'Input' => input
        };

        return request;
    }

    /**
     *  Convenience method for creating the request envelope for interacting with the DNA API.
     *  @param request The request to send to DNA
     *  @return Fully formed service request to DNA.
     */
    protected Map<String, Object> createGenericRequest(Map<String, Object> request) {
        List<Map<String, Object>> requestList = new List<Map<String, Object>> {
            request
        };

        return this.createGenericRequest(requestList);
    }

    /**
     *  Parses a DNA date string and returns a DateTime object
     *  @param dnaDate The DNA date to parse
     *  @return DateTime object corresponding to the DNA date, if valid.  Nullable.
     */
    @TestVisible
    protected DateTime parseDNADate(String dnaDate) {
        if (dnaDate == null) {
            return null;
        }

        // System.debug('passed Date: ' + dnaDate);

        Integer startIndex = dnaDate.indexOf('(');
        Integer endIndex = dnaDate.indexOf('-0');

        if (startIndex == -1 || endIndex == -1) {
            return null;
        }

        String substringDate = dnaDate.substring(startIndex + 1, endIndex);
        DateTime dateInstance = DateTime.newInstance(Long.valueOf(substringDate));

        return dateInstance;
    }

    /**
     * Creates a DNA date string.  Because dates are all stored in UTC format, this will ensure that the UTC time is set
     * to match Mountain time.
     */
    @TestVisible
    protected String createDNADate(Date d) {
        Time t = Time.newInstance(0, 0, 0, 0);
        Datetime dt = Datetime.newInstance(d, t);
        String dnaDate = createDNADate(dt);
        return dnaDate;
    }

    /**
     *  Creates a DNA date string from a DateTime object
     *  @param sfDate The DateTime to convert
     *  @return DNA date string
     */
    @TestVisible
    protected String createDNADate(DateTime d) {
        if (d == null) {
            return null;
        }

        // Determine the offset for the current daylight savings time.  The change in sign and zero padding are to
        // convert the offset to a DNA format.  For example, a MST datetime will result in a "-0700".
        Integer offset = DateUtils.getTimezoneOffsetHours() * 100;
        String timezoneOffset = '';
        if (offset < 0) {
            timezoneOffset = '-' + String.valueOf(-offset).leftPad(4, '0');
        } else {
            timezoneOffset = '+' + String.valueOf(offset).leftPad(4, '0');
        }

        String dnaTime = '/Date('+ d.getTime() + timezoneOffset + ')/';
        return dnaTime;
    }

    /**
     *  Parses DNA errors
     *  @param errorList The list of errors that were given by DNA.
     *  @return An error messages that can be given to the client
     */
    @TestVisible
    protected String parseErrors(List<Object> errorList) {
        String errorMessages = '';

        List<Map<String, Object>> errors = APIUtils.convertObjectList(errorList);
        for (Map<String, Object> rawError : errors) {
            String message = (String)rawError.get('ErrorMessage');
            errorMessages += message + ' ';
        }

        return errorMessages;
    }

    /**
     * Parses address data returned by DNA
     * @param desiredType The type of address desired.
     * @param rawAddresses The List of raw objects to parse
     * @return The address desired, if it exists in the list.
     */
    @TestVisible
    protected DNAAddress parseAddress(AddressType desiredType, List<Map<String, Object>> rawAddresses) {
        if (desiredType == null || rawAddresses == null) {
            return null;
        }

        String desiredTypeCode = addressCodeForAddressType(desiredType);
        for (Map<String, Object> rawAddress : rawAddresses) {
            String useCode = (String)rawAddress.get('AddressUseCode');
            if (!useCode.equals(desiredTypeCode)) {
                continue;
            }

            // Determine which address lines represent lines 1 and 2.  DNA defines the lowest line
            // number to be the first address line, the next lowest to be line 2, etc.  See
            // view_get_pers_address for details of the query.
            String line1 = null;
            String line2 = null;
            Integer line1Number = null;
            Integer line2Number = null;
            List<Map<String, Object>> addressLines = APIUtils.convertObjectList((List<Object>)rawAddress.get('AddressLines'));
            for (Map<String, Object> addressLine : addressLines) {
                Integer lineNumber = (Integer)addressLine.get('AddressLineNumber');
                if (line1Number == null || lineNumber < line1Number) {
                    line1 = (String)addressLine.get('AddressLineText');
                    line1Number = lineNumber;
                }
            }
            for (Map<String, Object> addressLine : addressLines) {
                Integer lineNumber = (Integer)addressLine.get('AddressLineNumber');
                if (lineNumber > line1Number && (line2Number == null || lineNumber < line2Number)) {
                    line2 = (String)addressLine.get('AddressLineText');
                    line2Number = lineNumber;
                }
            }

            String addressLine = line1 + (line2 != null ? '\n' + line2 : '');
            String city = (String)rawAddress.get('CityName');
            String stateCode = (String)rawAddress.get('StateCode');
            String countryCode = (String)rawAddress.get('CountryCode');
            String postalCode = (String)rawAddress.get('ZipCode');

            return new DNAAddress(city, countryCode, postalCode, stateCode, addressLine, AddressType.PRIMARY);
        }

        return null;
    }

    /**
     * Parses email addresses returned by DNA
     * @param desiredType The type of email address desired.
     * @param rawEmailAddresses The List of raw objects to parse
     * @return The email address, if it exists in the list.
     */
    protected String parseEmail(String desiredType, List<Map<String, Object>> rawEmailAddresses) {
        if (desiredType == null) {
            return null;
        }

        for (Map<String, Object> rawEmailAddress : rawEmailAddresses) {
            String emailType = (String)rawEmailAddress.get('AddressUseCode');

            if (!emailType.equals(desiredType)) {
                continue;
            }

            List<Map<String, Object>> addressList = APIUtils.convertObjectList((List<Object>)rawEmailAddress.get('ElectronicAddressLines'));

            // There's not reason this should be a single object list.  Instead of adding tons of code
            // to 'safely' pull this out, we're forcing it.
            Map<String, Object> addressLines = addressList[0];

            String emailAddress = (String)addressLines.get('AddressLineText');
            return emailAddress;
        }

        return null;
    }

    /**
     * Parses Phone Numbers returned by DNA
     * @param desiredType The type of phone number desired.
     * @param rawPhoneNumbers The List of raw objects to parse
     * @return The phone number indicated, if it exists in the list.
     */
    protected String parsePhoneNumber(String desiredType,  List<Map<String, Object>> rawPhoneNumbers) {
        if (desiredType == null) {
            return null;
        }

        for (Map<String, Object> rawNumber : rawPhoneNumbers) {
            String phoneType = (String)rawNumber.get('PhoneUseCode');

            if (!phoneType.equals(desiredType)) {
                continue;
            }

            String areaCode = (String)rawNumber.get('AreaCode');
            String exchange = (String)rawNumber.get('Exchange');
            String suffix = (String)rawNumber.get('PhoneNumber');
            String extension = (String)rawNumber.get('PhoneExtension');

            String fullNumber = '(' + areaCode + ') ' + exchange + '-' + suffix + (extension != null ? ' Ext: ' + extension : '');
            return fullNumber;
        }

        return null;
    }

    /**
     * Parses Tax IDs returned by DNA
     * @param desiredType The type of Tax ID desired.
     * @param rawTaxIds The List of raw objects to parse
     * @return The Tax ID indicated, if it exists in the list.
     * Currently only used for Organization tax ID's.
     */
    protected String parseTaxIDs(String taxIdCode, List<Map<String, Object>> rawTaxIds) {
        if (taxIdCode == null) {
            return null;
        }

        for (Map<String, Object> rawTaxId : rawTaxIds) {
            String code = (String)rawTaxId.get('TaxIdTypeCode');

            if (code != null && taxIdCode.equals(code)) {
                String taxId = (String)rawTaxId.get('TaxIdDisplay');
                String taxIdDigitsOnly = taxId.remove('-');
                if (taxIdDigitsOnly.length() == 9) {
                    String formattedTaxId = taxIdDigitsOnly.left(2) + '-' + taxIdDigitsOnly.right(7);
                    return formattedTaxId;
                } else {
                    return taxIdDigitsOnly;
                }
            }
        }

        return null;
    }

    /**
     * Maps an address type to its corresponding String code
     * @param addressType The type of address
     * @return The corresponding DNA String code.  If a case is missing, will return null
     */
    @TestVisible
    protected String addressCodeForAddressType(AddressType addressType) {
        switch on addressType {
            when ALTERNATE {
                return 'ALT';
            }
            when BIRTHPLACE {
                return 'POB';
            }
            when INTEREST {
                return 'INT';
            }
            when NOTICE {
                return 'NOTC';
            }
            when PRIMARY {
                return 'PRI';
            }
            when SEASONAL {
                return 'SEA';
            }
            when STATEMENTOVERRIDE {
                return 'STMT';
            }
            when TAX {
                return 'IRS';
            }
            when else {
                return null;
            }
        }
    }

    @TestVisible
    protected String addressLineCodeForAddressLineType(AddressLineType addressLineType) {
        switch on addressLineType {
            when POST_OFFICE_BOX_NUMBER {
                return 'POBN';
            }
            when INTERNAL_MAIL_STOP {
                return 'INTL';
            }
            when APARTMENT_NUMBER {
                return 'APTN';
            }
            when STREET {
                return 'ST';
            }
            when ATTENTION {
                return 'ATTN';
            }
            when BUILDING_NUMBER {
                return 'BLDG';
            }
            when ROOM_NUMBER {
                return 'ROOM';
            }
            when SUITE_NUMBER {
                return 'STE';
            }
            when RURAL_ROUTE_NUMBER {
                return 'RR';
            }
            when HIGHWAY_ROUTE_NUMBER {
                return 'HC';
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Maps a phone number type to its corresponding String code
     * @param phoneType The type of phone number
     * @return The corresponding DNA String code.  If a case is missing, will return null
     */
    @TestVisible
    protected String phoneCodeForPhoneNumberType(PhoneNumberType phoneType) {
        switch on phoneType {
            when BUSINESS {
               return 'BUS';
            }
            when CELL {
                return 'CELL';
            }
            when DONOTCALL {
                return 'DNC';
            }
            when FAX {
                return 'FAX';
            }
            when HOME {
                return 'PER';
            }
            when OTHER {
                return 'OTH';
            }
            when PAGER {
                return 'PAGE';
            }
            when RELATIVE {
                return 'REL';
            }
            when SEASONAL {
                return 'SEA';
            }
            when VACATION {
                return 'VAC';
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Maps an email type to its corresponding String code
     * @param emailType The type of Email
     * @return The corresponding DNA String code.  If a case is missing, will return null
     */
    @TestVisible
    protected String emailCodeForEmailType(EmailAddressType emailType) {
        switch on emailType {
            when BUSINESS {
                return 'EBUS';
            }
            when NPS {
                return 'ENPS';
            }
            when PRIMARY {
                return 'EHOM';
            }
            when RECEIPT {
                return 'RCPT';
            }
            when else {
                return null;
            }
        }
    }

// Private Methods

    /**
     *  Does a first-pass validation and parsing of a DNA network response.
     *  @param response The map that was returned from a service call to DNA.
     *  @return List<Map<String, Object>> of responses given back by DNA
     */
    private List<Map<String, Object>> parseResponse(Map<String, Object> response) {
        if (response == null) {
            return null;
        }

        //System.debug('parsing Output');
        Map<String, Object> output = (Map<String, Object>)response.get('Output');

        if (output == null) {
            return null;
        }

        //System.debug('parsing UserAuthentication');
        Map<String, Object> userAuthentication = (Map<String, Object>)output.get('UserAuthentication');

        if (userAuthentication == null) {
            return null;
        }

        //System.debug('parsing WasSuccessful');
        List<Object> authErrors = (List<Object>)userAuthentication.get('Errors');

        if (authErrors != null) {
            throw new UnauthenticatedException('Please log into DNA.');
        }

        List<Map<String, Object>> responses = APIUtils.convertObjectList((List<Object>)output.get('Responses'));

        //System.debug('finished parsing responses...' + responses);
        return responses;
    }

    /**
     *  Convenience method that builds the authentication portion of a network request.
     *  @return Map containing all the authentication details for a network request.
     *  @throws UnauthenticatedException if the DNA ticket is NOT in the cache.
     */
    private Map<String, Object> createUserAuthentication() {
        UserSessionCache sessionCache = new UserSessionCache();
        String ticket = sessionCache.getValue(UserSessionCache.DNA_TICKET);

        if (ticket == null) {
            throw new UnauthenticatedException('Please log into DNA.');
        }

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String applNumber = paramManager.getDNAApplNumber();
        String networkNode = paramManager.getDNANetworkNodeName();
        Integer authType = Integer.valueOf(paramManager.getDNAAuthorizationType());

        // This json object needs to get added to every request. The whoIsTicket is different per user.
        Map<String, Object> userAuthMap = new Map<String, Object> {
            'ApplNumber' => applNumber,
            'AuthorizationType' => authType,
            'NetworkNodeName' => networkNode,
            'Password' => ticket
        };

        return userAuthMap;
    }
}