public with sharing class AOXmlAvokaDataController {
	
	// The page that calls this will need to use URL.getSalesforceBaseUrl().getHost() to get the domain to use.
	
	// Get the XML Avoka data to be rendered on the page. 
	public String getXmlAvokaData() {
		Id caseId = null;
		try {
			caseId = apexpages.currentpage().getparameters().get('caseId');
		} catch (Exception e) {
			// If the value wasn't a valid Id, ignore this exception.
		}
		
		if (caseId != null) {
			List<Case> cases = [SELECT Id, AvokaData__c FROM CASE WHERE Id = :caseId];
			if (cases.size() == 1) {
				return cases[0].AvokaData__c;
			}
		}
		
		return null;
	}
	
}