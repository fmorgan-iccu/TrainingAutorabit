@IsTest
private with sharing class OpportunityContactRoleTriggerTest {

    @IsTest
    static void testPrimaryContactInfoOnOppty() {
        Contact c = getTestContact();

        Opportunity opp = getTestOpportunity(UserInfo.getUserId(), c.accountId, 'New', c.personNumber__c, null);
        insert opp;

        TriggerUtils.resetExecuted();

        Test.startTest();

        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            contactId = c.id,
            opportunityId = opp.id
        );
        oppContactRole.isPrimary = true;
        insert oppContactRole;

        Test.stopTest();

        // Retrieve the opportunity to ensure the stage has been updated properly.
        opp = [
            SELECT id,
                contact_first_name__c,
                email__c,
                stageName
            FROM Opportunity
            WHERE id = :opp.id
        ];

        System.assertEquals('Allan', opp.contact_first_name__c);
        System.assertEquals('test@iccu.com', opp.email__c);
    }

    private static Contact getTestContact() {
        String personNumber = '127472';
        String memberNumber = '28343';
        Account a = new Account();
        a.name = 'P' + personNumber;
        a.memberNumber__c = memberNumber;
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
            TaxId__c = '599-99-1126',
            PersonNumber__c = personNumber
        );

        insert c;
        return c;
    }

    private static Opportunity getTestOpportunity(Id ownerId, Id accountId, String stageName, String personNumber, String memberNumber) {
        Opportunity o = new Opportunity();
        o.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT).getRecordTypeId();
        o.ownerId = ownerId;
        o.accountId = accountId;
        o.name = 'Test Opp';
        o.type = 'Loan';
        o.stageName = stageName;
        o.closeDate = System.today();
        o.product__c = 'Fixed-Rate Platinum Visa';
        o.person_number__c = personNumber;
        o.memberNumber__c = memberNumber;
        return o;
    }

}