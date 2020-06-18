/**
 * Class for retrieving opportunities from a contact
 */
public class ContactOpportunityController {
	
    @AuraEnabled
    public static Map<String, Object> getContactOpportunities(String contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', 'Contact ID was null!');
            return response;
        }

        try {
            Opportunity[] opportunities = [
                SELECT
                    Amount,
                    CloseDate,
                    Id,
                    Name,
                    Owner.Name,
                	Owner.Id,
                    StageName,
                	(
                        SELECT 
                        	ContactId,
                        	IsPrimary,
                        	Role
                        FROM OpportunityContactRoles 
                    )
                FROM Opportunity
	            WHERE
                	IsClosed = false
                AND
                	Id IN (
                        SELECT opportunityId
                        FROM OpportunityContactRole
                        WHERE contactId = :contactId
                    )
            ];

            response.put('opportunities', opportunities);
        } catch (QueryException e) {
            response.put('opportunities', new List<Opportunity>());
            System.debug('>>>> Problem getting contact opportunities: ' + e);
        } catch(Exception e) {
            String error = 'There was a problem getting opportunities for the Contact: ' + e.getMessage();
            response.put('error', error);
        }

        return response;
    }
}