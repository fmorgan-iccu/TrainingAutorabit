/**
 * Model object representing a request to be sent to eSign.
 */
public class ESignSendCeremonyRequest {
    /**
     * ceremony The eSign ceremony to send for eSignatures.
     */
    public ESignCeremony ceremony { get; private set; }
    
    public ESignSendCeremonyRequest(ESignCeremony ceremony) {
        this.ceremony = ceremony;
    }
}