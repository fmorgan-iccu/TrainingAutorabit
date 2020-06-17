/**
 * Aura controller for getting Account/Organization information.
 */
public class AccountController {
    @TestVisible
    private static SFCacheUpdater updater;

    /**
     * Fetches an account.
     * @param accountId The unique ID of the account.
     * @return The account that corresponds to the identifier.
     */
    @AuraEnabled
    public static Account getAccount(String accountId) {
        if (accountId == null) {
            return null;
        }

        Account account = [
                SELECT
                    account.Email__c,
                    account.Name,
                    account.OrganizationNumber__c,
                    account.OrganizationTaxID__c,
                    account.OrganizationType__c,
                    account.MemberNumber__c,
                    account.Phone,
                    account.ShippingStreet,
                    account.ShippingCity,
                    account.ShippingState,
                    account.ShippingPostalCode,
                    account.ShippingCountry
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];

        return account;
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
                    account.MemberNumber__c,
                    account.Name,
                    account.OrganizationNumber__c,
                    account.OrganizationTaxID__c,
                    account.OrganizationType__c,
                    account.Phone,
                    account.ShippingStreet,
                    account.ShippingCity,
                    account.ShippingState,
                    account.ShippingPostalCode,
                    account.ShippingCountry
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
}