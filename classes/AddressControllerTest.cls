@IsTest
public with sharing class AddressControllerTest {

    @IsTest
    private static void testHappyPath() {
        Map<String, Object> options = AddressDetailController.getAddressOptions();

        System.assertEquals(2, options.size());
        System.assert(options.containsKey('stateOptions'));
        System.assert(options.containsKey('countryOptions'));

        List<Map<String, Object>> stateOptions = (List<Map<String, Object>>) options.get('stateOptions');
        List<Map<String, Object>> countryOptions = (List<Map<String, Object>>) options.get('countryOptions');

        System.assert(stateOptions.size() > 0);
        System.assert(countryOptions.size() > 0);
        System.assertEquals('USA', countryOptions[0].get('code'));
        // Because the address controller uses the state/country utilities, no further tests will
        // be performed here.
    }
}