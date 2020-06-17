@IsTest(seeAllData=true)
private with sharing class EmailUtilsTest {
    
    /* This test method can't actually send an email message.  So, this is to ensure code coverage
	 * only.  User acceptance testing has been performed to validate performance.
     */
	@IsTest
    private static void testHappyPath() {
		Id orgWideEmailId = EmailUtils.getOrgWideEmailAddress();
		System.assertNotEquals(null, orgWideEmailId);

        EmailTemplate template = EmailUtils.getEmailTemplate(EmailUtils.TEMPLATE_ICCU_CONTACT_INFORMATION_UPDATE);
		System.assertNotEquals(null, template);
    }

}