trigger ContactAfterTrigger on Contact (after insert, after update) {

	if (Trigger.isInsert || Trigger.isUpdate) {
		// If the current user is the "Batch" user and the record is of DNA type, determine if there
		// are any existing non-DNA contact with the same tax Id and identification number (DL,
		// Passport, etc.)  These records and their associated accounts will be merged.
		// NOTE:  This is only done for the Batch user to prevent UI glitches that would occur by
		// merging a contact after insert/update into another record.  If the system did this, the
		// team member could see a record disappear on them after saving.
		Id batchUserId = IdUtils.BATCH_USER_ID;
		if (UserInfo.getUserId() == batchUserId && !TriggerUtils.checkExecuted('BatchContactMerge')) {
			// Gather the first DNA record for each tax ID that is present.  This is done because
			// merging two DNA records is not supported by the MergeUtils process.  Also, gather a
			// list of identification numbers to make the dynamic contactDupes query below
			// "selective", meaning that it contains at least one field that reduces the overall
			// number of records returned to a small enough number.  This is required because the
			// tax ID field can't be declared as an external ID because it is declared to not be 
			// unique.  This was done to allow the Default records to have the same tax ID as a DNA
			// record and still store it as encrypted.  This ID filter is *only* used to limit the
			// number of possible records and the tax ID is still used to identify the exact record.  
			Id dnaRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
			Map<String, List<Contact>> candidateContactsToMerge = new Map<String, List<Contact>>();
			Set<String> identificationNumbers = new Set<String>();
			for (Contact c : Trigger.new) {
				// The Avoka forms require the tax ID and identification number and therefore the 
				// DNA record that is created will have both.  Only process the DNA records that
				// have both of these to ensure the query below is selective.
				if (c.recordTypeId == dnaRecordTypeId
					&& !String.isBlank(c.taxId__c)
					&& !String.isBlank(c.identificationNumber__c))
				{
					if (!candidateContactsToMerge.containsKey(c.taxId__c)) {
						List<Contact> contacts = new List<Contact> { c };
						candidateContactsToMerge.put(c.taxId__c, contacts);
						identificationNumbers.add(c.identificationNumber__c);
					}
				}
			}

			// Continue processing if at least one contact exists with a tax Id on file.
			if (candidateContactsToMerge.size() > 0) {
				// Identify the potential duplicate records for the tax Ids that have been found.
				// This query is built dynamically to query all of the fields (equivalent to
				// SELECT * FROM Contact).  The contact to merge into should be the oldest non-DNA
				// record.  This corresponds to the way the getApplicantContact function in the
				// AOApplicationDataController class matches an existing record.  Add each record
				// found to the duplicate list above.  Note:  The SOQL query can't sort on the tax
				// Id and the oldest has to be extracted in a separate loop.  See the note above
				// about why the identifiation number is included in the WHERE clause.
				Set<Id> contactIds = Trigger.newMap.keySet();
				Set<String> taxIds = candidateContactsToMerge.keySet();
				List<Contact> contactDupes =
					Database.query('SELECT '
						+ String.join(new List<String>(Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().keySet()), ',')
						+ ' FROM Contact WHERE recordTypeId != :dnaRecordTypeId AND identificationNumber__c IN :identificationNumbers AND taxId__c IN :taxIds AND id NOT IN :contactIds ORDER BY createdDate');
				Map<String, Contact> oldestNonDnaContact = new Map<String, Contact>();
				for (Contact c : contactDupes) {
					if (!oldestNonDnaContact.containsKey(c.taxId__c)) {
						oldestNonDnaContact.put(c.taxId__c, c);
					}
				}
				for (Contact c : oldestNonDnaContact.values()) {
					candidateContactsToMerge.get(c.taxId__c).add(c);
				}

				// The candidate contact list may contain entries that don't actually have
				// duplicates; remove them here.
				for (String taxId : candidateContactsToMerge.keySet()) {
					if (candidateContactsToMerge.get(taxId).size() <= 1) {
						candidateContactsToMerge.remove(taxId);
					}
				}

				// Due to governance limits, the number of contacts that the system can merge must
				// be reduced here.  This ensures that only those accounts that are associated with
				// these contacts are merged.
				// NOTE:  Because there is a one-to-one relationship between the Avoka created 
				// contact and the import from DNA, half of the remaining DML operations will be
				// used to merge the contacts and the second half will be used to merge the accounts.
				// To "play nicely" this will only use 80% of the remaining DML operations to allow
				// other triggers some DML operations.
				Integer remainingDmlStatements = Limits.getLimitDMLStatements() - Limits.getDMLStatements();
				Integer allowedContactDmlStatements = (remainingDmlStatements / 2.0 * 0.8).intValue();
				Set<String> contactTaxIds = candidateContactsToMerge.keySet();
				for (String taxId : contactTaxIds) {
					Integer expectedDmlOperations = candidateContactsToMerge.get(taxId).size() + 2;
					if (expectedDmlOperations < allowedContactDmlStatements) {
						allowedContactDmlStatements -= expectedDmlOperations;
					} else {
						candidateContactsToMerge.remove(taxId);
					}
				}

				if (candidateContactsToMerge.size() > 0) {
					// All remaining candidates are in fact going to be merged.  Identify any
					// duplicate accounts that also need to be merged.  These accounts should only
					// be those created by Avoka or the Batch process.  The map below will be from
					// the account Id to the tax Id.  This will allow for the SOQL query to be
					// optimized to retrieve all of the accounts in one query and then quickly
					// mapped back to the duplicate contacts.  Again, the query is dynamically built
					// to allow for retrieving all of the fields for each record.
					Map<Id, String> accountIdsToMerge = new Map<Id, String>();
					for (List<Contact> contacts : candidateContactsToMerge.values()) {
						for (Contact c : contacts) {
							accountIdsToMerge.put(c.accountId, c.taxId__c);
						}
					}
					Set<Id> accountIds = accountIdsToMerge.keySet();
					List<Account> accountDupes =
						Database.query('SELECT '
							+ String.join(new List<String>(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()), ',')
							+ ' FROM Account WHERE id IN :accountIds');
					Map<String, List<Account>> candidateAccountsToMerge = new Map<String, List<Account>>();
					for (Account a : accountDupes) {
						String contactTaxId = accountIdsToMerge.get(a.id);
						if (candidateAccountsToMerge.containsKey(contactTaxId)) {
							candidateAccountsToMerge.get(contactTaxId).add(a);
						} else {
							List<Account> accounts = new List<Account>();
							accounts.add(a);
							candidateAccountsToMerge.put(contactTaxId, accounts);
						}
					}

					// The candidate account list may contain entries that don't actually have
					// duplicates; remove them here.
					for (String taxId : candidateAccountsToMerge.keySet()) {
						if (candidateAccountsToMerge.get(taxId).size() <= 1) {
							candidateAccountsToMerge.remove(taxId);
						}
					}

					// Finally bulk merge the accounts and contacts.  It is important to note that the
					// system assumes that the number of duplicates will be relatively small for any
					// given batch.
					try {
						MergeUtils.massMerge(candidateContactsToMerge.values());
					} catch (MergeUtils.MergeLimitException e) {
						LogUtils.log(LoggingLevel.ERROR, 'ContactAfterTrigger_ContactMerge', e.getMessage());
					}
					if (candidateAccountsToMerge.size() > 0) {
						try {
							MergeUtils.massMerge(candidateAccountsToMerge.values());
						} catch (MergeUtils.MergeLimitException e) {
							LogUtils.log(LoggingLevel.ERROR, 'ContactAfterTrigger_AccountMerge', e.getMessage());
						}
					}
				}
			}
		}
	}

	if (Trigger.isUpdate) {
		if (!TriggerUtils.checkExecuted('ContactMergeIntoProcessing')) {
			// IMPORTANT NOTE:  Even though this is coded to support batch processing, in practice
			// the bulk processing can fail for any number of data reasons.  It is BEST to load the 
			// mergeIntoId__c values with a batch size of one.

			// If the mergeIntoId is set on one or more contacts, attempt to merge the contact.
			Set<Id> idsToMerge = new Set<Id>();
			for (Contact c : Trigger.new) {
				if (!String.isBlank(c.mergeIntoId__c)) {
					idsToMerge.add(c.id);
				}
			}
			if (idsToMerge.size() > 0) {
				// Retreive the contacts so that the records are not read only.  This query includes all
				// of the fields defined by the object definition to ensure that the merge saves the
				// appropriate data.
				List<Contact> contactsWithMergeInto =
					Database.query('SELECT '
						+ String.join(new List<String>(Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().keySet()), ',')
						+ ' FROM Contact WHERE id IN :idsToMerge');

				// Associate all of the contacts with the same mergeIntoId__c value into a list of contacts that
				// will be merged together.
				Map<Id, List<Contact>> contactsToMerge = new Map<Id, List<Contact>>();
				for (Contact c : contactsWithMergeInto) {
					List<Contact> contacts = contactsToMerge.get(c.mergeIntoId__c);
					if (contacts == null) {
						contacts = new List<Contact>();
						contactsToMerge.put(c.mergeIntoId__c, contacts);
					}
					contacts.add(c);
				}

				// Retrieve the target "mergeIntoId__c" contacts and add them to the appropriate merge list.
				Set<Id> mergeIntoIds = contactsToMerge.keySet();
				List<Contact> mergeIntoContacts = Database.query('SELECT '
					+ String.join(new List<String>(Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().keySet()), ',')
					+ ' FROM Contact WHERE id IN :mergeIntoIds');
				for (Contact c : mergeIntoContacts) {
					List<Contact> contacts = contactsToMerge.get(c.id);
					contacts.add(c);
				}

				// Finally merge the contacts.
				try {
					MergeUtils.massMerge(contactsToMerge.values());
				} catch (MergeUtils.MergeLimitException e) {
					LogUtils.log(LoggingLevel.ERROR, 'ContactMergeIntoProcessing', e.getMessage());
				}
			}
		}
	}

}