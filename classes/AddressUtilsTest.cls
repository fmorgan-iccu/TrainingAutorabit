@isTest
private class AddressUtilsTest {
    @isTest
    private static void testCityStateZipHappyPath() {
        String city = 'Tooele';
        String state = 'UT';
        String zip = '84074';
        
        String actual = AddressUtils.combineCityStateZip(city, state, zip);
        
        System.assertEquals('Tooele, UT  84074', actual);
    }
    
    @isTest
    private static void testCityStateZipMissingCity() {
        String city = null;
        String state = 'UT';
        String zip = '84074';
        
        String actual = AddressUtils.combineCityStateZip(city, state, zip);
        
        System.assertEquals('UT  84074', actual);
    }
    
    @isTest
    private static void testCityStateZipMissingState() {
        String city = 'Tooele';
        String state = null;
        String zip = '84074';
        
        String actual = AddressUtils.combineCityStateZip(city, state, zip);
        
        System.assertEquals('Tooele, 84074', actual);
    }
    
    @isTest
    private static void testCityStateZipMissingZip() {
        String city = 'Tooele';
        String state = 'UT';
        String zip = null;
        
        String actual = AddressUtils.combineCityStateZip(city, state, zip);
        
        System.assertEquals('Tooele, UT', actual);
    }
    
    @isTest
    private static void testCityStateZipMissingStateAndZip() {
        String city = 'Tooele';
        String state = null;
        String zip = null;
        
        String actual = AddressUtils.combineCityStateZip(city, state, zip);
        
        System.assertEquals('Tooele', actual);
    }
    
        @isTest
    private static void testCityStateZipMissingCityAndState() {
        String city = null;
        String state = null;
        String zip = '84074';
        
        String actual = AddressUtils.combineCityStateZip(city, state, zip);
        
        System.assertEquals('84074', actual);
    }

    @isTest
    private static void testCityStateZipMissingEverything() {
        String city = null;
        String state = null;
        String zip = null;
        
        String actual = AddressUtils.combineCityStateZip(city, state, zip);
        
        System.assertEquals(null, actual);
    }

    @isTest
    private static void testGetVerifiedAddress() {
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
        
        IAddress addressZipOnly = AddressUtils.getVerifiedAddress('83204');
        IAddress addressZipPlusFour = AddressUtils.getVerifiedAddress('83204-4678');

        Test.stopTest();

        System.assertNotEquals(null, addressZipOnly);
        System.assertEquals('Pocatello', addressZipOnly.getCity());
        System.assertEquals('ID', addressZipOnly.getStateCode());
        System.assertEquals('83204', addressZipOnly.getPostalCode());

        System.assertNotEquals(null, addressZipPlusFour);
        System.assertEquals('Pocatello', addressZipPlusFour.getCity());
        System.assertEquals('ID', addressZipPlusFour.getStateCode());
        System.assertEquals('83204', addressZipPlusFour.getPostalCode());
    }

    @isTest
    private static void testGetVerifiedAddressUnhappy() {
        Test.startTest();
        
        IAddress a = AddressUtils.getVerifiedAddress('');

        Test.stopTest();

        System.assertEquals(null, a);
    }

    @isTest
    private static void testIsAttention() {
        List<String> matches = new List<String> {
            'Fbo: Ron Salez',
            'FBO Jetco Prop',
            'c/o Frances Barber',
            'C/O Rollan Withrow',
            'CO Rich Charrier'
        };
        for (String addressLine : matches) {
            System.assertEquals(true, AddressUtils.isAttention(addressLine), '"' + addressLine +'" isn\'t detected as an Attention line and should be.');
        }
        
        List<String> noMatches = new List<String> {
            'LEGACY INC',
            'Acme LLC',
            'John Smith',
            'Wells Fargo'
        };
        for (String addressLine : noMatches) {
            System.assertEquals(false, AddressUtils.isAttention(addressLine), '"' + addressLine +'" is detected as an Attention line and should\'t be.');
        }
    }

