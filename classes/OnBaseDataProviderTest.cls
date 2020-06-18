@isTest
private class OnBaseDataProviderTest {
	@isTest
    private static void titleFormTestUnhappy() {

        Test.setMock(HttpCalloutMock.class, new MockOnBaseResponse());

        ServiceAccounts__c onBaseServiceAccount = new ServiceAccounts__c(
            Name = 'OnBase',
            Password__c = 'username',
            ServiceName__c = 'OnBase',
            Username__c = 'password',
            apiClientSecret__c = 'Secret'
        );
        insert onBaseServiceAccount;

        Contact testContact = getTestContact();
        Map<String, Object> testTitleForm = new Map<String,Object>();
        testTitleForm.put('accountNumber', '71965454');

        String requestBody = JSON.serialize(testTitleForm);

        Test.startTest();
        Map<String,Object> response = TitleFormController.saveTitleRelease(testContact.Id, requestBody);
        Test.stopTest();

        // Error Map for assertion
        Map<String, Object> error = new Map<String,Object>();
        error.put('error','All form fields are required.');

        System.assert(response != null);
        System.assertEquals(error, response);
    }

    @isTest
    private static void titleReleaseTestHappy() {

        Test.setMock(HttpCalloutMock.class, new MockOnBaseResponse());

        ServiceAccounts__c onBaseServiceAccount = new ServiceAccounts__c(
            Name = 'OnBase',
            Password__c = 'username',
            ServiceName__c = 'OnBase',
            Username__c = 'password',
            apiClientSecret__c = 'Secret'
        );
        insert onBaseServiceAccount;

        Contact testContact = getTestContact();
        Map<String, Object> happyTitleRelease = new Map<String, Object>();
        happyTitleRelease.put('accountNumber', '123456789');
        happyTitleRelease.put('companyName', 'ICCU');
        happyTitleRelease.put('make', 'Dodge');
        happyTitleRelease.put('model', 'ram');
        happyTitleRelease.put('year', 2019);
        happyTitleRelease.put('vin', '123456789101112H');
        happyTitleRelease.put('payOffType', 'Dealership');
        happyTitleRelease.put('thirdPartyName', 'thirdPartyName');
        happyTitleRelease.put('attn', 'attn');
        happyTitleRelease.put('thirdPartyStreet', 'thirdPartyStreet');
        happyTitleRelease.put('thirdPartyCity', 'thirdPartyCity');
        happyTitleRelease.put('thirdPartyState', 'thirdPartyState');
        happyTitleRelease.put('thirdPartyPostalCode', 'thirdPartyPostalCode');
        happyTitleRelease.put('nonDnaStreet', 'nonDnaStreet');
        happyTitleRelease.put('nonDnaState', 'nonDnaState');
        happyTitleRelease.put('nonDnaPostalCode', 'nonDnaPostalCode');
        happyTitleRelease.put('buyersName', 'buyersName');
        happyTitleRelease.put('buyersStreet', 'buyersStreet');
        happyTitleRelease.put('buyersCity', 'buyersCity');
        happyTitleRelease.put('buyersState', 'buyersState');
        happyTitleRelease.put('buyersPostalCode', 'buyersPostalCode');
        happyTitleRelease.put('newLoanNumber', '123456789');
        happyTitleRelease.put('actionToTake', 'actionToTake');
        happyTitleRelease.put('buyersIccuNumber', '987654321');
        happyTitleRelease.put('buyersNewLoanNumber', null);
        happyTitleRelease.put('checkBoxVerification', '1');

        Test.startTest();
        String requestBody = JSON.serialize(happyTitleRelease);
        Map<String,Object> response = TitleFormController.saveTitleRelease(testContact.Id, requestBody);
        Test.stopTest();

        Map<String, Object> success = new Map<String,Object>();
        success.put('success', true);

        System.assert(response != null);
        System.assertEquals(success, response);
    }

    private static Contact getTestContact() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),
            MemberNumber__c = '23423987',
            Email = 'something@example.com',
            FirstName = 'Jack',
            MiddleName = 'Joe',
            LastName = 'Johnson',
            MailingStreet = '123 Penny Lane',
            MailingCity = 'Chubbuck',
            MailingState = 'ID',
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxID__c = '000-00-0000',
            PersonNumber__c = '123456',
            Phone = '(555) 555-5555'
        );
        insert testContact;

        return testContact;
    }
}