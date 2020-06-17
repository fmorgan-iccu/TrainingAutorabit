@isTest
private class CaseTriggerTest {

	@isTest
    static void testCaseOwnerChange() {
		Contact contact = getTestDnaContact();

		List<Opportunity> testOpps = new List<Opportunity>();
		for (Integer i = 0; i < 200; i++) {
			testOpps.add(getTestOpportunity(IdUtils.BATCH_USER_ID, contact.accountId, 'New'));
		}
		insert testOpps;

		Group aoQueue = [SELECT id FROM Group WHERE type = 'Queue' AND developerNAME = 'FSCOnlineAccountOpening'];
		List<Case> testCases = new List<Case>();
		for (Integer i = 0; i < 200; i++) {
			testCases.add(getTestCase(aoQueue.id, contact.id, 'Open', testOpps[i].id));
		}
		insert testCases;

		TriggerUtils.resetExecuted();

		Test.startTest();

		// Simulate changing a full batch of users in a single request.
		Id caseOwnerId = UserInfo.getUserId();
		for (Integer i = 0; i < 200; i++) {
			testCases[i].ownerId = caseOwnerId;
		}
		update testCases;

		Test.stopTest();

		testOpps = [SELECT id FROM Opportunity WHERE ownerId = :caseOwnerId];
		System.assert(testOpps.size() == 200, 'Not all associated opportunity owners were chagned.');
    }
	
	private static Contact getTestDnaContact() {
		Account a = new Account();
		a.name = 'P127472';
		insert a;

		Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
		Contact c = new Contact (
			RecordTypeId = contactRecordTypeId,
			AccountId = a.id,
			Birthdate = Date.valueOf('1976-08-11'),
			MemberNumber__c = '28343',
			Email = 'dhyppolite@avoka.com',
			FirstName = 'Allan',
			LastName = 'Gliege',
			Phone = '(310) 427-5902',
			TaxId__c = '599-99-1126',
			PersonNumber__c = '127472'
		);
		
		insert c;
		return c;
	}
	
	private static Case getTestCase(Id ownerId, Id contactId, String status, Id opportunityId) {
		Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Online Account Opening').getRecordTypeId();
		Case c = new Case();
		c.ownerId = ownerId;
		c.contactId = contactId;
		c.status = status;
		c.opportunity__c = opportunityId;
		c.recordTypeId = caseRecordTypeId;
		return c;
	}

	private static Opportunity getTestOpportunity(Id ownerId, Id accountId, String stageName) {
		Opportunity o = new Opportunity();
		o.ownerId = ownerId;
		o.accountId = accountId;
		o.name = 'Test Opp';
		o.type = 'Loan';
		o.stageName = stageName;
		o.closeDate = System.today();
		o.product__c = 'Fixed-Rate Platinum Visa';
		o.productMajorCode__c = AOConstants.PRODUCT_MAJOR_TYPE_CRIF;
		o.productMinorCode__c = '119';
		return o;
	}

}