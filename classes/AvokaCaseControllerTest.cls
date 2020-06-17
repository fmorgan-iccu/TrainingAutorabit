@IsTest
private class AvokaCaseControllerTest {
	@IsTest
    private static void testHappyPath() {
        String mjr = 'CK';
        String mnr = 'CKBA';
        
        Test.setMock(HttpCalloutMock.class, new MockProductDataResponse());
        
        Test.startTest();

        try {
            Map<String, Object> response = AvokaCaseController.getProduct(mjr, mnr);
            
            System.assert(response != null);
            
            String error = (String)response.get('error');
            System.assert(error == null, 'Expected no error: ' + error);
            
            Map<String, Object> rawProduct = (Map<String, Object>)response.get('product');
            System.assert(rawProduct != null, 'Response product was null!');
            
            String expectedName = 'Free Checking';
            String name = (String)rawProduct.get('displayName');
            System.assert(name == expectedName, 'Expected (' + expectedName + ') but got (' + name + ').');
        } catch(Exception e) {
            System.assert(false, 'Unexpected exception thrown: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testUnhappyPath() {
        Test.startTest();
        
        try {
            Map<String, Object> nullProductResponse = AvokaCaseController.getProduct(null, null);
        	System.assert(nullProductResponse != null, 'response was null');

            String error = (String)nullProductResponse.get('error');
            System.assert(error != null, 'Expected an error, but none was given.');
            
            Map<String, Object> nonexistentResponse = AvokaCaseController.getProduct('asdf', 'reqw');
            error = (String)nonexistentResponse.get('error');
            
            System.assert(error != null, 'Expected an error, but none was given.');
        } catch(Exception e) {
            System.assert(false, 'Unexpected exception thrown: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
}