@isTest
private class MergeUtilsTest {

	@isTest
	static void testMergeWithDNA() {

		// This test creates two accounts and three contacts associated with these accounts and
		// performs a merge against this data to end up with one account and one contact.
		Account masterAccount = getTestAccount('Finance', 'Acme Inc', null, null, '(208) 270-9999', RecordTypeConstants.ACCOUNT_DEFAULT, 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood');
		Account dupeAccount = getTestAccount('Energy', 'P127472', '127472', IdUtils.BATCH_USER_ID, '(800) 123-1234', RecordTypeConstants.ACCOUNT_DNA, 'Chubbuck', 'USA', '83202', 'ID', '4400 Central Way');
		Test.setCreatedDate(masterAccount.id, DateTime.newInstance(2018,1,1));
		Test.setCreatedDate(dupeAccount.id, DateTime.newInstance(2018,2,1));

		String taxId = '666-18-0001';
		Contact masterContact = getTestContact(masterAccount.id, 'joe@iccu.com', 'John', 'Doughy', null, null, null, null, null, null, null, null, null, RecordTypeConstants.CONTACT_DEFAULT, taxid, false);
		Contact dupeContact1 = getTestContact(masterAccount.id, null, 'Joe', 'Dough', 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood', IdUtils.BATCH_USER_ID, null, '(208) 270-9999', 'HELOC', RecordTypeConstants.CONTACT_DEFAULT, taxid, true);
		Contact dupeContact2 = getTestContact(dupeAccount.id, null, 'Johnathan', 'Doe', 'Chubbuck', 'USA', '83202', 'ID', '4400 Central Way', IdUtils.BATCH_USER_ID, '123', '(800) 123-1234', 'Signature Loan', RecordTypeConstants.CONTACT_DNA, taxId, false);
		Test.setCreatedDate(masterContact.id, DateTime.newInstance(2018,1,1));
		Test.setCreatedDate(dupeContact1.id, DateTime.newInstance(2018,2,1));
		Test.setCreatedDate(dupeContact2.id, DateTime.newInstance(2018,3,1));

		// Mock up a list of the field history records for testing.  This is done because the
		// history records aren't written via a DML update until after the execution context
		// is finished and it is not possible for the test to create them directly with all of the
		// necessary data (e.g. createdDate).
		List<MergeUtils.FieldHistory> accountFieldHistories = new List<MergeUtils.FieldHistory> {
			new MergeUtils.FieldHistory('Industry', masterAccount.id, System.now(), 'Finance')
		};
		List<MergeUtils.FieldHistory> contactFieldHistories = new List<MergeUtils.FieldHistory> {
			new MergeUtils.FieldHistory('ProductInterest__c', dupeContact1.id, System.now(), 'HELOC')
		};

		// Query the contacts and accounts to merge along with the created date that is needed by
		// the merge process.
		List<Contact> contactsToMerge = [
			SELECT id,
				accountId,
				createdDate,
				doNotCall,
				email,
				firstName,
				hasOptedOutOfEmail,
				lastName,
				mailingCity,
				mailingCountry,
				mailingPostalCode,
				mailingState,
				mailingStreet,
				ownerId,
				personNumber__c,
				phone,
				productInterest__c,
				recordTypeId,
				taxId__c
			FROM Contact
			ORDER BY createdDate ASC
		];
		List<Account> accountsToMerge = [
			SELECT id,
				createdDate,
				industry,
				name,
				organizationNumber__c,
				ownerId,
				phone,
				recordTypeId,
				shippingCity,
				shippingCountry,
				shippingPostalCode,
				shippingState,
				shippingStreet
			FROM Account
			ORDER BY createdDate ASC
		];

		Test.startTest();

		// To properly test field history modifications, directly call the function with the wrapper
		// versions of the field histories.
		MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
		MergeUtils.massMerge(accountsToMerge, accountFieldHistories);

		Test.stopTest();

		List<Account> accounts = [
			SELECT id,
				industry,
				name,
				organizationNumber__c,
				ownerId,
				phone,
				recordTypeId,
				shippingCity,
				shippingCountry,
				shippingPostalCode,
				shippingState,
				shippingStreet
			FROM Account
		];
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DNA).getRecordTypeId();

		System.assert(accounts.size() == 1, 'Only one account should be present after the merge.');
		System.assert(accounts[0].id == masterAccount.id, 'The merge was not into the oldest record.');
		System.assert(accounts[0].industry == 'Finance', 'The industry value was not set to the most recent value as identified by the AccountHistory.');
		System.assert(accounts[0].name == 'P127472', 'The DNA name field was not kept.');
		System.assert(accounts[0].organizationNumber__c == '127472', 'The DNA organization number field was not kept.');
		System.assert(accounts[0].phone == '(800) 123-1234', 'The DNA phone field was not kept.');
		System.assert(accounts[0].recordTypeId == recordTypeId, 'The DNA record type was not kept.');
		System.assert(accounts[0].shippingCity == 'Chubbuck', 'The DNA shippingCity field was not kept.');
		System.assert(accounts[0].shippingCountry == 'USA', 'The DNA shippingCountry field was not kept.');
		System.assert(accounts[0].shippingPostalCode == '83202', 'The DNA shippingPostalCode field was not kept.');
		System.assert(accounts[0].shippingState == 'ID', 'The DNA shippingState field was not kept.');
		System.assert(accounts[0].shippingStreet == '4400 Central Way', 'The DNA shippingStreet field was not kept.');
		
		List<Contact> contacts = [
			SELECT id,
				accountId,
				doNotCall,
				email,
				firstName,
				hasOptedOutOfEmail,
				lastName,
				mailingCity,
				mailingCountry,
				mailingPostalCode,
				mailingState,
				mailingStreet,
				ownerId,
				personNumber__c,
				phone,
				productInterest__c,
				recordTypeId,
				taxId__c
			FROM Contact
		];
		recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();

		System.assert(contacts.size() == 1, 'Only one contact should be present after the merge.');
		System.assert(contacts[0].id == masterContact.id, 'The oldest contact was not retained.');
		System.assertEquals(true, contacts[0].doNotCall);
		System.assert(contacts[0].email == null, 'The DNA email field was not kept.');
		System.assert(contacts[0].firstName == 'Johnathan', 'The DNA firstName field was not kept.');
		System.assertEquals(false, contacts[0].hasOptedOutOfEmail);
		System.assert(contacts[0].lastName == 'Doe', 'The DNA lastName field was not kept.');
		System.assert(contacts[0].mailingCity == 'Chubbuck', 'The DNA mailingCity field was not kept.');
		System.assert(contacts[0].mailingCountry == 'USA', 'The DNA mailingCountry field was not kept.');
		System.assert(contacts[0].mailingPostalCode == '83202', 'The DNA mailingPostalCode field was not kept.');
		System.assert(contacts[0].mailingState == 'ID', 'The DNA mailingState field was not kept.');
		System.assert(contacts[0].mailingStreet == '4400 Central Way', 'The DNA mailingStreet field was not kept.');
		System.assert(contacts[0].personNumber__c == '123', 'The DNA personNumber was not kept.');
		System.assert(contacts[0].phone == '(800) 123-1234', 'The DNA phone field was not kept.');
		System.assert(contacts[0].productInterest__c == 'HELOC', 'The product interest field was not set to the most recent value as identified by the ContactHistory.');
		System.assert(contacts[0].recordTypeId == recordTypeId, 'The DNA record type was not kept.');
		System.assertEquals('666-18-0001', contacts[0].taxId__c);
	}

	@isTest
	static void testMergeWithoutDNA() {
		// This test creates two accounts and three contacts associated with these accounts and
		// performs a merge against this data to end up with one account and one contact.
		Account masterAccount = getTestAccount('Finance', 'Acme Inc', null, null, '(208) 270-9999', RecordTypeConstants.ACCOUNT_DEFAULT, 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood');
		Account dupeAccount = getTestAccount('Energy', 'Acme', null, IdUtils.BATCH_USER_ID, '(800) 123-1234', RecordTypeConstants.ACCOUNT_DEFAULT, 'Chubbuck', 'USA', '83202', 'ID', '4400 Central Way');
		Test.setCreatedDate(masterAccount.id, DateTime.newInstance(2018,1,1));
		Test.setCreatedDate(dupeAccount.id, DateTime.newInstance(2018,2,1));

		String taxId = '666-18-0002';
		Contact masterContact = getTestContact(masterAccount.id, 'joe@iccu.com', 'John', 'Doughy', null, null, null, null, null, IdUtils.AVOKA_USER_ID, null, null, null, RecordTypeConstants.CONTACT_DEFAULT, taxId, false);
		Contact dupeContact1 = getTestContact(masterAccount.id, null, 'Joe', 'Dough', 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood', IdUtils.BATCH_USER_ID, null, '(208) 270-9999', 'HELOC', RecordTypeConstants.CONTACT_DEFAULT, taxId, false);
		Contact dupeContact2 = getTestContact(dupeAccount.id, null, 'Johnathan', 'Doe', 'Chubbuck', 'USA', '83202', 'ID', '4400 Central Way', IdUtils.BATCH_USER_ID, null, null, 'Signature Loan', RecordTypeConstants.CONTACT_DEFAULT, taxId, false);
		Test.setCreatedDate(masterContact.id, DateTime.newInstance(2018,1,1));
		Test.setCreatedDate(dupeContact1.id, DateTime.newInstance(2018,2,1));
		Test.setCreatedDate(dupeContact2.id, DateTime.newInstance(2018,3,1));

		// Mock up a list of the field history records for testing.  This is done because the
		// ContactHistory records aren't written via a DML update until after the execution context
		// is finished and it is not possible for the test to create them directly with all of the
		// necessary data (e.g. createdDate).
		List<MergeUtils.FieldHistory> accountFieldHistories = new List<MergeUtils.FieldHistory> {
			new MergeUtils.FieldHistory('Industry', masterAccount.id, System.now(), 'Finance'),
			new MergeUtils.FieldHistory('ShippingStreet', masterAccount.id, System.now(), '5250 Heatherwood')
		};
		List<MergeUtils.FieldHistory> contactFieldHistories = new List<MergeUtils.FieldHistory> {
			new MergeUtils.FieldHistory('FirstName', masterContact.id, System.now(), 'John'),
			new MergeUtils.FieldHistory('MailingStreet', dupeContact1.id, System.now(), '5250 Heatherwood'),
			new MergeUtils.FieldHistory('ProductInterest__c', masterContact.id, System.now(), null)
		};

		// Query the contacts and accounts to merge along with the created date that is needed by
		// the merge process.  This query is sorted in descending order to ensure that the 
		// algorithm works despite the order of the list received.
		List<Contact> contactsToMerge = [
			SELECT id,
				accountId,
				createdDate,
				doNotCall,
				email,
				firstName,
				hasOptedOutOfEmail,
				lastName,
				mailingCity,
				mailingCountry,
				mailingPostalCode,
				mailingState,
				mailingStreet,
				ownerId,
				personNumber__c,
				phone,
				productInterest__c,
				recordTypeId,
				taxId__c
			FROM Contact
			ORDER BY createdDate DESC
		];
		List<Account> accountsToMerge = [
			SELECT id,
				createdDate,
				industry,
				name,
				organizationNumber__c,
				ownerId,
				phone,
				recordTypeId,
				shippingCity,
				shippingCountry,
				shippingPostalCode,
				shippingState,
				shippingStreet
			FROM Account
			ORDER BY createdDate DESC
		];

		Test.startTest();

		// To properly test field history modifications, directly call the function with the wrapper
		// versions of the field histories.
		MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
		MergeUtils.massMerge(accountsToMerge, accountFieldHistories);

		Test.stopTest();

		List<Account> accounts = [
			SELECT id,
				industry,
				name,
				organizationNumber__c,
				ownerId,
				phone,
				recordTypeId,
				shippingCity,
				shippingCountry,
				shippingPostalCode,
				shippingState,
				shippingStreet
			FROM Account
		];
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DEFAULT).getRecordTypeId();

		System.assert(accounts.size() == 1, 'Only one account should be present after the merge.');
		System.assert(accounts[0].id == masterAccount.id, 'The merge was not into the oldest record.');
		System.assert(accounts[0].industry == 'Finance', 'The industry value was not set to the most recent value as identified by the AccountHistory.');
		System.assert(accounts[0].name == 'Acme', 'The name field was not kept from the most recently created record.');
		System.assert(accounts[0].organizationNumber__c == null, 'The organization number is not null.');
		System.assert(accounts[0].ownerId == UserInfo.getUserId(), 'The non-service account owner was not kept (' + accounts[0].ownerId + ').');
		System.assert(accounts[0].phone == '(800) 123-1234', 'The phone field was not kept.');
		System.assert(accounts[0].recordTypeId == recordTypeId, 'The Default record type was not kept.');
		System.assert(accounts[0].shippingCity == 'Pocatello', 'The shippingCity field was not kept from the most recent group.');
		System.assert(accounts[0].shippingCountry == 'USA', 'The shippingCountry field was not kept from the most recent group.');
		System.assert(accounts[0].shippingPostalCode == '83204', 'The shippingPostalCode field was not kept from the most recent group.');
		System.assert(accounts[0].shippingState == 'ID', 'The shippingState field was not kept from the most recent group.');
		System.assert(accounts[0].shippingStreet == '5250 Heatherwood', 'The shippingStreet field was not kept from the most recent group.');

		List<Contact> contacts = [
			SELECT id,
				accountId,
				doNotCall,
				email,
				firstName,
				hasOptedOutOfEmail,
				lastName,
				mailingCity,
				mailingCountry,
				mailingPostalCode,
				mailingState,
				mailingStreet,
				ownerId,
				personNumber__c,
				phone,
				productInterest__c,
				recordTypeId,
				taxId__c
			FROM Contact
		];
		recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DEFAULT).getRecordTypeId();

		System.assert(contacts.size() == 1, 'Only one contact should be present after the merge.');
		System.assert(contacts[0].id == masterContact.id, 'The oldest contact was not retained.');
		System.assertEquals(false, contacts[0].doNotCall);
		System.assert(contacts[0].email == 'joe@iccu.com', 'The email field was not kept from the most recently created record.');
		System.assert(contacts[0].firstName == 'John', 'The firstName field was not kept from the most recent group.');
		System.assertEquals(false, contacts[0].hasOptedOutOfEmail);
		System.assert(contacts[0].lastName == 'Doughy', 'The lastName field was not kept from the most recent group.');
		System.assert(contacts[0].mailingCity == 'Pocatello', 'The mailingCity field was not kept from the most recent group.');
		System.assert(contacts[0].mailingCountry == 'USA', 'The mailingCountry field was not kept from the most recent group.');
		System.assert(contacts[0].mailingPostalCode == '83204', 'The mailingPostalCode field was not kept from the most recent group.');
		System.assert(contacts[0].mailingState == 'ID', 'The mailingState field was not kept from the most recent group.');
		System.assert(contacts[0].mailingStreet == '5250 Heatherwood', 'The mailingStreet field was not kept from the most recent group.');
		System.assert(contacts[0].ownerId == IdUtils.BATCH_USER_ID, 'The most recent service user was not kept.');
		System.assert(contacts[0].personNumber__c == null, 'The personNumber is not null.');
		System.assert(contacts[0].phone == '(208) 270-9999', 'The phone field was not set to the value from the most recently created record.');
		System.assert(contacts[0].productInterest__c == null, 'The product interest field was not set to the most recent value (null) as identified by the ContactHistory.');
		System.assert(contacts[0].recordTypeId == recordTypeId, 'The Default record type was not kept.');
		System.assertEquals('666-18-0002', contacts[0].taxId__c);
	}

	@isTest
	static void validateMergeUnhappyPath() {
		List<Account> accountsToMerge = null;
		List<MergeUtils.FieldHistory> accountFieldHistories = null;
		try {
			MergeUtils.massMerge(accountsToMerge, accountFieldHistories);
			System.assert(false, 'A list of accounts and field histories are required.');
		} catch (IllegalArgumentException e) {}

		accountsToMerge = new List<Account>();
		try {
			MergeUtils.massMerge(accountsToMerge, accountFieldHistories);
			System.assert(false, 'A list of accounts must have at least two accounts.');
		} catch (IllegalArgumentException e) {}

		accountsToMerge = new List<Account> {
			getTestAccount('Finance', 'Acme Inc', null, null, '(208) 270-9999', RecordTypeConstants.ACCOUNT_DEFAULT, 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood'),
			getTestAccount('Energy', 'P127472', null, IdUtils.BATCH_USER_ID, '(800) 123-1234', RecordTypeConstants.ACCOUNT_DNA, 'Chubbuck', 'USA', '83202', 'ID', '4400 Central Way')
		};
		try {
			MergeUtils.massMerge(accountsToMerge, accountFieldHistories);
			System.assert(false, 'A field history list must be provided when merging accounts; empty is fine.');
		} catch (IllegalArgumentException e) {}
		
		List<Contact> contactsToMerge = null;
		List<MergeUtils.FieldHistory> contactFieldHistories = null;
		try {
			MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
			System.assert(false, 'A list of contacts and field histories are required.');
		} catch (IllegalArgumentException e) {}

		contactsToMerge = new List<Contact>();
		try {
			MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
			System.assert(false, 'A list of contacts must have at least two contacts.');
		} catch (IllegalArgumentException e) {}

		contactsToMerge = new List<Contact> {
			getTestContact(accountsToMerge[0].id, null, 'Joe', 'Dough', 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood', IdUtils.BATCH_USER_ID, null, '(208) 270-9999', 'HELOC', RecordTypeConstants.CONTACT_DEFAULT, '666-11-2222', false),
			getTestContact(accountsToMerge[1].id, null, 'Johnathan', 'Doe', 'Chubbuck', 'USA', '83202', 'ID', '4400 Central Way', IdUtils.BATCH_USER_ID, null, '(800) 123-1234', 'Signature Loan', RecordTypeConstants.CONTACT_DNA, '666-11-3333', false)
		};
		try {
			MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
			System.assert(false, 'A field history list must be provided when merging contacts; empty is fine.');
		} catch (IllegalArgumentException e) {}

		accountsToMerge = [SELECT id, recordTypeId FROM Account];
		accountFieldHistories = new List<MergeUtils.FieldHistory>();
		try {
			MergeUtils.massMerge(accountsToMerge, accountFieldHistories);
			System.assert(false, 'A created date should be present on the account sObjects to merge.');
		} catch (IllegalArgumentException e) {}

		accountsToMerge = [SELECT id, createdDate FROM account];
		try {
			MergeUtils.massMerge(accountsToMerge, accountFieldHistories);
			System.assert(false, 'A record type Id should be present on the account sObjects to merge.');
		} catch (IllegalArgumentException e) {}

		contactsToMerge = [SELECT id, recordTypeId FROM Contact];
		contactFieldHistories = new List<MergeUtils.FieldHistory>();
		try {
			MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
			System.assert(false, 'A created date should be present on the contact sObjects to merge.');
		} catch (IllegalArgumentException e) {}

		contactsToMerge = [SELECT id, createdDate FROM Contact];
		try {
			MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
			System.assert(false, 'A record type Id should be present on the contact sObjects to merge.');
		} catch (IllegalArgumentException e) {}

		getTestAccount('Finance', 'Acme Inc', null, null, '(208) 270-9999', RecordTypeConstants.ACCOUNT_DNA, 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood');
		accountsToMerge = [SELECT id, createdDate, recordTypeId FROM Account];
		try {
			MergeUtils.massMerge(accountsToMerge, accountFieldHistories);
			System.assert(false, 'Only one DNA account record should be allowed in a merge.');
		} catch (IllegalArgumentException e) {}	

		getTestContact(accountsToMerge[0].id, null, 'Joe', 'Dough', 'Pocatello', 'USA', '83204', 'ID', '5250 Heatherwood', IdUtils.BATCH_USER_ID, null, '(208) 270-9999', 'HELOC', RecordTypeConstants.CONTACT_DNA, '666-11-4444', false);
		contactsToMerge = [SELECT id, createdDate, recordTypeId FROM Contact];
		try {
			MergeUtils.massMerge(contactsToMerge, contactFieldHistories);
			System.assert(false, 'Only one DNA contact record should be allowed in a merge.');
		} catch (IllegalArgumentException e) {}
	}

	private static Account getTestAccount(
		String industry,
		String name,
		String organizationNumber,
		Id ownerId,
		String phone,
		String recordTypeName,
		String shippingCity,
		String shippingCountry,
		String shippingPostalCode,
		String shippingState,
		String shippingStreet)
	{
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		Account a = new Account();
		a.recordTypeId = recordTypeId;
		if (industry != null) { a.industry = industry; }
		a.name = name;
		if (organizationNumber != null) { a.organizationNumber__c = organizationNumber; }
		if (ownerId != null) { a.ownerId = ownerId; }
		if (phone != null) { a.phone = phone; }
		if (shippingCity != null) { a.shippingCity = shippingCity; }
		if (shippingCountry != null) { a.shippingCountry = shippingCountry; }
		if (shippingPostalCode != null) { a.shippingPostalCode = shippingPostalCode; }
		if (shippingState != null) { a.shippingState = shippingState; }
		if (shippingStreet != null) { a.shippingStreet = shippingStreet; }
		insert a;
		return a;
	}

	private static Contact getTestContact(
		Id accountId,
		String email,
		String firstName,
		String lastName,
		String mailingCity,
		String mailingCountry,
		String mailingPostalCode,
		String mailingState,
		String mailingStreet,
		Id ownerId,
		String personNumber,
		String phone,
		String productInterest,
		String recordTypeName,
		String taxId,
		Boolean doNotCall)
	{
		Contact c = new Contact();
		c.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		c.accountId = accountId;
		if (firstName != null) { c.firstName = firstName; }
		c.lastName = lastName;
		if (email != null) { c.email = email; }
		if (phone != null) { c.phone = phone; }
		c.taxId__c = taxId;
		if (ownerId != null) { c.ownerId = ownerId; }
		if (personNumber != null) { c.personNumber__c = personNumber; }
		if (mailingCity != null) { c.mailingCity = mailingCity; }
		if (mailingCountry != null) { c.mailingCountry = mailingCountry; }
		if (mailingPostalCode != null) { c.mailingPostalCode = mailingPostalCode; }
		if (mailingState != null) { c.mailingState = mailingState; }
		if (mailingStreet != null) { c.mailingStreet = mailingStreet; }
		if (productInterest != null) { c.productInterest__c = productInterest; }
		if (doNotCall != null) { c.doNotCall = doNotCall; }
		insert c;
		return c;
	}

}