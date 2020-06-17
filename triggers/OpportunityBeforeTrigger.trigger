trigger OpportunityBeforeTrigger on Opportunity (before insert, before update) {

    if (Trigger.isInsert) {
        // The MRA department loads opportunities for existing members for various reasons (e.g.
        // IL Onboarding, Guaranteed Offers, etc.)  To simplify the data load, this will process
        // will lookup the account to link the opportunity based on the person number.  This is 
        // coded in a way that can be used by any department/automation that doesn't know the
        // account Id.
        Map<String, Id> personAccounts = new Map<String, Id>();
        for (Opportunity newOpp : Trigger.new) {
            if (newOpp.AccountId == null && newOpp.person_number__c != null) {
                personAccounts.put(newOpp.person_number__c, null);
            }
        }
        if (personAccounts.size() > 0) {
            Set<String> personNumbers = personAccounts.keySet();
            List<Account> accounts = [
                SELECT id,
                    personNumber__c
                FROM Account
                WHERE personNumber__c IN :personNumbers
            ];
            for (Account a : accounts) {
                personAccounts.put(a.personNumber__c, a.id);
            }
            for (Opportunity newOpp : Trigger.new) {
                if (newOpp.AccountId == null && newOpp.person_number__c != null) {
                    newOpp.accountId = personAccounts.get(newOpp.person_number__c);
                }
            }
        }
    }

	if (Trigger.isInsert || Trigger.isUpdate) {
		// Set the stage of an opportunity that is currently in the New stage to Assigned if the
		// owner is being changed from the Batch user to anyone else.
		for (Opportunity newOpp : Trigger.new) {
			if (newOpp.stageName == 'New' && newOpp.avokaJob__c != null) {
				Boolean insertAssignedToEmployee = Trigger.isInsert && newOpp.ownerId != IdUtils.BATCH_USER_ID;
				Boolean updateAssignedToEmployee = Trigger.isUpdate && Trigger.oldMap.get(newOpp.id).ownerId == IdUtils.BATCH_USER_ID && newOpp.ownerId != IdUtils.BATCH_USER_ID;
				if (insertAssignedToEmployee || updateAssignedToEmployee) {
					newOpp.stageName = 'Assigned';
				}
			}
		}

		// Set the email on the opportunity if there is a primary contact role associated with the
		// opportunity.  The OpportunityContactRole objects do not suppport triggers.  Therefore,
		// any opportunity that doesn't already have an email will be checked to determine if a
		// contact has been added.  For automations like the "Non Responsive Member"
		List<Id> missingEmailOppIds = new List<Id>();
		for (Opportunity newOpp : Trigger.new) {
			if (String.isEmpty(newOpp.email__c)) {
				missingEmailOppIds.add(newOpp.id);
			}
		}
		if (missingEmailOppIds.size() > 0) {
			for (OpportunityContactRole contactRole : [
				SELECT id,
					contact.email,
					contactId,
					opportunityId
				FROM OpportunityContactRole
				WHERE opportunityId IN :missingEmailOppIds
					AND isPrimary = true
				])
			{
				Opportunity newOpp = Trigger.newMap.get(contactRole.opportunityId);
				newOpp.email__c = contactRole.contact.email;
			}
		}
	}

}