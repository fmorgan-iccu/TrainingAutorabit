/**
 * Provides methods for standardized merging of records within a Salesforce environment.
 * Applies all ICCU specific rules for what records are given precedance (e.g. DNA vs other record
 * types) as well as the fields that should be give special attention (e.g. ownership of non-DNA
 * records)
 */
public with sharing class MergeUtils {

	public static final Integer MINIMUM_MERGE_RECORDS = 2;

	private static final List<List<String>> ACCOUNT_FIELD_GROUPS = new List<List<String>> {
		new List<String> {
			'ShippingCity',
			'ShippingCountry',
			'ShippingPostalCode',
			'ShippingState',
			'ShippingStreet'
		}
	};

	private static final List<List<String>> CONTACT_FIELD_GROUPS = new List<List<String>> {
		new List<String> {
			'IdentificationExpirationDate__c',
			'IdentificationIssueDate__c',
			'IdentificationIssueState__c',
			'IdentificationNumber__c',
			'IdentificationType__c'
		},
		new List<String> {
			'MailingCity',
			'MailingCountry',
			'MailingPostalCode',
			'MailingState',
			'MailingStreet'
		},
		new List<String> {
			'FirstName',
			'LastName',
			'MiddleName'
		}
	};

	// This is an educated guess at the number of changes that will occur during the rolling 18
	// month Contact/Account History retention period.
	private static final Integer MAX_HISTORY_RECORDS = 100;

	/**
	 * Convenience function for bulk merging contacts.  This process will validate the remaining
	 * DML and SOQL statements/rows that can be processed to prevent the system from throwing an
	 * unhandleable exception.
	 */
	public static void massMerge(List<List<Contact>> contactListsToMerge) {
		for (List<Contact> contactsToMerge : contactListsToMerge) {
			// Validate that the operation won't exceed the governance limits for DML.
			Integer expectedDmlOperations = contactsToMerge.size();
			if (Limits.getQueryRows() + MAX_HISTORY_RECORDS > Limits.getLimitQueryRows()
				|| Limits.getQueries() + 1 > Limits.getLimitQueries()
				|| Limits.getDMLRows() + expectedDmlOperations > Limits.getLimitDMLRows()
				|| Limits.getDMLStatements() + expectedDmlOperations > Limits.getLimitDMLStatements())
			{
				throw new MergeLimitException('Insufficient DML/SOQL operations to complete all merging operations.');
			}

			massMerge(contactsToMerge);
		}
	}
	
	public static Contact massMerge(List<Contact> contactsToMerge) {
		// Retrieve the field history for all of the changes associated with each of the contacts to
		// be merged.  The history is retained for 18 months and the overall number of changes is
		// expected to be small enough.  It is important to know that the Account and created
		// entries are ignored since the accounts must be merged separately and the created entry
		// doesn't actually correspond to a field.
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		for (Contact c : contactsToMerge) {
			contactMap.put(c.id, c);
		}
		List<ContactHistory> contactHistories = null;
		contactHistories = [
			SELECT id,
				contactId,
				createdDate,
				field,
				newValue
			FROM ContactHistory
			WHERE contactId IN :contactMap.keySet()
		];
		List<FieldHistory> fieldHistories = new List<FieldHistory>();
		for (ContactHistory ch : contactHistories) {
			fieldHistories.add(new FieldHistory(ch.field, ch.contactId, ch.createdDate, null));
		}

		return massMerge(contactsToMerge, fieldHistories);
	}

	/**
	 * Merge all of the contacts in the list into the oldest record.
	 */
	@TestVisible
	private static Contact massMerge(List<Contact> contactsToMerge, List<FieldHistory> fieldHistories) {
		// Retrieve the DNA record type Id to ensure that if any of the records being merged are of
		// this type that the type is always retained regardless of which record will be the master
		// record.
		Id dnaRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();

		if (contactsToMerge == null || contactsToMerge.size() < MINIMUM_MERGE_RECORDS) {
			throw new IllegalArgumentException('At least two contacts must be provided to massMerge.');
		}
		if (fieldHistories == null) {
			throw new IllegalArgumentException('A list of field history records must be provided.  An empty list is allowed.');
		}

		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		Contact masterContact = contactsToMerge.get(0);
		Contact dnaContact = null;
		for (Contact c : contactsToMerge) {
			// Validate that the contact has a createdDate field.
			if (!c.getPopulatedFieldsAsMap().keySet().contains('CreatedDate')) {
				throw new IllegalArgumentException('Contacts to merge must have a createdDate (' + c.id + ').');
			}

			// Validate that the contact has a recordTypeId field.
			if (!c.getPopulatedFieldsAsMap().keySet().contains('RecordTypeId')) {
				throw new IllegalArgumentException('Contacts to merge must have a recordTypeId (' + c.id + ').');
			}

			// Validate that there is only one record of DNA type, storing the first DNA record
			// found.
			if (c.recordTypeId == dnaRecordTypeId) {
				if (dnaContact != null) {
					throw new IllegalArgumentException('Only one DNA record may be provided per merge (' + c.id + ').');
				} else {
					dnaContact = c;
				}
			}

			// Add the contact to a map for rapid access by Id.
			contactMap.put(c.id, c);

			// Identify the master contact that all other contacts will be merged into; this contact
			// is the oldest contact in the list.
			if (c.createdDate <= masterContact.createdDate) {
				masterContact = c;
			}
		}

		// This algorithm requires that the contacts be sorted by the created date in ascending
		// order to work properly.
		contactsToMerge = SortUtils.sortListByCreatedDate((List<sObject>)contactsToMerge);

		// Loop over each of the contacts to merge and store all of the fields that may have been
		// present at the time of creation keeping the value from the most recent record that had a
		// value.  This is done because the values present on each record may be different and we
		// need to find the initial state prior to comparing this to the field modifications that
		// may have been made at a later time.
		Map<String, FieldHistory> valuesToKeep = new Map<String, FieldHistory>();
		FieldHistory fieldHistory = null;
		for (Contact c : contactsToMerge) {
			Set<String> populatedFields = c.getPopulatedFieldsAsMap().keySet();
			for (String fieldName : populatedFields) {
				Object fieldValue = c.get(fieldName);
				if (fieldValue != null) {
					fieldHistory = valuesToKeep.get(fieldName);
					Boolean performUpdate = fieldHistory == null || (Datetime)c.get('createdDate') > fieldHistory.modifiedDate;
					updateValuesToKeep(valuesToKeep, fieldName, c.id, c.createdDate, fieldValue, performUpdate);
				}
			}
		}

		// Iterate over each of the field history items and identify the first result for each
		// of the fields.  This entry is the contact that had the most recent modification to the
		// field; this is due to the order of the SOQL statement above.  Compare this to the created
		// date for the field and determine if it is a more recent modification.
		String lastField = null;
		Map<String, Schema.SObjectField> fieldMap = masterContact.getSObjectType().getDescribe().fields.getMap();
		for (FieldHistory fh : fieldHistories) {
			if (fh.fieldName != lastField) {
				if (fieldMap.containsKey(fh.fieldName)) {
					// The value is pulled directly from the original contact to ensure the correct
					// value is used.  The field history is text and only supports up to 255 characters.
					Object fieldValue = contactMap.get(fh.objectId).get(fh.fieldName);
					fieldHistory = valuesToKeep.get(fh.fieldName);
					Boolean performUpdate = fieldHistory == null || fh.modifiedDate > fieldHistory.modifiedDate;
					updateValuesToKeep(valuesToKeep, fh.fieldName, fh.objectId, fh.modifiedDate, fieldValue, performUpdate);
				}
				lastField = fh.fieldName;
			}
		}

		// Loop over the grouped fields and find the contact with the most recently changed value
		// within the group.  Copy the values of all of the fields in the group from the record
		// associated with the latest change.
		for (List<String> groupFieldNames : CONTACT_FIELD_GROUPS) {
			Datetime mostRecentChange = null;
			Id contactId = null;
			for (String fieldName : groupFieldNames) {
				fieldHistory = valuesToKeep.get(fieldName);
				if (fieldHistory != null
					&& valuesToKeep.containsKey(fieldName)
					&& (mostRecentChange == null || fieldHistory.modifiedDate > mostRecentChange))
				{
					mostRecentChange = fieldHistory.modifiedDate;
					contactId = fieldHistory.objectId;
				}
			}
			if (contactId != null) {
				Contact c = contactMap.get(contactId);
				Set<String> populatedFields = c.getPopulatedFieldsAsMap().keySet();
				for (String fieldName : groupFieldNames) {
					Object fieldValue = populatedFields.contains(fieldName) ? c.get(fieldName) : null;
					updateValuesToKeep(valuesToKeep, fieldName, contactId, mostRecentChange, fieldValue, true);
				}
			}
		}

		// If there is a DNA contact, use all of the data points sourced from that system as the
		// winning values since there are often special rules in place for making modifictions to
		// them (e.g. name, address, tax Id, etc.) 
		if (dnaContact != null) {
			List<String> supportedContactFields = SFCacheUpdater.SALESFORCE_CONTACT_FIELDS.values();
			Set<String> populatedFields = dnaContact.getPopulatedFieldsAsMap().keySet();
			for (String fieldName : supportedContactFields) {
				Object fieldValue = populatedFields.contains(fieldName) ? dnaContact.get(fieldName) : null;
				updateValuesToKeep(valuesToKeep, fieldName, dnaContact.id, dnaContact.createdDate, fieldValue, true);
			}
		}

		// Can-Spam laws require us to honor the contact's email preference.  In addition, the
		// system also track a "Do not call" preference.  If either of these fields are checked on
		// any of the records, it will remain checked.
		Boolean doNotEmail = false;
		Boolean doNotCall = false;
		for (Contact c : contactsToMerge) {
			doNotEmail = doNotEmail || c.hasOptedOutOfEmail;
			doNotCall = doNotCall || c.doNotCall;
		}
		if (valuesToKeep.containsKey('HasOptedOutOfEmail')) {
			valuesToKeep.get('HasOptedOutOfEmail').value = doNotEmail;
		}
		if (valuesToKeep.containsKey('DoNotCall')) {
			valuesToKeep.get('DoNotCall').value = doNotCall;
		}

		// Copy all of the fields from the field history into a contact record that can be updated.
		// This means that none of the fields that can't be written to must not be present on the
		// contact (e.g. createdDate, createdById, etc.)  The contact to update will be set to the
		// master record's Id that was the target of all of the merges above.
		Contact updateContact = new Contact();
		updateContact.id = masterContact.id;
		for (String fieldName : valuesToKeep.keySet()) {
			Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
			if (fieldDescribe.isUpdateable()) {
				Object fieldValue = valuesToKeep.get(fieldName).value;

				// Boolean fields can't be set to null
				if (fieldDescribe.getType() == Schema.DisplayType.Boolean && fieldValue == null) {
					fieldValue = false;
				}
				updateContact.put(fieldName, fieldValue);
			}
		}

		// The mergeIntoId__c field is used by the MergeContactsBatch process and should always be
		// removed during the merge process to prevent a future merge attempt.
		updateContact.mergeIntoId__c = null;

		Savepoint sp = Database.setSavepoint();
		try {
			// Now that the best possible value for each of the fields has been identified...
			
			// Create indirect associations with all of the accounts that are associated with any of
			// the merged contacts that aren't already associated with the master/winning contact.
			List<AccountContactRelation> existingRelationships = [
				SELECT id,
				accountId,
				contactId
				FROM AccountContactRelation
				WHERE contactId = :masterContact.id
			];
			Set<Id> existingAccountRelationships = new Set<Id>();
			for (AccountContactRelation acr : existingRelationships) {
				existingAccountRelationships.add(acr.accountId);
			}
			List<AccountContactRelation> newRelationships = new List<AccountContactRelation>();
			for (Contact c : contactsToMerge) {
				if (c.id != masterContact.id && !existingAccountRelationships.contains(c.accountId)) {
					AccountContactRelation acr = new AccountContactRelation();
					acr.accountId = c.accountId;
					acr.contactId = masterContact.id;
					newRelationships.add(acr);
				}
			}
			if (newRelationships.size() > 0) {
				insert newRelationships;
			}

			// Merge all of the contacts into the oldest record.  This will resolve all lookups that
			// reference the contact to be deleted and point them at the "master" contact.  The
			// merge DML command can fail when certain fields are present.  It is best practice to
			// have an sObject with the Id field only.
			for (Contact c : contactsToMerge) {
				if (c.id != masterContact.id) {
					Contact merge1 = new Contact(id=masterContact.id);
					Contact merge2 = new Contact(id=c.id);
					merge merge1 merge2;
				}
			}

			// Finally update the remaining record.  This is purposefully done and not deferred
			// until later for potential batch processing to ensure that the merge and update DML
			// commands are all successful.
			update updateContact;
		} catch (Exception e) {
			// Ensure that merge was completed entirely and that the update was also performed as a
			// single operation.
			Database.rollback(sp);

			// Re-throw the original exception
			throw e;
		}

		// Return the contact that can be updates so that those callers that will perform bulk DML
		// can do their thing.
		return updateContact;
	}

	/**
	 * Convenience function for bulk merging accounts.  This process will validate the remaining
	 * DML and SOQL statements/rows that can be processed to prevent the system from throwing an
	 * unhandleable exception.
	 */
	public static void massMerge(List<List<Account>> accountListsToMerge) {
		for (List<Account> accountsToMerge : accountListsToMerge) {
			// Validate that the operation won't exceed the governance limits for SOQL and DML.
			Integer expectedDmlOperations = accountsToMerge.size();
			if (Limits.getQueryRows() + MAX_HISTORY_RECORDS > Limits.getLimitQueryRows()
				|| Limits.getQueries() + 1 > Limits.getLimitQueries()
				|| Limits.getDMLRows() + expectedDmlOperations > Limits.getLimitDMLRows()
				|| Limits.getDMLStatements() + expectedDmlOperations > Limits.getLimitDMLStatements())
			{
				throw new MergeLimitException('Insufficient DML operations to complete all merging operations.');
			}

			massMerge(accountsToMerge);
		}
	}

	public static Account massMerge(List<Account> accountsToMerge) {
		// Retrieve the field history for all of the changes associated with each of the accounts to
		// be merged.  The history is retained for 18 months and the overall number of changes is
		// expected to be small enough.
		Map<Id, Account> accountMap = new Map<Id, Account>();
		for (Account a : accountsToMerge) {
			accountMap.put(a.id, a);
		}
		List<AccountHistory> accountHistories = null;
		accountHistories = [
			SELECT id,
				accountId,
				createdDate,
				field,
				newValue
			FROM AccountHistory
			WHERE accountId IN :accountMap.keySet()
		];
		List<FieldHistory> fieldHistories = new List<FieldHistory>();
		for (AccountHistory ah : accountHistories) {
			fieldHistories.add(new FieldHistory(ah.field, ah.accountId, ah.createdDate, null));
		}

		return massMerge(accountsToMerge, fieldHistories);
	}

	/**
	 * Merge all of the accounts in the list into the oldest record.
	 */
	@TestVisible
	private static Account massMerge(List<Account> accountsToMerge, List<FieldHistory> fieldHistories) {
		// Retrieve the DNA record type Id to ensure that if any of the records being merged are of
		// this type that the type is always retained regardless of which record will be the master
		// record.
		Id dnaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DNA).getRecordTypeId();

		if (accountsToMerge == null || accountsToMerge.size() < 2) {
			throw new IllegalArgumentException('At least two accounts must be provided to massMerge.');
		}
		if (fieldHistories == null) {
			throw new IllegalArgumentException('A list of field history records must be provided.  An empty list is allowed.');
		}

		Map<Id, Account> accountMap = new Map<Id, Account>();
		Account masterAccount = accountsToMerge.get(0);
		Account dnaAccount = null;
		for (Account a : accountsToMerge) {
			// Validate that the account has a createdDate field.
			if (!a.getPopulatedFieldsAsMap().keySet().contains('CreatedDate')) {
				throw new IllegalArgumentException('Accounts to merge must have a createdDate (' + a.id + ').');
			}
			
			// Validate that the account has a recordTypeId field.
			if (!a.getPopulatedFieldsAsMap().keySet().contains('RecordTypeId')) {
				throw new IllegalArgumentException('Accounts to merge must have a recordTypeId (' + a.id + ').');
			}

			// Validate that there is only one record of DNA type, storing the first DNA record
			// found.
			if (a.recordTypeId == dnaRecordTypeId) {
				if (dnaAccount != null) {
					throw new IllegalArgumentException('Only one DNA record may be provided per merge (' + a.id + ').');
				} else {
					dnaAccount = a;
				}
			}

			// Add the account to a map for rapid access by Id.
			accountMap.put(a.id, a);

			// Identify the master account that all other accounts will be merged into; this account
			// is the oldest account in the list.
			if (a.createdDate <= masterAccount.createdDate) {
				masterAccount = a;
			}
		}

		// This algorithm requires that the accounts be sorted by the created date in ascending
		// order to work properly.
		accountsToMerge = SortUtils.sortListByCreatedDate((List<sObject>)accountsToMerge);

		// Loop over each of the accounts to merge and store all of the fields that may have been
		// present at the time of creation.  This is done because the values present on each record
		// may be different and we need to find the initial state prior to comparing this to the
		// field modifications that may be present.
		Map<String, FieldHistory> valuesToKeep = new Map<String, FieldHistory>();
		FieldHistory fieldHistory = null;
		for (Account a : accountsToMerge) {
			Set<String> populatedFields = a.getPopulatedFieldsAsMap().keySet();
			for (String fieldName : populatedFields) {
				Object fieldValue = a.get(fieldName);
				if (fieldValue != null) {
					fieldHistory = valuesToKeep.get(fieldName);
					Boolean performUpdate = fieldHistory == null || (Datetime)a.get('createdDate') > fieldHistory.modifiedDate;
					updateValuesToKeep(valuesToKeep, fieldName, a.id, a.createdDate, fieldValue, performUpdate);
				}
			}
		}

		// Iterate over each of the field history items and identify the first result that for each
		// of the fields.  This entry is the account that had the most recent modification to the
		// field; this is due to the order of the SOQL statement above.  Compare this to the created
		// date for the field and determine if it is a more recent modification.
		String lastField = null;
		Map<String, Schema.SObjectField> fieldMap = masterAccount.getSObjectType().getDescribe().fields.getMap();
		for (FieldHistory fh : fieldHistories) {
			if (fh.fieldName != lastField) {
				if (fieldMap.containsKey(fh.fieldName)) {
					// The value is pulled directly from the original account to ensure the correct
					// value is used.  The field history is text and only supports up to 255 characters.
					Object fieldValue = accountMap.get(fh.objectId).get(fh.fieldName);
					fieldHistory = valuesToKeep.get(fh.fieldName);
					Boolean performUpdate = fieldHistory == null || fh.modifiedDate > fieldHistory.modifiedDate;
					updateValuesToKeep(valuesToKeep, fh.fieldName, fh.objectId, fh.modifiedDate, fieldValue, performUpdate);
				}
				lastField = fh.fieldName;
			}
		}

		// Loop over the grouped fields and find the contact with the most recently changed value
		// within the group.  Copy the values of all of the fields in the group from the record
		// associated with the latest change.
		for (List<String> groupFieldNames : ACCOUNT_FIELD_GROUPS) {
			Datetime mostRecentChange = null;
			Id accountId = null;
			for (String fieldName : groupFieldNames) {
				fieldHistory = valuesToKeep.get(fieldName);
				if (fieldHistory != null
					&& valuesToKeep.containsKey(fieldName)
					&& (mostRecentChange == null || fieldHistory.modifiedDate > mostRecentChange))
				{
					mostRecentChange = fieldHistory.modifiedDate;
					accountId = fieldHistory.objectId;
				}
			}
			if (accountId != null) {
				Account a = accountMap.get(accountId);
				Set<String> populatedFields = a.getPopulatedFieldsAsMap().keySet();
				for (String fieldName : groupFieldNames) {
					Object fieldValue = populatedFields.contains(fieldName) ? a.get(fieldName) : null;
					updateValuesToKeep(valuesToKeep, fieldName, accountId, mostRecentChange, fieldValue, true);
				}
			}
		}

		// If there is a DNA account, use all of the data points sourced from that system as the
		// winning values since there are often special rules in place for making modifictions to
		// the values (e.g. name, address, tax Id, etc.) 
		if (dnaAccount != null) {
			List<String> supportedAccountFields = SFCacheUpdater.SALESFORCE_ACCOUNT_FIELDS.values();
			Set<String> populatedFields = dnaAccount.getPopulatedFieldsAsMap().keySet();
			for (String fieldName : supportedAccountFields) {
				if (populatedFields.contains(fieldName)) {
					updateValuesToKeep(valuesToKeep, fieldName, dnaAccount.id, dnaAccount.createdDate, dnaAccount.get(fieldName), true);
				}
			}
		}

		// Copy all of the fields from the field history into a account record that can be updated.
		// This means that none of the fields that can't be written to must not be present on the
		// account (e.g. createdDate, createdById, etc.)  The account to update will be set to the
		// master record's Id that was the target of all of the merges above.
		Account updateAccount = new Account();
		updateAccount.id = masterAccount.id;
		for (String fieldName : valuesToKeep.keySet()) {
			if (fieldMap.get(fieldName).getDescribe().isUpdateable()) {
				updateAccount.put(fieldName, valuesToKeep.get(fieldName).value);
			}
		}

		// The mergeIntoId__c field is used by the MergeAccountsBatch process and should always be
		// removed during the merge process to prevent a future merge attempt.
		updateAccount.mergeIntoId__c = null;

		Savepoint sp = Database.setSavepoint();
		try {
			// Now that the best possible value for each of the fields has been identified...
			
			// Ensure that there is only one account contact relationship for each contact Id.
			// This process will identify and save any direct relationship and remove all other
			// relationships.  If a direct relationship is not found, one of the indirect
			// relationships will be saved.  This will prevent any errors from occuring during the
			// merge.
			Set<Id> accountIds = new Set<Id>();
			for (Account a : accountsToMerge) {
				accountIds.add(a.id);
			}
			List<AccountContactRelation> existingRelationships = [
				SELECT id,
					accountId,
					contactId,
					isDirect
				FROM AccountContactRelation
				WHERE accountId IN :accountIds
			];
			Map<Id, AccountContactRelation> contactRetainAcr = new Map<Id, AccountContactRelation>();
			for (AccountContactRelation acr : existingRelationships) {
				AccountContactRelation retainAcr = contactRetainAcr.get(acr.contactId);
				if (retainAcr == null || !retainAcr.isDirect) {
					contactRetainAcr.put(acr.contactId, acr);
				}
			}
			List<AccountContactRelation> deleteRelationships = new List<AccountContactRelation>();
			for (AccountContactRelation acr : existingRelationships) {
				Boolean retain = false;
				for (AccountContactRelation retainAcr : contactRetainAcr.values()) {
					if (acr.id == retainAcr.id) {
						retain = true;
						break;
					}
				}
				if (!retain) {
					deleteRelationships.add(acr);
				}
			}
			if (deleteRelationships.size() > 0) {
				delete deleteRelationships;
			}

			// Merge all of the accounts into the oldest record.  This will resolve all lookups that
			// reference the account to be deleted and point them at the "master" account.  The
			// merge DML command can fail when certain fields are present.  It is best practice to
			// have an sObject with the Id field only.
			for (Account a : accountsToMerge) {
				if (a.id != masterAccount.id) {
					Account merge1 = new Account(id=masterAccount.id);
					Account merge2 = new Account(id=a.id);
					merge merge1 merge2;
				}
			}

			// Finally update the remaining record.  This is purposefully done and not deferred
			// until later for potential batch processing to ensure that the merge and update DML
			// commands are all successful.
			update updateAccount;
		} catch (Exception e) {
			// Ensure that merge was completed entirely and that the update was also performed as a
			// single operation.
			Database.rollback(sp);

			// Re-throw the original exception
			throw e;
		}

		// Return the account that can be updates so that those callers that will perform bulk DML
		// can do their thing.
		return updateAccount;
	}

	/**
	 * Helper function to reduce the amount of code needed to update the valuesToKeep map.
	 */
	private static void updateValuesToKeep(
		Map<String, FieldHistory> valuesToKeep,
		String fieldName,
		Id objectId,
		Datetime modifiedDate,
		Object fieldValue,
		Boolean performUpdate)
	{
		// Identify the current value to keep and if one is not found, create a new value to track
		// the provided information.
		FieldHistory fieldHistory = valuesToKeep.get(fieldName);
		if (fieldHistory == null) {
			fieldHistory = new FieldHistory(
					fieldName,
					objectId,
					modifiedDate,
					fieldValue
				);
			valuesToKeep.put(fieldName, fieldHistory);
		}

		// If the field update was requested and the field is anything other than the ownerId,
		// perform the update.  For the ownerId fields, the service user will always loose to a
		// regular users.  To accomplish this, the ownerId will be updated if the new owner is not a
		// service user or if the current owner Id to keep is a service user.
		if (performUpdate
			&& (fieldName != 'OwnerId'
				|| !IdUtils.isServiceUser((Id)fieldValue)
				|| IdUtils.isServiceUser((Id)fieldHistory.value)
				)
			)
		{
			fieldHistory.objectId = objectId;
			fieldHistory.modifiedDate = modifiedDate;
			fieldHistory.value = fieldValue;
		}
	}

	/**
	 * Acts as a wrapper of a Account/Contact/Lead History record.
	 */
	public class FieldHistory {

		public String fieldName { get; set; }
		public Id objectId { get; set; }
		public Datetime modifiedDate { get; set; }
		public Object value { get; set; }

		public FieldHistory(String fieldName, Id objectId, Datetime modifiedDate, Object value) {
			this.fieldName = fieldName;
			this.objectId = objectId;
			this.modifiedDate = modifiedDate;
			this.value = value;
		}

	}

	public class MergeLimitException extends Exception {
	}

}