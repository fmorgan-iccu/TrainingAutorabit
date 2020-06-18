/**
 * Abstract class for mapping JSON data from the front end to the eSign API.
 */
public abstract class ESignAbstractMapper {
    /**
     * jsonData The json data sourced from the client to be mapped.
     */
    public Map<String, Object> jsonData { get; private set;}

    public ESignAbstractMapper(String jsonRepresentation) {
        if (jsonRepresentation == null || jsonRepresentation == '') {
            throw new IllegalArgumentException('The jsonRepresentation cannot be null or empty.');
        }

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(jsonRepresentation);
        this.jsonData = jsonData;
    }

    /**
     *  Abstract method that is implemented by subclasses to produce an ESignSendCeremonyRequest from the source JSON data.
     *  @return ESignSendCeremonyRequest to be sent to the remote system.
	 */
    public abstract ESignSendCeremonyRequest mapRequest();

    /**
     * Get's a template ID for the given template name, if it exists.
     * @param templateName The devloper friendly template name that is unique for a given document template.
     * @return The unique identifier of the template that corresponds to the template ID
     */
    public DocumentTemplate__mdt getTemplateMetadata(String templateName) {
        if (templateName == null || templateName.length() == 0) {
            return null;
        }

        DocumentTemplate__mdt template = [
            SELECT
                defaultRecipientName__c,
                defaultRecipientEmail__c,
                emailSubject__c,
                templateId__c
            FROM DocumentTemplate__mdt
            WHERE DeveloperName = :templateName
            LIMIT 1
        ];

        return template;
    }
}