@IsTest
private class ESignVisaOverchargeMapperTest {
    @IsTest
    private static void testHappyPath() {
        String json = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","pan":"1234123412341234","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","amountCharged":"$1000.34","correctCharge":"$100.34","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';

        String id = '1';
        String name = 'John Smith';
        String email = 'noreply@iccu.com';
        String role = 'Member1';

        ESignVisaOverchargeMapper mapper = new ESignVisaOverchargeMapper(json);

        ESignSendCeremonyRequest request = mapper.mapRequest();
        System.assert(request != null);

        ESignCeremony ceremony = request.ceremony;
        System.assert(ceremony != null);
        System.assert(ceremony.subject != null);

        List<ESignTemplate> templates = ceremony.templates;
        System.assert(templates != null);
        System.assert(templates.size() == 1);

        ESignTemplate template1 = templates.get(0);
        System.assertEquals(1, template1.sequence);
        System.assert(template1.id != null);
        System.assert(template1.id != ''); // not going to check the exact ID because it will be different across environments

        List<ESignRecipient> recipients1 = template1.recipients;
        System.assert(recipients1 != null);
        System.assert(recipients1.size() == 1);

        ESignRecipient recipient1 = recipients1.get(0);
	    System.assertEquals(id, recipient1.id);
        System.assertEquals(name, recipient1.name);
        System.assertEquals(email, recipient1.email);
        System.assertEquals(role, recipient1.role);

        ESignData data1 = recipient1.data;
        System.assert(data1 != null);

        List<ESignData.ESignTextData> textData1 = data1.textData;
        List<ESignData.ESignSelectData> radioData1 = data1.radioData;
        List<ESignData.ESignSelectData> checkData1 = data1.checkData;

        System.assert(textData1 != null);
        System.assert(radioData1 != null);
        System.assert(checkData1 != null);
        System.assert(textData1.size() == 19);
        System.assert(radioData1.size() == 0);
        System.assert(checkData1.size() == 0);
    }
}