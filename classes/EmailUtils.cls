public with sharing class EmailUtils {

	// Identifies email template developer names as constants.
	public static final String TEMPLATE_ICCU_CONTACT_INFORMATION_UPDATE = 'ICCU_Contact_Information_Update';

	// Identifies the type of merge fields that are present in the template.
	public static String CLASSIC_EMAIL_TEMPLATE_TYPE = 'Aloha';
	public static String LIGHTNING_EMAIL_TEMPLATE_TYPE = 'SFX';

	// Cached settings to reduce SOQL.
	private static Map<String, OrgWideEmailAddress> orgWideEmailAddressCache = new Map<String, OrgWideEmailAddress>();
	private static Map<String, EmailTemplate> emailTemplateCache = new Map<String, EmailTemplate>();


	/**
	 * Retrieves the Id of the organization-wide email address.  This can be used in the sendEmail
	 * methods.
	 * @param  orgWideEmailName Display name of an organization-wide email address
	 * @return                  The Id of the organization-wide email address
	 */
	public static Id getOrgWideEmailAddress(String orgWideEmailName){
		if (orgWideEmailName == null) {
			orgWideEmailName = 'noreply@iccu.com';
		}

		if (!orgWideEmailAddressCache.containsKey(orgWideEmailName)) {
			List<OrgWideEmailAddress> emailAddresses = [
				SELECT id,
					address
				FROM OrgWideEmailAddress
				WHERE displayName = :orgWideEmailName
			];
			if (emailAddresses.size() != 1) {
				throw new IllegalArgumentException(orgWideEmailName + ' isn\'t a valid organization-wide address display name.');
			}
			orgWideEmailAddressCache.put(orgWideEmailName, emailAddresses[0]);
		}

		OrgWideEmailAddress owea = orgWideEmailAddressCache.get(orgWideEmailName);
		return owea != null ? owea.id : null;
	}

	public static Id getOrgWideEmailAddress() {
		return getOrgWideEmailAddress(null);
	}

	/**
	 * Loads the text/html/custom email template.
	 * @param  templateName The name of the email template to retrieve.
	 * @return              A reference to the email template.
	 */
	public static EmailTemplate getEmailTemplate(String templateName) {
		if (!emailTemplateCache.containsKey(templateName)) {
			List<EmailTemplate> emailTemplates = [
				SELECT id,
					body,
					htmlValue,
					subject,
					uiType
				FROM EmailTemplate
				WHERE developerName = :templateName
			];
			if (emailTemplates.size() != 1) {
				throw new IllegalArgumentException(templateName + ' isn\'t a valid email template developer name.');
			}
			emailTemplateCache.put(templateName, emailTemplates[0]);
		}
		return emailTemplateCache.get(templateName);
	}

}