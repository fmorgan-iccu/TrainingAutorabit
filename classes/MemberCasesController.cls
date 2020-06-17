public class MemberCasesController {
    private static Integer DEFAULT_DAYS_AGO = 90;
    
	@AuraEnabled
    public static List<Case> getOpenMemberCases(String contactId) {
        if (contactId == null) {
            throw new IllegalArgumentException('Contact ID cannot be null.');
        }

        Case[] cases = [
            SELECT
                CaseNumber,
                CreatedDate,
                ClosedDate,
                Description,
                OwnerId,
                Priority,
                Status,
                Subject,
            	MCCClass__c,
            	MCCSubclass__c,
            	MemberSentiment__c,
            	Owner.Name,
            	RecordTypeId
            FROM Case
            WHERE 
            	ContactId = :contactId AND 
            	isClosed = false
            ORDER BY 
            	CreatedDate DESC
        ];

        return cases;
    }
    
    public static List<Case> getClosedMemberCases(String contactId) {
        return getClosedMemberCases(contactId, DEFAULT_DAYS_AGO);
    }
    
    @AuraEnabled
    public static List<Case> getClosedMemberCases(String contactId, Integer numberOfDaysAgo) {
        if (contactId == null) {
            throw new IllegalArgumentException('Contact ID cannot be null.');
        }
        
        // Fun Aura bug I found.  APEX doessn't correctly deserialize Integers, so we have to reparse the integer.
        // https://blog.texei.com/lightning-components-auraenabled-method-parameters-whats-working-and-what-s-not-83c351356104
        numberOfDaysAgo = Integer.valueOf(numberOfDaysAgo);
        
        if (numberOfDaysAgo == null || numberOfDaysAgo <= 0) {
            numberOfDaysAgo = DEFAULT_DAYS_AGO;
        }

        DateTime daysAgo = System.now().addDays(-numberOfDaysAgo);
        
        Case[] cases = [
            SELECT
            	CaseNumber,
                CreatedDate,
                ClosedDate,
                Description,
                OwnerId,
                Priority,
                Status,
                Subject,
	            MCCClass__c,
            	MCCSubclass__c,
            	MemberSentiment__c,
	            Owner.Name,
            	RecordTypeId
            FROM Case
            WHERE 
            	ContactId = :contactId AND 
            	isClosed = true AND
            	ClosedDate >= :daysAgo
            ORDER BY 
            	CreatedDate DESC
        ];

        return cases;
    }
    
    @AuraEnabled
    public static Map<String, Object> getContactOpportunities(String contactId) {
        return ContactOpportunityController.getContactOpportunities(contactId);
    }
}