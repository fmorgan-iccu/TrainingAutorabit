@isTest
private class LeadTriggerTest {
    
    @isTest
    private static void happyPath() {
        Test.startTest();
        
        Lead mccReferralLead = getTestLead('MCC Referral', 'John', 'Smith');
        
        Test.stopTest();
        
        Id mccReferralRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('MCC Referral').getRecordTypeId();
        
        mccReferralLead = [
			SELECT Id,
				RecordTypeId,
				Referral__c
			FROM Lead
			WHERE Id = :mccReferralLead.Id
		];
        System.assertEquals(mccReferralLead.recordTypeId, mccReferralRecTypeId);
        System.assertEquals(mccReferralLead.Referral__c, true);
    }
    
    @isTest
    private static void testMRABatchDate() {
        Lead indirectLendingLead = getTestLead('IL Onboarding', 'Jane', 'Smith');
        Lead indirectLendingLead2 = getTestLead('IL Onboarding', 'Jane', 'Smith');
        
        List<Lead> leads = new List<Lead>{ indirectLendingLead, indirectLendingLead2 };
        
        Test.startTest();
        
        update leads;
 
        Test.stopTest();
        
        indirectLendingLead = [
			SELECT Id,
				mraBatchDate__c
			FROM Lead
			WHERE Id = :indirectLendingLead.Id
		];
        System.assertEquals(indirectLendingLead.mraBatchDate__c, System.today());
    }
    
    private static Lead getTestLead(String leadSource, String firstName, String lastName) {
        Lead testLead = new Lead (
            FirstName = firstName,
            LastName = lastName,
            Company = 'Acme Inc.',
            LeadSource = leadSource
        );
        
        insert testLead;
        return testLead;
    }
    
}