trigger AccountBeforeTrigger on Account (before insert, before update) {

    if (Trigger.isInsert || Trigger.isUpdate) {
        // Ensure that the dna_person_org_number__c is assigned if it is not set and a numeric
        // person/org number is present.
        for (Account newAccount : Trigger.new) {
            if (newAccount.dna_person_org_number__c == null && newAccount.personNumber__c != null) {
                newAccount.dna_person_org_number__c = 'P' + newAccount.personNumber__c;
            } else if (newAccount.dna_person_org_number__c == null && newAccount.organizationNumber__c != null) {
                newAccount.dna_person_org_number__c = 'O' + newAccount.organizationNumber__c;
            }
        }
    }

}