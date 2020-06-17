public interface IEmailService {
	EmailMessageResult sendEmail(EmailMessage message);
	List<EmailMessageResult> sendEmails(List<EmailMessage> message);
}