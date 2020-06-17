public with sharing class COOPTravelNotificationDataProvider implements ICardTravelNotificationDataProvider {

    public static final String ICCU_ROUTING_NUMBER = '324173626';
    private static final String RESPONSE_OKAY_STATUS = 'OK';

    // This bypass mode can be used in the development environment if there is ever an issue
    // connecting to the CO-OP system.  This will cause the data provider to use the appropriate
    // mock response.  The system will not be fully functional, but can allow development of
    // modifications to continue.  Enabling this will cause some of the unit tests to fail!  So,
    // don't try to deploy this enabled.
    public static final Boolean COOP_BYPASS_MODE = false;

    public COOPTravelNotificationDataProvider() {
    }

    public Boolean cancelTravelNotification(String cardNumber, String detailId) {
        String requestBody = getTravelCancellationBody(cardNumber, detailId);
        Map<String, Object> responseJson = callApi('/travelNotificationCancellation', requestBody);
        Boolean successful = responseJson.containsKey('status') && responseJson.get('status') == RESPONSE_OKAY_STATUS;

        return successful;
    }

    public String getProviderName() {
        return 'COOP';
    }

    public List<CardTravelNotificationInfo> getTravelNotification(String cardNumber) {
        String requestBody = getTravelInquiryBody(cardNumber);
        Map<String, Object> responseData = callApi('/travelNotificationInquiry', requestBody);

        // Verify that the response is well formed.
        if ((String)responseData.get('status') != RESPONSE_OKAY_STATUS ||
            !responseData.containsKey('results'))
        {
            return null;
        }

        List<Object> resultList = (List<Object>)responseData.get('results');
        List<Map<String, Object>> resultData = APIUtils.convertObjectList(resultList);
        if (resultData == null || resultData.size() == 0) {
            return null;
        }

        List<CardTravelNotificationInfo> travelNotifications = new List<CardTravelNotificationInfo>();
        for (Map<String, Object> notificationData : resultData) {
            if (!notificationData.containsKey('notification')) {
                continue;
            }

            notificationData = (Map<String, Object>)notificationData.get('notification');

            Map<String, Object> cardholder = (Map<String, Object>)notificationData.get('cardholder');
            if (cardholder == null) {
                return null;
            }
            String firstName = (String)cardholder.get('firstName');
            String lastName = (String)cardholder.get('lastName');
            String primaryPhone = (String)cardholder.get('primaryPhone');

            // This implementation assumes a homogenous set of from/to dates and notes.  As such,
            // these values will only be retireved from the first entry of details.  If the
            // crmTravelForm code is updated to support different dates for various locations,
            // this will need to be revisited.
            // TODO:  The dates are not in fact the same accross each of the detail entries!
            // Need to create separate travel notification entries for each detail...
            List<Object> detailObjects = (List<Object>)notificationData.get('details');
            List<Map<String, Object>> travelDetails = APIUtils.convertObjectList(detailObjects);
            List<CardTravelNotificationInfo.Detail> details = new List<CardTravelNotificationInfo.Detail>();
            for (Map<String, Object> travelDetail : travelDetails) {
                String detailId = (String)travelDetail.get('id');
                String fDate = (String)travelDetail.get('fromDate');
                String tDate = (String)travelDetail.get('toDate');
                Date fromDate = Date.valueOf(fDate);
                Date toDate = Date.valueOf(tDate);
                String stateCode = (String)travelDetail.get('state');
                String countryCode = (String)travelDetail.get('country');
                CountryUtils.Country country = CountryUtils.getCountryByAlpha2(countryCode);
                if (country != null) {
                    countryCode = country.code;
                }
                String note = (String)travelDetail.get('note');

                CardTravelNotificationInfo.Detail detail = new CardTravelNotificationInfo.Detail(detailId, fromDate, toDate, stateCode, countryCode, note);
                details.add(detail);
            }

            CardTravelNotificationInfo info = new CardTravelNotificationInfo(cardNumber, firstName, lastName, primaryPhone, details);
            travelNotifications.add(info);
        }

        return travelNotifications;
    }

    public Boolean updateTravelNotification(CardTravelNotificationInfo info) {
        String requestBody = getTravelUpdateRequestBody(info);
        Map<String, Object> responseJson = callApi('/travelnotification', requestBody);
        Boolean successful = responseJson.containsKey('status') && responseJson.get('status') == 'OK';

        return successful;
    }

// Private Methods

    private Map<String, Object> callApi(String servicePath, String requestBody) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        EndpointManager endpointMgr = new EndpointManager();
        String endpoint = endpointMgr.getCoopConciergeEndpoint() + servicePath;

        ServiceAccounts__c serviceAccount = [
            SELECT apiClientSecret__c
            FROM ServiceAccounts__c
            WHERE serviceName__c = 'CO-OP'
            LIMIT 1
        ];
        String apiClientSecret = serviceAccount.apiClientSecret__c;

        ServiceParameterManager paramManager = new ServiceParameterManager();
        String proxyCertName = paramManager.getProxyCertificateName();
        request.setClientCertificateName(proxyCertName);

        request.setEndpoint(endpoint);
        request.setMethod(EndpointManager.HTTP_METHOD_POST);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', apiClientSecret);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Version', '1');
        request.setBody(requestBody);

        // LogUtils.debug(requestBody, 'callApiBody-');

        HttpResponse response = null;
        if (COOP_BYPASS_MODE) {
            response = (new MockCOOPResponse()).respond(request);
        } else {
            response = http.send(request);
        }

        // TODO:  Should a status check be added here?  The documentation doesn't indicate what
        // status codes to expect and it is unknown if error status codes will include a body.

        String responseBody = response.getBody();
        if (responseBody == null) {
            return null;
        }

        // LogUtils.debug(responseBody, 'Response:');

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        if (jsonData == null || !jsonData.containsKey('response')) {
            throw new DataServiceException('CO-OP response is not well formed.');
        }

        // Extract the inner response object.
        jsonData = (Map<String, Object>) jsonData.get('response');

        // Throw exceptions for any errors that occur.
        if (jsonData.containsKey('status') && (String)jsonData.get('status') == 'FAILED') {
            Object exceptionObject = jsonData.get('exceptions');
            List<Map<String, Object>> exceptions = APIUtils.convertObjectList((List<Object>)exceptionObject);
            String exceptionMessage = '';
            for (Map<String, Object> e : exceptions) {
                exceptionMessage += (e.containsKey('detail') ? e.get('detail') + ' ' : '');
            }
            throw new DataServiceException(exceptionMessage);
        }

        return jsonData;
    }

    private String getTravelCancellationBody(String cardNumber, String detailId) {
        if (String.isBlank(cardNumber)) {
            throw new IllegalArgumentException('The card number can\'t be null/empty when cancelling a travel notification.');
        }

        Map<String, Object> cancellationRequest = new Map<String, Object> {
            'rtn' => COOPTravelNotificationDataProvider.ICCU_ROUTING_NUMBER,
            'cardNumber' => cardNumber,
            'detailId' => detailId
        };
        String cancellationBody = JSON.serialize(cancellationRequest);

        return 'cancellation=' + EncodingUtil.urlEncode(cancellationBody, 'UTF-8');
    }

    private String getTravelInquiryBody(String cardNumber) {
        if (cardNumber == null) {
            throw new IllegalArgumentException('The card number can\'t be null when retrieving a travel notification.');
        }

        Map<String, Object> inquiryRequest = new Map<String, Object> {
            'rtn' => COOPTravelNotificationDataProvider.ICCU_ROUTING_NUMBER,
            'cardNumber' => cardNumber
        };
        String inquiryBody = JSON.serialize(inquiryRequest);

        return 'inquiry=' + EncodingUtil.urlEncode(inquiryBody, 'UTF-8');
    }

    private String getTravelUpdateRequestBody(CardTravelNotificationInfo info) {
        if (info.cardNumber == null || info.firstName == null || info.lastName == null || info.details == null) {
            throw new IllegalArgumentException('All arguments are required when creating a travel notification.');
        }

        List<CardTravelNotificationInfo.Detail> infoDetail = info.details;
        for (CardTravelNotificationInfo.Detail detail : infoDetail) {
            if (String.isBlank(detail.stateCode) && String.isBlank(detail.countryCode)) {
                throw new IllegalArgumentException('At least one state or country must be provided when creating a travel notification.');
            }
        }

        // Determine if any of the countries are restricted or blocked.  If any are any restricted
        // countries, submit the request as VIP.  If any are blocked, throw an error.
        Boolean vipRequest = false;
        for (CardTravelNotificationInfo.Detail detail : infoDetail) {
            CountryUtils.Country countryDefinition = CountryUtils.getCountry(detail.countryCode);
            if (countryDefinition == null) {
                throw new IllegalArgumentException('Invalid country code, ' + detail.countryCode + ', provided.');
            }
            if (countryDefinition.coopRestricted) {
                vipRequest = true;
            }
            if (countryDefinition.ofacBlocked) {
                throw new IllegalArgumentException('Travel plans currently cannot be submitted for ' + countryDefinition.name + '.');
            }
        }

        Map<String, Object> institution = new Map<String, Object> {
            'rtn' => COOPTravelNotificationDataProvider.ICCU_ROUTING_NUMBER
        };

        Map<String, Object> cardholder = new Map<String, Object> {
            'cardNumber' => info.cardNumber,
            'firstName' => info.firstName,
            'lastName' => info.lastName,
            'primaryPhone' => info.primaryPhone.replaceAll('[^0-9]', ''),
            'primaryPhoneType' => 'Home'
        };

        Map<String, Object> blockingInstructions = new Map<String, Object> {
            'code' => 'BI02'
        };

        List<Map<String, Object>> details = new List<Map<String, Object>>();
        for (CardTravelNotificationInfo.Detail detail : infoDetail) {
            Map<String, Object> d = new Map<String, Object> {
                'fromDate' => DateUtils.format(detail.fromDate, 'MM/dd/yyyy'),
                'toDate' => DateUtils.format(detail.toDate, 'MM/dd/yyyy'),
                'purpose' => 'OTH',
                'note' => detail.note
            };
            if (detail.stateCode != null) {
                d.put('state', detail.stateCode);
                d.put('country', 'US');
            } else {
                // Per the CO-OP APIs, the system uses 2 character character codes, see
                // https://idahocentral.atlassian.net/wiki/spaces/SYS/pages/43352072/CO-OP+API
                CountryUtils.Country countryDefinition = CountryUtils.getCountry(detail.countryCode);
                String countryCodeAlpha2 = countryDefinition.codeAlpha2;

                d.put('country', countryCodeAlpha2);
            }
            details.add(d);
        }

        Map<String, Object> notificationData = new Map<String, Object> {
            'notification' => new Map<String, Object> {
                'vip' => (vipRequest ? 'Y' : 'N'),
                'institution' => institution,
                'cardholder' => cardholder,
                'details' => details
            }
        };
        if (!vipRequest) {
            Map<String, Object> notification = (Map<String, Object>)notificationData.get('notification');
            notification.put('blockingInstructions', blockingInstructions);
        }

        String notificationBody = JSON.serialize(notificationData);

        return 'notification=' + EncodingUtil.urlEncode(notificationBody, 'UTF-8');
    }

}