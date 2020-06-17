/*
 *	Controller for displaying Quick Links 
 */
public class QuickLinksController {

	@AuraEnabled   
    public static QuickLink__c[] getQuickLinks() {
        QuickLink__c[] quicklinks = [
            SELECT 
            	URL__c,  	
	            Name,
        	    Order__c	
            FROM QuickLink__c
            ORDER BY Order__c
        ];
        
        return quicklinks;
    }
}