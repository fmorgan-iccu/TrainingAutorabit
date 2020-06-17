@isTest
private class FinancialAccountTriggerTest {

	@isTest
	private static void testHappyPath() {
		// Create the dependent records for the financial account.
		Id dnaContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
    	List<Contact> contactsToInsert = new List<Contact>();
		for (Integer i = 0; i < 3; i++) {
			String taxId = '666-18-' + String.valueOf(i+100).leftPad(4, '0');
			Contact c = new Contact();
			c.lastName = 'LastName'+i;
			c.ownerId = IdUtils.BATCH_USER_ID;
			c.recordTypeId = dnaContactRecordTypeId;
			c.taxId__c = taxId;
			c.personNumber__c = String.valueOf(i+1000);
			contactsToInsert.add(c);
		}
		insert contactsToInsert;

		// Create 200 financial accounts to test the bulk insert works properly.
		List<FinancialAccount__c> financialAccountsToInsert = new List<FinancialAccount__c>();
		for (Integer i = 0; i < 200; i++) {
			FinancialAccount__c fa = new FinancialAccount__c(
				accountNumber__c = String.valueOf(i+1),
				closed__c = false,
				name = 'Checking ' + i,
				openedDate__c = Date.newInstance(2019, 1, 1),
				primaryRolesJson__c = '[' + contactsToInsert[0].personNumber__c + ']',
				productMajorCode__c = 'CK',
				productMinorCode__c = 'CKBA'
			);
			financialAccountsToInsert.add(fa);
		}

		// For the first account, link it to two of the person contacts and mark it as closed.
		financialAccountsToInsert[0].primaryRolesJson__c = '['
			+ contactsToInsert[0].personNumber__c + ','
			+ contactsToInsert[1].personNumber__c
			+ ']';
		financialAccountsToInsert[0].closed__c = true;
		financialAccountsToInsert[0].closedDate__c = Date.newInstance(2019, 2, 1);

		// To properly test that roles aren't duplicated, that deletion of roles works and that new
		// roles are correctly added, update the second account to link to two people and a third
		// will be added during the test.
		financialAccountsToInsert[0].primaryRolesJson__c = '['
			+ contactsToInsert[0].personNumber__c + ','
			+ contactsToInsert[1].personNumber__c
			+ ']';

		Test.startTest();

		insert financialAccountsToInsert;

		// Test an update of an existing account and proper role deletion and addition, by swapping
		// the role to another user.
		FinancialAccount__c faUpdate = new FinancialAccount__c(
			id = financialAccountsToInsert[1].id,
			primaryRolesJson__c = '['
				+ contactsToInsert[1].personNumber__c + ','
				+ contactsToInsert[2].personNumber__c
				+ ']'
		);
		update faUpdate;

		Test.stopTest();

		// Perform all validation for the test.
		List<FinancialAccount__c> financialAccounts = [
			SELECT id,
				accountNumber__c,
				closed__c,
				closedDate__c,
				name,
				openedDate__c,
				primaryRolesJson__c,
				productMajorCode__c,
				productMinorCode__c
			FROM FinancialAccount__c
		];
		System.assertEquals(200, financialAccounts.size());
		for (FinancialAccount__c fa : financialAccounts) {
			if (fa.id == financialAccountsToInsert[0].id) {
				System.assertEquals(true, fa.closed__c);
				System.assertEquals(Date.newInstance(2019, 2, 1), fa.closedDate__c);
			} else{
				System.assertEquals(false, fa.closed__c);
				System.assertEquals(null, fa.closedDate__c);
			}
			
			System.assertNotEquals(null, fa.accountNumber__c);
			System.assert(fa.name.left(9) == 'Checking ');
			System.assertEquals(Date.newInstance(2019, 1, 1), fa.openedDate__c);
			System.assertEquals(null, fa.primaryRolesJson__c);
			System.assertEquals('CK', fa.productMajorCode__c);
			System.assertEquals('CKBA', fa.productMinorCode__c);
		}

		List<AggregateResult> financialAccountRolesAR = [
			SELECT contact__c, COUNT(id) qty
			FROM FinancialAccountRole__c
			GROUP BY contact__c
		];
		System.assertEquals(3, financialAccountRolesAR.size());
		for (AggregateResult ar : financialAccountRolesAR) {
			Id contactId = (Id)ar.get('contact__c');
			if (contactId == contactsToInsert[0].id) {
				System.assertEquals(199, ar.get('qty'));
			} else if (contactId == contactsToInsert[1].id) {
				System.assertEquals(2, ar.get('qty'));
			} else {
				System.assertEquals(1, ar.get('qty'));
			}
		}

		List<FinancialAccountRole__c> financialAccountRoles = [
			SELECT id, name
			FROM FinancialAccountRole__c
			WHERE financialAccount__c IN (SELECT id FROM FinancialAccount__c WHERE accountNumber__c = '1')
		];
		System.assertEquals(2, financialAccountRoles.size());
		System.assertEquals('Checking 0', financialAccountRoles[0].name);
	}

}