@isTest
private class OpportunityTriggerTest {

    @isTest
    static void testOpportunityAssigned() {
        Contact c = getTestDnaContact();

        TriggerUtils.resetExecuted();

        Test.startTest();

        // Ensure that the stage is set for a new opportunity directly assigned to a user.
        Opportunity insertOpp = getTestOpportunity(UserInfo.getUserId(), c.accountId, 'New', c.personNumber__c, 'R64582K');
        insert insertOpp;

        // Ensure that the stage is not changed for an opportunity owned by the Batch user.
        Opportunity updateOpp = getTestOpportunity(IdUtils.BATCH_USER_ID, c.accountId, 'New', c.personNumber__c, 'R64582I');
        insert updateOpp;

        // Create a contact role for the update opportunity to validate that the email is copied to
        // the opportunity.
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            contactId = c.id,
            opportunityId = updateOpp.id
        );
        oppContactRole.isPrimary = true;
        insert oppContactRole;

        // A single SOQL query is used inside the test context for validation purposes because this
        // is a very simple non-batch test and is not expected to come close to governance limits.
        updateOpp = [
            SELECT id,
                stageName
            FROM Opportunity
            WHERE id = :updateOpp.id
        ];
        String newBatchOppStage = updateOpp.stageName;

        // Change the owner from batch to the current user.
        updateOpp.ownerId = UserInfo.getUserId();
        update updateOpp;

        Test.stopTest();

        // Verify that the new batch opportunity is still at the New stage.
        System.assertEquals('New', newBatchOppStage);

        // Verify that the inserted opportunity was set to assigned.
        insertOpp = [
            SELECT id,
                stageName
            FROM Opportunity
            WHERE id = :insertOpp.id
        ];

        System.assertEquals('Assigned', insertOpp.stageName);

        // Retrieve the opportunity to ensure the stage has been updated properly.
        updateOpp = [
            SELECT id,
                email__c,
                stageName
            FROM Opportunity
            WHERE id = :updateOpp.id
        ];

        System.assertEquals('Assigned', updateOpp.stageName);
        System.assertEquals('test@iccu.com', updateOpp.email__c);
    }

    @isTest
    static void testOpportunityClose() {
        Contact c = getTestDnaContact();

        List<Opportunity> testOpps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            testOpps.add(getTestOpportunity(IdUtils.BATCH_USER_ID, c.accountId, 'New', c.personNumber__c));
        }
        insert testOpps;

        Group oaoQueue = [
            SELECT id
            FROM Group
            WHERE type = 'Queue'
                AND developerName = 'FSCOnlineAccountOpening'
        ];
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 200; i++) {
            testCases.add(getTestCase(oaoQueue.id, c.id, 'Open', testOpps[i].id));
        }
        insert testCases;

        testOpps = [SELECT id, stageName FROM Opportunity];

        TriggerUtils.resetExecuted();

        Test.startTest();

        // Simulate changing a full batch of opportunity stage to a closed in a single request.
        for (Integer i = 0; i < 200; i++) {
            testOpps[i].stageName = 'FSC - Complete';
        }
        update testOpps;

        Test.stopTest();

        // Verify that all of the cases are closed properly.
        testCases = [SELECT id FROM Case WHERE isClosed = true];
        System.assert(testCases.size() == 200, 'Not all associated cases were closed.');
    }

    @IsTest
    static void testPersonNumberCreate() {
        Contact c1 = getTestDnaContact('28343', '127472', '599-99-1126');
        Contact c2 = getTestDnaContact('27100', '123444', '599-99-1127');

        // Create 200 test opportunities with now assigned account but using a person number.
        // This will cause the account and opportunity contact role to be assigned based on the
        // person number.
        Id ownerId = UserInfo.getUserId();
        List<Opportunity> newOpps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            if (i < 100) {
                newOpps.add(getTestOpportunity(ownerId, null, 'New', c1.personNumber__c));
            } else {
                newOpps.add(getTestOpportunity(ownerId, null, 'New', c2.personNumber__c));
            }
        }

        Test.startTest();

        insert newOpps;

        Test.stopTest();

        List<Opportunity> opportunities = [
            SELECT id,
                accountId,
                person_number__c,
                (SELECT 
                    contactId,
                    isPrimary,
                    opportunityId,
                    role
                    FROM OpportunityContactRoles)
            FROM Opportunity
        ];
        System.assertEquals(200, opportunities.size());
        for (Opportunity o : opportunities) {
            List<OpportunityContactRole> roles = o.OpportunityContactRoles;
            System.assertEquals(1, roles.size());
            System.assertEquals(o.accountId == c1.accountId ? c1.id : c2.id, roles[0].contactId);
            System.assert(roles[0].isPrimary);
            System.assert(roles[0].role == null);
        }
    }

    private static Contact getTestDnaContact() {
        return getTestDnaContact('28343', '127472', '599-99-1126');
    }

    private static Contact getTestDnaContact(String memberNumber, String personNumber, String taxId) {
        Account a = new Account();
        a.name = 'P' + personNumber;
        a.personNumber__c = personNumber;
        insert a;

        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
        Contact c = new Contact (
            RecordTypeId = contactRecordTypeId,
            AccountId = a.id,
            Birthdate = Date.valueOf('1976-08-11'),
            MemberNumber__c = memberNumber,
            Email = 'test@iccu.com',
            FirstName = 'Allan',
            LastName = 'Gliege',
            Phone = '(310) 427-5902',
            TaxId__c = taxId,
            PersonNumber__c = personNumber
        );
        
        insert c;
        return c;
    }

    private static Case getTestCase(Id ownerId, Id contactId, String status, Id opportunityId) {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_ONLINE_ACCOUNT_OPENING).getRecordTypeId();
        Case c = new Case();
        c.ownerId = ownerId;
        c.contactId = contactId;
        c.status = status;
        c.opportunity__c = opportunityId;
        c.recordTypeId = caseRecordTypeId;
        return c;
    }

    private static Opportunity getTestOpportunity(Id ownerId, Id accountId, String stageName, String personNumber) {
        return getTestOpportunity(ownerId, accountId, stageName, personNumber, null);
    }

    private static Opportunity getTestOpportunity(Id ownerId, Id accountId, String stageName, String personNumber, String avokaJob) {
        Opportunity o = new Opportunity();
        o.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT).getRecordTypeId();
        o.ownerId = ownerId;
        o.accountId = accountId;
        o.name = 'Test Opp';
        o.type = 'Loan';
        o.stageName = stageName;
        o.closeDate = System.today();
        o.product__c = 'Fixed-Rate Platinum Visa';
        o.productMajorCode__c = AOConstants.PRODUCT_MAJOR_TYPE_CRIF;
        o.productMinorCode__c = '119';
        o.person_number__c = personNumber;
        o.avokaJob__c = avokaJob;
        return o;
    }

}