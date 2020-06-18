global with sharing class AOApplicationRestResponse {
    global List<String> error_messages { get; private set; }
    global String application_id { get; private set; }
    global AOApplicationRestRequest application { get; private set; }

    global AOApplicationRestResponse(List<String> errorMessages, String applicationId) {
        this.error_messages = errorMessages;
        this.application_id = applicationId;
    }

    public static AOApplicationRestResponse getInstance(List<String> errorMessages, String applicationId, AOApplicationRestRequest request) {
        AOApplicationRestResponse response = new AOApplicationRestResponse(errorMessages, applicationId);
        response.application = request;
        return response;
    }
}