    @isTest
    private static void testIsApartment() {
        List<String> matches = new List<String> {
            'Apartment 1',
            '#131',
            'Apt. C104',
            'Apt 11',
            '1510 Malta Ave. #1',
            '980 W Parkstone Apt A108',
            '10305 SW Wilsonville apt 10',
            '16384 N Franklin Blvd Apt D5',
            '#15-192',
            '#B',
            'Unit #9302',
            'Apartment # 148',
            '#101',
            '10 College Ave #A',
            'Apartment B1',
            '101',
            'A201',
            '4405 Fairstone Dr Apt106'
        };
        for (String addressLine : matches) {
            System.assertEquals(true, AddressUtils.isApartment(addressLine), '"' + addressLine +'" isn\'t detected as an apartment and should be.');
        }
        
        List<String> noMatches = new List<String> {
            'Aptitude St. 123',
            'Unit A2',
            '2219 S Kihei Rd A114',
            'Aprt. 1',
            'Trlr 18',
            'Num 267',
            'Appt 1'
        };
        for (String addressLine : noMatches) {
            System.assertEquals(false, AddressUtils.isApartment(addressLine), '"' + addressLine +'" is detected as an apartment and should\'t be.');
        }
    }

    @isTest
    private static void testIsBuilding() {
        List<String> matches = new List<String> {
            'Building 2412 Suite 318',
            'Trailer # 14',
            'Trailer 9',
            'Unit # 105',
            'Unit 2120',
            'Trlr 47',
            'Unit 103',
            'BLD P-108',
            '321 S Saint Vrain ave unit A',
            '669 Quinn Bldg #1',
            'Bld. A Apt. 525'
        };
        for (String addressLine : matches) {
            System.assertEquals(true, AddressUtils.isBuilding(addressLine), '"' + addressLine +'" isn\'t detected as an building and should be.');
        }
        
        List<String> noMatches = new List<String> {
            'HC 71 Box 1090',
            'Suite 700',
            'Space D'
        };
        for (String addressLine : noMatches) {
            System.assertEquals(false, AddressUtils.isBuilding(addressLine), '"' + addressLine +'" is detected as an building and should\'t be.');
        }
    }

    @isTest
    private static void testIsPostOfficeBox() {
        List<String> matches = new List<String> {
            'PO Box',
            'P.O. Box',
            'PO. Box',
            'po box',
            'P.o box',
            'po box',
            'p.o. box',
            'post office box',
            'P.O. Box',
            'PO. Box',
            'P O Box',
            'p o box 1',
            'PO Box',
            'Postal Box',
            'Post Office Box',
            'P.O Box',
            'post office box 1',
            'postal office box 1',
            'postal box 1',
            'p.0. box',
            'p.  o.  box',
            'p.o.  box'
        };
        for (String addressLine : matches) {
            System.assertEquals(true, AddressUtils.isPostOfficeBox(addressLine), '"' + addressLine +'" isn\'t detected as a PO Box and should be.');
        }
        
        List<String> noMatches = new List<String> {
            'post office b 1',
            'post off box 1',
            'post off b 1',
            'post o box 1',
            'post o b 1',
            'p office box 1',
            'p office b 1',
            'p off box 1',
            'p off b 1',
            'p-o-b-1',
            'p.o.b.1',
            'POB',
            'pob #1',
            'pob num1',
            'pob number1',
            'foo pob1',
            'box #1',
            'po 1',
            'pb 1',
            'Expo Blvd',
            'Rural Route Box 1',
            'Army Post 1',
            'postal office 1',
            'poop box',
            'pony box',
            'POBox',
            'PO',
            'po bo',
            'Pobox',
            'Post',
            'PostOfficeBox'
        };
        for (String addressLine : noMatches) {
            System.assertEquals(false, AddressUtils.isPostOfficeBox(addressLine), '"' + addressLine +'" is detected as a PO Box and should\'t be.');
        }
    }

    @isTest
    private static void testIsRuralRoute() {
        List<String> matches = new List<String> {
            'RT 3 Box 252',
            'Route 2 Box 85-P',
            'RR 3 Box 252',
            'RT. 3 Box 219',
            'Rural Route 6 Box 667',
            'rt 6 box 873'
        };
        for (String addressLine : matches) {
            System.assertEquals(true, AddressUtils.isRuralRoute(addressLine), '"' + addressLine +'" isn\'t detected as an rural route and should be.');
        }
        
        List<String> noMatches = new List<String> {
            'PO Box 457',
            'Rte 123',
            'rrainbox 901',
            'Box 1750',
            '#1700 Hackamore'
        };
        for (String addressLine : noMatches) {
            System.assertEquals(false, AddressUtils.isRuralRoute(addressLine), '"' + addressLine +'" is detected as an rural route and should\'t be.');
        }
    }
}