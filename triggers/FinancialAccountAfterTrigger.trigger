/**
 * NOTE:  The name of the financial account is populated by the AppWorx batch job that uses the 
 * DNA defined description of the account.  The products database should be used to define a
 * member friendly description.  A scheduled process will need to be written to pull the product
 * database member friendly name and cache this in a custom object.  This information should be used
 * to update the financial account name with the correct name if a nickname isn't provided.
 */
trigger FinancialAccountAfterTrigger on FinancialAccount__c (after insert, after update) {

	if (Trigger.isInsert|| Trigger.isUpdate) {
		// Identify all of the persons that are associated with the financial accounts.
		Map<String, Id> personContactIds = new Map<String, Id>();
		Map<Id, List<String>> allFinancialAccountRoles = new Map<Id, List<String>>();
		for (FinancialAccount__c financialAccount : Trigger.new) {
			if (financialAccount.primaryRolesJson__c != null) {
				if (!allFinancialAccountRoles.containsKey(financialAccount.id)) {
					allFinancialAccountRoles.put(financialAccount.id, new List<String>());
				}
				List<String> financialAccountRolePersons = allFinancialAccountRoles.get(financialAccount.id);

				List<Object> rolePersonNumbers = (List<Object>)JSON.deserializeUntyped(financialAccount.primaryRolesJson__c);
				for (Object personNumber : rolePersonNumbers) {
					String pn = String.valueOf((Integer)personNumber);
					personContactIds.put(pn, null);
					financialAccountRolePersons.add(pn);
				}
			}
		}

		// If any of the financial accounts have associated persons...
		if (!allFinancialAccountRoles.isEmpty()) {
			// Query all of the contacts for all of the accounts at one time.
			Set<String> personNumbers = personContactIds.keySet();
			List<Contact> contacts = [
				SELECT id,
					personNumber__c
				FROM Contact
				WHERE personNumber__c IN :personNumbers
			];
			for (Contact c : contacts) {
				personContactIds.put(c.personNumber__c, c.id);
			}

			// Identify all of the junction objects that already exist for all of the financial
			// accounts in this context.  Create a set to rapidly identify the existing
			// account/contact Id comb
			Set<Id> financialAccountIds = allFinancialAccountRoles.keySet();
			List<FinancialAccountRole__c> existingFinancialAccountRoles = [
				SELECT id,
					contact__c,
					contact__r.personNumber__c,
					financialAccount__c
				FROM FinancialAccountRole__c
				WHERE financialAccount__c IN :financialAccountIds
			];
			Set<String> existingRoleKeys = new Set<String>();
			for (FinancialAccountRole__c role : existingFinancialAccountRoles) {
				existingRoleKeys.add(role.financialAccount__c + '-' + role.contact__c);
			}

			// Delete any financial account roles that aren't present.
			List<FinancialAccountRole__c> rolesToDelete = new List<FinancialAccountRole__c>();
			for (FinancialAccountRole__c role : existingFinancialAccountRoles) {
				List<String> financialAccountRolePersons = allFinancialAccountRoles.get(role.financialAccount__c);
				if (!financialAccountRolePersons.contains(role.contact__r.personNumber__c)) {
					rolesToDelete.add(role);
				}
			}
			delete rolesToDelete;

			// Insert all of the new financial account roles.
			List<FinancialAccountRole__c> rolesToAdd = new List<FinancialAccountRole__c>();
			for (Id i : financialAccountIds) {
				List<String> rolePersonNumbers = allFinancialAccountRoles.get(i);
				if (rolePersonNumbers != null) {
					for (String personNumber : rolePersonNumbers) {
						Id contactId = personContactIds.get(personNumber);
						String roleKey = i + '-' + contactId;
						if (contactId != null && !existingRoleKeys.contains(roleKey)) {
							FinancialAccountRole__c role = new FinancialAccountRole__c(
								name=Trigger.newMap.get(i).name,
								contact__c=contactId,
								financialAccount__c=i
							);
							rolesToAdd.add(role);
						}
					}
				}
			}
			insert rolesToAdd;

			// Finally, clear the primaryRolesJson on the Financial Accounts so this won't be triggered
			// again.
			List<FinancialAccount__c> financialAccountsToUpdate = new List<FinancialAccount__c>();
			for (FinancialAccount__c financialAccount : Trigger.new) {
				if (financialAccount.primaryRolesJson__c != null) {
					FinancialAccount__c fa = new FinancialAccount__c();
					fa.id = financialAccount.id;
					fa.primaryRolesJson__c = null;
					financialAccountsToUpdate.add(fa);
				}
			}
			update financialAccountsToUpdate;
		}
	}

}