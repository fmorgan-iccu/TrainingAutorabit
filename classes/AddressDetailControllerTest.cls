@IsTest
private class AddressDetailControllerTest {

    @IsTest
    private static void testGetSuggestedCityState() {
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
        Contact c = new Contact(
            lastName = 'Test',
            mailingCity = 'Pocatello',
            mailingCountry = 'USA',
            mailingPostalCode = '83204',
            mailingState = 'ID',
            recordTypeId = recordTypeId
        );
        insert c;

        Test.startTest();

        Map<String, String> resultFound = AddressDetailController.getSuggestedCityState('83204');
        Map<String, String> resultNotFound = AddressDetailController.getSuggestedCityState('');

        Test.stopTest();

        System.assertNotEquals(null, resultFound);
        System.assertEquals('Pocatello', resultFound.get('city'));
        System.assertEquals('ID', resultFound.get('stateCode'));

        System.assertNotEquals(null, resultNotFound);
        System.assertEquals(null, resultNotFound.get('city'));
        System.assertEquals(null, resultNotFound.get('stateCode'));
    }

}