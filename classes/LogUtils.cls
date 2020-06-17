/**
 * Provides methods to save log entries in a persistent sObject.  This is useful to record
 * unexpected errors, track down transient issues that can't be replicated, or audit information.
 */
public with sharing class LogUtils {

	// Stores queued log entries so that they can be persisted with one DML operation.
	@TestVisible
	private static List<LogEntry__c> queuedLogEntries = new List<LogEntry__c>();

	/**
	 * Creates a log entry to record an action/error that occurred in a specific area of the code.
	 * If autoInsert is false, the caller is responsible for calling saveLogEntries at the
	 * appropriate time to commit the changes.
	 *
	 * @param  level      indicates the logging level (e.g. LoggingLevel.ERROR) for the entry
	 * @param  areaName   a unique identifier that defines where the entry occurred
	 * @param  recordId   the Id of a record associated with the log, if applicable
	 * @param  message    a message describing the event that occurred
	 * @param  autoInsert controls whether the DML operation is performed immediately or queued for
	 *						a later update
	 */
	public static void log(LoggingLevel level, String areaName, Id recordId, String message, Boolean autoInsert) {
		// Create the log entry in the database
		LogEntry__c l = new LogEntry__c();
		l.level__c = level.name();
		l.areaName__c = areaName != null ? areaName : 'Unknown';
		l.recordId__c = recordId;
		l.message__c = message.left(131072); // Ensure that the message never exceeds the maximum length that can be stored.

		if (autoInsert) {
			insert l;
		} else {
			queuedLogEntries.add(l);
		}

		// Echo the log entry to the debug log for visibility.
		System.debug(level, message);

		// Delete up to 500 system log entries that are older than 60 days.
		if (!TriggerUtils.checkExecuted('PurgeLogEntries')) {
			Datetime cutoff = System.now().addDays(-60);
			List<LogEntry__c> entriesToDelete = [
				SELECT id
				FROM LogEntry__c
				WHERE createdDate < :cutoff
				LIMIT 500
			];
			if (entriesToDelete.size() > 0) {
				delete entriesToDelete;
			}
		}
	}

	/**
	 * Various overloaded methods to make the autoInsert optional as well as the recordId.
	 */
	public static void log(LoggingLevel level, String areaName, Id recordId, String message) {
		log(level, areaName, recordId, message, true);
	}
	public static void log(LoggingLevel level, String areaName, String message) {
		log(level, areaName, null, message, true);
	}

	/***
	 * Causes any log entries previously entered to be inserted and the queue empted.
	 */
	public static void saveLogEntries() {
		if (queuedLogEntries != null && queuedLogEntries.size() > 0) {
			insert queuedLogEntries;
			queuedLogEntries.clear();
		}
	}

	/**
	 * A helper method for use when debugging code where saving a log entry is not possible and the
	 * entire contents of a long string are needed (e.g. after an HTTP callout).  The output will be
	 * placed in the debug console and this function should only be called during development to
	 * ensure debug logs don't get unnecessarily truncated.
	 */
	private static Integer chunkSize = 275;  // Max length of a debug log string
	public static void debug(String value, String prefix) {
		Integer chunks = Math.ceil((1.0 * value.length()) / chunkSize).intValue();
		for (Integer i = 0; i < chunks; i++) {
        	System.debug(prefix + i + ':  ' + value.mid(i * chunkSize, chunkSize));
		}
	}

}