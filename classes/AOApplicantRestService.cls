@RestResource(urlMapping='/accountopening/applicant/*')
global with sharing class AOApplicantRestService {

    /**
     * Search for the applicant by tax Id.
     */
    @HttpGet
    global static AOApplicantRestResponse search() {
        AOApplicationRestRequest request = AORestHelper.parseRequestBody();

        RestResponse res = RestContext.response;
        List<String> errorMessages = new List<String>();
        Contact c = null;
        try {
            Id dnaRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
            c = AOApplicantRestService.lookupContact(request.applicant.person.tax_id, dnaRecordTypeId, false);
            if (c == null) {
                errorMessages.add('The applicant was not found.');
            }
            res.statusCode = 200;
        } catch (Exception e) {
            errorMessages.add('The lookup of the applicant failed.  ' + e.getMessage());
            res.statusCode = 500;
        }

        AOApplicantRestResponse response = new AOApplicantRestResponse(errorMessages, c);
        return response;
    }

    @HttpPost
    global static AOApplicantRestResponse createApplicant() {
        RestResponse res = RestContext.response;
        res.statusCode = 405;
        List<String> errorMessages = new List<String> {'The createApplicant method is for future use and is not yet implemented.'};
        AOApplicantRestResponse response = new AOApplicantRestResponse(errorMessages, null);
        return response;
    }

    @HttpPut
    global static AOApplicantRestResponse updateApplicant() {
        RestResponse res = RestContext.response;
        res.statusCode = 405;
        List<String> errorMessages = new List<String> {'The updateApplicant method is for future use and is not yet implemented.'};
        AOApplicantRestResponse response = new AOApplicantRestResponse(errorMessages, null);
        return response;
    }

    private static Contact lookupContact(String taxId, Id recordTypeId, Boolean lock) {
        if (String.isBlank(taxId)) {
            throw new IllegalArgumentException('The taxId must be provided.');
        }
        String sqlStatement =
            'SELECT id, birthDate, businessPhone__c, email, firstName, lastName, memberNumber__c, mobilePhone, personNumber__c, phone, identificationType__c, identificationNumber__c, identificationIssueState__c, identificationIssueDate__c, identificationExpirationDate__c, mailingStreet, mailingCity, mailingState, mailingPostalCode, mailingCountry, taxId__c ' +
            'FROM Contact ' +
            'WHERE taxId__c = :taxId ' +
            (recordTypeId != null ? 'AND recordTypeId = :recordTypeId ' : '') +
            'ORDER BY createdDate ASC ' +
            (lock ? 'FOR UPDATE' : '');
        List<Contact> contacts = (List<Contact>)Database.query(sqlStatement);
        Contact c = contacts.size() > 0 ? contacts[0] : null;
        return c;
    }

}