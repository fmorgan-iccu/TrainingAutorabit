/**
 * Interface describing the behaviors of an eSignature Provider
 */
public interface IESignProvider {

    /**
     * Sends a set of eSignature document templates to a given set of recipients to participate in a signing ceremony.
     * @param request The signing ceremony request to be sent for signatures
     */
    void sendCeremonyForESignature(ESignSendCeremonyRequest request);
}