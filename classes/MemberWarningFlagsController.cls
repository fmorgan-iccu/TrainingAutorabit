public class MemberWarningFlagsController {
    @TestVisible
	private static INetworkFactory networkFactory;
    
	@AuraEnabled
    public static Map<String, Object> fetchMemberWarningFlags(String contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', 'Contact was null.');

            return response;
        }
        
        if (MemberWarningFlagsController.networkFactory == null) {
            MemberWarningFlagsController.networkFactory = new ConcreteNetworkProvider();
        }

        Set<String> acceptableCodes = new Set<String>();
        acceptableCodes.add('BADD');	// Bad Address
        acceptableCodes.add('BRST');	// Branch Stop
        acceptableCodes.add('CHOF');	// Charged Off Account
        acceptableCodes.add('DECM');	// Deceased Member
        acceptableCodes.add('FRDA');	// Fraud
        acceptableCodes.add('LEVY');	// Garnishment / Tax Levy
        acceptableCodes.add('NEGM');	// Negative Member
        acceptableCodes.add('NEW');		// New Account
        acceptableCodes.add('NOTE');	// See Account Note *only until the branches have access to the CRM, branches will place notes in this field and I would only know to look for it with this flag
        acceptableCodes.add('PHON');	// Update Phone Number
        acceptableCodes.add('PMTO');	// Payments Only
        acceptableCodes.add('PNOT');	// See Person Note *only until the branches have access to the CRM, branches will place notes in this field and I would only know to look for it with this flag
        acceptableCodes.add('TTL');		// Total Lockout
        acceptableCodes.add('SAST');	// Stop Assist Member Assistance

        try {
            Contact contact = [
	            SELECT
	            	PersonNumber__c	
	            FROM Contact 
	            WHERE ID = :contactId
	        	LIMIT 1
	        ];
            
            SFPerson person = new SFPerson(contact);
            
        	IPersonDataProvider personProvider = MemberWarningFlagsController.networkFactory.getPersonDataProvider();
            IPersonAccountDataProvider accountProvider = MemberWarningFlagsController.networkFactory.getPersonAccountDataProvider();

            List<IPersonWarningFlag> personflags = personProvider.getPersonWarningFlags(person.getPersonNumber());
            List<IPersonWarningFlag> accountFlags = accountProvider.getAllWarningFlags(person);

            List<IPersonWarningFlag> flags = new List<IPersonWarningFlag>();
            flags.addAll(personFlags);
            flags.addAll(accountFlags);

            List<Map<String, Object>> responseFlags = new List<Map<String, Object>>();

            for (IPersonWarningFlag flag : flags) {
                if (!acceptableCodes.contains(flag.getFlagCode())) { // Only want to include flags that are in the set above.
                    continue;
                }

                Map<String, Object> responseFlag = new Map<String, Object>();

                responseFlag.put('effectiveDate', flag.getEffectiveDate());
                responseFlag.put('flagCode', flag.getFlagCode());
                responseFlag.put('flagCodeDescription', flag.getFlagCodeDescription());
                responseFlag.put('inactiveDate', flag.getInactiveDate());
                responseFlag.put('noteClassCode', flag.getNoteClassCode());
                responseFlag.put('noteClassCodeDescription', flag.getNoteClassCodeDescription());
                responseFlag.put('noteSubClassCode', flag.getNoteSubClassCode());
                responseFlag.put('noteSubClassCodeDescription', flag.getNoteSubClassCodeDescription());
                responseFlag.put('noteText', flag.getNoteText());

                responseFlags.add(responseFlag);
            }

            response.put('warningFlags', responseFlags);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
        } catch (Exception e) {
            response.put('error', 'There was an unexpected error. ' + e);
        }
        
        return response;
    }
}