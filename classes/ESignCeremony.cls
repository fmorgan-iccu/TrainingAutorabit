/**
 * Model object representing a signing ceremony of an eSignature process.
 */
public class ESignCeremony {
    /**
     * subject The email subject that should appear on the notification a recipient receives.
     */
	public String subject { get; private set; }

    /**
     * templates The templates that should be used in the eSignature process.
     */
    public List<ESignTemplate> templates { get; private set; }

    /**
     * customFields The custom fields (invisible to the user) that should be associated with the documents.
     */
    public List<ESignCustomField> customFields { get; private set; }

    public ESignCeremony(String subject, List<ESignTemplate> templates, List<ESignCustomField> customFields) {
        this.subject = subject;
        this.templates = templates;
        this.customFields = customFields;
    }
}