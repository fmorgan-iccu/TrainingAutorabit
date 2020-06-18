/**
 * MuleSoft implementation of an eSignature Provider
 */
public class MuleSoftESignProvider implements IESignProvider {
    public String endpoint { get; private set; }
    public String clientId { get; private set; }
    public String clientSecret { get; private set; }

    public MuleSoftESignProvider(String endpoint, String clientId, String clientSecret) {
        if (endpoint == null) {
            throw new IllegalArgumentException('endpoint cannot be null.');
        }

        if (clientId == null) {
            throw new IllegalArgumentException('clientId cannot be null.');
        }

        if (clientSecret == null) {
            throw new IllegalArgumentException('clientSecret cannot be null.');
        }

        this.endpoint = endpoint;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }

    public void sendCeremonyForESignature(ESignSendCeremonyRequest ceremonyRequest) {
        if (ceremonyRequest == null) {
            throw new IllegalArgumentException('ceremony cannot be null.');
        }

        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();
        Map<String, Object> serializedCeremony = serializer.serializeSendCeremonyRequest(ceremonyRequest);
        String json = JSON.serialize(serializedCeremony);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.endpoint);
        request.setBody(json);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('client_id', this.clientId);
        request.setHeader('client_secret', this.clientSecret);
        request.setMethod(EndpointManager.HTTP_METHOD_POST);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            throw new DataServiceException('Unable to submit signing ceremony ' + response.getStatusCode() + ' Data: ' + response.getBody());
        }
    }

}