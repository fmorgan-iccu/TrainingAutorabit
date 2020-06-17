trigger OpportunityAfterTrigger on Opportunity (after insert, after update) {

    if (Trigger.isInsert) {
        if (!TriggerUtils.checkExecuted('oppSetAccountContactFromPNum')){
            // To speed up the creation of opportunities when the person number is present, an
            // opportunity contact role will be automatically created.  This is particularly
            // useful for data loads that need to creat the links to the correct contact; For
            // example, the MRA department loads opportunities for existing members for various
            // reasons (e.g. IL Onboarding, Guaranteed Offers, etc.)
            Map<String, Id> personIds = new Map<String, Id>();
            Map<Id, String> oppPersons = new Map<Id, String>(); // Only one person number per opportunity.
            for (Opportunity newOpp : Trigger.new) {
                if (newOpp.person_number__c != null) {
                    personIds.put(newOpp.person_number__c, null);
                    oppPersons.put(newOpp.id, newOpp.person_number__c);
                }
            }
            if (personIds.size() > 0) {
                Id dnaRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
                List<Contact> contacts = [
                    SELECT id,
                        personNumber__c
                    FROM Contact
                    WHERE personNumber__c IN :personIds.keySet()
                        AND recordTypeId = :dnaRecordTypeId
                ];
                for (Contact c : contacts) {
                    personIds.put(c.personNumber__c, c.id);
                }
                List<OpportunityContactRole> newRoles = new List<OpportunityContactRole>();
                for (Id oppId : oppPersons.keySet()) {
                    String personNumber = oppPersons.get(oppId);
                    Id contactId = personIds.get(personNumber);
                    if (contactId != null) {
                        OpportunityContactRole newRole = new OpportunityContactRole(
                            contactId=contactId,
                            isPrimary=true,
                            opportunityId=oppId
                        );
                        newRoles.add(newRole);
                    }
                }
                if (newRoles.size()> 0) {
                    insert newRoles;
                }
            }
        }
    }

    if (Trigger.isInsert || Trigger.isUpdate) {
        if (!TriggerUtils.checkExecuted('UpdateOppAssociatedCaseStatus')) {
            // If an opportunity is being closed, determine if there are any associated cases open
            // and close them.  This process avoids recursion by checking statuses that will not be
            // the same once the update occurs.

            // First determine if any of the opportunities being inserted or updated were set to the
            // a closed stage.
            List<Id> oppsToCheck = new List<Id>();
            for (Opportunity newOpp : Trigger.newMap.values()) {
                if ((Trigger.isInsert && newOpp.isClosed)
                    || (Trigger.isUpdate && (newOpp.isClosed && !Trigger.oldMap.get(newOpp.id).isClosed)))
                {
                    oppsToCheck.add(newOpp.id);
                }
            }

            // If any closed opportunities were found, identify any cases that are associated with
            // these opportunities that are still open and close them using a single DML operation.
            if (oppsToCheck.size() > 0) {
                List<Case> casesToClose = [
                    SELECT id,
                        status
                    FROM Case
                    WHERE opportunity__c IN :oppsToCheck
                        AND isClosed = false
                ];
                if (casesToClose.size() > 0) {
                    for (Case c : casesToClose) {
                        c.status = 'Closed';
                    }
                    update casesToClose;
                }
            }
        }
    }

}