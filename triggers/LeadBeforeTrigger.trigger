trigger LeadBeforeTrigger on Lead (before insert, before update) {

    // Identify the name of the active user profile
    Id userProfileId = UserInfo.getProfileId();
    String profileName = AccessUtils.getProfileName(userProfileId);
    
    if (Trigger.isInsert) {
        
        // Identify the ID of the MCC Referral lead record type.
        Id mccReferralRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('MCC Referral').getRecordTypeId();
        
        for (Lead l : Trigger.new) {
            // Ensure that the new MCC referral records are set to the correct record type for proper sharing and that the
            // referral check box is set.
            if (l.leadSource == 'MCC Referral') {
           		l.RecordTypeId = mccReferralRecTypeId;
				if (l.ReferralType__c == 'Cross Sell') {
           			l.Referral__c = true;
				}
            }
        }
    }
    
    // Only do this if the leads are being updated in bulk.  This identifies that it is in a data load.
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.new.size() > 1) {
    	for (Lead l : Trigger.new) {
            // Ensure that the MRA Batch Date is set when the lead is created by the correct user.
            if (l.leadSource == 'IL Onboarding' &&
                	(profileName == 'MRA User' || profileName == 'MRA Manager' || profileName == 'System Administrator'))
            {
                l.mraBatchDate__c = System.today();
            }
        }
    }
    
}