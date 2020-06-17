global class SandBoxRefresh implements SandboxPostCopy  {
    
    public static final List<String> FORM_NAMES = new List<String> {
        'accountsandfunding',
        'AT4SF-canvas',
        'depositproducts',
        'disclosures',
        'loanappdetails',
        'loanproducts',
        'transact-sdk',
        'triage',
        'youth'
    };
    public static String DELIVERY_PROCESSOR = 'AvokaDeliveryProcessor';
        
    global void runApexClass(SandboxContext context) {
        // Retrieve required system identifiers
        Id sysAdminId = [SELECT id FROM Profile WHERE Name = 'System Administrator'][0].id;
        Id orgId = UserInfo.getOrganizationId();
        
        // ProdQA and QA are two orgs that developers shouldn't have access to.  In these environments,
        // only enable the primary administratos (Matt and Dana).  For all other administrators, activate them
        // in all sandboxes.
        List<User> adminsToActivate = null;
        if (Test.isRunningTest() && orgid != IdUtils.PRODQA_ORG_ID && orgid != IdUtils.PRODUCTION_ORG_ID){
            adminsToActivate = [
                SELECT id,
                    email,
                    isActive
                FROM User
                WHERE IsActive = false
                    AND ProfileId = :sysAdminId ];
        } else {
            adminsToActivate = [
                SELECT id,
                    email,
                    isActive
                FROM User
                WHERE IsActive = false
                    AND ProfileId = :sysAdminId 
                    AND (email like 'dbarnett@iccu.com%' OR email like 'mmcewen@iccu.com%')];
        }
        activateAdministrators(adminsToActivate);
        
        // Create Delivery Processing records for the supported Avoka flows.
        createAvokaDeliveryProcessorRecords();
    }
    private void activateAdministrators(List<User> admins) {
        // Correct the email addresses for the administrators.
        for (User admin : admins) {
            admin.email = getCorrectedEmail(admin.email);
        }
        update admins;
        
        // Activate the users
        for (User admin : admins) {
            admin.isActive = true;
        }
        update admins;
        
        // Fire a password reset and send the reset email
        for (User admin : admins) {
            System.resetPassword(admin.Id, true);  
        }      
        
    }

    private String getCorrectedEmail(String email) {
        // Old sandbox refresh email masking
        string newEmail = email.replace('@example.com', '').replace('=', '@');

        // New (Spring 19) sandbox refresh email masking
        newEmail= newEmail.replace('.invalid', '');        
        return newEmail;
    }
    
    // This function is run in the future because a MIXED_DML_OPERATION will be thrown.
    // This is because Salesforce will not allow a modification to a setup object to
    // occur with a non-setup object in a single execution process.
    @future
    private static void createAvokaDeliveryProcessorRecords() {
        // TODO:  Need to check if these values exist first.
        List<avoka__Transact_Delivery_Processor__c> processors = new List<avoka__Transact_Delivery_Processor__c>();
        for (String formName : FORM_NAMES) {
            processors.add(
                new avoka__Transact_Delivery_Processor__c(Name = formName,
                                                          avoka__Saved_Processor_Class__c = DELIVERY_PROCESSOR,
                                                          avoka__Completed_Processor_Class__c = DELIVERY_PROCESSOR,
                                                          avoka__Abandoned_Processor_Class__c = DELIVERY_PROCESSOR)
            );
        }
        insert processors;
    }
      
}