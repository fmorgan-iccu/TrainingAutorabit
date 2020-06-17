public with sharing class MemberHeaderController {

    @TestVisible
    private static SFCacheUpdater updater;
    @TestVisible
    private static IEmailService emailService;

    @AuraEnabled
    public static Map<String, Object> getHeaderInformation(String contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', '`contactId` is required.');
            return response;
        }

        Contact contact = ContactController.getContact(contactId);
        response.put('contact', contact);

        // Determine the users permissions.
        Boolean enableForms = AccessUtils.checkPermission('MemberForms');
        response.put('allowForms', enableForms);

        return response;
    }

    @Auraenabled
    public static Boolean isAuthenticated() {
        ConcreteNetworkProvider networkFactory = new ConcreteNetworkProvider();
        IPersonDataProvider personDataProvider = networkFactory.getPersonDataProvider();
        IAuthenticationManager authManager = personDataProvider.getAuthenticationManager();

        return authManager.isUserAuthenticated();
    }

    /**
     * refreshContent updates the contact in SF with current DNA data for use in lightning component controller
     * @param contactId the salesforce contact id, usually the current contact on the contact page
     */
    @AuraEnabled
    public static Map<String, Object> refreshContent(Id contactId, String personNumber) {
        Map<String, Object> response = new Map<String, Object>();

        if (personNumber == null || personNumber.length() == 0) {
            response.put('error', 'The person number of this record is missing. This may occur if this is a new member and their DNA data has not been synced with SalesForce. Any DNA related functionality of this contact will be reduced until it is updated with a DNA person number.');
            return response;
        }

        try {
            if (MemberHeaderController.updater == null) {
                MemberHeaderController.updater = new SFCacheUpdater();
            }
            IPerson person = MemberHeaderController.updater.fetchPerson(personNumber);
            Contact contact = ContactController.getContact(contactId);
            Contact updatedContact = updater.persistPerson(person, contact);
            response.put('contact', updatedContact);

        } catch (UnauthenticatedException e) {
            // The CRMMemberHeaderController checks for this exact message.  If this is ever
            // changed, please update the controller code.
            response.put('error', 'Please log in to DNA.');
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> resetVerifiedIdentityPhone(Id contactId) {
        Map<String, Object> response = new Map<String, Object>();
        Boolean success = true;

        if (String.isBlank(contactId)) {
            response.put('error', '`contactId` is required.');
            success = false;
        }

        try {
            Contact c = new Contact(id=contactId, VerifiedIdentityPhone__c=false);
            update c;
        } catch (Exception e) {
            response.put('error', e.getMessage());
            success = false;
        }

        response.put('success', success);
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateContact(
        Id contactId,
        String email,
        String mailingStreet1,
        String mailingStreet2,
        String mailingCity,
        String mailingCountry,
        String mailingPostalCode,
        String mailingState,
        String mobilePhone,
        String phone,
        Boolean verifiedIdentityPhone)
    {
        Map<String, Object> response = new Map<String, Object>();

        // Validate the format of the various fields to be certain that they conform with the
        // minimum requirements (e.g. PO Box format, phone length, required fields, etc.)!
        if (String.isBlank(mailingStreet1)
            || AddressUtils.isPostOfficeBox(mailingStreet1)
            || String.isBlank(mailingCity)
            || String.isBlank(mailingCountry)
            || String.isBlank(mailingPostalCode)
            || String.isBlank(mailingState)
            || (String.isBlank(phone)
                && String.isBlank(mobilePhone)))
        {
            response.put('error', 'One or more fields are invalid.');
            return response;
        }

        // If the mobile phone is present but the home phone is not, copy the data.
        if (String.isBlank(phone) && !String.isBlank(mobilePhone)) {
            phone = mobilePhone;
        }

        // Retreive the contact on file to ensure all required fields are available for update,
        // saving the original email for the notification message.
        Contact originalContact = ContactController.getContact(contactId);

        // Assign the new values into the contact for updating into DNA and Salesforce.
        Contact updateContact = originalContact.clone();
        updateContact.id = originalContact.id;
        updateContact.email = email;
        updateContact.mailingStreet = mailingStreet1 + (!String.isBlank(mailingStreet2) ? '\n' + mailingStreet2 : '');
        updateContact.mailingCity = mailingCity;
        updateContact.mailingCountry = mailingCountry;
        updateContact.mailingPostalCode = mailingPostalCode;
        updateContact.mailingState = mailingState;
        updateContact.mobilePhone = PhoneUtils.format(mobilePhone);
        updateContact.phone = PhoneUtils.format(phone);
        updateContact.VerifiedIdentityPhone__c = verifiedIdentityPhone;

        // Instantiate an IPerson from the Salesforce data, and assemble the various address objects needed
        // to update the contact.
        SFPerson person = new SFPerson(updateContact);
        List<IAddress> addresses = new List<IAddress> {
            new SFAddress(updateContact, AddressType.PRIMARY)
        };
        List<PhoneNumber> phoneNumbers = new List<PhoneNumber> {
            new PhoneNumber(PhoneUtils.formatDigitsOnly(phone), PhoneNumberType.HOME)
        };
        if (mobilePhone != null) {
            phoneNumbers.add(new PhoneNumber(PhoneUtils.formatDigitsOnly(mobilePhone), PhoneNumberType.CELL));
        }

        List<EmailAddress> emailAddresses = new List<EmailAddress>{
            new EmailAddress(updateContact.email, EmailAddressType.PRIMARY)
        };

        // Call the core system to update the members information.
        ConcreteNetworkProvider networkFactory = new ConcreteNetworkProvider();
        IPersonDataProvider personDataProvider = networkFactory.getPersonDataProvider();
        try {
            IPerson pers = personDataProvider.updatePersonContactInfo(person, addresses, phoneNumbers, emailAddresses);
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Please login to ' + personDataProvider.getProviderName() + ' and try again.');
            response.put('requiredLogins', new List<String> { personDataProvider.getProviderName() });
            return response;
        } catch (Exception e) {
            response.put('error', 'Unable to update the member\'s information in DNA.  Try again or make the change directly in DNA. ' + e.getMessage());
            return response;
        }

        // Send an email notification to the current address on file if the email field is changing.
        // If an error occurs, make sure to notify the team member that the member hasn't been
        // notified. Only send the email notification if original contact has an email address.
        Boolean emailChanged = !String.isBlank(originalContact.email) && updateContact.email != originalContact.email;
        Boolean addressChanged =
            updateContact.mailingStreet != originalContact.mailingStreet ||
            updateContact.mailingCity != originalContact.mailingCity ||
            updateContact.mailingCountry != originalContact.mailingCountry ||
            updateContact.mailingPostalCode != originalContact.mailingPostalCode ||
            updateContact.mailingState != originalContact.mailingState;
        Boolean mobilePhoneChanged = updateContact.mobilePhone != originalContact.mobilePhone;
        Boolean phoneChanged = updateContact.phone != originalContact.phone;
        if (!String.isBlank(originalContact.email) && (emailChanged || addressChanged || mobilePhoneChanged || phoneChanged)) {
            try {
                // Determine what fields have changed and concatenate them.
                String updatedFields = '';
                if (emailChanged) {
                    updatedFields += 'email address, ';
                }
                if (addressChanged) {
                    updatedFields += 'primary address, ';
                }
                if (mobilePhoneChanged) {
                    updatedFields += 'mobile phone, ';
                }
                if (phoneChanged) {
                    updatedFields += 'home phone, ';
                }

                // Remove the trailing comma.
                updatedFields = updatedFields.replaceFirst(', $', '');

                // If the string still contains a comma, replace the last one with a natural
                // language "and".
                updatedFields = updatedFields.replaceFirst(',(?=[^,]+$)', ' and');

                // Create the variables structure.
                Map<String, String> vars = new Map<String, String>();
                vars.put('var.updatedFields', updatedFields);

                // Create the email message to be sent from a template.
                Id noReplyId = EmailUtils.getOrgWideEmailAddress('noreply@iccu.com');
                EmailMessage message = new EmailMessage();
                message.fromOrgWideEmailId = noReplyId;
                message.setPrimaryRecipient(originalContact);
                message.loadFromTemplate(EmailUtils.TEMPLATE_ICCU_CONTACT_INFORMATION_UPDATE, vars);

                // Send the email message.
                if (MemberHeaderController.emailService == null) {
                    MemberHeaderController.emailService = new SFEmailService();
                }
                EmailMessageResult messageResult = MemberHeaderController.emailService.sendEmail(message);
                if (!messageResult.isSuccess) {
                    String errorMessage = 'Unable to send an e-mail update notification. ' + messageResult.errorMessage;
                    response.put('error', errorMessage);
                    return response;
                }
            } catch (Exception e) {
                String logMessage = 'Unable to send an e-mail update notification. ' + e.getMessage() + ' -- ' + e.getStackTraceString();
                LogUtils.log(LoggingLevel.INFO, 'MemberHeaderController', originalContact.id, logMessage);

                response.put('error', 'Unable to send an e-mail update notification.');
                return response;
            }
        }

        // Update the contact in Salesforce after updating DNA.
        try {
            update updateContact;
            updateContact = ContactController.getContact(contactId);
            response.put('contact', updateContact);
        } catch (Exception e) {
            response.put('error', 'Unable to upate the member\'s information in Salesforce. ' + e.getMessage());
            return response;
        }

        return response;
    }

}