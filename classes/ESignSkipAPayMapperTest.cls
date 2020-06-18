@IsTest
private class ESignSkipAPayMapperTest {

    @IsTest
    private static void testHappyPath() {
        String json = '{"name":"John Smith","email":"noreply@iccu.com","memberNumber":"9999999999999","addressLine1":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","accounts":[{"accountNumber":"88888888888888","accountDescription":"VISA Credit Card","unpaidBalance":"5,456","paymentAmount":"144","skipDate":"5/1/2020","letterDate":"4/23/2020","skipMonth":"05","loanType":"visa"}]}';

        String id = '1';
        String name = 'John Smith';
        String email = 'noreply@iccu.com';
        String subject = 'Idaho Central Credit Union Skip-a-Pay';
        String role = 'Borrower1';

        ESignSkipAPayMapper mapper = new ESignSkipAPayMapper(json);

        ESignSendCeremonyRequest request = mapper.mapRequest();
        System.assert(request != null);

        ESignCeremony ceremony = request.ceremony;
        System.assert(ceremony != null);
        System.assertEquals(subject, ceremony.subject);

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
        System.assert(textData1.size() == 12);
        System.assert(radioData1.size() == 0);
        System.assert(checkData1.size() == 1);


        // For test coverage...
        String consumerJson = '{"name":"John Smith","email":"noreply@iccu.com","memberNumber":"9999999999999","addressLine1":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","accounts":[{"accountNumber":"88888888888888","accountDescription":"VISA Credit Card","unpaidBalance":"5,456","paymentAmount":"144","skipDate":"5/1/2020","letterDate":"4/23/2020","skipMonth":"05","loanType":"consumer"}]}';
        mapper = new ESignSkipAPayMapper(consumerJson);
        mapper.mapRequest();
    }

    @IsTest
    private static void testBadLoanType() {
        String json = '{"name":"John Smith","email":"noreply@iccu.com","memberNumber":"9999999999999","addressLine1":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","accounts":[{"accountNumber":"88888888888888","accountDescription":"VISA Credit Card","unpaidBalance":"5,456","paymentAmount":"144","skipDate":"5/1/2020","letterDate":"4/23/2020","skipMonth":"05","loanType":"spaceship"}]}';
        ESignSkipAPayMapper mapper = new ESignSkipAPayMapper(json);

        try {
            mapper.mapRequest();
            System.assert(false, 'expected to throw an exception, but did not.');
        } catch (IllegalArgumentException e) {
            // Expected
        }
    }
}