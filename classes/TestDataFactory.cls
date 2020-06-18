@IsTest
public class TestDataFactory {

    public static Account createAccount(Boolean isDna, Boolean doInsert) {
        List<Account> accounts = TestDataFactory.createAccounts(1, true, doInsert);
        return accounts[0];
    }

    public static List<Account> createAccounts(Integer numAccounts, Boolean isDna, Boolean doInsert) {
        String recordTypeName = isDna ? RecordTypeConstants.ACCOUNT_DNA : RecordTypeConstants.ACCOUNT_DEFAULT;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<Account> accts = new List<Account>();
        for(Integer i = 0; i < numAccounts; i++) {
            String orgNumber = '' + 100 + i;
            String phone = '(234) 234-' + String.valueOf(i).leftPad(4, '0');
            Account a = new Account(
                industry = 'Energy',
                name = 'O' + orgNumber + ' - Test Company ' + i,
                organizationNumber__c = orgNumber,
                phone = phone,
                recordTypeId = recordTypeId,
                BillingCity = 'Pocatello',
                BillingCountry = 'USA',
                BillingPostalCode = '83204',
                BillingState = 'ID',
                BillingStreet = '123 Main Street'
            );
            accts.add(a);
        }
        if (doInsert) {
            insert accts;
        }
        return accts;
    }

    public static List<Account> createAccountsWithContacts(Integer numAccounts, Integer numContactsPerAcct, Boolean isDnaAccountContact) {
        Integer numContacts = numAccounts * numContactsPerAcct;
        List<Contact> contacts = TestDataFactory.createContacts(numContacts, isDnaAccountContact, false);
        List<Account> accts = TestDataFactory.createAccounts(numAccounts, isDnaAccountContact, false);

        // If there is only one DNA contact per account, treat them as "person accounts".
        if (numContactsPerAcct == 1 && isDnaAccountContact) {
            for (Integer i = 0; i < numAccounts; i++) {
                Account a = accts[i];
                Contact c = contacts[i];
                a.name = 'P' + c.personNumber__c;
                a.memberNumber__c = c.memberNumber__c;
                a.org_number__c = null;
                a.personNumber__c = c.personNumber__c;
                a.phone = c.phone;
            }
        }
        insert accts;

        // Link the contacts to an account
        for (Integer i = 0; i < numContacts; i++) {
            Integer accountIndex = i / numContacts;
            contacts[i].accountId = accts[accountIndex].id;
        }
        insert contacts;

        return accts;
    }

    public static List<Account> createAccountsWithOpps(Integer numAccounts, Integer numOppsPerAcct, Boolean isDnaAccount, String oppRecordTypeName, String stageName) {
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecordTypeName).getRecordTypeId();

        // Create the accounts and contacts to link to the opportunity.
        List<Account> accts = createAccounts(numAccounts, isDnaAccount, true);

