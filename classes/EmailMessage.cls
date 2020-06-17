public class EmailMessage {

	public Id fromOrgWideEmailId {get; set;}
	public sObject primaryRecipient {get; private set;}
	public Set<String> toAddresses {get; private set;}
	public Set<String> ccAddresses {get; private set;}
	public Set<String> bccAddresses {get; private set;}
	public String subject {get; set;}
	public String htmlBody {get; set;}
	public String textBody {get; set;}

	public EmailMessage() {
		this.fromOrgWideEmailId = null;
		this.primaryRecipient = null;
		this.toAddresses = new Set<String>();
		this.ccAddresses = new Set<String>();
		this.bccAddresses = new Set<String>();
		this.subject = '';
		this.htmlBody = '';
		this.textBody = '';
	}

	public void addBccAddress(String emailAddress) {
		this.bccAddresses.add(emailAddress);
	}

	public void addCcAddress(String emailAddress) {
		this.ccAddresses.add(emailAddress);
	}

	public void addToAddress(String emailAddress) {
		this.toAddresses.add(emailAddress);
	}

	public List<String> getBccAddressList() {
		List<String> addresses = new List<String>();
		addresses.addAll(this.bccAddresses);
		return addresses;
	}

	public List<String> getCcAddressList() {
		List<String> addresses = new List<String>();
		addresses.addAll(this.ccAddresses);
		return addresses;
	}

	public Id getRecipientId() {
		switch on primaryRecipient {
			when Contact c {
				return c.id;
			}
			when Lead l {
				return l.id;
			}
			when User u {
				return u.id;
			}
            when null {
                return null;
            }
			when else {
				return null;
			}
		}
	}

	public List<String> getToAddressList() {
		List<String> addresses = new List<String>();
		addresses.addAll(this.toAddresses);
		return addresses;
	}

	/**
	 * Convenience method to populate a template with variable substiutions.  To properly substitute
	 * the recipient merge fields, call setPrimaryRecipient before calling this function.
	 * @param  templateName     The developer name of the the email template to load.
	 * @param  varSubstitutions A map of variable names and associated values to substitute into the message.
	 */
	public void loadFromTemplate(String templateName, Map<String, String> varSubstitutions) {
		// Retrieve the email template.
		EmailTemplate template = EmailUtils.getEmailTemplate(templateName);

		// Get a qualified list of populated fields on the contact record.
		Map<String, Object> qualifiedRecipientFields = new Map<String, Object>();
		if (this.primaryRecipient != null) {
			qualifiedRecipientFields = ObjectUtils.getQualifiedPopulatedFieldsAsMap(this.primaryRecipient);
		}

		// Get a qualified list of populated fields on the organization record.
		Organization org = OrganizationUtils.getOrganizationInfo();
		Map<String, Object> qualifiedOrganizationFields = ObjectUtils.getQualifiedPopulatedFieldsAsMap(org);

		// Identify all of the matching groups
		String substitutionExpression = null;
		if (template.uiType == EmailUtils.CLASSIC_EMAIL_TEMPLATE_TYPE) {
			substitutionExpression = '\\{\\!([^}]+)\\}';
		} else if (template.uiType == EmailUtils.LIGHTNING_EMAIL_TEMPLATE_TYPE) {
			substitutionExpression = '\\{\\{\\{([^}]+)\\}\\}\\}';
		}
		Pattern substitutionPattern = Pattern.compile(substitutionExpression);

		// Substitute the contact fields and variables into the html body.
		String workingHtmlBody = template.htmlValue;
		Map<String, String> htmlBodySubstitutions = new Map<String, String>();
		Matcher htmlMatcher = substitutionPattern.matcher(workingHtmlBody);
		while (htmlMatcher.find()) {
			htmlBodySubstitutions.put(htmlMatcher.group(1), htmlMatcher.group());
		}
		Set<String> substitutions = htmlBodySubstitutions.keySet();
		for (String substitution : substitutions) {
			if (qualifiedRecipientFields.containsKey(substitution)) {
				workingHtmlBody = workingHtmlBody.replace(htmlBodySubstitutions.get(substitution), qualifiedRecipientFields.get(substitution).toString());
			} else if (qualifiedOrganizationFields.containsKey(substitution)) {
				workingHtmlBody = workingHtmlBody.replace(htmlBodySubstitutions.get(substitution), qualifiedOrganizationFields.get(substitution).toString());
			} else if (varSubstitutions.containsKey(substitution)) {
				workingHtmlBody = workingHtmlBody.replace(htmlBodySubstitutions.get(substitution), varSubstitutions.get(substitution));
			}
		}

		// Substitute the contact fields and variables into the plain text body.
		String workingTextBody = template.body;
		Map<String, String> textBodySubstitutions = new Map<String, String>();
		Matcher plainTextMatcher = substitutionPattern.matcher(workingTextBody);
		while (plainTextMatcher.find()) {
			textBodySubstitutions.put(plainTextMatcher.group(1), plainTextMatcher.group());
		}
		substitutions = textBodySubstitutions.keySet();
		for (String substitution : substitutions) {
			if (qualifiedRecipientFields.containsKey(substitution)) {
				workingTextBody = workingTextBody.replace(textBodySubstitutions.get(substitution), qualifiedRecipientFields.get(substitution).toString());
			} else if (qualifiedOrganizationFields.containsKey(substitution)) {
				workingTextBody = workingTextBody.replace(textBodySubstitutions.get(substitution), qualifiedOrganizationFields.get(substitution).toString());
			} else if (varSubstitutions.containsKey(substitution)) {
				workingTextBody = workingTextBody.replace(textBodySubstitutions.get(substitution), varSubstitutions.get(substitution));
			}
		}

		// Finally assign the bodies to the member variables.
		this.subject = template.subject;
		this.htmlBody = workingHtmlBody;
		this.textBody = workingTextBody;
	}

	/**
	 * Sets the primary recipient that will be used for all merge fields when a template is used.
	 * Also sets the context of the email so that it can be attached to the correct object as an
	 * activity.
	 * @param  recipient A Contact, Lead or User object to use as the primary recipient.
	 */
	public void setPrimaryRecipient(sObject recipient) {
		switch on recipient {
			when Contact c {
				toAddresses.add(c.email);
			}
			when Lead l {
				toAddresses.add(l.email);
			}
			when User u {
				toAddresses.add(u.senderEmail);
			}
			when else {
				throw new IllegalArgumentException('The recipient isn\'t a Contact, Lead or User object.');
			}
		}
		this.primaryRecipient = recipient;
	}

}