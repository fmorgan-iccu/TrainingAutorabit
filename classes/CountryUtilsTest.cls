@IsTest
private with sharing class CountryUtilsTest {

    @IsTest
    private static void testHappyPath() {
        List<Map<String, Object>> countries = CountryUtils.getCountries();
        System.assert(countries.size() > 0);

        Map<String, Object> firstCountry = countries[0];
        System.assert(firstCountry.containsKey('name'));
        System.assert(firstCountry.containsKey('code'));
        System.assert(firstCountry.containsKey('codeAlpha2'));
        System.assert(firstCountry.containsKey('ofacBlocked'));
        System.assert(firstCountry.containsKey('coopRestricted'));
        System.assertEquals('United States', firstCountry.get('name'));

        CountryUtils.Country unitedStates = CountryUtils.getCountry('USA');
        System.assertEquals('United States', unitedStates.name);
        System.assertEquals('USA', unitedStates.code);
        System.assertEquals('US', unitedStates.codeAlpha2);
        System.assertEquals(false, unitedStates.ofacBlocked);
        System.assertEquals(false, unitedStates.coopRestricted);

        CountryUtils.Country italy = CountryUtils.getCountryByAlpha2('IT');
        System.assertEquals('Italy', italy.name);
        System.assertEquals('ITA', italy.code);
        System.assertEquals('IT', italy.codeAlpha2);
        System.assertEquals(false, italy.ofacBlocked);
        System.assertEquals(false, italy.coopRestricted);

        CountryUtils.Country nullCountry = CountryUtils.getCountry(null);
        System.assertEquals(null, nullCountry);

        nullCountry = CountryUtils.getCountry('INVALID');
        System.assertEquals(null, nullCountry);

        nullCountry = CountryUtils.getCountryByAlpha2(null);
        System.assertEquals(null, nullCountry);

        nullCountry = CountryUtils.getCountryByAlpha2('??');
        System.assertEquals(null, nullCountry);
    }

}