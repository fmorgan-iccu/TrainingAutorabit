public class MemberAccountsController {
    @TestVisible
    private static INetworkFactory networkFactory;
    
    @TestVisible
    private static Set<String> validAccountProfiles;
    
    @AuraEnabled
    public static Map<String, Object> getMemberAccountsList(String contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', '`contactId` was null.');
            return response;
        }

        Contact contact = ContactController.getContact(contactId);

        boolean canViewEmployeeAccounts = MemberAccountsController.canCurrentUserViewEmployeeAccounts();
        
        if (contact.IsEmployee__c == true && canViewEmployeeAccounts == false) {
            response.put('error', 'Unable to view team member accounts.');
            return response;
        }

        try {
            List<IAccount> accounts = MemberAccountsController.getMemberAccounts(contactId);
            List<Map<String, Object>> responseAccounts = new List<Map<String, Object>>();
            Map<String, Contact> contactCache = MemberAccountsController.buildAccountContactCache(accounts);
            Map<String, Account> accountCache = MemberAccountsController.buildAccountAccountCache(accounts);

            for (IAccount account : accounts) {
                Map<String, Object> responseAccount = MemberAccountsController.mapAccountToMap(account, contactCache, accountCache);
                responseAccounts.add(responseAccount);
            }

            response.put('accounts', responseAccounts);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
        } catch (Exception e) {
            response.put('error', 'An unexpected error occured: ' + e);
        }

        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> getMemberAccountsGrouped(String contactId) {
        Map<String, Object> response = new Map<String, Object>();
        
        if (contactId == null) {
            response.put('error', 'Contact was null.');

            return response;
        }
        
        boolean canViewEmployeeAccounts = MemberAccountsController.canCurrentUserViewEmployeeAccounts();
        
        Contact contact = ContactController.getContact(contactId);

        if (contact.IsEmployee__c == true && canViewEmployeeAccounts == false) {
            response.put('error', 'Unable to view team member accounts.');
            return response;
        }

        if (MemberAccountsController.networkFactory == null) {
            MemberAccountsController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();
        IAuthenticationManager authManager = accountProvider.getAuthenticationManager();
        
        boolean isAuthenticated = authManager.isUserAuthenticated();
        
        if (!isAuthenticated) {
            response.put('error', 'Please log into DNA.');
            return response;
        }

        SFPerson person = new SFPerson(contact);

        try {
            List<AccountGroup> groups = accountProvider.getAccountsGrouped(person);
            List<Object> mappedGroups = MemberAccountsController.mapAccountGroupToGroupMap(groups);

            response.put('accounts', mappedGroups);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
            System.debug('Not authenticated: ' + e);
        } catch (Exception e) {
            response.put('error', 'An unexpected error occured: ' + e);
        }

        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> getOrganizationAccountsGrouped(String accountId) {
        Map<String, Object> response = new Map<String, Object>();
        
        if (accountId == null) {
            response.put('error', 'Account was null.');

            return response;
        }
        
        if (MemberAccountsController.networkFactory == null) {
            MemberAccountsController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();
        IAuthenticationManager authManager = accountProvider.getAuthenticationManager();
        
        boolean isAuthenticated = authManager.isUserAuthenticated();
        
        if (!isAuthenticated) {
            response.put('error', 'Please log into DNA.');
            return response;
        }

        Account account = [
                SELECT 
                    account.Email__c,
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
                WHERE Id = :accountId
                LIMIT 1
            ];
        
        SFOrganization orc = new SFOrganization(account);

        try {
            List<AccountGroup> groups = accountProvider.getAccountsGrouped(orc);
            List<Object> mappedGroups = MemberAccountsController.mapAccountGroupToGroupMap(groups);

            response.put('accounts', mappedGroups);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
            System.debug('Not authenticated: ' + e);
        } catch (Exception e) {
            response.put('error', 'An unexpected error occured: ' + e);
        }

        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> getContact(String contactId) {
        Contact contact = ContactController.getContact(contactId);

        Map<String, Object> response = new  Map<String, Object>();
        response.put('contact', contact);

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getAccountTransactions(Map<String, Object> accountMap, DateTime startDate, DateTime endDate) {
        Map<String, Object> response = new Map<String, Object>();

        if (accountMap == null) {
            response.put('error', '`accountMap` was null.');
            return response;
        }

        if (accountMap.get('accountNumber') == null) {
            response.put('error', '`accountNumber` is null.');
            return response;
        }

        if (MemberAccountsController.networkFactory == null) {
            MemberAccountsController.networkFactory = new ConcreteNetworkProvider();
        }

        if (endDate == null) {
            endDate = System.now();
        }

        if (startDate == null) {
            startDate = endDate.addDays(-31);
        }

        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

        double availableBalance = (double)accountMap.get('availableBalance');
        double currentBalance = (double)accountMap.get('currentBalance');
        String name = (String)accountMap.get('name');
        String majorType = (String)accountMap.get('majorType');
        String minorType = (String)accountMap.get('minorType');
        String nickName = (String)accountMap.get('nickName');
        String accountNumber = (String)accountMap.get('accountNumber');

        IAccount account = new SFAccount(availableBalance, currentBalance, name, majorType, minorType, nickName, accountNumber);

        try {
            List<IAccountTransaction> transactions = accountProvider.getTransactions(account.getAccountNumber(), startDate, endDate);
            List<Map<String, Object>> rawTransactions = new List<Map<String, Object>>();
            response.put('startDate', startDate);
            response.put('endDate', endDate);

            for (IAccountTransaction trans : transactions) {
                Map<String, Object> rawTrans = new Map<String, Object>();

                rawTrans.put('amount', trans.getAmount());
                rawTrans.put('balance', trans.getBalance());
                rawTrans.put('checkNumber', trans.getCheckNumber());
                rawTrans.put('description', trans.getDescription());
                rawTrans.put('effectiveDate', String.valueOf(trans.getEffectiveDate()));
                rawTrans.put('externalDescription', trans.getExternalDescription());
                rawTrans.put('internalDescription', trans.getInternalDescription());
                rawTrans.put('isCredit', trans.getIsCredit());
                rawTrans.put('postDate', String.valueOf(trans.getPostDate()));
                rawTrans.put('originatingPerson', trans.getOriginatingPerson());
                rawTrans.put('status', trans.getStatus());
                rawTrans.put('transactionNumber', trans.getTransactionNumber());
                rawTrans.put('typeCode', trans.getTypeCode());

                rawTransactions.add(rawTrans);
            }

            response.put('transactions', rawTransactions);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log in to continue.');
        } catch (Exception e) {
            response.put('error', 'An unexpected error occured: ' + e);
        }

        return response; 
    }

    /**
     * The heavy lifting of going to service to get accounts.
     * @param contactId the SF Contact Id of the member
     * @return A list of IAccount instances
     */
    public static List<IAccount> getMemberAccounts(String contactId) {
        if (MemberAccountsController.networkFactory == null) {
            MemberAccountsController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

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
        
        SFPerson person = new SFPerson(contact);

        Map<String, Object> response = new Map<String, Object>();

        List<IAccount> accounts = accountProvider.getAccounts(person);
        return accounts;
    }

    /**
     * Reusable code to map an IAccount to a Map collection type
     * @param account The IAccount type to convert
     * @return A mapped Map <rimshot>
     */
    private static Map<String, Object> mapAccountToMap(IAccount account, Map<String, Contact> contactCache, Map<String, Account> accountCache) {
        List<Map<String, Object>> owners = new List<Map<String, Object>>();
        for (IJointAccountOwner owner : account.getJointOwners()) {
            Map<String, Object> responseOwner = MemberAccountsController.mapJointOwnerToMap(owner, contactCache, accountCache);
            owners.add(responseOwner);
        }

        Map<String, Object> responseAccount = new Map<String, Object>();
        responseAccount.put('accountNumber', account.getAccountNumber());
        responseAccount.put('availableBalance', account.getAvailableBalance());
        responseAccount.put('branchName', account.getBranchName());
        responseAccount.put('currentBalance', account.getCurrentBalance());
        responseAccount.put('interestRate', account.getInterestRate());
        responseAccount.put('jointOwners', owners);
        responseAccount.put('majorType', account.getMajorType());
        responseAccount.put('minorType', account.getMinorType());
        responseAccount.put('name', account.getName());
        responseAccount.put('nextPaymentAmount', account.getNextPaymentAmount());
        responseAccount.put('nextPaymentDate', account.getNextPaymentDate());
        responseAccount.put('nickName', account.getNickName());
        responseAccount.put('status', account.getStatus());
        
        return responseAccount;
    }

    /*
     * Reusable method to create a Map from an IJointAccountOwner
     * @param owner The owner to Map
     * @param contactCache Cache of SF contacts
     * @return Map representing an IJointAccountOwner 
     */
    private static Map<String, Object> mapJointOwnerToMap(IJointAccountOwner owner, Map<String, Contact> contactCache, Map<String, Account> accountCache) {
        String entityNumber = owner.getEntityNumber();
        String entityType = owner.getEntityType();
        
        Map<String, Object> responseOwner = new Map<String, Object>();
        responseOwner.put('canTransact', owner.getCanTransact());
        responseOwner.put('entityNumber', entityNumber);
        responseOwner.put('entityType', entityType);
        responseOwner.put('fullName', owner.getFullName());
        responseOwner.put('isOrg', owner.isOrg());
        responseOwner.put('isPerson', owner.isPerson());
        responseOwner.put('roleCode', owner.getRoleCode());
        responseOwner.put('roleDescription', owner.getRoleDescription());
        
        if (owner.isPerson()) {
            Contact contact = contactCache.get(entityNumber);
            
            if (contact != null) { // Sanity check
                responseOwner.put('contactId', contact.Id);
            }
        } else if (owner.isOrg()) {
            Account account = accountCache.get(entityNumber);
            
            if (account != null) { // Sanity check
                responseOwner.put('accountId', account.Id);
            }
        }

        return responseOwner;
    }

    /*
     * Takes a list of account owners and attached the roles that they have on the account.
     * @param owners The list of owners to group by owner
     * @param contactCache Cache of SF contacts
     * @return List of owners with their attached roles.
     */
    private static List<Map<String, Object>> groupJointsByOwner(List<IJointAccountOwner> owners, Map<String, Contact> contactCache, Map<String, Account> accountCache) {
        Map<String, List<String>> ownersGroup = new Map<String, List<String>>();
        Map<String, IJointAccountOwner> ownerMap = new Map<String, IJointAccountOwner>();
        // Used to map a person Number to a person's name, since a name is NOT unique.

        for (IJointAccountOwner owner : owners) {
            ownerMap.put(owner.getEntityNumber(), owner);
            
            // Add the role to the owners
            // The key we're initially going to use is Person Number, since it is unique.
            String groupOwnersKey = owner.getEntityNumber();
            List<String> groupedOwnersList = ownersGroup.get(groupOwnersKey);
            if (groupedOwnersList == null) {
                groupedOwnersList = new List<String>();
            }
            
            groupedOwnersList.add(owner.getRoleDescription());
            ownersGroup.put(groupOwnersKey, groupedOwnersList);
        }

        List<Map<String, Object>> finalOwnersGroup = new List<Map<String, Object>>();

        // Now finish up by converting the map to use names, instead of person numbers
        for (String ownersGroupKey : ownersGroup.keySet()) {
            IJointAccountOwner owner = ownerMap.get(ownersGroupKey);

            if (owner != null) { // Sanity check
                Map<String, Object> mappedOwner = MemberAccountsController.mapJointOwnerToMap(owner, contactCache, accountCache);
                mappedOwner.put('roles', ownersGroup.get(ownersGroupKey));

                finalOwnersGroup.add(mappedOwner);
            }
        }

        return finalOwnersGroup;
    }
    
    /*
     * Takes a list of account owners and groups them by their role.
     * @param owners The list of owners to group by role
     * @param contactCache Cache of SF contacts
     * @return Map of Roles and all the owners that are assigned that role.
     */
    private static Map<String, Object> groupJointsByRole(List<IJointAccountOwner> owners, Map<String, Contact> contactCache, Map<String, Account> accountCache) {
        Map<String, Object> rolesGroup = new Map<String, Object>();
        
        for (IJointAccountOwner owner : owners) {
            // Add them to the owners group, keyed off of their role description.
            String groupRolesKey = owner.getRoleDescription();
            List<Map<String, Object>> groupedRolesList = (List<Map<String, Object>>)rolesGroup.get(groupRolesKey);
            if (groupedRolesList == null) {
                groupedRolesList = new List<Map<String, Object>>();
            }

            Map<String, Object> responseOwner = MemberAccountsController.mapJointOwnerToMap(owner, contactCache, accountCache);
            groupedRolesList.add(responseOwner);
            rolesGroup.put(groupRolesKey, groupedRolesList);
        }

        return rolesGroup;
    }
    
    /**
     * Optimization method to build a cache of contact look ups to save on SOQL calls for contacts we need to repeatedly query.
     * @param owners List of accounts
     * @return Map of person numbers to contacts
     */
    private static Map<String, Contact> buildAccountContactCache(List<IAccount> accounts) {
        Map<String, Contact> contactCache = new Map<String, Contact>();
        
        Set<String> personNumbers = new Set<String>();
        
        for (IAccount account : accounts) {
            if (account.getJointOwners() == null) { // Sanity check
                continue;
            }

            for (IJointAccountOwner owner : account.getJointOwners()) {
                String entityNumber = owner.getEntityNumber();
                if (!personNumbers.contains(entityNumber)) {
                    personNumbers.add(entityNumber);
                }
            }
        }
        
        try {
            Contact[] jointContacts = [
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
                WHERE PersonNumber__c IN :personNumbers
            ];
            
            for (Contact contact : jointContacts) {
                contactCache.put(contact.PersonNumber__c, contact);
            }
            
        } catch (QueryException e) {
            // These persons, for whatever reason, doesn't exist in SF. Most likely to happen in test.
        }

        return contactCache;
    }
    
    /**
     * Optimization method to build a cache of contact look ups to save on SOQL calls for contacts we need to repeatedly query.
     * @param owners List of accounts
     * @return Map of person numbers to contacts
     */
    private static Map<String, Account> buildAccountAccountCache(List<IAccount> accounts) {
        Map<String, Account> accountCache = new Map<String, Account>();
        
        Set<String> orgNumbers = new Set<String>();
        
        for (IAccount account : accounts) {
            if (account.getJointOwners() == null) { // Sanity check
                continue;
            }
            for (IJointAccountOwner owner : account.getJointOwners()) {
                String entityNumber = owner.getEntityNumber();
                
                // Only care about orgs.
                if (!owner.isOrg()) {
                    continue;
                }

                if (!orgNumbers.contains(entityNumber)) {
                    orgNumbers.add(entityNumber);
                }
            }
        }
        
        try {
            Account[] orgAccounts = [
                SELECT 
                    Email__c,
                    Name,
                    OrganizationNumber__c,
                    OrganizationTaxID__c,
                    OrganizationType__c,
                    Phone,
                    ShippingStreet,
                    ShippingCity,
                    ShippingState,
                    ShippingPostalCode,
                    ShippingCountry
                FROM Account
                WHERE OrganizationNumber__c IN :orgNumbers
            ];

            for (Account orgAccount : orgAccounts) {
                accountCache.put(orgAccount.OrganizationNumber__c, orgAccount);
            }
        } catch (QueryException e) {
            // These persons, for whatever reason, doesn't exist in SF. Most likely to happen in test.
        }

        return accountCache;
    }
    
    private static List<Map<String, Object>> mapAccountGroupToGroupMap(List<AccountGroup> groups) {
        List<Map<String, Object>> mappedGroups = new List<Map<String, Object>>();
        
        for (AccountGroup accountGroup : groups) {
            List<IAccount> accounts = accountGroup.getAccounts();
            List<Map<String, Object>> mappedAccounts = new List<Map<String, Object>>();
            Map<String, Contact> contactCache = MemberAccountsController.buildAccountContactCache(accounts);
            Map<String, Account> accountCache = MemberAccountsController.buildAccountAccountCache(accounts);

            for (IAccount account : accounts) {
                Map<String, Object> responseAccount = MemberAccountsController.mapAccountToMap(account, contactCache, accountCache);
                
                List<IJointAccountOwner> owners = account.getJointOwners();
                if (owners != null) {
                    List<Map<String, Object>> ownerGroups = MemberAccountsController.groupJointsByOwner(owners, contactCache, accountCache);
                    Map<String, Object> roleGroups = MemberAccountsController.groupJointsByRole(owners, contactCache, accountCache);
                    
                    responseAccount.put('ownerGroups', ownerGroups);
                    responseAccount.put('roleGroups', roleGroups);
                }
                
                mappedAccounts.add(responseAccount);
            }
            
            Map<String, Object> mappedGroup = new Map<String, Object>();
            mappedGroup.put('name', accountGroup.getName());
            mappedGroup.put('accounts', mappedAccounts);
            
            mappedGroups.add(mappedGroup);
        }
        
        return mappedGroups;
    }
    
    private static boolean canCurrentUserViewEmployeeAccounts() {
        id userProfileID = UserInfo.getProfileId();
        Profile prof = [
            SELECT 
                Name
            FROM 
                profile
            WHERE id = :userProfileID
            LIMIT 1
        ];
        
        if (MemberAccountsController.validAccountProfiles == null) {
            Set<String> validAccountProfiles = new Set<String>();
            validAccountProfiles.add('RUL - MCC Manager');
            validAccountProfiles.add('FSC Manager');
            validAccountProfiles.add('FSC Lead Loan Officer');

            MemberAccountsController.validAccountProfiles = validAccountProfiles;
        }

        String profileName = prof.Name;
        boolean canViewAccounts = MemberAccountsController.validAccountProfiles.contains(profileName);

        return canViewAccounts;
    }
}