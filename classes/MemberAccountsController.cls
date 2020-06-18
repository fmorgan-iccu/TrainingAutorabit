public class MemberAccountsController {

    @TestVisible
    private static INetworkFactory networkFactory;

    @AuraEnabled
    public static Map<String, Object> getAccount(String accountNumber) {
        return MemberAccountsController.getAccountWithPayoff(accountNumber, null);
    }

    @AuraEnabled
    public static Map<String, Object> getAccountWithPayoff(String accountNumber, Date payoffDate) {
        Map<String, Object> response = new Map<String, Object>();

        if (accountNumber == null) {
            response.put('error', '`accountNumber` was null.');
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

        try {
            IAccount account = accountProvider.getAccount(accountNumber, payoffDate);

            List<IAccount> accounts = new List<IAccount> { account };
            Map<String, Contact> contactCache = MemberAccountsController.buildAccountContactCache(accounts);
            Map<String, Account> accountCache = MemberAccountsController.buildAccountAccountCache(accounts);

            Map<String, Object> responseAccount = MemberAccountsController.mapAccountToMap(account, contactCache, accountCache, true);

            response.put('account', responseAccount);
        } catch (Exception e) {
            response.put('error', 'An unexpected error occured: ' + e);
            return response;
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getAccountCollateral(String accountNumber) {
        Map<String, Object> response = new Map<String, Object>();

        if (String.isBlank(accountNumber)) {
            response.put('error', 'The `accountNumber` must be provided.');
            return response;
        }

        MemberAccountsController.networkFactory = new ConcreteNetworkProvider();
        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

        // Get the collateral information for the requested account.
        List<ICollateral> collateral = null;
        try {
            collateral = accountProvider.getCollateral(accountNumber);
            List<Map<String, Object>> collateralList = MemberAccountsController.mapCollateralToMap(collateral);
            response.put('collateral', collateralList);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
            System.debug('Not authenticated: ' + e);
        } catch (Exception e) {
            response.put('error', 'An unexpected error occured: ' + e);
        }

        // Determine if any of the owners of the accounts associated with the collateral is an employee.
        Boolean isEmployee = false;
        Set<String> personNumbers = new Set<String>();
        for (ICollateral c : collateral) {
            List<IAccount> accounts = c.getAccounts();
            for (IAccount a : accounts) {
                List<IJointAccountOwner> owners =  a.getJointOwners();
                for (IJointAccountOwner o : owners) {
                    if (o.getEntityType() == DNAConstants.ENTITY_TYPE_PERSON) {
                        personNumbers.add(o.getEntityNumber());
                    }
                }
            }
        }
        List<Contact> contacts = [
            SELECT id,
                IsEmployee__c
            FROM Contact
            WHERE PersonNumber__c IN :personNumbers
        ];
        for (Contact c : contacts) {
            if (c.IsEmployee__c) {
                isEmployee = true;
                break;
            }
        }
        Boolean canViewEmployeeAccounts = MemberAccountsController.canCurrentUserViewEmployeeAccounts();
        if (isEmployee && !canViewEmployeeAccounts) {
            response.remove('collateral');
            response.put('error', 'Unable to view team member accounts.');
            return response;
        }

        return response;
    }

    /**
     * Retrieves the contact, account and transaction list as a single request.  The response is a Map like:
     * { "contact": {...}, "account": {...}, "transactions": [] }
     */
    @AuraEnabled
    public static Map<String, Object> getAccountWithTransactions(Id recordId, String accountNumber, DateTime startDate, DateTime endDate) {
        Map<String, Object> accountMap = new Map<String, Object> { 'accountNumber' => accountNumber };
        Map<String, Object> accountResponse = MemberAccountsController.getAccount(accountNumber);
        Map<String, Object> transactionResponse = MemberAccountsController.getAccountTransactions(accountMap, startDate, endDate);

        Map<String, Object> response = new Map<String, Object>();
        if (accountResponse.containsKey('error')) {
            response.put('error', accountResponse.get('error'));
            return response;
        }
        if (transactionResponse.containsKey('error')) {
            response.put('error', transactionResponse.get('error'));
            return response;
        }

        response.putAll(accountResponse);
        response.putAll(transactionResponse);

        String recordType = '' + recordId.getSobjectType();
        if (recordType == 'Contact') {
            Map<String, Object> contactResponse = MemberAccountsController.getContact(recordId);
            if (contactResponse.containsKey('error')) {
                response.put('error', contactResponse.get('error'));
                return response;
            }
            response.putAll(contactResponse);
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getMemberAccountsList(String contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', '`contactId` was null.');
            return response;
        }

        Contact contact = SFPerson.getInstance(contactId).getContact();
        if (contact == null) {
            response.put('error', 'Unable to find the `contactId`.');
            return response;
        }

        Boolean canViewEmployeeAccounts = MemberAccountsController.canCurrentUserViewEmployeeAccounts();
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
                Map<String, Object> responseAccount = MemberAccountsController.mapAccountToMap(account, contactCache, accountCache, false);

                Boolean fullRefund = account.getGapPurchaseDate() != null && Date.valueOf(account.getGapPurchaseDate()).daysBetween(System.today()) < 90;
                responseAccount.put('fullRefund', fullRefund);

                if (account.getGapPurchaseDate() != null) {
                    responseAccount.put('cancelBeforeDate', account.getGapPurchaseDate().addDays(90));
                }

                if (account.getHasLifeInsurance() != null) {
                    responseAccount.put('hasLifeInsurance', account.getHasLifeInsurance());
                }

                if (account.getHasDisabilityInsurance() != null) {
                    responseAccount.put('hasDisabilityInsurance', account.getHasDisabilityInsurance());
                }

                Double formattedCurrentBalance = account.getCurrentBalance();
                responseAccount.put('formattedCurrentBalance', formattedCurrentBalance);

                Double formattedMonthlyPayment = account.getNextPaymentAmount();
                responseAccount.put('formattedMonthlyPayment', formattedMonthlyPayment);

                Map<String, Object> collateralResponse = MemberAccountsController.getAccountCollateral(account.getAccountNumber());
                List<Map<String, Object>> collateral = (List<Map<String, Object>>)collateralResponse.get('collateral');
                if (collateral.size() > 0) {
                    Map<String, Object> c = collateral[0];
                    String make = (String)c.get('make');
                    String model = (String)c.get('model');
                    String formattedMake =  make != null ? make : '';
                    String formattedModel = model != null ? model : '';
                    responseAccount.put('collateral', formattedMake + ' ' + formattedModel);
                }

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
    public static Map<String, Object> getOrganizationAccountsList(String accountId) {
        Map<String, Object> response = new Map<String, Object>();

        if (accountId == null) {
            response.put('error', '`accountId` was null.');
            return response;
        }

        Account account = SFOrganization.getInstance(accountId).getAccount();
        if (account == null) {
            response.put('error', 'Unable to find the account.');
            return response;
        }

        // Handle the cases where the account is a person account or doesn't have an organization number.
        if (account.PersonNumber__c != null || account.OrganizationNumber__c == null) {
            List<Map<String, Object>> responseAccounts = new List<Map<String, Object>>();
            response.put('accounts', responseAccounts);
            return response;
        }

        /* TODO:  Need to determine how the employee access should be handled for accounts.  Should the account have
            a flag that identifies that an employee has a role on one or more accounts?
        Boolean canViewEmployeeAccounts = MemberAccountsController.canCurrentUserViewEmployeeAccounts();
        if (contact.IsEmployee__c == true && canViewEmployeeAccounts == false) {
            response.put('error', 'Unable to view team member accounts.');
            return response;
        }*/

        try {
            List<IAccount> accounts = MemberAccountsController.getOrganizationAccounts(accountId);
            List<Map<String, Object>> responseAccounts = new List<Map<String, Object>>();
            Map<String, Contact> contactCache = MemberAccountsController.buildAccountContactCache(accounts);
            Map<String, Account> accountCache = MemberAccountsController.buildAccountAccountCache(accounts);

            for (IAccount a : accounts) {
                Map<String, Object> responseAccount = MemberAccountsController.mapAccountToMap(a, contactCache, accountCache, false);
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

        Boolean canViewEmployeeAccounts = MemberAccountsController.canCurrentUserViewEmployeeAccounts();
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

        Boolean isAuthenticated = authManager.isUserAuthenticated();
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

        SFOrganization org = SFOrganization.getInstance(accountId);
        try {
            List<AccountGroup> groups = accountProvider.getAccountsGrouped(org);
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

        String accountNumber = (String)accountMap.get('accountNumber');
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

        // Retrieve all of the employee person numbers
        List<Contact> employees = [
            SELECT Id,
                PersonNumber__c
            FROM Contact
            WHERE IsEmployee__c = true
        ];
        Set<String> employeePersonNumbers = new Set<String>();
        for (Contact e : employees) {
            employeePersonNumbers.add(e.PersonNumber__c);
        }

        try {
            List<IAccountTransaction> transactions = accountProvider.getTransactions(accountNumber, startDate, endDate);
            List<Map<String, Object>> rawTransactions = new List<Map<String, Object>>();
            response.put('startDate', startDate);
            response.put('endDate', endDate);

            for (IAccountTransaction trans : transactions) {
                Map<String, Object> rawTrans = new Map<String, Object>();

                // Determine if the originating person is an employee an the role of the person.
                String originatingPersonNumber = trans.getOriginatingPersonNumber();
                Boolean isEmployee = employeePersonNumbers.contains(originatingPersonNumber);
                String originatingPersonRole = isEmployee ? 'Team Member' : 'Member';

                // Determine a short and long description to use for display.  Some transactions, like deposits or
                // withdrawls, don't have an external description.
                String checkNumber = trans.getCheckNumber();
                String description = trans.getDescription(); // Transaction type description
                String externalDescription = trans.getExternalDescription();
                String internalDescription = trans.getInternalDescription();
                String longDescription = null;
                if (!String.isBlank(externalDescription)) {
                    longDescription = externalDescription;
                } else {
                    longDescription = description + ' - ' + internalDescription + (!String.isBlank(checkNumber) ? ' #' + checkNumber : '');
                }

                // The short description will remove any numbers and associated punctuation from the beginning of the
                // long description and truncate it to 20 characters.
                String shortDescription = longDescription.replaceFirst('^[ 0-9:,.-]+', '');
                if (isEmployee) {
                    shortDescription = 'Branch Transaction';
                }

                rawTrans.put('amount', trans.getAmount());
                rawTrans.put('balance', trans.getBalance());
                rawTrans.put('cardTransactionNumber', trans.getCardTransactionNumber());
                rawTrans.put('checkNumber', checkNumber);
                rawTrans.put('description', description);
                rawTrans.put('effectiveDate', String.valueOf(trans.getEffectiveDate()));
                rawTrans.put('externalDescription', externalDescription);
                rawTrans.put('internalDescription', internalDescription);
                rawTrans.put('isCredit', trans.getIsCredit());
                rawTrans.put('isPending', trans.getIsPending());
                rawTrans.put('longDescription', longDescription);
                rawTrans.put('postDate', String.valueOf(trans.getPostDate()));
                rawTrans.put('originatingPerson', trans.getOriginatingPersonName());
                rawTrans.put('originatingPersonNumber', originatingPersonNumber);
                rawTrans.put('originatingPersonIsEmployee', isEmployee);
                rawTrans.put('originatingPersonRole', originatingPersonRole);
                rawTrans.put('shortDescription', shortDescription);
                rawTrans.put('standardIndustryClassCode', trans.getStandardIndustryClassCode());
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

    public static List<IAccount> getMemberAccounts(String contactId) {
        if (MemberAccountsController.networkFactory == null) {
            MemberAccountsController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

        SFPerson person = SFPerson.getInstance(contactId);
        List<IAccount> accounts = accountProvider.getAccounts(person);

        filterAccountsByGapStatus(accounts);

        return accounts;
    }

    public static List<IAccount> getOrganizationAccounts(String accountId) {
        if (MemberAccountsController.networkFactory == null) {
            MemberAccountsController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

        SFOrganization org = SFOrganization.getInstance(accountId);
        List<IAccount> accounts = accountProvider.getAccounts(org);

        return accounts;
    }

    /**
     * Function for filtering accounts that have GAP.
     * @param accounts a List of IAccounts to be filtered.
     * @return A list of IAccount instances
     */
    @AuraEnabled
    public static List<IAccount> filterAccountsByGapStatus(List<IAccount> accounts) {
    List<IAccount> autoAccounts = new List<IAccount>();
        for (IAccount a : accounts) {
            if (a.getAccountType() == DNAAccount.ACCOUNT_TYPE_AUTO) {
                autoAccounts.add(a);
            }
        }

        INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

        Map<String, List<IAccountTransaction>> filteredTransactionsByAccount = accountProvider.getFilteredAccountTransactions(autoAccounts, new List<String> { DNAAccount.TRANSACTION_TYPE_GAP_PURCHASE, DNAAccount.TRANSACTION_TYPE_GAP_REFUND, DNAAccount.TRANSACTION_TYPE_FIRST_PAYMENT, DNAAccount.TRANSACTION_TYPE_INSURANCES });
        for (String accountNumber : filteredTransactionsByAccount.keySet()) {
            IAccount currentAccount = null;
            for (IAccount a : accounts) {
                if (a.getAccountNumber() == accountNumber) {
                    currentAccount = a;
                    break;
                }
            }
            List<IAccountTransaction> filteredTransactions = filteredTransactionsByAccount.get(accountNumber);
            // Loop over the transactions to determine GAP and Subsequent action status for this account.
            Integer paymentsMade = 0;
            Boolean activeInsurance =  false;
            for (IAccountTransaction trans : filteredTransactions) {
                if (trans.getTypeCode() == DNAAccount.TRANSACTION_TYPE_FIRST_PAYMENT) {
                    paymentsMade = paymentsMade + 1;
                }
                if (trans.getTypeCode() == DNAAccount.TRANSACTION_TYPE_INSURANCES && (trans.getInternalDescriptionNumber() == DNAConstants.SINGLELIFE_INSURANCE_INTERNAL_NBR  || trans.getInternalDescriptionNumber() == DNAConstants.JOINTLIFE_INSURANCE_INTERNAL_NBR)) {
                    if (Date.valueOf(trans.getPostDate()).daysBetween(System.today()) < DNAConstants.DAYS_SINCE_INSURANCE) {
                        currentAccount.setHasLifeInsurance(true);
                    }
                }
                if (trans.getTypeCode() == DNAAccount.TRANSACTION_TYPE_INSURANCES && trans.getInternalDescriptionNumber() == DNAConstants.DISABILITY_INSURANCE_INTERNAL_NBR) {
                    if (Date.valueOf(trans.getPostDate()).daysBetween(System.today()) < DNAConstants.DAYS_SINCE_INSURANCE) {
                        currentAccount.setHasDisabilityInsurance(true);
                    }
                }
                if (trans.getTypeCode() == DNAAccount.TRANSACTION_TYPE_GAP_PURCHASE && trans.getInternalDescriptionNumber() == DNAConstants.GAP_PURCHASE_INTERNAL_NBR) {
                    currentAccount.setActiveGapPolicy(true);
                    currentAccount.setGapPurchaseDate(trans.getPostDate());
                } else if (trans.getTypeCode() == DNAAccount.TRANSACTION_TYPE_GAP_REFUND && trans.getInternalDescriptionNumber() == DNAConstants.GAP_REFUND_INTERNAL_NBR) {
                    currentAccount.setCancelledGapPolicy(true);
                }
            }
            if (paymentsMade > 0) {
                currentAccount.setFirstPaymentMade(true);
            } else {
                currentAccount.setFirstPaymentMade(false);
            }
        }
        return accounts;
    }

    /**
     * Reusable code to map an IAccount to a Map collection type
     * @param account The IAccount type to convert
     * @return A mapped Map <rimshot>
     */
    private static Map<String, Object> mapAccountToMap(IAccount account, Map<String, Contact> contactCache, Map<String, Account> accountCache, Boolean includeJointGroups) {
        Map<String, Object> responseAccount = new Map<String, Object>();
        String accountType = account.getAccountType();
        responseAccount.put('accountNumber', account.getAccountNumber());
        responseAccount.put('accountType', accountType);
        responseAccount.put('availableBalance', account.getAvailableBalance());
        responseAccount.put('branchName', account.getBranchName());
        responseAccount.put('currentBalance', account.getCurrentBalance());
        responseAccount.put('interestRate', account.getInterestRate());
        responseAccount.put('majorType', account.getMajorType());
        responseAccount.put('minorType', account.getMinorType());
        responseAccount.put('name', account.getName());
        responseAccount.put('nextPaymentAmount', account.getNextPaymentAmount());
        responseAccount.put('nextPaymentDate', account.getNextPaymentDate());
        responseAccount.put('nickName', account.getNickName());
        responseAccount.put('status', account.getStatus());
        responseAccount.put('payoffAmount', account.getPayoffAmount());
        responseAccount.put('perDiem', account.getPerDiem());
        responseAccount.put('activeGapPolicy', account.getActiveGapPolicy());
        responseAccount.put('cancelledGapPolicy', account.getCancelledGapPolicy());
        responseAccount.put('gapPurchaseDate', account.getGapPurchaseDate());
        responseAccount.put('canSkipPayment', account.getCanSkipPayment());
        responseAccount.put('visaNextPaymentAmount', account.getVisaNextPaymentAmount());
        responseAccount.put('firstPaymentMade', account.getFirstPaymentMade());
        responseAccount.put('hasLifeInsurance', account.getHasLifeInsurance());
        responseAccount.put('hasDisabilityInsurance', account.getHasDisabilityInsurance());

        // Determine if the account is overdue.
        Boolean isOverdue = false;
        Date today = System.today();
        DateTime nextPaymentDateTime = account.getNextPaymentDate();
        if (nextPaymentDateTime !=  null) {
            Date nextPaymentDate = nextPaymentDateTime.date();
            if (nextPaymentDate < today) {
                isOverdue = true;
            }
        }
        responseAccount.put('isOverdue', isOverdue);

        // Add the joint owner information.
        List<IJointAccountOwner> owners = account.getJointOwners();
        List<Map<String, Object>> ownersMap = new List<Map<String, Object>>();
        if (owners != null) {
            for (IJointAccountOwner owner : owners) {
                Map<String, Object> responseOwner = MemberAccountsController.mapJointOwnerToMap(owner, contactCache, accountCache);
                ownersMap.add(responseOwner);
            }
        }
        responseAccount.put('jointOwners', ownersMap);

        // Get grouped joint information.
        if (owners != null && includeJointGroups) {
            List<Map<String, Object>> ownerGroups = MemberAccountsController.groupJointsByOwner(owners, contactCache, accountCache);
            Map<String, Object> roleGroups = MemberAccountsController.groupJointsByRole(owners, contactCache, accountCache);

            responseAccount.put('ownerGroups', ownerGroups);
            responseAccount.put('roleGroups', roleGroups);
        }

        // Identify an icon that should be used throughout the system.
        String icon = null;
        if (accountType == DNAAccount.ACCOUNT_TYPE_MORTGAGE) {
            icon = 'custom:custom107'; // home icon
        } else if (accountType == DNAAccount.ACCOUNT_TYPE_DEPOSIT) {
            icon = 'custom:custom17'; // money bag icon
        } else if (accountType == DNAAccount.ACCOUNT_TYPE_AUTO) {
            icon = 'custom:custom31'; // auto icon
        } else if (accountType == DNAAccount.ACCOUNT_TYPE_CREDIT_CARD) {
            icon = 'custom:custom40'; // card icon
        } else {
            icon = 'custom:custom16'; // bank icon
        }
        responseAccount.put('icon', icon);

        return responseAccount;
    }

    private static List<Map<String, Object>> mapCollateralToMap(List<ICollateral> collateral) {
        // Get the contacts/accounts associated with the accounts.
        List<IAccount> allAccounts = new List<IAccount>();
        for (ICollateral c : collateral) {
            List<IAccount> accounts = c.getAccounts();
            allAccounts.addAll(accounts);
        }
        Map<String, Contact> contactCache = MemberAccountsController.buildAccountContactCache(allAccounts);
        Map<String, Account> accountCache = MemberAccountsController.buildAccountAccountCache(allAccounts);

        // Build up the collateral list.
        List<Map<String, Object>> collateralList = new List<Map<String, Object>>();
        for (ICollateral c : collateral) {
            List<Map<String, Object>> accountList = new List<Map<String, Object>>();
            List<IAccount> accounts = c.getAccounts();
            for (IAccount a : accounts) {
                Map<String, Object> accountMap = MemberAccountsController.mapAccountToMap(a, contactCache, accountCache, false);
                accountList.add(accountMap);
            }

            Map<String, Object> collateralMap = new Map<String, Object>();
            collateralMap.put('accounts', accountList);
            collateralMap.put('description', c.getDescription());
            collateralMap.put('id', c.getId());
            collateralMap.put('make', c.getMake());
            collateralMap.put('model', c.getModel());
            collateralMap.put('propertyNumber', c.getPropertyNumber());
            collateralMap.put('purchasePrice', c.getPurchasePrice());
            collateralMap.put('typeCode', c.getTypeCode());
            collateralMap.put('year', c.getYear());
            collateralMap.put('value', c.getValue());

            collateralList.add(collateralMap);
        }

        return collateralList;
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

    /**
     * Function for filtering accounts that are ACH.
     * @param accounts a List of IAccounts to be filtered.
     * @return A list of IAccount instances
     */
    @AuraEnabled
    public static List<IAccountTransaction> getAchTransactions(String accountNumber) {

         INetworkFactory networkFactory = MemberAccountsController.networkFactory;
        IPersonAccountDataProvider accountProvider = networkFactory.getPersonAccountDataProvider();

         IAccount account = accountProvider.getAccount(accountNumber);

         List<IAccount> accounts = new List<IAccount> { account };

         Map<String, List<IAccountTransaction>> filteredTransactionsByAccount = accountProvider.getFilteredAccountTransactions(accounts, new List<String> { DNAAccount.TRANSACTION_TYPE_ACH });
        List<IAccountTransaction> achTransactions = new List<IAccountTransaction>();

         List<IAccountTransaction> filteredTransactions = filteredTransactionsByAccount.get(accountNumber);
            // Loop over the transactions to determine ACH.
            for (IAccountTransaction trans : filteredTransactions) {
                if (trans.getTypeCode() == DNAAccount.TRANSACTION_TYPE_ACH) {
                    achTransactions.add(trans);
                }
            }
        return achTransactions;
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

        // Get all of the person numbers associated with the accounts.
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

        // Retrieve the contacts
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
                    BillingStreet,
                    BillingCity,
                    BillingState,
                    BillingPostalCode,
                    BillingCountry
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

        List<IAccount> allAccounts = new List<IAccount>();
        for (AccountGroup accountGroup : groups) {
            List<IAccount> accounts = accountGroup.getAccounts();
            allAccounts.addAll(accounts);
        }
        Map<String, Contact> contactCache = MemberAccountsController.buildAccountContactCache(allAccounts);
        Map<String, Account> accountCache = MemberAccountsController.buildAccountAccountCache(allAccounts);

        for (AccountGroup accountGroup : groups) {
            List<Map<String, Object>> mappedAccounts = new List<Map<String, Object>>();

            List<IAccount> accounts = accountGroup.getAccounts();
            for (IAccount account : accounts) {
                Map<String, Object> responseAccount = MemberAccountsController.mapAccountToMap(account, contactCache, accountCache, true);
                mappedAccounts.add(responseAccount);
            }

            Map<String, Object> mappedGroup = new Map<String, Object>();
            mappedGroup.put('name', accountGroup.getName());
            mappedGroup.put('accounts', mappedAccounts);

            mappedGroups.add(mappedGroup);
        }

        return mappedGroups;
    }

    private static Boolean canCurrentUserViewEmployeeAccounts() {
        Boolean canViewAccounts = AccessUtils.checkPermission('Employee_Financial_Account');
        return canViewAccounts;
    }

}