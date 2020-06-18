@isTest
private class SFOrganizationTest {

    @isTest
    private static void testHappyPath() {
        String email = 'email@example.com';
        String name = 'Name';
        String orgNumber = 'Org Number';
        String taxID  = '888-88-8888';
        String orgType = '1234';
        String phone = '555-555-5555';
        String street = '123 Main';
        String city = 'pocatello';
        String state = 'ID';
        String postalCode = '83201';
        String country = 'USA';

        Account testAccount = new Account (
            Email__c = email,
            Name =  name,
            OrganizationNumber__c = orgNumber,
            OrganizationTaxID__c = taxID,
            OrganizationType__c = orgType,
            Phone = phone,
            BillingStreet = street,
            BillingCity = city,
            BillingState = state,
            BillingPostalCode = postalCode,
            BillingCountry = country
        );

        SFOrganization account = new SFOrganization(testAccount);

        System.assertEquals(email, account.getEmailAddress());
        System.assertEquals(name, account.getName());
        System.assertEquals(orgNumber, account.getOrgNumber());
        System.assertEquals(orgType, account.getOrgType());
        System.assertEquals(phone, account.getPhoneNumber());
        System.assertEquals(taxID, account.getTaxId());
        System.assertEquals(street, account.getAddress().getStreet());
        System.assertEquals(city, account.getAddress().getCity());
        System.assertEquals(state, account.getAddress().getStateCode());
        System.assertEquals(postalCode, account.getAddress().getPostalCode());
        System.assertEquals(country, account.getAddress().getCountryCode());
    }
}