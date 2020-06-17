public class MemberReferralController {

	@AuraEnabled
    public static Map<String, Object> fetchFormData() {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            User[] users = [
                SELECT 
                	FirstName,
                    Id, 
                    LastName,
                	Name,
                    UserRole.Name
                FROM User
                WHERE UserRole.Name = 'FSC User'
                ORDER BY LastName, FirstName
            ];
            
            // Get the lead record type Id
            Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypeConstants.LEAD_DEFAULT).getRecordTypeId();
            
            // Determine the Id of the referral type field to use on the form.
            Id referralTypeFieldId = IdUtils.getLeadRecordFieldIdByName('ReferralType__c');

            response.put('orgId', UserInfo.getOrganizationId());
            response.put('fscUsers', users);
            response.put('currentUserName', UserInfo.getName());
            response.put('orgHost', URL.getSalesforceBaseUrl().getHost());
            response.put('userFirstName', UserInfo.getFirstName());
            response.put('leadRecordTypeId', leadRecordTypeId);
            response.put('referralTypeFieldId', referralTypeFieldId);
        } catch (Exception e) {
            response.put('error', 'Error getting information ' + e);
        }

        return response;
    }
}