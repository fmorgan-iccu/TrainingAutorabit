@IsTest
private without sharing class AOApplicantRestServiceTest {

    @IsTest
    private static void testGetApplicant() {
        List<Contact> contacts = TestDataFactory.createContactsWithAccounts(1, 1, true, true);
        Contact c = contacts[0];

        // A minimalistic request with a lot of null/empty nodes to validate that the system
        // handles this gracefully.
        RestRequest request = new RestRequest();
        request.requestUri = 'https://test.salesforce.com/services/apexrest/accountopening/applicant';
        request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf('{"applicant":{"person":{"tax_id":"' + c.taxId__c + '"}}}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();

        AOApplicantRestResponse response = AOApplicantRestService.search();

        Test.stopTest();

        // Verify the HTTP status code.
        System.assertEquals(200, RestContext.response.statusCode);

        // Verify the response is properly formatted.
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.error_messages);
        System.assertEquals(0, response.error_messages.size());
        System.assertEquals(c.PersonNumber__c, response.applicant.person_number);
        System.assertEquals(c.MemberNumber__c, response.applicant.member_number);
        System.assertEquals(c.TaxID__c, response.applicant.tax_id);
        System.assertEquals(c.FirstName, response.applicant.first_name);
        System.assertEquals(c.LastName, response.applicant.last_name);
        System.assertEquals(response.formatDate(c.Birthdate), response.applicant.birth_date);
        System.assertEquals(c.Phone, response.applicant.home_phone.phone_number);
        System.assertEquals(c.MobilePhone, response.applicant.mobile_phone.phone_number);
        System.assertEquals(c.BusinessPhone__c, response.applicant.work_phone.phone_number);
        System.assertEquals(c.Email, response.applicant.email);
        System.assertEquals(c.MailingStreet, response.applicant.primary_address.line_1);
        System.assertEquals(c.MailingCity, response.applicant.primary_address.city);
        System.assertEquals(c.MailingCountry, response.applicant.primary_address.country);
        System.assertEquals(c.MailingPostalCode, response.applicant.primary_address.postal_code);
        System.assertEquals(c.MailingState, response.applicant.primary_address.state);
        System.assertEquals(c.IdentificationType__c, response.applicant.identification.type);
        System.assertEquals(c.IdentificationNumber__c, response.applicant.identification.id_number);
        System.assertEquals(c.IdentificationIssueState__c, response.applicant.identification.issuing_authority);
        System.assertEquals(response.formatDate(c.IdentificationIssueDate__c), response.applicant.identification.issue_date);
        System.assertEquals(response.formatDate(c.IdentificationExpirationDate__c), response.applicant.identification.expire_date);
    }

    @IsTest
    private static void testApplicantNotFound() {
        // A minimalistic request with a lot of null/empty nodes to validate that the system
        // handles this gracefully.
        RestRequest request = new RestRequest();
        request.requestUri = 'https://test.salesforce.com/services/apexrest/accountopening/applicant';
        request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf('{"applicant":{"person":{"tax_id":"555-11-1111"}}}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();

        AOApplicantRestResponse response = AOApplicantRestService.search();

        Test.stopTest();

        // Verify the HTTP status code.
        System.assertEquals(200, RestContext.response.statusCode);

        // Verify the response is properly formatted.
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.error_messages);
        System.assertEquals(1, response.error_messages.size());
        System.assertEquals('The applicant was not found.', response.error_messages[0]);
    }

    @IsTest
    private static void testPostApplicant() {
        RestRequest request = new RestRequest();
        request.requestUri = 'https://test.salesforce.com/services/apexrest/accountopening/applicant';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();

        AOApplicantRestResponse response = AOApplicantRestService.createApplicant();

        Test.stopTest();

        // Verify the HTTP status code.
        System.assertEquals(405, RestContext.response.statusCode);

        // Verify the response is properly formatted.
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.error_messages);
        System.assertEquals(1, response.error_messages.size());
        System.assertEquals('The createApplicant method is for future use and is not yet implemented.', response.error_messages[0]);
    }

    @IsTest
    private static void testPutApplicant() {
        RestRequest request = new RestRequest();
        request.requestUri = 'https://test.salesforce.com/services/apexrest/accountopening/applicant';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf('{}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();

        AOApplicantRestResponse response = AOApplicantRestService.updateApplicant();

        Test.stopTest();

        // Verify the HTTP status code.
        System.assertEquals(405, RestContext.response.statusCode);

        // Verify the response is properly formatted.
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.error_messages);
        System.assertEquals(1, response.error_messages.size());
        System.assertEquals('The updateApplicant method is for future use and is not yet implemented.', response.error_messages[0]);
    }

}