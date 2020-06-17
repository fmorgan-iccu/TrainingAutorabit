/*
 *  Class that encapsulates all the logic for updating certain SalesForce objects.
 */
public with sharing class SFCacheUpdater {

    // The following field mappings are used to identify the field that a particular IPerson
    // function should populate.  This is done to ensure that the merge process is aware of the
    // fields that are populated from external source systems.  Also, some of the fields are not set
    // by the SFCacheUpdater, but are used by the AppWorx synchronization code.  This centralizes
    // the possible fields that are updated in one place.
    public static final Map<String, String> SALESFORCE_CONTACT_FIELDS = new Map<String, String> {
        'AccountId' => 'AccountId',
        'BirthDate' => 'Birthdate',
        'BusinessPhone' => 'BusinessPhone__c',
        'CreditScore' => 'CreditScore__c',
        'CreditScoreDate' => 'CreditScoreDate__c',
        'DefaultBranch' => 'DefaultBranch__c',
        'Email' => 'Email',
        'FirstName' => 'FirstName',
        'IdentificationExpirationDate' => 'IdentificationExpirationDate__c',
        'IdentificationNumber' => 'IdentificationNumber__c',
        'IdentificationIssueDate' => 'IdentificationIssueDate__c',
        'IdentificationIssueState' => 'IdentificationIssueState__c',
        'IdentificationType' => 'IdentificationType__c',
        'IsEmployee' => 'IsEmployee__c',
        'JointAccountCount' => 'JointAccountCount__c',
        'JointAccountIDs' => 'JointAccountIDs__c',
        'LastName' => 'LastName',
        'MailingCity' => 'MailingCity',
        'MailingCountry' => 'MailingCountry',
        'MailingPostalCode' => 'MailingPostalCode',
        'MailingStreet' => 'MailingStreet',
        'MailingState' => 'MailingState',
        'MemberNumber' => 'MemberNumber__c',
        'MemberSince' => 'MemberSince__c',
        'MiddleName' => 'MiddleName',
        'MobilePhone' => 'MobilePhone',
        'OnlineAgreementIDs' => 'OnlineAgreementIDs__c',
        'OtherPhone' => 'OtherPhone',
        'PersonNumber' => 'PersonNumber__c',
        'Phone' => 'Phone',
        'PreferredName' => 'PreferredName__c',
        'RecordTypeId' => 'RecordTypeId',
        'TaxIDOwnerCount' => 'TaxIDOwnerCount__c',
        'TaxID' => 'TaxID__c'
    };
    public static final Map<String, String> SALESFORCE_ACCOUNT_FIELDS = new Map<String, String> {
        'Email' => 'Email__c',
        'MemberNumber' => 'MemberNumber__c',
        'Name' => 'Name',
        'OrganizationName' => 'OrganizationName__c',
        'OrganizationNumber' => 'OrganizationNumber__c',
        'OrganizationTaxID' => 'OrganizationTaxID__c',
        'OrganizationType' => 'OrganizationType__c',
        'Phone' => 'Phone',
        'RecordTypeId' => 'RecordTypeId',
        'BillingStreet' => 'BillingStreet',
        'BillingCity' => 'BillingCity',
        'BillingState' => 'BillingState',
        'BillingPostalCode' => 'BillingPostalCode',
        'BillingCountry' => 'BillingCountry'
    };

    private INetworkFactory networkFactory;

    public SFCacheUpdater() {
        this.networkFactory = new ConcreteNetworkProvider();
    }

    @TestVisible
    private SFCacheUpdater(INetworkFactory networkFactory) {
        this.networkFactory = networkFactory;
    }

    /*
     *  Fetches an IPerson from the system of record.
     *  @param personNumber The person number of the IPerson to fetch
     *  @return a new instance of an IPerson
     */
    public IPerson fetchPerson(String personNumber) {
        if (personNumber == null || personNumber.length() == 0) {
            throw new IllegalArgumentException('The person number cannot be null.');
        }

        IPersonDataProvider personDataProvider = this.networkFactory.getPersonDataProvider();
        IPerson fetchedPerson = personDataProvider.getPersonDetails(personNumber);
        return fetchedPerson;
    }

    /*
     *  Fetches an IPerson from the system of record.
     *  @param personNumber The person number of the IPerson to fetch
     *  @return a new instance of an IPerson
     */
    public IOrganization fetchOrganization(String orgNumber) {
        if (orgNumber == null || orgNumber.length() == 0) {
            throw new IllegalArgumentException('The organization number cannot be null.');
        }

        IOrganizationDataProvider orcDataProvider = this.networkFactory.getOrganizationDataProvider();
        IOrganization fetchedOrc = orcDataProvider.getOrganizationDetails(orgNumber);
        return fetchedOrc;
    }

    /*
     *  Maps an IPerson to the SalesForce database.
     *  @param contact The SalesForce contact to be updated
     *  @param person The IPerson source of data to update the contact
     */
    public Contact persistPerson(IPerson person, Contact contact) {
        if (person == null) {
            throw new IllegalArgumentException('Persisting person: Person cannot be null.');
        }

        if (contact == null) {
            throw new IllegalArgumentException('Persisting person: Contact cannot be null.');
        }

        contact.put(SALESFORCE_CONTACT_FIELDS.get('BirthDate'), person.getDateOfBirth());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('IdentificationNumber'), person.getDriversLicenseNumber());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('Email'), person.getEmailAddress());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('FirstName'), person.getFirstName());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('MiddleName'), person.getMiddleName());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('Phone'), PhoneUtils.format(person.getHomePhone()));
        contact.put(SALESFORCE_CONTACT_FIELDS.get('LastName'), person.getLastName());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('MemberNumber'), person.getMemberNumber());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('MemberSince'), person.getMembershipDate());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('MobilePhone'), PhoneUtils.format(person.getMobilePhone()));
        contact.put(SALESFORCE_CONTACT_FIELDS.get('PersonNumber'), person.getPersonNumber());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('PreferredName'), person.getPreferredName());
        contact.put(SALESFORCE_CONTACT_FIELDS.get('TaxID'), person.getTaxId());

        IAddress address = person.getPrimaryAddress();

        if (address != null) {
            contact.put(SALESFORCE_CONTACT_FIELDS.get('MailingCity'), address.getCity());
            contact.put(SALESFORCE_CONTACT_FIELDS.get('MailingCountry'), address.getCountryCode());
            contact.put(SALESFORCE_CONTACT_FIELDS.get('MailingPostalCode'), address.getPostalCode());
            contact.put(SALESFORCE_CONTACT_FIELDS.get('MailingState'), address.getStateCode());
            contact.put(SALESFORCE_CONTACT_FIELDS.get('MailingStreet'), address.getStreet());
        }

        update contact;

        return contact;
    }

    public Account persistOrganization(IOrganization org, Account account) {
        // Use the same format as the DNA SQL synchronization for the account name.
        String accountName = 'O' + org.getOrgNumber() + ' - ' + org.getName();

        account.put(SALESFORCE_ACCOUNT_FIELDS.get('Email'), org.getEmailAddress());
        account.put(SALESFORCE_ACCOUNT_FIELDS.get('Name'), accountName);
        account.put(SALESFORCE_ACCOUNT_FIELDS.get('OrganizationNumber'), org.getOrgNumber());
        account.put(SALESFORCE_ACCOUNT_FIELDS.get('OrganizationTaxID'), org.getTaxId());
        account.put(SALESFORCE_ACCOUNT_FIELDS.get('OrganizationType'), org.getOrgType());
        account.put(SALESFORCE_ACCOUNT_FIELDS.get('Phone'), PhoneUtils.format(org.getPhoneNumber()));

        IAddress address = org.getAddress();

        if (address != null) {
            account.put(SALESFORCE_ACCOUNT_FIELDS.get('BillingStreet'), address.getStreet());
            account.put(SALESFORCE_ACCOUNT_FIELDS.get('BillingCity'), address.getCity());
            account.put(SALESFORCE_ACCOUNT_FIELDS.get('BillingState'), address.getStateCode());
            account.put(SALESFORCE_ACCOUNT_FIELDS.get('BillingPostalCode'), address.getPostalCode());
            account.put(SALESFORCE_ACCOUNT_FIELDS.get('BillingCountry'), address.getCountryCode());
        }

        update account;

        return account;
    }

}