        // Create the opportunities with and link them to the accounts.
        List<Opportunity> opps = new List<Opportunity>();
        for (Account a : accts) {
            List<Opportunity> acctOpps = TestDataFactory.createOpportunities(numOppsPerAcct, recordTypeId, oppRecordTypeName, stageName, a, false);
            opps.addAll(acctOpps);
        }
        insert opps;
        return accts;
    }

    public static Contact createContact(Boolean isDna, Boolean doInsert) {
        List<Contact> contacts = TestDataFactory.createContacts(1, true, doInsert);
        return contacts[0];
    }

    public static List<Contact> createContacts(Integer numContacts, Boolean isDna, Boolean doInsert) {
        String recordTypeName = isDna ? RecordTypeConstants.CONTACT_DNA : RecordTypeConstants.CONTACT_DEFAULT;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Date now = Date.today();
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numContacts; i++) {
            String memberNumber = '' + 100 + i;
            String personNumber = '' + 1000 + i;
            String taxId = '666-18-' + String.valueOf(i).leftPad(4, '0');
            String phone = '(123) 123-' + String.valueOf(i).leftPad(4, '0');
            String mailingStreet = i + ' Main Street';
            String idNumber = 'PA1111' + String.valueOf(i).leftPad(4, '0');
            Date idIssueDate = now.addDays(-90);
            Date idExpireDate = idIssueDate.addYears(8);
            Contact c = new Contact(
                Birthdate = Date.newInstance(1976, 8, Math.mod(i, 30)),
                Email = 'test' + i + '@iccu.com',
                FirstName = 'Test' + i,
                LastName = 'Contact',
                MemberNumber__c = memberNumber,
                PersonNumber__c = personNumber,
                Phone = phone,
                RecordTypeId = recordTypeId,
                TaxID__c = taxId,
                IdentificationType__c = '1',
                IdentificationExpirationDate__c = idExpireDate,
                IdentificationIssueDate__c = idIssueDate,
                IdentificationIssueState__c = 'ID',
                IdentificationNumber__c = idNumber,
                MailingStreet = mailingStreet,
                MailingCity = 'Pocatello',
                MailingCountry = 'USA',
                MailingPostalCode = '83204',
                MailingState = 'ID'
            );
            contacts.add(c);
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static List<Contact> createContactsWithAccounts(Integer numAccounts, Integer numContactsPerAcct, Boolean isDnaAccountContact, Boolean doInsert) {
        Integer numContacts = numAccounts * numContactsPerAcct;
        List<Contact> contacts = TestDataFactory.createContacts(numContacts, isDnaAccountContact, false);
        List<Account> accts = TestDataFactory.createAccounts(numAccounts, isDnaAccountContact, false);

        // If there is only one DNA contact per account, create the Accounts as "person accounts".
        if (numContactsPerAcct == 1 && isDnaAccountContact) {
            for (Integer i = 0; i < numAccounts; i++) {
                Account a = accts[i];
                Contact c = contacts[i];
                a.name = 'P' + c.personNumber__c;
                a.memberNumber__c = c.memberNumber__c;
                a.personNumber__c = c.personNumber__c;
            }
        }
        insert accts;

        // Link each contact to an account.
        for (Integer i = 0; i < numContacts; i++) {
            Integer accountIndex = i / numContacts;
            contacts[i].accountId = accts[accountIndex].id;
        }
        if (doInsert) {
            insert contacts;
        }

        return contacts;
    }

    public static Case createCase(Id caseRecordTypeId, Id contactId, Id accountId, String status, Boolean doInsert) {
        List<Case> cases = createCases(1, caseRecordTypeId, contactId, accountId, status, doInsert);
        return cases[0];
    }

    public static List<Case> createCases(Integer numCases, Id caseRecordTypeId, Id contactId, Id accountId, String status, Boolean doInsert) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < numCases; i++) {
            Case k = new Case(
                AccountId = accountId,
                ContactId = contactId,
                Description = 'Test Case',
                Priority = 'High',
                Status = status
            );
            cases.add(k);
        }
        if (doInsert) {
            insert cases;
        }

        return cases;
    }

    public static MemberInsight__c createMemberInsight(Id contactId, Boolean doInsert) {
        MemberInsight__c insight = new MemberInsight__c(
            Name = 'Test Insight',
            ExtraDetails__c = 'some extra details',
            InsightType__c = 'Medical',
            ContactID__c = contactId
        );
        if (doInsert) {
            insert insight;
        }

        return insight;
    }

    public static Opportunity createOpportunity(Id recordTypeId, String oppRecordTypeName, String stageName, Account a, Boolean doInsert) {
        List<Opportunity> opps = createOpportunities(1, recordTypeId, oppRecordTypeName, stageName, a, doInsert);
        return opps[0];
    }

    public static List<Opportunity> createOpportunities(Integer numOpps, Id recordTypeId, String oppRecordTypeName, String stageName, Account a, Boolean doInsert) {
        // Determine appropriate values based on record type.
        String oppType = oppRecordTypeName == RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT ? 'Deposits' : 'Loan';
        String productName = oppRecordTypeName == RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT ? 'Share Savings' : 'Fixed-Rate Platinum Visa';

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < numOpps; i++) {
            Opportunity o = new Opportunity(
                accountId = a.id,
                closeDate = System.today().addMonths(1),
                name = a.name + ' - ' + productName + ' #' + i,
                recordTypeId = recordTypeId,
                product__c = productName,
                stageName = stageName,
                type = oppType
            );
            opps.add(o);
        }
        if (doInsert) {
            insert opps;
        }

        return opps;
    }

    public static List<Opportunity> createOppsWithAccounts(
        Integer numAccounts,
        Integer numOppsPerAcct,
        String oppRecordTypeName,
        String stageName,
        Boolean isDnaAccount,
        Boolean doInsert)
    {
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecordTypeName).getRecordTypeId();

        // Create the accounts to link to the opportunity.
        List<Account> accts = TestDataFactory.createAccounts(numAccounts, isDnaAccount, true);

        // Create the opportunities and link them to the accounts.
        List<Opportunity> opps = new List<Opportunity>();
        for (Account a : accts) {
            List<Opportunity> acctOpps = TestDataFactory.createOpportunities(numOppsPerAcct, recordTypeId, oppRecordTypeName, stageName, a, false);
            opps.addAll(acctOpps);
        }
        if (doInsert) {
            insert opps;
        }
        return opps;
    }

    public static List<Opportunity> createOppsWithAccountsContactsAndPrimaryRole(
        Integer numAccounts,
        Integer numOppsPerAcct,
        String oppRecordTypeName,
        String stageName,
        Boolean isDnaAccount)
    {
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecordTypeName).getRecordTypeId();

        // Create the accounts to link to the opportunity.
        List<Account> accts = TestDataFactory.createAccounts(numAccounts, isDnaAccount, true);

        // Create the contacts
        List<Contact> contacts = TestDataFactory.createContacts(numAccounts, isDnaAccount, false);
        for (Integer i = 0; i < numAccounts; i++) {
            contacts[i].accountId = accts[i].id;
        }
        insert contacts;

        // Create the opportunities and link them to the accounts.
        List<Opportunity> opps = new List<Opportunity>();
        for (Account a : accts) {
            List<Opportunity> acctOpps = createOpportunities(numOppsPerAcct, recordTypeId, oppRecordTypeName, stageName, a, false);
            opps.addAll(acctOpps);
        }
        insert opps;

        // Create the primary opportunity contact role.
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
        for (Integer i = 0; i < numAccounts; i++) {
            for (Integer j = 0; j < numOppsPerAcct; j++) {
                OpportunityContactRole r = new OpportunityContactRole();
                r.ContactId = contacts[i].id;
                r.OpportunityId = opps[(i * numOppsPerAcct) + j].id;
                r.role = AOConstants.OPPORTUNITY_ROLE_PRIMARY_BORROWER;
                r.IsPrimary = true;
                oppContactRoles.add(r);
            }
        }
        insert oppContactRoles;

        return opps;
    }

    public static List<Opportunity> createOppsWithPrimaryRoles(Integer numOpps, Id recordTypeId, String oppRecordTypeName, String stageName, Account a, Contact c) {
        List<Opportunity> opps = TestDataFactory.createOpportunities(numOpps, recordTypeId, oppRecordTypeName, stageName, a, true);

        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
        for (Opportunity o : opps) {
            OpportunityContactRole r = new OpportunityContactRole();
            r.ContactId = c.id;
            r.OpportunityId = o.id;
            r.role = AOConstants.OPPORTUNITY_ROLE_PRIMARY_BORROWER;
            r.IsPrimary = true;
            oppContactRoles.add(r);
        }
        insert oppContactRoles;

        return opps;
    }

    public static List<Lead> createLeads(Integer numLeads, Boolean doInsert) {
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < numLeads; i++) {
            Lead l = new Lead(
                company='Lead Company ' + i,
                email='lead' + i + '@unknown.domain.com',
                firstName='Test' + i,
                lastName='Lead'
            );
            leads.add(l);
        }
        if (doInsert) {
            insert leads;
        }
        return leads;
    }

    public static User createUser(String roleName, String profileName, List<String> permissionSetNames) {
        // Determine the role to assign to the user.
        List<UserRole> roles = [
            SELECT Id
            FROM UserRole
            WHERE Name = :roleName
        ];
        Id roleId = roles[0].id;

        // Determine the profile to assign to the user.
        List<Profile> profiles = [
            SELECT Id
            FROM Profile
            WHERE Name = :profileName
        ];
        Id profileId = profiles[0].id;

        // Create the user.
        User u = new User(
            alias='testuser',
            cashBox__c = '9999',
            email='testuser@iccu.com.invalid',
            emailEncodingKey='ISO-8859-1',
            extension='9999',
            firstName='Test',
            isActive=true,
            lastName='User',
            languageLocaleKey='en_US',
            localeSidKey='en_US',
            networkNodeName__c = 'SomeNetworkNode',
            profileId=profileId,
            timeZoneSidKey='America/Denver',
            title='Test Title',
            username='testuser@iccu.com'
        );
        insert u;

        // Assign permission sets.
        if (permissionSetNames != null && permissionSetNames.size() > 0) {
            List<PermissionSet> permissionSets = [
                SELECT Id
                FROM PermissionSet
                WHERE Name IN :permissionSetNames
            ];
            List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : permissionSets) {
                PermissionSetAssignment a = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.id);
                assignments.add(a);
            }
            insert assignments;
        }

        return u;
    }

}