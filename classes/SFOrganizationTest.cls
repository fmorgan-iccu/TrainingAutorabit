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
        
        Account testAccount = new Account (
            Email__c = email,
            Name =  name,
            OrganizationNumber__c = orgNumber,
            OrganizationTaxID__c = taxID,
            OrganizationType__c = orgType,
            Phone = phone
        );

        SFOrganization account = new SFOrganization(testAccount);

        System.assert(account.getEmailAddress().equals(email));
        System.assert(account.getName().equals(name));
        System.assert(account.getOrgNumber().equals(orgNumber));
        System.assert(account.getOrgType().equals(orgType));
        System.assert(account.getPhoneNumber().equals(phone));
        System.assert(account.getTaxId().equals(taxID));
        System.assert(account.getAddress() == null);
    }
}