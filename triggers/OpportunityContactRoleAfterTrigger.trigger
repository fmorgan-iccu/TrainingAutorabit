trigger OpportunityContactRoleAfterTrigger on OpportunityContactRole (before insert, before update) {

    if (Trigger.isInsert || Trigger.isUpdate) {
        // Set contact information from the primary contact role associated with the opportunity.
        // This is populated for automations like the "Non Responsive Member".
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, OpportunityContactRole> roleMap = new Map<Id, OpportunityContactRole>();
        for (OpportunityContactRole contactRole : Trigger.new) {
            if (contactRole.isPrimary) {
                contactMap.put(contactRole.contactId, null);
                roleMap.put(contactRole.opportunityId, contactRole);
            }
        }
        Set<Id> contactIds = contactMap.keySet();
        if (contactIds.size() > 0) {
            List<Contact> contacts = [
                SELECT id,
                    businessPhone__c,
                    creditScore__c,
                    email,
                    firstName,
                    homePhone,
                    mobilePhone,
                    phone
                FROM Contact
                WHERE id IN :contactIds
            ];
            for (Contact c : contacts) {
                contactMap.put(c.id, c);
            }
        }
        Set<Id> opportunityIds = roleMap.keySet();
        if (opportunityIds.size() > 0) {
            List<Opportunity> opportunities = [
                SELECT id,
                    business_phone__c,
                    contact_first_name__c,
                    credit_score__c,
                    email__c,
                    home_phone__c,
                    mobile__c,
                    phone__c
                FROM Opportunity
                WHERE id IN :opportunityIds
            ];
            if (opportunities.size() > 0) {
                List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
                for (Opportunity o : opportunities) {
                    Opportunity opp = new Opportunity(id = o.id);
                    OpportunityContactRole contactRole = roleMap.get(o.id);
                    Contact c = contactMap.get(contactRole.contactId);
                    if (c != null && contactRole != null) {
                        Boolean needsUpdate = false;
                        if (String.isBlank(o.business_phone__c) && !String.isBlank(c.businessPhone__c)) {
                            opp.business_phone__c = c.businessPhone__c;
                            needsUpdate = true;
                        }
                        if (o.credit_score__c == null && c.creditScore__c != null) {
                            opp.credit_score__c = c.creditScore__c;
                            needsUpdate = true;
                        }
                        if (String.isBlank(o.email__c) && !String.isBlank(c.email)) {
                            opp.email__c = c.email;
                            needsUpdate = true;
                        }
                        if (String.isBlank(o.contact_first_name__c) && !String.isBlank(c.firstName)) {
                            opp.contact_first_name__c = c.firstName;
                            needsUpdate = true;
                        }
                        if (String.isBlank(o.home_phone__c) && !String.isBlank(c.homePhone)) {
                            opp.home_phone__c = c.homePhone;
                            needsUpdate = true;
                        }
                        if (String.isBlank(o.mobile__c) && !String.isBlank(c.mobilePhone)) {
                            opp.mobile__c = c.mobilePhone;
                            needsUpdate = true;
                        }
                        if (String.isBlank(o.phone__c) && !String.isBlank(c.phone)) {
                            opp.phone__c = c.phone;
                            needsUpdate = true;
                        }

                        if (needsUpdate) {
                            opportunitiesToUpdate.add(opp);
                        }
                    }
                }
                if (opportunitiesToUpdate.size() > 0) {
                    update opportunitiesToUpdate;
                }
            }
        }
    }

}