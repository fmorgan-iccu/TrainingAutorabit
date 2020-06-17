@isTest
private class TMTransactionTest {
	@isTest
    private static void testHappyPath() {
        String email = 'email';
        String firstName = 'firstName';
        String lastName = 'lastName';
        String routeName = '66';

        TMTransactionApplicant applicant = new TMTransactionApplicant(email, firstName, lastName, routeName);

        String id = '12345';
        String clientName = 'client name';
        String contactEmailAddress = 'address@example.com';
        String deliveryStatus = 'delivery status';
        String externalProfileId = 'zxvlkasjdf';
        String formName = 'form name';
        String formStatus = 'form status';
        String formURL = 'form url';
        AccountOpeningProduct product = new AccountOpeningProduct('categoryId', 'description', 'displayName', 'majorTypeCode', 'minorTypeCode');
        DateTime timeLastUserActivity = System.now().addDays(-5);
        DateTime timeRequested = System.now().addDays(-8);
        DateTime timeSubmitted = System.now().addDays(34);
        String trackingCode = '223534533';

        TMTransaction trans = new TMTransaction(id, applicant, clientName, contactEmailAddress, deliveryStatus, externalProfileId, formName, formStatus, formURL, product, timeLastUserActivity, timeRequested, timeSubmitted, trackingCode);
        System.assert(id.equals(trans.getId()));
        System.assert(clientName.equals(trans.getClientName()));
        System.assert(contactEmailAddress.equals(trans.getContactEmail()));
        System.assert(deliveryStatus.equals(trans.getDeliveryStatus()));
        System.assert(externalProfileId.equals(trans.getExternalProfileId()));
        System.assert(formName.equals(trans.getFormName()));
        System.assert(formStatus.equals(trans.getFormStatus()));
        System.assert(formURL.equals(trans.getFormURL()));
        System.assert(product == trans.getProduct());
        System.assert(timeLastUserActivity == trans.getTimeLastUserActivity());
        System.assert(timeRequested == trans.getTimeRequested());
        System.assert(timeLastUserActivity == trans.getTimeLastUserActivity());
        System.assert(timeSubmitted == trans.getTimeSubmitted());
        System.assert(trackingCode.equals(trans.getTrackingCode()));
    }
}