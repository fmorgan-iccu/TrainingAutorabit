public with sharing class AddressDetailController {

    // A proxy method to get the countries list.
    @AuraEnabled
    public static Map<String,Object> getAddressOptions() {
        List<Map<String, Object>> states = USStateUtils.getStates();
        List<Map<String, Object>> countries = CountryUtils.getCountries();
        Map<String,Object> options = new Map<String,Object> {
            'stateOptions' => states,
            'countryOptions' => countries
        };
        return options;
    }

    /**
     * Gets the a DNA verified city and state for the given postal code.
     */
    @AuraEnabled
    public static Map<String, String> getSuggestedCityState(String postalCode) {
        SFAddress address = AddressUtils.getVerifiedAddress(postalCode);
        Map<String, String> results = new Map<String, String> {
            'city' => address != null ? address.getCity() : null,
            'stateCode' => address != null ? address.getStateCode() : null
        };
        return results;
    }

}