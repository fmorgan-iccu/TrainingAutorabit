@isTest(seeAllData=true)
private with sharing class EmailMessageTest {
    
    /* This test method can't actually send an email message.  So, this is to ensure code coverage
	 * only.  User acceptance testing has been performed to validate performance.
     */
	@isTest
    static void testEmail() {
		// Test the contact email
		Contact c = new Contact(firstName='Joe', lastName='Smith', email='to@iccu.com');
		insert c;
		
		// Create a variable list to substitute
		Map<String, String> vars = new Map<String, String>();
		vars.put('var.updatedFields', 'primary address and email address');
		
		// Create a new email message and populate using a template.
		EmailMessage msg = new EmailMessage();

		msg.fromOrgWideEmailId = EmailUtils.getOrgWideEmailAddress();
		msg.setPrimaryRecipient(c);
		msg.addToAddress('also@iccu.com');
		msg.addCcAddress('cc@iccu.com');
		msg.addBccAddress('bcc@iccu.com');
		msg.loadFromTemplate(EmailUtils.TEMPLATE_ICCU_CONTACT_INFORMATION_UPDATE, vars);

		// Check recipients
		System.assert(msg.toAddresses.contains('to@iccu.com'));
		System.assert(msg.toAddresses.contains('also@iccu.com'));
		System.assert(msg.ccAddresses.contains('cc@iccu.com'));
		System.assert(msg.bccAddresses.contains('bcc@iccu.com'));

		// The actual values will not be checked here since the contents are subject to change.
		// Simply check that something was loaded.
		System.assertNotEquals('', msg.subject);
		System.assertNotEquals('', msg.htmlBody);
		System.assertNotEquals('', msg.textBody);

		// To properly test the contact, organization and variables merge are working, we will check
		// the various merge fields are present.
		System.assert(msg.htmlBody.contains('Joe'));
		System.assert(msg.htmlBody.contains('Idaho Central Credit Union'));
		System.assert(msg.htmlBody.contains('primary address and email address'));
		System.assert(msg.textBody.contains('Joe'));
		System.assert(msg.textBody.contains('Idaho Central Credit Union'));
		System.assert(msg.textBody.contains('primary address and email address'));
    }

}