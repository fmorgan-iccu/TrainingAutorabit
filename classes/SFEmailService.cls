public with sharing class SFEmailService implements IEmailService {

	@TestVisible
	private Boolean allOrNone = false;
	@TestVisible
	private Boolean sendingEnabled = false;

	/**
	 * Constructor for sending email.  Tests should disable sending to avoid errors being thrown.
	 */
	public SFEmailService(Boolean allOrNone, Boolean sendingEnabled) {
		this.allOrNone = allOrNone;
		this.sendingEnabled = sendingEnabled;
	}

	/**
	 * Overloaded constructors to apply the default of all or none set to true and sending enabled
	 * to true.
	 */
	public SFEmailService() {
		this.allOrNone = true;
		this.sendingEnabled = true;
	}

	/**
	 * Convenience function for sending a single email message.
	 * @param  message The email message to send.
	 * @return         The results of sending the email.
	 */
	public EmailMessageResult sendEmail(EmailMessage message) {
		List<EmailMessageResult> results = sendEmails(new List<EmailMessage> { message });
		return results.size() > 0 ? results[0] : null;
	}

	/**
	 * Sends the email messages using the standard Salesforce Messaging.SingleEmailMessage process.
	 *
	 * @param  messages The email messages to send.
	 * @return          The results of the individual sends.
	 */
	public List<EmailMessageResult> sendEmails(List<EmailMessage> messages) {
		if (this.sendingEnabled) {
			try {
				Messaging.reserveSingleEmailCapacity(messages.size());
			} catch (System.NoAccessException e) {
				this.sendingEnabled = false;
			}
		}

		List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
		for (EmailMessage msg : messages) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			if (msg.primaryRecipient != null) {
				Id targetId = msg.getRecipientId();
				mail.setTargetObjectId(targetId);
				if (msg.primaryRecipient instanceof Contact || msg.primaryRecipient instanceof Lead) {
					mail.setSaveAsActivity(false);
				}
			}
			if (msg.fromOrgWideEmailId != null) {
				mail.setOrgWideEmailAddressId(msg.fromOrgWideEmailId);
			}
			mail.setToAddresses(msg.getToAddressList());
			mail.setCcAddresses(msg.getCcAddressList());
			mail.setBccAddresses(msg.getBccAddressList());
			mail.setSubject(msg.subject);
			mail.setHtmlBody(msg.htmlBody);
			mail.setPlainTextBody(msg.textBody);
			emailMessageList.add(mail);
		}
		
		List<EmailMessageResult> results = new List<EmailMessageResult>();
		if (this.sendingEnabled) {
			// Summarize each of the sends error(s), if any, into a single error message.
			List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailMessageList, this.allOrNone);
			for (Messaging.SendEmailResult result : sendResults) {
				String errorMessage = '';
				List<Messaging.SendEmailError> emailErrors = result.getErrors();
				for (Messaging.SendEmailError e : emailErrors) {
					errorMessage += ' ' + e.getMessage();
				}
				EmailMessageResult r = new EmailMessageResult(result.isSuccess(), errorMessage);
				results.add(r);
			}
		} else {
			// Deliverability is disabled, mock the response as successful.
			for (EmailMessage message : messages) {
				results.add(new EmailMessageResult(true, null));
			}
		}

		return results;
	}

}