@IsTest
private class ESignACHDisputeMapperTest {

    @IsTest
    private static void testHappyPath() {
        String json = '{"name":"John Smith","taxId":"666-66-6666","email":"noreply@iccu.com","memberNumber":"9999999999999","accountNumber":"88888888888888","companies":[{"name":"Idaho Power","reason":"NOT_AUTHORIZED","transactions":[{"date":"4/23/2020","amount":"$123.23"}]},{"name":"CITY OF POCATELLO","reason":"DIFFERENT_AMOUNT","transactions":[{"date":"4/20/2020","amount":"$12,123.23"}]}]}';

        String id = '1';
        String name = 'John Smith';
        String email = 'noreply@iccu.com';
        String subject = 'Idaho Central Credit Union ACH Dispute';
        String role = 'Borrower1';

        ESignACHDisputeMapper mapper = new ESignACHDisputeMapper(json);

        ESignSendCeremonyRequest request = mapper.mapRequest();
        System.assert(request != null);

        ESignCeremony ceremony = request.ceremony;
        System.assert(ceremony != null);
        System.assertEquals(subject, ceremony.subject);

        List<ESignTemplate> templates = ceremony.templates;
        System.assert(templates != null);
        System.assert(templates.size() == 2);

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
        System.assert(textData1.size() == 8);
        System.assert(radioData1.size() == 1);
        System.assert(checkData1.size() == 0);
    }

    @IsTest
    private static void testUnhappySuper() {
        try {
            ESignACHDisputeMapper mapper = new ESignACHDisputeMapper(null);
            System.assert(false, 'Should have thrown an exception.');
        } catch (IllegalArgumentException e) {
            // EXPECTED
        }

        try {
            ESignACHDisputeMapper mapper = new ESignACHDisputeMapper('');
            System.assert(false, 'Should have thrown an exception.');
        } catch (IllegalArgumentException e) {
            // EXPECTED
        }

        ESignACHDisputeMapper mapper = new ESignACHDisputeMapper('{}');

        DocumentTemplate__mdt template = mapper.getTemplateMetadata('');
        System.assert(template == null);
		template = mapper.getTemplateMetadata(null);
        System.assert(template == null);
    }
}