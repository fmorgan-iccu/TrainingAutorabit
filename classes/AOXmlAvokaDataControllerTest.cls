@isTest
private class AOXmlAvokaDataControllerTest {

	// The data packet is incomplete because it is unnecessary for this test and simplifies the validation.
	private static String xmlPaylod = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm></AvokaSmartForm></Root>';

	@isTest
    private static void testHappyPath() {
        Contact testContact = getTestContact();
		Case testCase = getTestCase(testContact.Id);

		AOXmlAvokaDataController controller = new AOXmlAvokaDataController();
		
		ApexPages.currentPage().getParameters().put('caseId',testCase.id);

        Test.startTest();
        
        String response = controller.getXmlAvokaData();
        
        Test.stopTest();
        
        System.assertEquals(xmlPaylod, response);
    }

	@isTest
    private static void testUnhappyPath() {
		AOXmlAvokaDataController controller = new AOXmlAvokaDataController();
		
		ApexPages.currentPage().getParameters().put('caseId', '');

        Test.startTest();
        
        String response = controller.getXmlAvokaData();
        
        Test.stopTest();
        
        System.assertEquals(null, response);
    }

	private static Contact getTestContact() {
		Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
		Contact testContact = new Contact (
			RecordTypeId = contactRecordTypeId,
			MemberNumber__c = '23423987',
			Email = 'lbaxter@avoka.com',
			FirstName = 'Kenneth',
			LastName = 'Peeler',
			TaxId__c = '666-18-0648',
			PersonNumber__c = '123456'
		);
		
		insert testContact;
		return testContact;
	}

	private static Case getTestCase(Id contactId) {
		Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_ONLINE_ACCOUNT_OPENING).getRecordTypeId();
		Case testCase = new Case(
			ContactId=contactId,
			Status='Open',
			RecordTypeId=caseRecordTypeId,
			AvokaJob__c='J9SFRMD20180718012856',
			AvokaData__c=xmlPaylod
		);
		insert testCase;
		return testCase;
	}
}