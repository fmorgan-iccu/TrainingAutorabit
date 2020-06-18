trigger ContactBeforeTrigger on Contact (before delete, before insert, before update) {

    if (Trigger.isInsert || Trigger.isUpdate) {
        // Lookup the record type name to store it for duplicate rule purposes.
        Map<Id, String> recordTypeNames = new Map<Id, String>();
        for (Contact c : Trigger.new) {
            if (!recordTypeNames.containsKey(c.recordTypeId)) {
                String recordTypeName = Schema.SObjectType.Contact.getRecordTypeInfosById().get(c.recordTypeId).getname();
                recordTypeNames.put(c.recordTypeId, recordTypeName);
            }
            c.recordTypeName__c = recordTypeNames.get(c.recordTypeId);
        }

        // Determine if the user has at least one eAgreement on file.  If so, the contact will be considered to have
        // enrolled for eBranch.
        for (Contact c : Trigger.new) {
            Boolean onlineBankingEnrolled = false;
            if (!String.isEmpty(c.onlineAgreementIds__c)) {
                try {
                    List<String> eAgreementIds = (List<String>)JSON.deserialize(c.onlineAgreementIds__c, List<String>.class);
                    onlineBankingEnrolled = eAgreementIds.size() > 0;
                } catch (System.JSONException e) {
                    // Ignore badly formatted JSON
                }
            }
            c.onlineBankingEnrolled__c = onlineBankingEnrolled;
        }

        // Determine if a default branch is specified.
        for (Contact c : Trigger.new) {
            String defaultBranchName = null;
            if (!String.isEmpty(c.defaultBranch__c)) {
                try {
                    Map<String, Object> defaultBranch = (Map<String, Object>)JSON.deserializeUntyped(c.defaultBranch__c);
                    if (defaultBranch.containsKey('OrgName')) {
                        defaultBranchName = (String)defaultBranch.get('OrgName');
                    }
                } catch (System.JSONException e) {
                    // Ignore badly formatted JSON
                }
            }
            c.defaultBranchName__c = defaultBranchName;
        }
    }
    
}