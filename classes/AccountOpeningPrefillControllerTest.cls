@isTest
private class AccountOpeningPrefillControllerTest {

    @IsTest
    private static void testPrefillHappyPath() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),
            MemberNumber__c = '23423987',
            Email = 'something@example.com',
            FirstName = 'Jack', 
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxID__c = '000-00-0000', 
            PersonNumber__c = '1342342',
            Phone = '(555) 555-5555'
        );
        
        insert testContact;
        
        ServiceAccounts__c avokaServiceAccount = new ServiceAccounts__c(
            Name = 'AvokaTM',
            Password__c = 'username',
            ServiceName__c = 'AvokaTM',
            Username__c = 'password'
        );

        insert avokaServiceAccount;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAvokaTMResponse());
        
        Map<String, Object> product = new Map<String, Object>();
        product.put('majorTypeCode', 'SAV');
        product.put('minorTypeCode', 'SVG');
        
        Map<String, Object> response = AccountOpeningPrefillController.submitPrefilledApplication(testContact.Id, product);
        System.assert(response != null);
        
        String error = (String)response.get('error');
        System.assert(error == null, error);
        System.assert(response.get('prefillURL') != null, response);
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testGetProductsHappyPath() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockProductDataResponse());
        
        Map<String, Object> response = AccountOpeningPrefillController.getAvailableProducts();
        System.assert(response != null);
        
        String error = (String)response.get('error');
        System.assert(error == null, error);
        
        List<Map<String, Object>> products = (List<Map<String, Object>>)response.get('products');
        System.assert(products != null);

        for (Map<String, Object> product : products) {
            String displayName = (String)product.get('displayName');
            String description = (String)product.get('description');
            String majorTypeCode = (String)product.get('majorTypeCode');
            String minorTypeCode = (String)product.get('minorTypeCode');

            System.assert(description != null, 'description was null!');
            System.assert(displayName != null, 'displayName was null!');
            System.assert(majorTypeCode != null, 'majorTypeCode was null!');
            System.assert(minorTypeCode != null, 'minorTypeCode was null!');
        }

        Test.stopTest();
    }

    @IsTest
    private static void testPrefillUnhappyPath() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),
            MemberNumber__c = '23423987',
            Email = 'something@example.com',
            FirstName = 'Jack', 
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxID__c = '000-00-0000', 
            PersonNumber__c = '1342342',
            Phone = '(555) 555-5555'
        );
        
        insert testContact;
        
        ServiceAccounts__c avokaServiceAccount = new ServiceAccounts__c(
            Name = 'AvokaTM',
            Password__c = 'username',
            ServiceName__c = 'AvokaTM',
            Username__c = 'password'
        );

        insert avokaServiceAccount;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAvokaTMResponse());
        
        Map<String, Object> product = new Map<String, Object>();
        
        Map<String, Object> noTypeCodesResponse = AccountOpeningPrefillController.submitPrefilledApplication(testContact.Id, product);
        String noTypeCodesError = (String)noTypeCodesResponse.get('error');
        System.assert(noTypeCodesError != null);
        
        Map<String, Object> nullProductResponse = AccountOpeningPrefillController.submitPrefilledApplication(testContact.Id, null);
        String nullProductError = (String)nullProductResponse.get('error');
        System.assert(nullProductError != null);
        
        Map<String, Object> nullContactResponse = AccountOpeningPrefillController.submitPrefilledApplication(null, product);
        String nullContactError = (String)nullContactResponse.get('error');
        System.assert(nullContactError != null);
        
        Test.stopTest();
    }
}