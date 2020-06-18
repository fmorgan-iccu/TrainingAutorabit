@isTest
private class TaskTriggerTest {

	@isTest
    static void testFirstCall() {
		Contact testContact = getTestContact();

		// Create a call for a prior day to verify that the test doesn't pick it up.
		Task priorTask = getTestTask(testContact.id, 'Inbound');
		insert priorTask;
		Test.setCreatedDate(priorTask.id, System.today().addDays(-1));

		// Create a outbound call for the current day to be certain it is ignored.
		Task outboundTask = getTestTask(testContact.id, 'Outbound');
		insert outboundTask;

		TriggerUtils.resetExecuted();

		Test.startTest();

		// Simulate a single call for a contact.
		Task testTask = getTestTask(testContact.id, 'Inbound');
		insert testTask;

		Test.stopTest();

		List<Task> tasks = [
			SELECT id,
				firstCallOfDay__c,
				multipleCalls__c
			FROM Task
			WHERE callType = 'Inbound'
				AND createdDate = TODAY
		];

		System.assertEquals(1, tasks.size());
		System.assertEquals(true, tasks[0].firstCallOfDay__c);
		System.assertEquals(false, tasks[0].multipleCalls__c);
    }

	@isTest
    static void testSecondCall() {
		Contact testContact = getTestContact();

		// Create the first call of the day.
		Task firstTask = getTestTask(testContact.id, 'Inbound');
		insert firstTask;

		// Create a call for a prior day to verify that the test doesn't pick it up.
		Task priorTask = getTestTask(testContact.id, 'Inbound');
		insert priorTask;
		Test.setCreatedDate(priorTask.id, System.today().addDays(-1));

		TriggerUtils.resetExecuted();

		Test.startTest();

		// Simulate a second phone call arriving.
		Task secondTask = getTestTask(testContact.id, 'Inbound');
		insert secondTask;

		Test.stopTest();

		List<Task> tasks = [
			SELECT id,
				firstCallOfDay__c,
				multipleCalls__c
			FROM Task
			WHERE createdDate = TODAY
			ORDER BY createdDate
		];

		System.assertEquals(2, tasks.size());
		System.assertEquals(true, tasks[0].firstCallOfDay__c);
		System.assertEquals(true, tasks[0].multipleCalls__c);
		System.assertEquals(false, tasks[1].firstCallOfDay__c);
		System.assertEquals(true, tasks[1].multipleCalls__c);
    }

	@isTest
	static void testTaskDelete() {
		Contact testContact = getTestContact();

		// Create several tasks
		List<Task> testTasks = new List<Task>();
		testTasks.add(getTestTask(testContact.id, 'Inbound'));
		testTasks.add(getTestTask(testContact.id, 'Inbound'));
		testTasks.add(getTestTask(testContact.id, 'Inbound'));
		insert testTasks;

		// Ensure that the tasks are in the same day at different times.
		Datetime now = Datetime.now();
		Test.setCreatedDate(testTasks[0].id, now.addMinutes(-10));
		Test.setCreatedDate(testTasks[1].id, now.addMinutes(-5));
		Test.setCreatedDate(testTasks[2].id, now.addSeconds(-30));

		testTasks = [
			SELECT id,
				createdDate,
				firstCallOfDay__c,
				multipleCalls__c,
				whoId
			FROM Task
			WHERE createdDate = TODAY
			ORDER BY createdDate
		];

		TriggerUtils.resetExecuted();

		Test.startTest();

		// Simulate someone deleting the first call of the day.
		delete testTasks[0];

		Test.stopTest();

		List<Task> tasks = [
			SELECT id,
				firstCallOfDay__c,
				multipleCalls__c,
				whoId
			FROM Task
			WHERE createdDate = TODAY
			ORDER BY createdDate
		];

		System.assertEquals(2, tasks.size());
		System.assertEquals(true, tasks[0].firstCallOfDay__c);
		System.assertEquals(true, tasks[0].multipleCalls__c);
		System.assertEquals(false, tasks[1].firstCallOfDay__c);
		System.assertEquals(true, tasks[1].multipleCalls__c);
	}

	@isTest
	static void testTaskInsertBatch() {
		Contact testContact = getTestContact();

		// Create 200 tasks to insert in one batch.
		List<Task> testTasks = new List<Task>();
		for (Integer i = 0; i < 200; i++) {
			testTasks.add(getTestTask(testContact.id, 'Inbound'));
		}

		Test.startTest();

		insert testTasks;

		Test.stopTest();

		List<Task> firstCallTasks = [
			SELECT id,
				firstCallOfDay__c,
				multipleCalls__c,
				whoId
			FROM Task
			WHERE createdDate = TODAY
				AND firstCallOfDay__c = true
		];
		List<Task> callbackTasks = [
			SELECT id,
				firstCallOfDay__c,
				multipleCalls__c,
				whoId
			FROM Task
			WHERE createdDate = TODAY
				AND firstCallOfDay__c = false
		];

		System.assertEquals(1, firstCallTasks.size());
		System.assertEquals(199, callbackTasks.size());
	}

	@isTest
	static void testTaskDeleteBatch() {
		Contact testContact = getTestContact();

		// Create 201 tasks to insert in one batch.
		List<Task> testTasks = new List<Task>();
		for (Integer i = 0; i < 201; i++) {
			testTasks.add(getTestTask(testContact.id, 'Inbound'));
		}
		insert testTasks;

		// Remove the last entry that will be retained.
		testTasks.remove(200);

		TriggerUtils.resetExecuted();

		Test.startTest();

		delete testTasks;

		Test.stopTest();

		List<Task> tasks = [
			SELECT id,
				firstCallOfDay__c,
				multipleCalls__c,
				whoId
			FROM Task
			WHERE createdDate = TODAY
		];

		System.assertEquals(1, tasks.size());
		System.assertEquals(true, tasks[0].firstCallOfDay__c);
		System.assertEquals(false, tasks[0].multipleCalls__c);
	}

	private static Contact getTestContact() {
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

	private static Task getTestTask(Id contactId, String callType) {
		Task t = new Task();
		t.callType = callType;
		t.ownerId = UserInfo.getUserId();
		t.priority = 'Normal';
		t.subject = 'Call';
		t.status = 'Completed';
		t.type = 'Call';
		t.whoId = contactId;

		return t;
	}

}