@RestResource(urlMapping='/accountopening/application/*')
global with sharing class AOApplicationRestService {

    @HttpPost
    global static AOApplicationRestResponse createApplication() {
        String requestBody = AORestHelper.getRequestBody();
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(requestBody);

        // Validate the request contains the necessary values.
        List<String> messages = new List<String>();
        if (!String.isBlank(request.application_id)) {
            messages.add('POST is not supported with an application_id; try PUT to update an application.');
        }
        AOApplicationRestService.validateCommonRequestValues(request, messages);
        if (messages.size() > 0) {
            return getErrorResponse(messages, request.application_id, 400);
        }

        try {
            return AOApplicationRestService.processDelivery(request, requestBody, 201);
        } catch (Exception e) {
            messages.add('Creating the application failed: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            return getErrorResponse(messages, request.application_id, 500);
        }
    }

    @HttpGet
    global static AOApplicationRestResponse getApplication() {
        Map<String, String> params = RestContext.request.params;
        String applicationId = params.get('applicationId');

        // Validate the request contains the application Id.
        List<String> messages = new List<String>();
        if (String.isBlank(applicationId)) {
            messages.add('GET is not supported without an applicationId.');
            return getErrorResponse(messages, applicationId, 400);
        }

        // Validate that there is at least one prior request for the application.
        List<AccountOpeningRequest__c> lastApplicationRequests = [
            SELECT Id,
                RequestData__c
            FROM AccountOpeningRequest__c
            WHERE ApplicationId__c = :applicationId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (lastApplicationRequests.size() == 0) {
            messages.add('The application_id was not found.');
            return getErrorResponse(messages, applicationId, 400);
        }
        AccountOpeningRequest__c lastApplicationRequest = lastApplicationRequests[0];

        // Parse the original request and return the response.
        try {
            String jsonPayload = lastApplicationRequest.RequestData__c;
            if (jsonPayload.left(1) != '{' && jsonPayload.right(1) != '}') {
                jsonPayload = AORestHelper.decompressRequest(jsonPayload);
            }
            AOApplicationRestRequest lastRestRequest = (AOApplicationRestRequest)JSON.deserialize(jsonPayload, AOApplicationRestRequest.class);
            AOApplicationRestResponse response = AOApplicationRestResponse.getInstance(null, applicationId, lastRestRequest);
            RestResponse res = RestContext.response;
            res.statusCode = 200;
            return response;
        } catch (Exception e) {
            messages.add('Retrieving the application failed: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            return getErrorResponse(messages, applicationId, 500);
        }
    }

    @HttpPut
    global static AOApplicationRestResponse updateApplication() {
        String requestBody = AORestHelper.getRequestBody();
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(requestBody);

        // Validate the request contains the necessary values.
        List<String> messages = new List<String>();
        if (String.isBlank(request.application_id)) {
            messages.add('PUT is not supported without an application_id; try POST to create an application.');
        }
        AOApplicationRestService.validateCommonRequestValues(request, messages);
        if (messages.size() > 0) {
            return getErrorResponse(messages, request.application_id, 400);
        }

        try {
            return AOApplicationRestService.processDelivery(request, requestBody, 202);
        } catch (Exception e) {
            messages.add('Creating the application failed: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            return getErrorResponse(messages, request.application_id, 500);
        }
    }

    private static AOApplicationRestResponse getErrorResponse(List<String> messages, String applicationId, Integer statusCode) {
        RestResponse res = RestContext.response;
        AOApplicationRestResponse response = new AOApplicationRestResponse(messages, applicationId);
        res.statusCode = statusCode;
        return response;
    }

    private static void validateCommonRequestValues(AOApplicationRestRequest request, List<String> messages) {
        if (request.applicant == null || request.applicant.person == null) {
            messages.add('An applicant and applicant.person must be provided.');
        }
        if (request.form == null) {
            messages.add('Form information must be provided.');
        }
    }

    /**
     * Process the delivered information by parsing the decision log/system information and
     * then call the persistence layer.
     */
    private static AOApplicationRestResponse processDelivery(AOApplicationRestRequest request, String requestBody, Integer successStatusCode) {
        // If an application id is not present, assign one using the UUID class.
        if (String.isBlank(request.application_id)) {
            Uuid uniqueId = new Uuid();
            request.application_id = uniqueId.getValue();
        }

        // Determine if the uncompressed requestBody can be stored in the Account Opening Request object.  If not,
        // use the compressed content sent from the Account Opening application.
        if (requestBody.length() > ObjectUtils.MAX_TEXT_FIELD_LENGTH) {
            RestRequest req = RestContext.request;
            requestBody = req.requestBody.toString();
        }

        // Create a searchable name for the application that includes the applicant's name and tracking code.
        String applicationName = request.form.tracking_code;
        applicationName += ' - ' + (request.applicant.person.first_name != null ? request.applicant.person.first_name + ' ' : '') + request.applicant.person.last_name;

        // Create the Account Opening Request log entry
        AccountOpeningRequest__c aoRequest = new AccountOpeningRequest__c();
        aoRequest.name = applicationName;
        aoRequest.jobReferenceCode__c = request.form.job_reference_code;
        aoRequest.trackingCode__c = request.form.tracking_code;
        aoRequest.applicationId__c = request.application_id;
        aoRequest.formName__c = request.form.name;
        aoRequest.applicantEmail__c = request.applicant.person.email;
        aoRequest.processingStatus__c = AOConstants.ACCOUNT_OPENING_STATUS_READY;
        aoRequest.requestData__c = requestBody.left(ObjectUtils.MAX_TEXT_FIELD_LENGTH);
        insert aoRequest;

        try {
            // This is the only parser that is required from the original XML delivery process.
            AODecisionLogParser decisionLogParser = new AODecisionLogParser();
            AOApplicationInfo appInfo = new AOApplicationInfo(request);
            decisionLogParser.parsePayload(appInfo);

            // Identify if there are any errors for the application.
            appInfo.detectErrorState();

            // Persist the application using the original persistence code.
            Opportunity o = AOApplicationDataController.persistApplicationInfo(appInfo);

            // Mark the request as complete.
            aoRequest.processingStatus__c = AOConstants.ACCOUNT_OPENING_STATUS_COMPLETE;
            aoRequest.opportunity__c = o != null ? o.id : null;
            update aoRequest;
        } catch (Exception e) {
            // Record the error on the Account Opening Request record.
            aoRequest.processingStatus__c = AOConstants.ACCOUNT_OPENING_STATUS_FAILED;
            aoRequest.errorMessage__c = e.getMessage() + ' - ' + e.getStackTraceString();
            update aoRequest;
        }

        RestResponse res = RestContext.response;
        res.statusCode = successStatusCode;
        AOApplicationRestResponse response = new AOApplicationRestResponse(null, aoRequest.applicationId__c);
        return response;
    }

}