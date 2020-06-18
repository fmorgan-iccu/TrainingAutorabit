global class SandBoxRefresh implements SandboxPostCopy  {

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

}