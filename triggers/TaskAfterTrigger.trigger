trigger TaskAfterTrigger on Task (after insert, after delete) {

	// Update the first call resolution (FCR) variables; see the before trigger for more info.
	if (!TriggerUtils.checkExecuted('FCRAfterCheck')) {
		// If this is a new task and it is flagged as being a call back (multipleCalls__c), update
		// the associated first call record so that it is flagged as requiring multiple calls.
		if (Trigger.isInsert) {
			// Identify the contacts associated with multiple calls.
			Set<Id> contactIds = new Set<Id>();
			for (Task t : Trigger.new) {
				if (t.callType == 'Inbound') {
					if (t.multipleCalls__c == true) {
						contactIds.add(t.whoId);
					}
				}
			}

			// Find the first calls of the day that aren't currently marked as being associated with
			// multiple calls.
			List<Task> firstCalls = [
				SELECT id
				FROM Task
				WHERE callType = 'Inbound'
					AND createdDate = TODAY
					AND firstCallOfDay__c = true
					AND multipleCalls__c = false
					AND type = 'Call'
					AND whoId IN :contactIds
			];

			// Update the identified tasks as being associated with multiple calls.
			for (Task t : firstCalls) {
				t.multipleCalls__c = true;
			}
			update firstCalls;
		}

		// When a task is deleted, recompute the first/multi call flags.
		if (Trigger.isDelete) {
			// Get a list of the contacts to recompute for.
			Set<Id> contactIds = new Set<Id>();
			for (Task t : Trigger.old) {
				if (t.callType == 'Inbound') {
					contactIds.add(t.whoId);
				}
			}

			// Get all of the call data for these contacts.
			List<Task> tasks = [
				SELECT id,
					callType,
					createdDate,
					firstCallOfDay__c,
					multipleCalls__c,
					whoId
				FROM Task
				WHERE callType = 'Inbound'
					AND createdDate = TODAY
					AND type = 'Call'
					AND whoId IN :contactIds
				ORDER BY whoId, createdDate
			];

			// For each contact, determine the number of inbound calls for the day.
			Map<Id,Integer> callCountByContact = new Map<Id,Integer>();
			for (Task t : tasks) {
				Integer callCount = callCountByContact.get(t.whoId);
				if (callCount == null) {
					callCount = 0;
				}
				callCount += 1;
				callCountByContact.put(t.whoId, callCount);
			}

			// Update the task flags based on the number of calls and the order they occurred.
			Id currContactId = null;
			for (Task t : tasks) {
				if (t.callType == 'Inbound') {
					t.firstCallOfDay__c = t.whoId != currContactId;
					t.multipleCalls__c = callCountByContact.get(t.whoId) > 1;
					if (t.whoId != currContactId) {
						currContactId = t.whoId;
					}
				}
			}
			update tasks;
		}
	}
}