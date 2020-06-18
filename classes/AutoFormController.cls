public with sharing class AutoFormController {

    @AuraEnabled
    public static Map<String, Object> saveAutoPayoff(String contactId, String requestJson) {
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

        // Verify that the form fields are present.
        if (!request.containsKey('accountNumber') ||
            !request.containsKey('memberNumber') ||
            !request.containsKey('companyCity') ||
            !request.containsKey('companyName') ||
            !request.containsKey('companyPostalCode') ||
            !request.containsKey('companyState') ||
            !request.containsKey('companyStreetAddress') ||
            !request.containsKey('make') ||
            !request.containsKey('model') ||
            !request.containsKey('payoffAmount') ||
            !request.containsKey('perDiem') ||
            !request.containsKey('payoffDate') ||
            !request.containsKey('year') ||
            !request.containsKey('vin'))
        {
            response.put('error', 'All form fields are required.');
            return response;
        }

        String account_number = (String)request.get('accountNumber');
        String member_number = (String)request.get('memberNumber');
        String companyCity = (String)request.get('companyCity');
        String companyName = (String)request.get('companyName');
        String companyPostalCode = (String)request.get('companyPostalCode');
        String companyState = (String)request.get('companyState');
        String companyStreetAddress = (String)request.get('companyStreetAddress');
        String make = (String)request.get('make');
        String city = contact.mailingCity;
        String postal_code = contact.mailingPostalCode;
        String memberState = contact.mailingState;
        String memberStreetAddress = contact.mailingStreet;
        String model = (String)request.get('model');
        String payoffAmount = (String)request.get('payoffAmount');
        String perDiem = (String)request.get('perDiem');
        String payoffDate = (String)request.get('payoffDate');
        String year = (String)request.get('year');
        String vin = (String)request.get('vin');

        OnBaseFormDataProvider.AutoForm autoPayoffForm = new OnBaseFormDataProvider.AutoForm(
                member_number,
                account_number,
                companyCity,
                companyName,
                companyPostalCode,
                companyState,
                companyStreetAddress,
                make,
                city,
                postal_code,
                memberState,
                memberStreetAddress,
                model,
                payoffAmount,
                perDiem,
                payoffDate,
                year,
                vin
            );

        OnBaseFormDataProvider formDataProvider = new OnBaseFormDataProvider();
        try {
            formDataProvider.saveAutoPayoffForm(autoPayoffForm);
        } catch (Exception e) {
            response.put('error', e.getMessage());
            return response;
        }

        response.put('success', true);
        return response;
    }

}