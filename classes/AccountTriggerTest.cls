@IsTest
public with sharing class AccountTriggerTest {

    @IsTest
    static void testAccountMerge() {
        Id dnaAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DNA).getRecordTypeId();
        Id defaultAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DEFAULT).getRecordTypeId();

        // Batch testing is only done for a single merge because this is the expected batch size.
        Account masterAccount = getTestAccount('Loser', IdUtils.BATCH_USER_ID, defaultAccountRecordTypeId);
        Account dupeAccount = getTestAccount('Winner', IdUtils.BATCH_USER_ID, dnaAccountRecordTypeId);

        // Insert the master and dupe acounts outside of the test since these both are created prior
        // to the batch contact data load.
        insert masterAccount;
        insert dupeAccount;

        // Ensure that the trigger code is allowed to fire again.
        TriggerUtils.resetExecuted();

        Test.startTest();

        dupeAccount.mergeIntoId__c = masterAccount.id;
        update dupeAccount;

        Test.stopTest();

        // Only verify that there is one account.  The actual merge processing is tested in the
        // merge utility tests.
        List<Account> accounts = [
            SELECT id
            FROM Account
        ];
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    static void testDnaPersonOrgNumber() {
        Id dnaAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DNA).getRecordTypeId();

        Account personAccount = getTestAccount('Test Person', IdUtils.BATCH_USER_ID, dnaAccountRecordTypeId);
        personAccount.personNumber__c = '12345';

        Account orgAccount = getTestAccount('Test Org', IdUtils.BATCH_USER_ID, dnaAccountRecordTypeId);
        orgAccount.organizationNumber__c = '67890';

        List<Account> accounts = new List<Account> { personAccount, orgAccount };

        Test.startTest();

        insert accounts;

        Test.stopTest();

        accounts = [
            SELECT id,
                dna_person_org_number__c,
                organizationNumber__c,
                personNumber__c
            FROM Account
        ];

        System.assertEquals(2, accounts.size());
        for (Account a : accounts) {
            if (a.personNumber__c != null) {
                System.assertEquals('P12345', a.dna_person_org_number__c);
            }
            if (a.organizationNumber__c != null) {
                System.assertEquals('O67890', a.dna_person_org_number__c);
            }
        }
    }

    private static Account getTestAccount(String name, Id ownerId, Id recordTypeId) {
        Account a = new Account();
        a.name = name;
        if (ownerId != null) { a.ownerId = ownerId; }
        a.recordTypeId = recordTypeId;
        return a;
    }

}