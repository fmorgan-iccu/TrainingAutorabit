public class ProductOfferingsController {
    @TestVisible
	private static INetworkFactory networkFactory;

	@AuraEnabled
	public static Map<String, Object> getProductOfferings(String contactId) {
        if (ProductOfferingsController.networkFactory == null) {
            ProductOfferingsController.networkFactory = new ConcreteNetworkProvider();
        }
        
        if (contactId == null) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('error', 'There was a problem getting contacts. Contact ID was null.');
            
            return response;
        }

        INetworkFactory networkFactory = ProductOfferingsController.networkFactory;
        IProductOfferingDataProvider offeringDataProvider = networkFactory.getProductOfferingDataProvider();
        
        try {
			Contact contact = [
                SELECT 
	            	Birthdate,  	
	            	MemberNumber__c, 	
	            	Email,	
	            	FirstName, 
	                LastName, 
	                MailingStreet, 
	            	MailingCity, 
	            	MailingState, 
	            	MailingPostalCode,
	            	MobilePhone, 	
	            	TaxID__c, 
	            	PersonNumber__c,             	 
	            	Phone	
	            FROM Contact 
	            WHERE ID = :contactId
	        	LIMIT 1
            ];
            List<ProductOfferingGroup> groups = offeringDataProvider.getProductOfferings(new SFPerson(contact));
        
            List<Map<String, Object>> mappedGroups = new List<Map<String, Object>>();
            
            for (ProductOfferingGroup offeringGroup : groups) {
                List<Map<String, Object>> mappedOfferings = new List<Map<String, Object>>();
                
                for (ProductOffering offering : offeringGroup.getOfferings()) {                
                    Map<String, Object> mappedOffering = new Map<String, Object>();
                    mappedOffering.put('title', offering.getTitle());
                    mappedOffering.put('agentScript', offering.getAgentScript());
                    mappedOffering.put('icon', offering.getIconName());
                    mappedOffering.put('color', offering.getColor());
                    mappedOffering.put('weight', offering.getWeight());
    
                    mappedOfferings.add(mappedOffering);
                }
    
                Map<String, Object> mappedGroup = new Map<String, Object>();
                mappedGroup.put('title', offeringGroup.getTitle());
                mappedGroup.put('offerings', mappedOfferings);
    
                mappedGroups.add(mappedGroup);
            }
    
            Map<String, Object> response = new Map<String, Object>();
            response.put('offeringGroups', mappedGroups);
            response.put('error', null);
            
            return response;
        } catch (UnauthenticatedException e) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('offeringGroups', null);
            response.put('error', 'Please log into DNA.');
            
            return response;
        } catch (Exception e) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('offeringGroups', null);
            response.put('error', 'There was a problem getting product offerings. Please try again later. ' + String.valueOf(e));

            return response;
        }
	}
	
	@AuraEnabled
	public static List<MarketingPromotion__c> getMarketingPromotions(String contactId) {
        Date today = Date.today();
        
        Contact contact = [
                SELECT 
	            	CreditScore__c
	            FROM Contact 
	            WHERE ID = :contactId
	        	LIMIT 1
            ];
        
        integer creditScore = 0;

        if (contact.CreditScore__c != null) {
            creditScore = (integer)contact.CreditScore__c;
        }

        MarketingPromotion__c[] promotions = [
            SELECT 
                ColorPicker__c,  	
                EndDate__c,
                Name,
                StartDate__c
            FROM MarketingPromotion__c 
            WHERE 
            	StartDate__c <= :today AND 
            	EndDate__c >= :today AND
            	MinimumCreditScore__c <= :creditScore AND
            	MaximumCreditScore__c >= :creditScore
            ORDER BY EndDate__c ASC
        ];

		return promotions;
	}
}