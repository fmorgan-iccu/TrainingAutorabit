public with sharing class CountryUtils {

    public class Country {
        public String name { get; private set; }
        public String code { get; private set; }
        public String codeAlpha2 { get; private set; }
        public Boolean ofacBlocked { get; private set; }
        public Boolean coopRestricted { get; private set; }

        public Country(String name, String code, String codeAlpha2, Boolean ofacBlocked, Boolean coopRestricted) {
            this.name = name;
            this.code = code;
            this.codeAlpha2 = codeAlpha2;
            this.ofacBlocked = ofacBlocked;
            this.coopRestricted = coopRestricted;
        }

        public Map<String, Object> toMap() {
            Map<String, Object> countryMap = new Map<String, Object> {
                'name' => this.name,
                'code' => this.code,
                'codeAlpha2' => this.codeAlpha2,
                'ofacBlocked' => this.ofacBlocked,
                'coopRestricted' => this.coopRestricted
            };
            return countryMap;
        }
    }

    /**
     * Country names and alpha 2 character codes are sourced from DNA using the following query.
     *
     *      SELECT ctryname, shortcd FROM ctry;
     *
     * The ISO 3166-1 alpha-3 standard establishes these codes.
     */
    private static final Map<String, Country> countries = new Map<String, Country> {
        'USA' => new Country('United States', 'USA', 'US', false, false),
        'AFG' => new Country('Afghanistan', 'AFG', 'AF', false, false),
        'ALA' => new Country('Aland Islands', 'ALA', 'AX', false, false),
        'ALB' => new Country('Albania', 'ALB', 'AL', false, false),
        'DZA' => new Country('Algeria', 'DZA', 'DZ', false, false),
        'ASM' => new Country('American Samoa', 'ASM', 'AS', false, false),
        'AND' => new Country('Andorra', 'AND', 'AD', false, false),
        'AGO' => new Country('Angola', 'AGO', 'AO', false, false),
        'AIA' => new Country('Anguilla', 'AIA', 'AI', false, false),
        'ATA' => new Country('Antarctica', 'ATA', 'AQ', false, false),
        'ATG' => new Country('Antigua and Barbuda', 'ATG', 'AG', false, false),
        'ARG' => new Country('Argentina', 'ARG', 'AR', false, false),
        'ARM' => new Country('Armenia', 'ARM', 'AM', false, false),
        'ABW' => new Country('Aruba', 'ABW', 'AW', false, false),
        'AUS' => new Country('Australia', 'AUS', 'AU', false, false),
        'AUT' => new Country('Austria', 'AUT', 'AT', false, false),
        'AZE' => new Country('Azerbaijan', 'AZE', 'AZ', false, true),
        'BHS' => new Country('Bahamas', 'BHS', 'BS', false, false),
        'BHR' => new Country('Bahrain', 'BHR', 'BH', false, false),
        'BGD' => new Country('Bangladesh', 'BGD', 'BD', false, false),
        'BRB' => new Country('Barbados', 'BRB', 'BB', false, false),
        'BLR' => new Country('Belarus', 'BLR', 'BY', false, false),
        'BEL' => new Country('Belgium', 'BEL', 'BE', false, false),
        'BLZ' => new Country('Belize', 'BLZ', 'BZ', false, false),
        'BEN' => new Country('Benin', 'BEN', 'BJ', false, false),
        'BMU' => new Country('Bermuda', 'BMU', 'BM', false, false),
        'BTN' => new Country('Bhutan', 'BTN', 'BT', false, false),
        'BOL' => new Country('Bolivia', 'BOL', 'BO', false, false),
        'BIH' => new Country('Bosnia and Herzegovina', 'BIH', 'BA', false, false),
        'BWA' => new Country('Botswana', 'BWA', 'BW', false, false),
        'BRA' => new Country('Brazil', 'BRA', 'BR', false, false),
        'BRN' => new Country('Brunei Darussalam', 'BRN', 'BN', false, false),
        'BGR' => new Country('Bulgaria', 'BGR', 'BG', false, false),
        'BFA' => new Country('Burkina Faso', 'BFA', 'BF', false, false),
        'BDI' => new Country('Burundi', 'BDI', 'BI', false, false),
        'CMR' => new Country('Cameroon', 'CMR', 'CM', false, false),
        'KHM' => new Country('Cambodia', 'KHM', 'KH', false, false),
        'CAN' => new Country('Canada', 'CAN', 'CA', false, false),
        'CPV' => new Country('Cape Verde', 'CPV', 'CV', false, false),
        'CAF' => new Country('Central African Republic', 'CAF', 'CF', false, false),
        'TCD' => new Country('Chad', 'TCD', 'TD', false, false),
        'CHL' => new Country('Chile', 'CHL', 'CL', false, false),
        'CHN' => new Country('China', 'CHN', 'CN', false, false),
        'CXR' => new Country('Christmas Island', 'CXR', 'CX', false, false),
        'FYP' => new Country('Clipperton Island', 'FYP', 'CP', false, false),
        'CCK' => new Country('Cocos (Keeling) Islands', 'CCK', 'CC', false, false),
        'COL' => new Country('Colombia', 'COL', 'CO', false, false),
        'COM' => new Country('Comoros', 'COM', 'KM', false, false),
        'COG' => new Country('Congo', 'COG', 'CG', false, false),
        'COD' => new Country('Congo, Democratic Republic of', 'COD', 'CD', false, false),
        'COK' => new Country('Cook Islands', 'COK', 'CK', false, false),
        'CRI' => new Country('Costa Rica', 'CRI', 'CR', false, false),
        'CIV' => new Country('Cote D\'Ivoire', 'CIV', 'CI', false, false),
        'HRV' => new Country('Croatia', 'HRV', 'HR', false, false),
        'CUW' => new Country('Curacao', 'CUW', 'CW', false, false),
        'CYP' => new Country('Cyprus', 'CYP', 'CY', false, false),
        'CUB' => new Country('Cuba', 'CUB', 'CU', false, true),
        'CZE' => new Country('Czech Republic', 'CZE', 'CZ', false, false),
        'DNK' => new Country('Denmark', 'DNK', 'DK', false, false),
        'DJI' => new Country('Djibouti', 'DJI', 'DJ', false, false),
        'DMA' => new Country('Dominica', 'DMA', 'DM', false, false),
        'DOM' => new Country('Dominican Republic', 'DOM', 'DO', false, false),
        'ECU' => new Country('Ecuador', 'ECU', 'EC', false, false),
        'SLV' => new Country('El Salvador', 'SLV', 'SV', false, false),
        'EGY' => new Country('Egypt', 'EGY', 'EG', false, false),
        'GNQ' => new Country('Equatorial Guinea', 'GNQ', 'GQ', false, false),
        'ERI' => new Country('Eritrea', 'ERI', 'ER', false, false),
        'EST' => new Country('Estonia', 'EST', 'EE', false, false),
        'ETH' => new Country('Ethiopia', 'ETH', 'ET', false, false),
        'FLK' => new Country('Falkland Islands (Malvinas)', 'FLK', 'FK', false, false),
        'FRO' => new Country('Faroe Islands', 'FRO', 'FO', false, false),
        'FIN' => new Country('Finland', 'FIN', 'FI', false, false),
        'FJI' => new Country('Fiji', 'FJI', 'FJ', false, false),
        'FRA' => new Country('France', 'FRA', 'FR', false, false),
        'GUF' => new Country('French Guiana', 'GUF', 'GF', false, false),
        'PYF' => new Country('French Polynesia', 'PYF', 'PF', false, false),
        'GAB' => new Country('Gabon', 'GAB', 'GA', false, false),
        'GMB' => new Country('Gambia', 'GMB', 'GM', false, false),
        'GEO' => new Country('Georgia', 'GEO', 'GE', false, false),
        'DEU' => new Country('Germany', 'DEU', 'DE', false, false),
        'GHA' => new Country('Ghana', 'GHA', 'GH', false, false),
        'GIB' => new Country('Gibraltar', 'GIB', 'GI', false, false),
        'CYM' => new Country('Grand Cayman', 'CYM', 'KY', false, false),
        'GRC' => new Country('Greece', 'GRC', 'GR', false, false),
        'GRL' => new Country('Greenland', 'GRL', 'GL', false, false),
        'GRD' => new Country('Grenada', 'GRD', 'GD', false, false),
        'GLP' => new Country('Guadeloupe', 'GLP', 'GP', false, false),
        'GUM' => new Country('Guam', 'GUM', 'GU', false, false),
        'GTM' => new Country('Guatemala', 'GTM', 'GT', false, false),
        'GIN' => new Country('Guinea', 'GIN', 'GN', false, false),
        'GNB' => new Country('Guinea-Bissau', 'GNB', 'GW', false, false),
        'GUY' => new Country('Guyana', 'GUY', 'GY', false, false),
        'HTI' => new Country('Haiti', 'HTI', 'HT', false, false),
        'HND' => new Country('Honduras', 'HND', 'HN', false, false),
        'HKG' => new Country('Hong Kong', 'HKG', 'HK', false, false),
        'HUN' => new Country('Hungary', 'HUN', 'HU', false, false),
        'ISL' => new Country('Iceland', 'ISL', 'IS', false, false),
        'IND' => new Country('India', 'IND', 'IN', false, false),
        'IDN' => new Country('Indonesia', 'IDN', 'ID', false, false),
        'IRQ' => new Country('Iraq', 'IRQ', 'IQ', false, false),
        'IRN' => new Country('Iran, Islamic Republic of', 'IRN', 'IR', true, false),
        'IRL' => new Country('Ireland', 'IRL', 'IE', false, false),
        'ISR' => new Country('Israel', 'ISR', 'IL', false, false),
        'ITA' => new Country('Italy', 'ITA', 'IT', false, false),
        'JAM' => new Country('Jamaica', 'JAM', 'JM', false, false),
        'JPN' => new Country('Japan', 'JPN', 'JP', false, false),
        'JOR' => new Country('Jordan', 'JOR', 'JO', false, false),
        'KAZ' => new Country('Kazakhstan', 'KAZ', 'KZ', false, false),
        'KEN' => new Country('Kenya', 'KEN', 'KE', false, false),
        'KIR' => new Country('Kiribati', 'KIR', 'KI', false, false),
        'KOR' => new Country('Korea, Republic of', 'KOR', 'KR', false, true),
        'KGZ' => new Country('Kyrgyzstan', 'KGZ', 'KG', false, false),
        'OMN' => new Country('Oman', 'OMN', 'OM', false, false),
        'PRK' => new Country('Korea, Democratic People\'s Republic of', 'PRK', 'KP', true, false),
        'KWT' => new Country('Kuwait', 'KWT', 'KW', false, false),
        'LAO' => new Country('Lao People Democratic Republic', 'LAO', 'LA', false, false),
        'LVA' => new Country('Latvia', 'LVA', 'LV', false, false),
        'LBN' => new Country('Lebanon', 'LBN', 'LB', false, false),
        'LSO' => new Country('Lesotho', 'LSO', 'LS', false, false),
        'LBR' => new Country('Liberia', 'LBR', 'LR', false, false),
        'LBY' => new Country('Libyan Arab Jamahiriya', 'LBY', 'LY', false, false),
        'LIE' => new Country('Liechtenstein', 'LIE', 'LI', false, false),
        'LTU' => new Country('Lithuania', 'LTU', 'LT', false, false),
        'LUX' => new Country('Luxembourg', 'LUX', 'LU', false, false),
        'MAC' => new Country('Macao', 'MAC', 'MO', false, false),
        'MKD' => new Country('Macedonia', 'MKD', 'MK', false, false),
        'MDG' => new Country('Madagascar', 'MDG', 'MG', false, false),
        'MWI' => new Country('Malawi', 'MWI', 'MW', false, false),
        'MYS' => new Country('Malaysia', 'MYS', 'MY', false, true),
        'MDV' => new Country('Maldives', 'MDV', 'MV', false, false),
        'MLI' => new Country('Mali', 'MLI', 'ML', false, false),
        'MLT' => new Country('Malta', 'MLT', 'MT', false, false),
        'IMN' => new Country('Man, Isle of', 'IMN', 'IM', false, false),
        'MHL' => new Country('Marshall Islands', 'MHL', 'MH', false, false),
        'MTQ' => new Country('Martinique', 'MTQ', 'MQ', false, false),
        'MRT' => new Country('Mauritania', 'MRT', 'MR', false, false),
        'MUS' => new Country('Mauritius', 'MUS', 'MU', false, false),
        'MYT' => new Country('Mayotte', 'MYT', 'YT', false, false),
        'MEX' => new Country('Mexico', 'MEX', 'MX', false, false),
        'FSM' => new Country('Micronesia, Federated State', 'FSM', 'FM', false, false),
        'MDA' => new Country('Moldova, Republic of', 'MDA', 'MD', false, false),
        'MCO' => new Country('Monaco', 'MCO', 'MC', false, false),
        'MNG' => new Country('Mongolia', 'MNG', 'MN', false, false),
        'MSR' => new Country('Montserrat', 'MSR', 'MS', false, false),
        'MAR' => new Country('Morocco', 'MAR', 'MA', false, false),
        'MOZ' => new Country('Mozambique', 'MOZ', 'MZ', false, false),
        'MMR' => new Country('Myanmar', 'MMR', 'MM', false, true),
        'NAM' => new Country('Namibia', 'NAM', 'NA', false, false),
        'NRU' => new Country('Nauru', 'NRU', 'NR', false, false),
        'NPL' => new Country('Nepal', 'NPL', 'NP', false, false),
        'NLD' => new Country('Netherlands', 'NLD', 'NL', false, false),
        'ANT' => new Country('Netherlands Antilles', 'ANT', 'AN', false, false),
        'NCL' => new Country('New Caledonia', 'NCL', 'NC', false, false),
        'NZL' => new Country('New Zealand', 'NZL', 'NZ', false, false),
        'NIC' => new Country('Nicaragua', 'NIC', 'NI', false, false),
        'NER' => new Country('Niger', 'NER', 'NE', false, false),
        'NGA' => new Country('Nigeria', 'NGA', 'NG', false, false),
        'NIU' => new Country('Niue', 'NIU', 'NU', false, false),
        'NFK' => new Country('Norfolk Island', 'NFK', 'NF', false, false),
        'MNP' => new Country('Northern Mariana Islands', 'MNP', 'MP', false, false),
        'NOR' => new Country('Norway', 'NOR', 'NO', false, false),
        'PLW' => new Country('Palau', 'PLW', 'PW', false, false),
        'PSE' => new Country('Palestinian Terr., Occcupied', 'PSE', 'PS', false, false),
        'PNG' => new Country('Papua New Guinea', 'PNG', 'PG', false, false),
        'PAK' => new Country('Pakistan', 'PAK', 'PK', false, false),
        'PAN' => new Country('Panama', 'PAN', 'PA', false, false),
        'PRY' => new Country('Paraguay', 'PRY', 'PY', false, false),
        'PER' => new Country('Peru', 'PER', 'PE', false, false),
        'PHL' => new Country('Philippines', 'PHL', 'PH', false, false),
        'PCN' => new Country('Pitcairn', 'PCN', 'PN', false, false),
        'PRT' => new Country('Portugal', 'PRT', 'PT', false, false),
        'POL' => new Country('Poland', 'POL', 'PL', false, false),
        'PRI' => new Country('Puerto Rico', 'PRI', 'PR', false, false),
        'QAT' => new Country('Qatar', 'QAT', 'QA', false, false),
        'REU' => new Country('Reunion', 'REU', 'RE', false, false),
        'ROU' => new Country('Romania', 'ROU', 'RO', false, false),
        'RUS' => new Country('Russia', 'RUS', 'RU', false, false),
        'RWA' => new Country('Rwanda', 'RWA', 'RW', false, false),
        'BLM' => new Country('Saint Barthelemy', 'BLM', 'BL', false, false),
        'SHN' => new Country('Saint Helena ', 'SHN', 'SH', false, false),
        'KNA' => new Country('Saint Kitts and Nevis', 'KNA', 'KN', false, false),
        'LCA' => new Country('Saint Lucia', 'LCA', 'LC', false, false),
        'SPM' => new Country('Saint Pierre and Miquelon', 'SPM', 'PM', false, false),
        'VCT' => new Country('Saint Vincent and Grenadines', 'VCT', 'VC', false, false),
        'WSM' => new Country('Samoa', 'WSM', 'WS', false, false),
        'SMR' => new Country('San Marino', 'SMR', 'SM', false, false),
        'STP' => new Country('Sao Tome and Principe', 'STP', 'ST', false, false),
        'SAU' => new Country('Saudi Arabia', 'SAU', 'SA', false, true),
        'SEN' => new Country('Senegal', 'SEN', 'SN', false, false),
        'SCG' => new Country('Serbia and Montenegro', 'SCG', 'RS', false, false),
        'SYC' => new Country('Seychelles', 'SYC', 'SC', false, false),
        'SLE' => new Country('Sierra Leone', 'SLE', 'SL', false, false),
        'SGP' => new Country('Singapore', 'SGP', 'SG', false, false),
        'SXM' => new Country('Sint Maarten', 'SXM', 'SX', false, false),
        'SVK' => new Country('Slovakia', 'SVK', 'SK', false, false),
        'SVN' => new Country('Slovenia', 'SVN', 'SI', false, false),
        'SLB' => new Country('Solomon Islands', 'SLB', 'SB', false, false),
        'SOM' => new Country('Somalia', 'SOM', 'SO', false, false),
        'ZAF' => new Country('South Africa', 'ZAF', 'ZA', false, false),
        'SSD' => new Country('South Sudan', 'SSD', 'SS', false, false),
        'ESP' => new Country('Spain', 'ESP', 'ES', false, false),
        'LKA' => new Country('Sri Lanka', 'LKA', 'LK', false, false),
        'SDN' => new Country('Sudan', 'SDN', 'SD', true, false),
        'SUR' => new Country('Suriname', 'SUR', 'SR', false, false),
        'SJM' => new Country('Svalbard and Jan Mayen', 'SJM', 'SJ', false, false),
        'SWZ' => new Country('Swaziland', 'SWZ', 'SZ', false, false),
        'SWE' => new Country('Sweden', 'SWE', 'SE', false, false),
        'CHE' => new Country('Switzerland', 'CHE', 'CH', false, false),
        'SYR' => new Country('Syrian Arab Republic', 'SYR', 'SY', true, false),
        'TWN' => new Country('Taiwan, Province of China', 'TWN', 'TW', false, true),
        'TJK' => new Country('Tajikistan', 'TJK', 'TJ', false, false),
        'TZA' => new Country('Tanzania, United Republic of', 'TZA', 'TZ', false, false),
        'THA' => new Country('Thailand', 'THA', 'TH', false, true),
        'TLS' => new Country('Timor-Leste', 'TLS', 'TL', false, false),
        'TGO' => new Country('Togo', 'TGO', 'TG', false, false),
        'TKL' => new Country('Tokelau', 'TKL', 'TK', false, false),
        'TON' => new Country('Tonga', 'TON', 'TO', false, false),
        'TTO' => new Country('Trinidad and Tobago', 'TTO', 'TT', false, false),
        'TUN' => new Country('Tunisia', 'TUN', 'TN', false, false),
        'TKM' => new Country('Turkmenistan', 'TKM', 'TM', false, false),
        'TCA' => new Country('Turks and Caicos Islands', 'TCA', 'TC', false, false),
        'TUR' => new Country('Turkey', 'TUR', 'TR', false, false),
        'TUV' => new Country('Tuvalu', 'TUV', 'TV', false, false),
        'UGA' => new Country('Uganda', 'UGA', 'UG', false, false),
        'UKR' => new Country('Ukraine', 'UKR', 'UA', false, false),
        'ARE' => new Country('United Arab Emirates', 'ARE', 'AE', false, false),
        'GBR' => new Country('United Kingdom', 'GBR', 'GB', false, false),
        'URY' => new Country('Uruguay', 'URY', 'UY', false, false),
        'UZB' => new Country('Uzbekistan', 'UZB', 'UZ', false, false),
        'VUT' => new Country('Vanuatu', 'VUT', 'VU', false, false),
        'VAT' => new Country('Vatican City', 'VAT', 'VA', false, false),
        'VEN' => new Country('Venezuela', 'VEN', 'VE', false, false),
        'VNM' => new Country('Vietnam', 'VNM', 'VN', false, false),
        'VGB' => new Country('Virgin Islands, British', 'VGB', 'VG', false, false),
        'VIR' => new Country('Virgin Islands, US', 'VIR', 'VI', false, false),
        'WLF' => new Country('Wallis and Futuna', 'WLF', 'WF', false, false),
        'ESH' => new Country('Western Sahara', 'ESH', 'EH', false, false),
        'YEM' => new Country('Yemen', 'YEM', 'YE', false, false),
        'ZMB' => new Country('Zambia', 'ZMB', 'ZM', false, false),
        'ZWE' => new Country('Zimbabwe', 'ZWE', 'ZW', false, false)
    };

    // Fast lookup from two character codes to three character codes, see getCountryByAlpha2.
    private static Map<String, String> codeLookup = null;

    public static Country getCountry(String code) {
        if (code == null) {
            return null;
        }

        Country country = countries.get(code);
        
        return country;
    }

    public static Country getCountryByAlpha2(String code) {
        if (code == null) {
            return null;
        }

        // Lazy load the lookup map to avoid unnecessary process.
        if (CountryUtils.codeLookup == null) {
            CountryUtils.codeLookup = new Map<String, String>();
            Set<String> countryCodes = countries.keySet();
            for (String codeAlpha3 : countryCodes) {
                Country c = countries.get(codeAlpha3);
                String codeAlpha2 = c.codeAlpha2;
                CountryUtils.codeLookup.put(codeAlpha2, codeAlpha3);
            }
        }

        String fullCode = CountryUtils.codeLookup.get(code);
        if (fullCode == null) {
            return null;
        }
        Country country = countries.get(fullCode);

        return country;
    }

    /**
     * This function should only be used by controllers/REST interfaces that require a base type
     * representation of the data.  Always use the Country based functions if at all possible.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCountries() {
        List<Map<String,Object>> countryList = new List<Map<String,Object>>();
        for (Country c : countries.values()) {
            countryList.add(c.toMap());
        }
        return countryList;
    }
}