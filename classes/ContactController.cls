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

    @AuraEnabled
    public static Contact getContactByAccount(String accountId) {
        if (accountId == null) {
            return null;
        }

        Contact c = SFPerson.getInstanceByAccount(accountId).getContact();
        return c;
    }

    @AuraEnabled
    public static Contact fetchContact(String contactId) {
        ContactController controller = new ContactController(contactId);
        return controller.getContact();
    }

    @TestVisible
    private static Contact queryContact(Id contactId) {
        if (contactId == null) {
            return null;
        }

        Contact c = SFPerson.getInstance(contactId).getContact();
        return c;
    }

    @AuraEnabled
    public static Map<String,Object> fetchContactOwner(String contactId) {
        return ContactController.getContactOwner(contactId);
    }

    public static Map<String,Object> getContactOwner(Id contactId) {
        Map<String,Object> response = new Map<String,Object>();

        if (contactId == null) {
            return response;
        }

        List<Contact> contacts = [
            SELECT
                Owner.Name,
                Owner.Extension,
                Owner.Title,
                Owner.Email,
                PrivateClient__c
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        if (contacts.size() == 0) {
            response.put('error', 'Unable to find the contactId ' + contactId);
            return response;
        }

        Contact c = contacts[0];
        response.put('name', c.Owner.Name);
        response.put('extension', c.Owner.Extension);
        response.put('title', c.Owner.Title);
        response.put('email', c.Owner.Email);
        response.put('privateClient', c.PrivateClient__c);

        return response;
    }

}