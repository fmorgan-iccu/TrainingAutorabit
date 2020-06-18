trigger OpportunityBeforeTrigger on Opportunity (before insert, before update) {

    if (Trigger.isInsert) {
        // If a person or member number is identified on the account (e.g. via data load) and the
        // account is not specified, look the account up via the person number first or the member
        // number if person number is not provided.
        Map<String, Id> personNumberAccounts = new Map<String, Id>();
        Map<String, Id> memberNumberAccounts = new Map<String, Id>();
        for (Opportunity newOpp : Trigger.new) {
            String personNumber = newOpp.person_number__c;
            String personPrefix = personNumber != null ? personNumber.left(1) : null;

            // If the person number begins with an O (oh), then it is actually an org number and
            // is not allowed.
            /* NOTE:  Enabling this error causes problems with the AccountContactRole being
                created for records in the same batch that don't have an "O" prefix.  It seems
                that the error opportunity ID is being assigned as the related opportunity?!?
                this needs more research if we want to use it.
            if (personPrefix == 'O' || personPrefix == 'o') {
                newOpp.addError('Organizations can\'t be specified in the person number');
                newOpp.person_number__c = null;
            } */

            // If the person number starts with a P or p, remove this prefix.
            if (personPrefix == 'P' || personPrefix == 'p') {
                personNumber = personNumber.right(personNumber.length() - 1);
                newOpp.person_number__c = personNumber;
            }

            if (newOpp.AccountId == null && newOpp.person_number__c != null) {
                personNumberAccounts.put(newOpp.person_number__c, null);
            }
            if (newOpp.AccountId == null && newOpp.person_number__c == null && newOpp.memberNumber__c != null) {
                memberNumberAccounts.put(newOpp.memberNumber__c, null);
            }
        }
        if (personNumberAccounts.size() > 0 || memberNumberAccounts.size() > 0) {
            Map<Id, Account> accountMap = new Map<Id, Account>();
            Set<String> personNumbers = personNumberAccounts.keySet();
            Set<String> memberNumbers = memberNumberAccounts.keySet();
            List<Account> accounts = [
                SELECT id,
                    memberNumber__c,
                    personNumber__c
                FROM Account
                WHERE memberNumber__c IN :memberNumbers OR
                    personNumber__c IN :personNumbers
            ];
            for (Account a : accounts) {
                accountMap.put(a.id, a);
                if (a.personNumber__c != null) {
                    personNumberAccounts.put(a.personNumber__c, a.id);
                }
                if (a.memberNumber__c != null) {
                    memberNumberAccounts.put(a.memberNumber__c, a.id);
                }
            }
            for (Opportunity newOpp : Trigger.new) {
                if (newOpp.AccountId == null) {
                    if (newOpp.person_number__c != null) {
                        newOpp.accountId = personNumberAccounts.get(newOpp.person_number__c);
                    } else if (newOpp.memberNumber__c != null) {
                        newOpp.accountId = memberNumberAccounts.get(newOpp.memberNumber__c);
                    }

                    // Ensure that the person number is set so that the contact roles can be created
                    // in the after trigger.  This is done here to simplify the after trigger.
                    if (newOpp.accountId != null && newOpp.person_number__c == null && accountMap.containsKey(newOpp.accountId)) {
                        Account a = accountMap.get(newOpp.accountId);
                        newOpp.person_number__c = a.personNumber__c;
                    }
                }
            }
        }
    }

    if (Trigger.isInsert || Trigger.isUpdate) {
        // Default several of the opportunity fields if they don't have a value.  This can only
        // occur if the object is crated by Apex or a data load.
        Id defaultOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_PROSPECT).getRecordTypeId();
        Date defaultCloseDate = System.now().date().addDays(OpportunityConstants.DEFAULT_DAYS_TO_CLOSE);
        for (Opportunity newOpp : Trigger.new) {
            if (newOpp.recordTypeId == null) {
                newOpp.recordTypeId = defaultOppRecordTypeId;
            }
            if (newOpp.stageName == null) {
                newOpp.stageName = OpportunityConstants.STAGE_NEW;
            }
            if (newOpp.closeDate == null) {
                newOpp.closeDate = defaultCloseDate;
            }
        }

        // Set the stage of an opportunity that is currently in the New stage to Assigned if the
        // owner is being changed from the Batch user to anyone else.
        for (Opportunity newOpp : Trigger.new) {
            if (newOpp.stageName == OpportunityConstants.STAGE_NEW && newOpp.avokaJob__c != null) {
                Boolean insertAssignedToEmployee = Trigger.isInsert && newOpp.ownerId != IdUtils.BATCH_USER_ID;
                Boolean updateAssignedToEmployee = Trigger.isUpdate && Trigger.oldMap.get(newOpp.id).ownerId == IdUtils.BATCH_USER_ID && newOpp.ownerId != IdUtils.BATCH_USER_ID;
                if (insertAssignedToEmployee || updateAssignedToEmployee) {
                    newOpp.stageName = OpportunityConstants.STAGE_ASSIGNED;
                }
            }
        }
    }

}