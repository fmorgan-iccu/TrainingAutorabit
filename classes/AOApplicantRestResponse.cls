global with sharing class AOApplicantRestResponse {
    global List<String> error_messages;
    global AOApplicationRestRequest.Person applicant;

    global AOApplicantRestResponse(List<String> errorMessages, Contact c) {
        error_messages = errorMessages;

        applicant = new AOApplicationRestRequest.Person();
        if (c != null) {
            applicant.person_number = c.personNumber__c;
            applicant.member_number = c.memberNumber__c;
            applicant.tax_id = c.taxId__c;
            applicant.first_name = c.firstName;
            applicant.last_name = c.lastName;
            applicant.birth_date = formatDate(c.birthDate);
            applicant.home_phone = new AOApplicationRestRequest.Phone();
            applicant.home_phone.phone_number = c.phone;
            applicant.mobile_phone = new AOApplicationRestRequest.Phone();
            applicant.mobile_phone.phone_number = c.mobilePhone;
            applicant.work_phone = new AOApplicationRestRequest.Phone();
            applicant.work_phone.phone_number = c.businessPhone__c;
            applicant.email = c.email;

            // Provide the identification information on file.
            applicant.identification = new AOApplicationRestRequest.PersonIdentification();
            applicant.identification.type = c.identificationType__c;
            applicant.identification.id_number = c.identificationNumber__c;
            applicant.identification.issuing_authority = c.identificationIssueState__c;
            applicant.identification.issue_date = formatDate(c.identificationIssueDate__c);
            applicant.identification.expire_date = formatDate(c.identificationExpirationDate__c);

            // Provide the mailing address on file.
            List<String> addressLines = c.mailingStreet != null ? c.mailingStreet.split('\\r?\\n') : new List<String>();
            applicant.primary_address = new AOApplicationRestRequest.Address();
            applicant.primary_address.line_1 = addressLines.size() > 0 ? addressLines[0] : null;
            applicant.primary_address.line_2 = addressLines.size() > 1 ? addressLines[1] : null;
            applicant.primary_address.city = c.mailingCity;
            applicant.primary_address.state = c.mailingState;
            applicant.primary_address.postal_code = c.mailingPostalCode;
            applicant.primary_address.country = c.mailingCountry;
        }
    }

    @TestVisible
    private String formatDate(Date d) {
        String formatted = d != null ? DateUtils.format(d, 'yyyy-MM-dd') : null;
        return formatted;
    }
}