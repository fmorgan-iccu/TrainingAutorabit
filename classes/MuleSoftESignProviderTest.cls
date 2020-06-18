@IsTest
private class MuleSoftESignProviderTest {
    
    private static ESignCeremony getCeremony() {
        String subject = 'Subsequent Action';
        List<ESignTemplate> templates = new List<ESignTemplate>();
        List<ESignCustomField> customFields = new List<ESignCustomField>();
        
        ESignCeremony ceremony = new ESignCeremony(subject, templates, customFields);
        
        return ceremony;
    }
    
    @IsTest
    private static void testHappyPath() {
        ESignCeremony ceremony = MuleSoftESignProviderTest.getCeremony();
        ESignSendCeremonyRequest request = new ESignSendCeremonyRequest(ceremony);
        
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        MuleSoftESignProvider provider = new MuleSoftESignProvider('https://example.com', 'id', 'secret');
        provider.sendCeremonyForESignature(request);
    }
    
    @IsTest
    private static void testUnhappyCall() {
        ESignCeremony ceremony = MuleSoftESignProviderTest.getCeremony();
        ESignSendCeremonyRequest request = new ESignSendCeremonyRequest(ceremony);
        
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        
        try {
            MuleSoftESignProvider provider = new MuleSoftESignProvider('https://example.com', 'id', 'secret');
        	provider.sendCeremonyForESignature(request);
        } catch(DataServiceException e) {
            // Expected exception
        } catch(Exception e) {
            throw e;
        }
    }
    
    @IsTest
    private static void testBadCeremony() {
        try {
            MuleSoftESignProvider provider = new MuleSoftESignProvider('https://example.com', 'id', 'secret');
        	provider.sendCeremonyForESignature(null);
            System.assert(false, 'The method should have thrown an exception, but did not.');
        } catch (IllegalArgumentException e) {
            // Expected
        } catch (Exception e) {
            throw e;
        }
    }
    
    @IsTest
    private static void testBadConstructor() {
        // Null endpoint
        try {
            MuleSoftESignProvider provider = new MuleSoftESignProvider(null, 'id', 'secret');
            System.assert(false, 'The constructor should have thrown an exception, but did not.');
        } catch (IllegalArgumentException e) {
            // Expected
        } catch (Exception e) {
            throw e;
        }
        
        // Null clientId
        try {
            MuleSoftESignProvider provider = new MuleSoftESignProvider('https://example.com', null, 'secret');
            System.assert(false, 'The constructor should have thrown an exception, but did not.');
        } catch (IllegalArgumentException e) {
            // Expected
        } catch (Exception e) {
            throw e;
        }
        
        // Null secret
        try {
            MuleSoftESignProvider provider = new MuleSoftESignProvider('https://example.com', 'id', null);
            System.assert(false, 'The constructor should have thrown an exception, but did not.');
        } catch (IllegalArgumentException e) {
            // Expected
        } catch (Exception e) {
            throw e;
        }
    }
}