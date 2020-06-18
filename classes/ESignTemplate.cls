/**
 * Model object representing a document template of an eSignature process.
 */
public class ESignTemplate {
    /**
     * id The ID of the template for the ESign provider
     */
    public String id { get; private set; }

    /**
     * sequence The order in which the template should appear in the envelope to sign
     */
    public Integer sequence { get; private set; }

    /**
     * recipients The individuals that should receive the envelope to sign
     */
    public List<ESignRecipient> recipients { get; private set; }

    public ESignTemplate(String id, Integer sequence, List<ESignRecipient> recipients) {
        this.id = id;
        this.sequence = sequence;
        this.recipients = recipients;
    }
}