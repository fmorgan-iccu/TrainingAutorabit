@IsTest
private class ESignSubsequentActionMapperTest {

    @IsTest
    private static void testHappyPath() {
        String json = '{"iccu":{"accountNumber":"99999999999","requestDate":"4/24/2020","collateralDescription":"2020 CHEVY CAMERO","vin":"IDSPISPOPD","releaseBorrower":true,"releaseDate":"5/1/2020","releaseName":"John Smith","borrowerNumber":"8888888888888","loanModification":true,"unpaidBalance":"5,567.34","interestRate":"16.78","interestStartDate":"5/1/2020","modMonthlyPayment":true,"modRate":false,"modNone":false,"monthlyPayment1":"786.36","dueDate1":"5/1/2020","monthlyPayment2":"400.00","modReason1":"xxxxxxxx","modReason2":"","creditProtection":true,"makeMorePayments":true,"increasePayments":false,"monthlyPayment3":"456.34","cancelationOfInsurance":true,"lifeInsurance":true,"lifeName1":"Billy Smith","lifeName2":"Jane Smith","creditDisability":true,"creditName1":"Billy Smith"},"borrowers":[{"name":"John Smith","email":"jsmith@example.com"},{"name":"Jane Smith","email":"jsmith1@example.com"},{"name":"Billy Smith","email":"bsmith@example.com"}]}';

        String id = '0';
        String name = 'MCC Processing';
        String role = 'ICCU1';

        ESignSubsequentActionMapper mapper = new ESignSubsequentActionMapper(json);

        ESignSendCeremonyRequest request = mapper.mapRequest();
        System.assert(request != null);

        ESignCeremony ceremony = request.ceremony;
        System.assert(ceremony != null);

        List<ESignTemplate> templates = ceremony.templates;
        System.assert(templates != null);
        System.assert(templates.size() == 1);

        ESignTemplate template1 = templates.get(0);
        System.assertEquals(1, template1.sequence);
        System.assert(template1.id != null);
        System.assert(template1.id != ''); // not going to check the exact ID because it will be different across environments

        List<ESignRecipient> recipients1 = template1.recipients;
        System.assert(recipients1 != null);
        System.assert(recipients1.size() == 4);

        ESignRecipient recipient1 = recipients1.get(3);
		System.assertEquals(id, recipient1.id);
        System.assertEquals(name, recipient1.name);
        System.assertEquals(role, recipient1.role);

        ESignData data1 = recipient1.data;
        System.assert(data1 != null);

        List<ESignData.ESignTextData> textData1 = data1.textData;
        List<ESignData.ESignSelectData> radioData1 = data1.radioData;
        List<ESignData.ESignSelectData> checkData1 = data1.checkData;

        System.assert(textData1 != null);
        System.assert(radioData1 != null);
        System.assert(checkData1 != null);
        System.assertEquals(24, textData1.size()); // All of ICCU1 and borrower names
        System.assertEquals(2, radioData1.size());
        System.assertEquals(6, checkData1.size());
    }
}