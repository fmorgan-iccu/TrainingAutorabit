@isTest
private class DNAOrganizationTest {
    @isTest
    private static void testHappyPath() {
        DNAAddress address = new DNAAddress('city', 'countryCode', 'postalCode', 'stateCode', 'street');
        String emailAddress = '2342345';
        String name = 'adfasdf';
        String orgNumber = 'jghjfghj';
        String orgType = '3434534';
        String phoneNumber = '23534645';
        String taxId = '2564564';
        
        DNAOrganization orc = new DNAOrganization(address, emailAddress, name, orgNumber, orgType, phoneNumber, taxId);
        
        System.assert(address == orc.getAddress());
        System.assert(emailAddress.equals(orc.getEmailAddress()));
        System.assert(name.equals(orc.getName()));
        System.assert(orgNumber.equals(orc.getOrgNumber()));
        System.assert(orgType.equals(orc.getOrgType()));
        System.assert(phoneNumber.equals(orc.getPhoneNumber()));
        System.assert(taxId.equals(orc.getTaxId()));
    }
}