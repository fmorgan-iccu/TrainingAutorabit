/**
 * Aura controller for getting Account/Organization information.
 */
public class AccountController {
    @TestVisible
    private static SFCacheUpdater updater;
    private static INetworkFactory networkFactory;
    private Account accountObject;
    private static IEmailService emailService;


    /**
     * constructor
     * @param accountId the salesforce contact id, usually the current contact on the contact page
     */
    public AccountController(Id accountId) {
        this.accountObject = AccountController.queryAccount(accountId);
    }

    @AuraEnabled
    public Account getAccountObject() {
        return this.accountObject;
    }

    /**
     * getContact static helper method to instanciate instance and get contact in lightning component controller
     * @param contactId the salesforce contact id, usually the current contact on the contact page
     */
    @AuraEnabled
    public static Account getAccountObject(String accountId) {
        AccountController controller = new AccountController(accountId);
        return controller.getAccountObject();
    }

    @TestVisible
    private static Account queryAccount(Id accountId) {
        if (accountId == null) {
            return null;
        }

        Account a = SFOrganization.getInstance(accountId).getAccount();
        return a;
    }

    /**
     * Fetches an account.
     * @param accountId The unique ID of the account.
     * @return The account that corresponds to the identifier.
     */
    @AuraEnabled
    public static Map<String, Object> getAccount(Id accountId) {
        Map<String, Object> response = new Map<String, Object>();

        if (accountId == null) {
            response.put('error', '`accountId` is required.');
            return response;
        }

        SFOrganization sfOrganization = SFOrganization.getInstance(accountId);
        IOrganization o = sfOrganization.getRedactedOrganization();
        response.put('account', o.getAccount());

        // Determine the users permissions.
        Boolean canViewFullTaxId = AccessUtils.checkPermission('Full_Tax_ID');
        response.put('canViewFullTaxId', canViewFullTaxId);

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getAccountTotals(String accountId) {
        Map<String, Object> response = new Map<String, Object>();

        IOrganization org = SFOrganization.getInstance(accountId);

        if (AccountController.networkFactory == null) {
            AccountController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = AccountController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

        AccountSummary accountsummary = null;
        try {
            accountsummary = accountProvider.getAccountOwnerTotals(org);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
            System.debug('Not authenticated: ' + e);
        } catch (Exception e) {
            response.put('error', 'An unexpected error occured: ' + e);
        }

        Double loanTotalOwner = accountsummary.getLoanTotalOwner();
        Double depositTotalOwner = accountsummary.getDepositTotalOwner();

        response.put('LoanTotalOwner', loanTotalOwner);
        response.put('LoanTotalOwnerFormatted', NumberUtils.formatCurrency(loanTotalOwner));
        response.put('DepositTotalOwner', depositTotalOwner);
        response.put('DepositTotalOwnerFormatted', NumberUtils.formatCurrency(depositTotalOwner));


        return response;
    }

    @AuraEnabled
    public static Map<String, Object> refreshContent(String orgNumber) {
        Map<String, Object> response = new Map<String, Object>();

        if (orgNumber == null || orgNumber.length() == 0) {
            response.put('error', 'The org number of this record is missing. This may occur if this is a new org and their DNA data has not been synced with SalesForce. Any DNA related functionality of this account will be reduced until it is updated with a DNA org number.');
            return response;
        }

        if (AccountController.updater == null) {
            AccountController.updater = new SFCacheUpdater();
        }

        try {
            SFCacheUpdater updater = AccountController.updater;
            IOrganization orc = updater.fetchOrganization(orgNumber);
            Account account = [
                SELECT
                    account.Email__c,
                    account.Name,
                    account.OrganizationNumber__c,
                    account.OrganizationTaxID__c,
                    account.OrganizationType__c,
                    account.MemberNumber__c,
                    account.Phone,
                    account.BillingAddress,
                    account.MembershipDate__c
                FROM Account
                WHERE OrganizationNumber__c = :orgNumber
                LIMIT 1
            ];

            Account updatedAccount = updater.persistOrganization(orc, account);
            response.put('account', updatedAccount);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log in to DNA.');
        } catch (Exception e) {
            response.put('error', e);
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateAccount(
        Id accountId,
        String mailingStreet1,
        String mailingStreet2,
        String mailingCity,
        String mailingCountry,
        String mailingPostalCode,
        String mailingState,
        String phone,
        Boolean verifiedIdentityPhone)
    {
        Map<String, Object> response = new Map<String, Object>();

        // Validate the format of the various fields to be certain that they conform with the
        // minimum requirements (e.g. PO Box format, phone length, required fields, etc.)!
        if (String.isBlank(mailingStreet1)
            || AddressUtils.isPostOfficeBox(mailingStreet1)
            || String.isBlank(mailingCity)
            || String.isBlank(mailingCountry)
            || String.isBlank(mailingPostalCode)
            || String.isBlank(mailingState)
            || String.isBlank(phone))
        {
            response.put('error', 'One or more fields are invalid.');
            return response;
        }

        // Retreive the account on file to ensure all required fields are available for update,
        // saving the original email for the notification message.
        Account originalAccount = AccountController.queryAccount(accountId);

        // Assign the new values into the Account for updating into DNA and Salesforce.
        Account updatedAccount = originalAccount.clone();
        updatedAccount.id = originalAccount.id;
        updatedAccount.BillingStreet = mailingStreet1 + (!String.isBlank(mailingStreet2) ? '\n' + mailingStreet2 : '');
        updatedAccount.BillingCity = mailingCity;
        updatedAccount.BillingCountry = mailingCountry;
        updatedAccount.BillingPostalCode = mailingPostalCode;
        updatedAccount.BillingState = mailingState;
        updatedAccount.Phone = PhoneUtils.format(phone);
        updatedAccount.VerifiedIdentityPhone__c = verifiedIdentityPhone;

        // Instantiate an IAccount from the Salesforce data, and assemble the various address objects needed
        // to update the account.
        SFOrganization organization = new SFOrganization(updatedAccount);
        List<IAddress> addresses = new List<IAddress> {
            new SFAddress(updatedAccount, AddressType.PRIMARY)
        };
        List<PhoneNumber> phoneNumbers = new List<PhoneNumber> {
            new PhoneNumber(PhoneUtils.formatDigitsOnly(updatedAccount.Phone), PhoneNumberType.BUSINESS)
        };

        // Call the core system to update the members information.
        ConcreteNetworkProvider networkFactory = new ConcreteNetworkProvider();
        IOrganizationDataProvider organizationDataProvider = networkFactory.getOrganizationDataProvider();
        try {
            IOrganization org = organizationDataProvider.updateOrganizationContactInfo(organization, addresses, phoneNumbers);
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Please log into DNA and try again.');
            response.put('requiredLogins', 'DNA');
            return response;
        } catch (Exception e) {
            response.put('error', 'Unable to update the organizations\'s information in DNA.  Try again or make the change directly in DNA. ' + e.getMessage());
            return response;
        }

        // Send an email notification to the current address on file if the email field is changing.
        // If an error occurs, make sure to notify the team member that the member hasn't been
        // notified. Only send the email notification if original account has an email address.
        Boolean addressChanged =
            updatedAccount.BillingStreet != originalAccount.BillingStreet ||
            updatedAccount.BillingCity != originalAccount.BillingCity ||
            updatedAccount.BillingCountry != originalAccount.BillingCountry ||
            updatedAccount.BillingPostalCode != originalAccount.BillingPostalCode ||
            updatedAccount.BillingState != originalAccount.BillingState;
        Boolean phoneChanged = updatedAccount.phone != originalAccount.phone;
        if (!String.isBlank(originalAccount.Email__c) && (addressChanged || phoneChanged)) {
            try {
                // Determine what fields have changed and concatenate them.
                String updatedFields = '';
                if (addressChanged) {
                    updatedFields += 'primary address, ';
                }
                if (phoneChanged) {
                    updatedFields += 'home phone, ';
                }

                // Remove the trailing comma.
                updatedFields = updatedFields.replaceFirst(', $', '');

                // If the string still contains a comma, replace the last one with a natural
                // language "and".
                updatedFields = updatedFields.replaceFirst(',(?=[^,]+$)', ' and');

                // Create the variables structure.
                Map<String, String> vars = new Map<String, String>();
                vars.put('var.updatedFields', updatedFields);

                // Create the email message to be sent from a template.
                Id noReplyId = EmailUtils.getOrgWideEmailAddress('noreply@iccu.com');
                EmailMessage message = new EmailMessage();
                message.fromOrgWideEmailId = noReplyId;
                message.setPrimaryRecipient(originalAccount);
                message.loadFromTemplate(EmailUtils.TEMPLATE_ICCU_CONTACT_INFORMATION_UPDATE, vars);

                // Send the email message.
                if (AccountController.emailService == null) {
                    AccountController.emailService = new SFEmailService();
                }
                EmailMessageResult messageResult = AccountController.emailService.sendEmail(message);
                if (!messageResult.isSuccess) {
                    String errorMessage = 'Unable to send an e-mail update notification. ' + messageResult.errorMessage;
                    response.put('error', errorMessage);
                    return response;
                }
            } catch (Exception e) {
                String logMessage = 'Unable to send an e-mail update notification. ' + e.getMessage() + ' -- ' + e.getStackTraceString();
                LogUtils.log(LoggingLevel.INFO, 'AccountController', originalAccount.id, logMessage);

                response.put('error', 'Unable to send an e-mail update notification.');
                return response;
            }
        }

        // Update the contact in Salesforce after updating DNA.
        try {
            update updatedAccount;
            updatedAccount = AccountController.queryAccount(accountId);
            response.put('account', updatedAccount);
        } catch (Exception e) {
            response.put('error', 'Unable to upate the organizations\'s information in Salesforce. ' + e.getMessage());
            return response;
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> resetVerifiedIdentityPhone(Id accountId) {
        Map<String, Object> response = new Map<String, Object>();
        Boolean success = true;

        if (String.isBlank(accountId)) {
            response.put('error', '`accountId` is required.');
            success = false;
        }

        try {
            Account a = new Account(id=accountId, VerifiedIdentityPhone__c=false);
            update a;
        } catch (Exception e) {
            response.put('error', e.getMessage());
            success = false;
        }

        response.put('success', success);
        return response;
    }
}