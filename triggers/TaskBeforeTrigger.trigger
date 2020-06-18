trigger TaskBeforeTrigger on Task (before insert) {
    
	// First Call Resolution (FCR) logic.
	// TODO:  Should this only be for the MCC?  Need to test how the activity is handled on transfer.
	if (Trigger.isInsert && !TriggerUtils.checkExecuted('FCRBeforeCheck')) {
		// Identify the contacts that are associated with the inbound calls that are being created.
		Set<Id> contactIds = new Set<Id>();
		for (Task t : Trigger.new) {
			if (t.callType == 'Inbound') {
				contactIds.add(t.whoId);
			}
		}

		// Retrieve any existing inbound calls from today for the contacts related to the new tasks.
		List<Task> existingTasks = [
			SELECT id,
				whoId
			FROM Task
			WHERE callType = 'Inbound'
				AND createdDate = TODAY
				AND type = 'Call'
				AND whoId IN :contactIds
		];

		// Create a set to identify which contact Ids where found.  These are the people with
		// multiple calls.
		Set<Id> existingTaskOwnerIds = new Set<Id>();
		for (Task t : existingTasks) {
			existingTaskOwnerIds.add(t.whoId);
		}
		
		// For all of the new inbound calls, determine if this is the first call or multiple calls.
		// If the owner is in the existing task owner or has previously been inserted as part of
		// this batch, this is a call back.  Otherwise, it is a first call.
		Set<Id> insertedContactIds = new Set<Id>();
		for (Task t : Trigger.new) {
			if (t.callType == 'Inbound') {
				if (existingTaskOwnerIds.contains(t.whoId) || insertedContactIds.contains(t.whoId)) {
					t.multipleCalls__c = true;
				} else {
					t.firstCallOfDay__c = true;
				}
				insertedContactIds.add(t.whoId);
			}
		}
	}

}