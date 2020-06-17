@isTest
private class LogUtilsTest {

	@isTest
    static void singleLogEntries() {
		Contact c = getTestContact('Acme Inc.', RecordTypeConstants.CONTACT_DNA);
		insert c;

        Test.startTest();

		LogUtils.log(LoggingLevel.ERROR, 'Test1', 'A test with only a message.');
		LogUtils.log(LoggingLevel.WARN, 'Test2', c.id, 'A test with a message and Id.');
		
		Test.stopTest();
       	
		List<LogEntry__c> logEntries = [
			SELECT id,
				areaName__c,
				level__c,
				message__c,
				recordId__c
			FROM LogEntry__c
			ORDER BY areaName__c
		];

		System.assertEquals('Test1', logEntries[0].areaName__c);
		System.assertEquals('ERROR', logEntries[0].level__c);
		System.assertEquals('A test with only a message.', logEntries[0].message__c);
		System.assertEquals(null, logEntries[0].recordId__c);
		System.assertEquals('Test2', logEntries[1].areaName__c);
		System.assertEquals('WARN', logEntries[1].level__c);
		System.assertEquals('A test with a message and Id.', logEntries[1].message__c);
		System.assertEquals(c.id, logEntries[1].recordId__c);
    }
    
    @isTest
    static void multipleWithSave() {
    	Contact c = getTestContact('Acme Inc.', RecordTypeConstants.CONTACT_DNA);
		insert c;

		// Create an old entry that will be deleted.
		LogEntry__c entry = new LogEntry__c();
		entry.areaName__c = 'OldLog';
		entry.level__c = LoggingLevel.INFO.name();
		entry.message__c = 'Will be deleted';
		insert entry;
		Test.setCreatedDate(entry.id, DateTime.newInstance(2000, 1, 1));

        Test.startTest();

		LogUtils.log(LoggingLevel.ERROR, 'Test1', null, 'A test with only a message.', false);
		LogUtils.log(LoggingLevel.WARN, 'Test2', c.id, 'A test with a message and Id.', false);

		System.assertEquals(2, LogUtils.queuedLogEntries.size());

		LogUtils.saveLogEntries();
		
		System.assertEquals(0, LogUtils.queuedLogEntries.size());

		Test.stopTest();
       	
		List<LogEntry__c> logEntries = [
			SELECT id,
				areaName__c,
				level__c,
				message__c,
				recordId__c
			FROM LogEntry__c
			ORDER BY areaName__c
		];

		System.assertEquals('Test1', logEntries[0].areaName__c);
		System.assertEquals('ERROR', logEntries[0].level__c);
		System.assertEquals('A test with only a message.', logEntries[0].message__c);
		System.assertEquals(null, logEntries[0].recordId__c);
		System.assertEquals('Test2', logEntries[1].areaName__c);
		System.assertEquals('WARN', logEntries[1].level__c);
		System.assertEquals('A test with a message and Id.', logEntries[1].message__c);
		System.assertEquals(c.id, logEntries[1].recordId__c);
    }

	private static Contact getTestContact(String lastName, String recordTypeName) {
		Contact c = new Contact();
		c.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		c.lastName = lastName;
		return c;
	}

}