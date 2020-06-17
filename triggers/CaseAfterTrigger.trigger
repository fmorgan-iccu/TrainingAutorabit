trigger CaseAfterTrigger on Case (after insert, after update) {

	if (Trigger.isInsert || Trigger.isUpdate) {
		// If a case is being assigned to a user from a queue and is associated with an opportunity,
		// update the opportunity owner to match the case owner.
		if (!TriggerUtils.checkExecuted('UpdateCaseOppOwner')) {
			// Identify the cases that are associated with an opportunity and are being assigned from a
			// queue to a user.
			Map<Id, Case> oppIdToCaseMap = new Map<Id, Case>();
			for (Case c : Trigger.newMap.values()) {
				Boolean insertAssignedToEmployee = Trigger.isInsert && !IdUtils.isQueue(c.ownerId);
				Boolean updateAssignedToEmployee =
					Trigger.isUpdate
					&& IdUtils.isQueue(Trigger.oldMap.get(c.Id).ownerId)
					&& !IdUtils.isQueue(c.ownerId);
				if (c.opportunity__c != null && (insertAssignedToEmployee || updateAssignedToEmployee)) {
					oppIdToCaseMap.put(c.opportunity__c, c);
				}
			}

			// Retrieve the opportunities, if any, and update their owners to match the case.  Only
			// update the opportunity if the owner Id is different to prevent recursive updates.
			if (oppIdToCaseMap.size() > 0) {
				List<Opportunity> oppsToCheck = [
					SELECT id,
						closeDate,
						isClosed,
						ownerId
					FROM Opportunity
					WHERE id IN :oppIdToCaseMap.keySet()
				];
				List<Opportunity> oppsToUpdate = new List<Opportunity>();
				Date today = System.today();
				for (Opportunity o : oppsToCheck) {
					Id caseOwnerId = oppIdToCaseMap.get(o.id).ownerId;
					if (o.ownerId != caseOwnerId) {
						o.ownerId = caseOwnerId;
						// Because of the Closed_Opportunity validation rule, an opportunity close
						// date can't be in the past.  This will prevent an update of the owner if
						// this is caused.  So, set the close date to today if it is in the past.
						if (!o.isClosed && o.closeDate < today) {
							o.closeDate = today;
						}
						oppsToUpdate.add(o);
					}
				}
				if (oppsToUpdate.size() > 0) {
					update oppsToUpdate;
				}
			}
		}
	}
	
}