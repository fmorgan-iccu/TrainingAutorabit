/**
* class for working with a Contact in salesforce with data pull from DNA
*/
public with sharing class ContactController {

    private Contact contact;


    public ContactController() {
    }

    /**
     * constructor
     * @param contactId the salesforce contact id, usually the current contact on the contact page
     */
    public ContactController(Id contactId) {
        this.contact = ContactController.queryContact(contactId);
    }

    @AuraEnabled
    public Contact getContact() {
        return this.contact;
    }

    /**
     * getContact static helper method to instanciate instance and get contact in lightning component controller
     * @param contactId the salesforce contact id, usually the current contact on the contact page
     */
    @AuraEnabled
    public static Contact getContact(String contactId) {
        ContactController controller = new ContactController(contactId);
        return controller.getContact();
    }

    @TestVisible
    private static Contact queryContact(Id contactId) {
        if (contactId == null) {
            return null;
        }
        
        return [
            SELECT
                Birthdate,
                CreditScore__c,
                Email,
                FirstName,
                IsEmployee__c,
                MiddleName,
                LastName,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry,
                MemberNumber__c,
                MobilePhone,
                Name,
                PersonNumber__c,
                Phone,
                PreferredName__c,
                TaxID__c,
                VerifiedIdentityPhone__c
            FROM Contact
            WHERE ID = :contactId
            LIMIT 1
        ];
    }

}