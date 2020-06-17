@isTest
private class ContactTriggerTest {

	static testMethod void testHappyPath() {
		Id dnaContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
		Id defaultContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DEFAULT).getRecordTypeId();

        Test.startTest();

		// Test inserting a batch of 200 records for governance compliance.
		List<Contact> contactsToInsert = new List<Contact>();
		for (Integer i = 0; i < 100; i++) {
			String taxId = '666-18-' + String.valueOf(i).leftPad(4, '0');
			contactsToInsert.add(getTestContact(null, 'LastName'+i, IdUtils.BATCH_USER_ID, defaultContactRecordTypeId, taxId, null, '[]', ''));
		}
		for (Integer i = 0; i < 100; i++) {
			String taxId = '666-18-' + String.valueOf(i+100).leftPad(4, '0');
			contactsToInsert.add(getTestContact(null, 'LastName'+i, IdUtils.BATCH_USER_ID, dnaContactRecordTypeId, taxId, null, '[123,456]', '{"BranchOrgNumber": 58,"OrgName": "Jerome"}'));
		}

        // Modify the last DNA contact to have a malformed eAgreement list and default branch to test the error cases.
        contactsToInsert[199].onlineAgreementIds__c = '[123,]';
        contactsToInsert[199].defaultBranch__c = '{"breakMe""Nope"}';

		insert contactsToInsert;

		Test.stopTest();

		List<Contact> defaultContacts = [
			SELECT id,
                defaultBranchName__c,
                onlineBankingEnrolled__c
			FROM Contact
			WHERE recordTypeName__c = 'Default'
            ORDER BY id
		];
		List<Contact> dnaContacts = [
			SELECT id,
                defaultBranchName__c,
                onlineBankingEnrolled__c
			FROM Contact
			WHERE recordTypeName__c = 'DNA'
            ORDER BY id
		];

		// Verify that the correct number of record names were found.
		System.assertEquals(100, defaultContacts.size());
		System.assertEquals(100, dnaContacts.size());

        // Verify the various field values that are inferred from other data.
        for (Integer i = 0; i < 100; i++) {
            System.assertEquals(null, defaultContacts[i].defaultBranchName__c, 'The branch name was not null for the default contact, ' + i);
            System.assertEquals(false, defaultContacts[i].onlineBankingEnrolled__c, 'The online banking enrolled flag was set for the default contact, ' + i);
        }
        for (Integer i = 0; i < 99; i++) {
            System.assertEquals('Jerome', dnaContacts[i].defaultBranchName__c, 'The branch name was not Jerome for the DNA contact, ' + i);
            System.assertEquals(true, DNAContacts[i].onlineBankingEnrolled__c, 'The bonline banking enrolled flag was not set for the DNA contact, ' + i);
        }
        System.assertEquals(null, dnaContacts[99].defaultBranchName__c);
        System.assertEquals(false, dnaContacts[99].onlineBankingEnrolled__c);
    }

	@isTest
    static void testBulkDnaUpdate() {
		// Typically bulk updates are performed on a full batch of 200 records.  In this case, the
		// expected duplicate percent is considered to be low (<20% of total records).  We will test
		// a full 200 in this case but only to assert that it doesn't throw unrecoverable DML
		// exceptions.  The test assertion will validate that there are some winners.

		Id dnaAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DNA).getRecordTypeId();
		Id defaultAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DEFAULT).getRecordTypeId();
		Id dnaContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
		Id defaultContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DEFAULT).getRecordTypeId();

		// NOTE:  Only 199 records are created here because one more is added outside of the loops.
		List<Account> masterAccounts = new List<Account>();
		List<Account> dupeAccounts = new List<Account>();
		for (Integer i = 0; i < 199; i++) {
			masterAccounts.add(getTestAccount('Loser' + i, IdUtils.BATCH_USER_ID, defaultAccountRecordTypeId));
			dupeAccounts.add(getTestAccount('Winner' + i, IdUtils.BATCH_USER_ID, dnaAccountRecordTypeId));
		}

		// Insert the master and dupe acounts outside of the test since these both are created prior
		// to the batch contact data load.
		insert masterAccounts;
		insert dupeAccounts;

        List<Contact> masterContacts = new List<Contact>();
		List<Contact> dupeContacts = new List<Contact>();
		for (Integer i = 0; i < 199; i++) {
			String taxId = '666-18-' + String.valueOf(i).leftPad(4, '0');
			String idNumber = 'PA11' + String.valueOf(i).leftPad(4, '0') + 'A';
			masterContacts.add(getTestContact(masterAccounts[i].id, 'Loser'+i, IdUtils.BATCH_USER_ID, defaultContactRecordTypeId, taxId, idNumber, null, null));
			dupeContacts.add(getTestContact(dupeAccounts[i].id, 'Winner'+i, IdUtils.BATCH_USER_ID, dnaContactRecordTypeId, taxId, idNumber, null, null));
		}

		// Add a single contact with a tax id that doesn't match that won't be included in the merge.
		dupeContacts.add(getTestContact(dupeAccounts[0].id, 'Winner no-dupe', IdUtils.BATCH_USER_ID, dnaContactRecordTypeId, '666-19-0000', 'PA911111A', null, null));

		//  Only insert the master contacts prior to the start of the test.
		insert masterContacts;

		// Ensure that the trigger code is allowed to fire again.
		TriggerUtils.resetExecuted();

		// Used to emulate the bath user via data load.
		User batchUser = new User(Id=IdUtils.BATCH_USER_ID);

		Test.startTest();

		System.runAs(batchUser) {
			try {
				insert dupeContacts;
			} catch (MergeUtils.MergeLimitException e) {
				System.assert(false, 'The ContactAfterTrigger didn\'t prevent the merge from exceeding governance limits.');
			}
		}

		Test.stopTest();

		// Verify 
		List<Account> winningAccounts = [
			SELECT id
			FROM Account
			WHERE name LIKE 'Winner%'
		];
		List<Account> losingAccounts = [
			SELECT id
			FROM Account
			WHERE name LIKE 'Loser%'
		];
		List<Contact> winningContacts = [
			SELECT id
			FROM Contact
			WHERE lastName LIKE 'Winner%'
		];
		List<Contact> losingContacts = [
			SELECT id
			FROM Contact
			WHERE lastName LIKE 'Loser%'
		];
		System.assert(winningAccounts.size() == 199, 'The trigger didn\'t retain all winning accounts.');
		System.assert(winningContacts.size() == 200, 'The trigger didn\'t retain all winning contacts.');
		System.assert(losingAccounts.size() < 199, 'The trigger didn\'t merge any losing accounts.');
		System.assert(losingContacts.size() < 199, 'The trigger didn\'t merge any losing contacts.');
    }

	private static Account getTestAccount(String name, Id ownerId, Id recordTypeId) {
		Account a = new Account();
		a.name = name;
		if (ownerId != null) { a.ownerId = ownerId; }
		a.recordTypeId = recordTypeId;
		return a;
	}

	private static Contact getTestContact(
        Id accountId,
        String lastName,
        Id ownerId,
        Id recordTypeId,
        String taxId,
        String identificationNumber,
        String onlineAgreementIds,
        String defaultBranch)
    {
		Contact c = new Contact();
		if (accountId != null) {
			c.accountId = accountId;
		}
		c.lastName = lastName;
		if (ownerId != null) {
			c.ownerId = ownerId;
		}
		c.recordTypeId = recordTypeId;
		c.taxId__c = taxId;
		c.identificationNumber__c = identificationNumber;
        c.onlineAgreementIds__c = onlineAgreementIds;
        c.defaultBranch__c = defaultBranch;
		return c;
	}

}