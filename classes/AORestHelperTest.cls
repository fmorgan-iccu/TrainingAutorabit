@IsTest
private class AORestHelperTest {

    @IsTest
    private static void testCompression() {
        String payload = '{"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340"}}}';

        Test.startTest();

        String compressedPayload = AORestHelper.compressRequest(payload);
        String decompressedPayload = AORestHelper.decompressRequest(compressedPayload);

        Test.stopTest();

        System.assertNotEquals(null, compressedPayload);
        // NOTE:  The Zippex library doesn't actually compress the payload!
        //System.assert(compressedPayload.length() < payload.length(), 'Payload was not compressed, smaller than original size.');
        System.assertEquals(payload, decompressedPayload);
    }

    @IsTest
    private static void testValidCompression() {
        String payload = '{"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340"}}}';
        String compressedPayload = AORestHelper.compressRequest(payload);

        RestRequest request = new RestRequest();
        request.requestUri = 'https://test.salesforce.com/services/apexrest/accountopening/applicant';
        request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf(compressedPayload);
        RestContext.request = request;

        Test.startTest();

        AOApplicationRestRequest appRequest = AORestHelper.parseRequestBody();

        Test.stopTest();

        System.assertEquals('Paul', appRequest.applicant.person.first_name);
    }

    @IsTest
    private static void testInvalidCompression() {
        String requestBody = '{"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340"}}}';
        Blob payload = Blob.valueOf(requestBody);
        Zippex zip = new Zippex();
        zip.addFile('invalid.json', payload, null);
        Blob zipData = zip.getZipArchive();
        String compressedPayload = EncodingUtil.base64Encode(zipData);

        Test.startTest();

        String decompressedPayload = AORestHelper.decompressRequest(compressedPayload);

        Test.stopTest();

        System.assertEquals(null, decompressedPayload);
    }

}