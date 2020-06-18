public with sharing class TitleFormController {

    @AuraEnabled
    public static Map<String, Object> saveTitleRelease(String contactId, String requestJson) {
        Map<String, Object> response = new Map<String, Object>();

        // The contact must be provided.
        if (contactId == null) {
            response.put('error', '`contactId` may not be null.');
            return response;
        }

        // Ensure that the contact that is provide can be queried.
        Contact contact = ContactController.getContact(contactId);
        if (contact == null) {
            response.put('error', 'The contact was not found.');
        }

        // Verify that the JSON data can be deserialized.
        Map<String, Object> request = null;
        try {
            request = (Map<String, Object>)JSON.deserializeUntyped(requestJson);
        } catch (Exception e) {
            response.put('error', e.getMessage());
            return response;
        }

        //Verify that the required form fields are present.
        if (!request.containsKey('payOffType') ||
            !request.containsKey('accountNumber'))
        {
            response.put('error', 'All form fields are required.');
            return response;
        }

        String accountNumber = (String)request.get('accountNumber');
        String memberNumber = contact.MemberNumber__c;
        String memberCity = (String)request.get('memberCity');
        String companyName = (String)request.get('companyName');
        String memberPostalCode = (String)request.get('memberPostalCode');
        String memberState = (String)request.get('memberState');
        String memberStreetAddress = (String)request.get('memberStreetAddress');
        String make = (String)request.get('make');
        String model = (String)request.get('model');
        Integer year = (Integer)request.get('year');
        String vin = (String)request.get('vin');
        String memberFirstName = contact.FirstName;
        String memberLastName = contact.LastName;
        String payOffType = (String)request.get('payOffType');
        String thirdPartyName = (String)request.get('thirdPartyName');
        String attn = (String)request.get('attn');
        String thirdPartyStreet = (String)request.get('thirdPartyStreet');
        String thirdPartyCity = (String)request.get('thirdPartyCity');
        String thirdPartyState = (String)request.get('thirdPartyState');
        String thirdPartyPostalCode = (String)request.get('thirdPartyPostalCode');
        String nonDnaStreet = (String)request.get('nonDnaStreet');
        String nonDnaCity = (String)request.get('nonDnaCity');
        String nonDnaState = (String)request.get('nonDnaState');
        String nonDnaPostalCode = (String)request.get('nonDnaPostalCode');
        String buyersName = (String)request.get('buyersName');
        String buyersStreet = (String)request.get('buyersStreet');
        String buyersCity = (String)request.get('buyersCity');
        String buyersState = (String)request.get('buyersState');
        String buyersPostalCode = (String)request.get('buyersPostalCode');
        //String newLoanNumber = (String)request.get('newLoanNumber');
        String actionToTake = (String)request.get('actionToTake');
        //String buyersIccuNumber = (String)request.get('buyersIccuNumber');
        String checkBoxVerification = (String)request.get('checkBoxVerification');
        String buyersNewLoanNumber = (String)request.get('buyersNewLoanNumber');
        String createdBy = UserInfo.getName();

        // new_loan_number is one field in OnBase shared by both the fields below, null is acceptable for these fields if they are not
        // presented on the front end form.
        //Integer processedNewLoanNumber = newLoanNumber != null ? Integer.valueOf(newLoanNumber): null;
        //Integer processedBuyersNewLoanNumber = buyersNewLoanNumber != null ? Integer.valueOf(buyersNewLoanNumber): null;

        OnBaseFormDataProvider.TitleForm titleReleaseForm = new OnBaseFormDataProvider.TitleForm();
        titleReleaseForm.account_number = accountNumber;
        titleReleaseForm.member_number = memberNumber;
        titleReleaseForm.city = memberCity;
        titleReleaseForm.company_name = companyName;
        titleReleaseForm.postal_code = memberPostalCode;
        titleReleaseForm.state = memberState;
        titleReleaseForm.address = memberStreetAddress;
        titleReleaseForm.collateral_make = make;
        titleReleaseForm.collateral_model = model;
        titleReleaseForm.collateral_year = year;
        titleReleaseForm.vin = vin;
        titleReleaseForm.member_first_name = memberFirstName;
        titleReleaseForm.member_last_name = memberLastName;
        titleReleaseForm.payoff_type = payOffType;
        titleReleaseForm.third_party_name = thirdPartyName;
        titleReleaseForm.attn = attn;
        titleReleaseForm.third_party_street = thirdPartyStreet;
        titleReleaseForm.third_party_city = thirdPartyCity;
        titleReleaseForm.third_party_state = thirdPartyState;
        titleReleaseForm.third_party_postal_code = thirdPartyPostalCode;
        titleReleaseForm.non_dna_street = nonDnaStreet;
        titleReleaseForm.non_dna_city = nonDnaCity;
        titleReleaseForm.non_dna_state = nonDnaState;
        titleReleaseForm.non_dna_postal_code = nonDnaPostalCode;
        titleReleaseForm.buyers_name = buyersName;
        titleReleaseForm.buyers_street = buyersStreet;
        titleReleaseForm.buyers_city = buyersCity;
        titleReleaseForm.buyers_state = buyersState;
        titleReleaseForm.buyers_postal_code = buyersPostalCode;
        //titleReleaseForm.new_loan_number = processedNewLoanNumber != null ? processedNewLoanNumber: processedBuyersNewLoanNumber;
        titleReleaseForm.action_to_take = actionToTake;
        //titleReleaseForm.buyers_iccu_number = buyersIccuNumber != null ? Integer.valueOf(buyersIccuNumber): null;
        titleReleaseForm.check_box_verification = checkBoxVerification;
        titleReleaseForm.created_by = createdBy;

        OnBaseFormDataProvider formDataProvider = new OnBaseFormDataProvider();
        try {
            formDataProvider.saveTitleReleaseForm(titleReleaseForm);
        } catch (Exception e) {
            response.put('error', e.getMessage());
            return response;
        }

        response.put('success', true);
        return response;
    }

}