/*
 * Class implementing IPersonAccountDataProvider
 * Connects to DNA and fetches all of the accounts of a person.
 */
public with sharing class DNAPersonAccountDataProvider extends DNACoreDataProvider implements IPersonAccountDataProvider {
    /*
     * Default constructor
     */
    public DNAPersonAccountDataProvider() {
        super();
    }

    /*
     * Constructor for specifying the IAuthenticationManager.  Primarily to facilitate unit testing.
     * @authManager The IAuthenticationManager to use
     */
    public DNAPersonAccountDataProvider(IAuthenticationManager authenticationManager) {
        super(authenticationManager);
    }

    public IAccount getAccount(String accountNumber) {
        return getAccount(accountNumber, null);
    }

    public IAccount getAccount(String accountNumber, Date payoffDate) {
        if (String.isBlank(accountNumber)) {
            throw new IllegalArgumentException('The `accountNumber` must be provided.');
        }
        Date today = System.today();
        if (payoffDate != null && payoffDate < today) {
            throw new IllegalArgumentException('The payoff date must be in the future.');
        }

        List<Map<String, Object>> requests = new List<Map<String, Object>>();

        Map<String, Object> accountRequest = new Map<String, Object>();
        accountRequest.put('AccountNumber', accountNumber);
        accountRequest.put('__type', 'AccountDetailInquiryRequest:http://www.opensolutions.com/CoreApi');
        requests.add(accountRequest);

        Boolean hasPayoffDate = payoffDate != null;
        if (hasPayoffDate) {
            Map<String, Object> payoffRequest = new Map<String, Object>();
            String effectiveDate = createDNADate(payoffDate);
            payoffRequest.put('AccountNumber', accountNumber);
            payoffRequest.put('EffectiveDate', effectiveDate);
            payoffRequest.put('IsPayOff', true);
            payoffRequest.put('__type', 'AccountPayOffPayDownInquiryRequest:http://www.opensolutions.com/CoreApi');
            requests.add(payoffRequest);
        }

        Map<String, Object> request = this.createGenericRequest(requests);
        List<Map<String, Object>> responses = this.callApi(request);

        // Check for error conditions.
        Integer expectedResponses = hasPayoffDate ? 2 : 1;
        if (responses == null || responses.size() != expectedResponses) {
            return null;
        }
        for (Map<String, Object> response : responses) {
            List<Object> errors = (List<Object>)response.get('Errors');
            if (errors != null) {
                String message = this.parseErrors(errors);
                throw new DataServiceException(message);
            }
        }

        Map<String, Object> accountMap = responses[0];
        DNAAccount account = this.parseAccount(accountMap);

        if (hasPayoffDate) {
            Map<String, Object> payoffMap = responses[1];
            Double amountDue = (Double)payoffMap.get('TotalAmountDueFinancialInstitution');
            account.setPayoffAmount(amountDue);

            Double perDiem = (Double)accountMap.get('TotalPerDiem');
            account.setPerDiem(perDiem);
        }

        return account;
    }

    /*
     * Fetches the IAccount instances of an IPerson
     * @param The person for which we should fetch their DNA accounts.
     * @return A list of IAccount objects that belong to the person.
     */
    public List<IAccount> getAccounts(IPerson person) {
        if (person == null || person.getPersonNumber() == null) {
            throw new IllegalArgumentException('The `person` nor its person number may be null.');
        }

        List<IAccount> accounts = this.getAccounts(DNAConstants.ENTITY_TYPE_PERSON, person.getPersonNumber());
        return accounts;
    }

    /*
     * Fetches the IAccount instances of an IOrganization
     * @param The orc for which we should fetch their DNA accounts.
     * @return A list of IAccount objects that belong to the orc.
     */
    public List<IAccount> getAccounts(IOrganization organization) {
        if (organization == null || organization.getOrgNumber() == null) {
            throw new IllegalArgumentException('The `organization` nor its organization number may be null.');
        }

        List<IAccount> accounts = this.getAccounts(DNAConstants.ENTITY_TYPE_ORGANIZATION, organization.getOrgNumber());
        return accounts;
    }

    /*
     * Fetches the IWarningFlag instances associated with the IAccounts of an IOrganization
     * @param org The organization for which we should fetch their DNA account flags.
     * @return A list of IWarningFlag objects that belong to the IOrganizations's IAccounts.
     */
    public List<IWarningFlag> getAllWarningFlags(IOrganization org) {
        if (org == null || org.getOrgNumber() == null) {
            throw new IllegalArgumentException('The `org` nor its org number may be null.');
        }

        List<IAccount> accounts = this.getAccounts(org);
        List<IWarningFlag> flags = this.getAllWarningFlags(accounts);

        return flags;
    }

    /*
     * Fetches the IWarningFlag instances associated with the IAccounts of an IPerson
     * @param person The person for which we should fetch their DNA account flags.
     * @return A list of IWarningFlag objects that belong to the IPerson's IAccounts.
     */
    public List<IWarningFlag> getAllWarningFlags(IPerson person) {
        if (person == null || person.getPersonNumber() == null) {
            throw new IllegalArgumentException('The `person` nor its person number may be null.');
        }

        List<IAccount> accounts = this.getAccounts(person);
        List<IWarningFlag> flags = this.getAllWarningFlags(accounts);

        return flags;
    }

    /*
     * Fetches the IWarningFlag instances associated with a list of IAccounts
     * @param accounts The accounts for which we should fetch their DNA flags.
     * @return A list of IWarningFlag objects that belong to the IAccounts.
     */
    public List<IWarningFlag> getAllWarningFlags(List<IAccount> accounts) {
        if (accounts == null) {
            throw new IllegalArgumentException('The `accounts` may not be null.');
        }
        if (accounts.size() == 0) {
            return new List<IWarningFlag>();
        }

        List<Map<String, Object>> requests = new List<Map<String, Object>>();

        for (IAccount account : accounts) {
            // Add the request for warnings
            Map<String, Object> warningRequest = new Map<String, Object>();
            warningRequest.put('AccountNumber', account.getAccountNumber());
            warningRequest.put('__type', 'AccountWarningListRequest:http://www.opensolutions.com/CoreApi');

            requests.add(warningRequest);

            // Add the request for lockouts
            Map<String, Object> lockoutRequest = new Map<String, Object>();
            lockoutRequest.put('AccountNumber', account.getAccountNumber());
            lockoutRequest.put('__type', 'AccountLockoutListRequest:http://www.opensolutions.com/CoreApi');

            requests.add(lockoutRequest);
        }

        Map<String, Object> request = this.createGenericRequest(requests);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        List<IWarningFlag> flags = new List<DNAWarningFlag>();

        for (Map<String, Object> responseMap : responses) {
            List<IWarningFlag> parsedFlags = null;
            List<Object> warnings = (List<Object>)responseMap.get('AccountWarnings');

            if (warnings != null) {
                List<Map<String, Object>> rawFlags = APIUtils.convertObjectList(warnings);
                parsedFlags = this.parseWarningFlags(rawFlags);
            } else {
                List<Map<String, Object>> rawFlags = APIUtils.convertObjectList((List<Object>)responseMap.get('LockOuts'));
                parsedFlags = this.parseLockoutFlags(rawFlags);
            }

            flags.addAll(parsedFlags);
        }

        return flags;
    }

    public AccountSummary getAccountOwnerTotals(IOrganization organization) {
        List<IAccount> accounts = this.getAccounts(organization);
        return getAccountOwnerTotals(accounts);
    }

    /*
     * Calculates and returns the Deposit and Loan totals for all accounts related to an AccountId.
     */
    private AccountSummary getAccountOwnerTotals(List<IAccount> accounts) {
        Double loanTotalOwner = 0;
        Double depositTotalOwner = 0;
        AccountSummary response  = new AccountSummary(null, null);

        if (accounts == null) {
            return response  = new AccountSummary(0, 0);
        }
        if (accounts.size() == 0) {
            return response  = new AccountSummary(0, 0);
        }

        for (IAccount account : accounts) {
            String accountKey = account.getMajorType();

            // Check to see which account MajorType and sum the available balance.
            if (accountKey == 'CK') {
                depositTotalOwner = depositTotalOwner + account.getCurrentBalance();
                continue;
            } else if (accountKey == 'SAV') {
                depositTotalOwner = depositTotalOwner + account.getCurrentBalance();
                continue;
            } else if (accountKey == 'EXT') {
                loanTotalOwner = loanTotalOwner + account.getCurrentBalance();
                continue;
            } else if (accountKey == 'TD') {
                depositTotalOwner = depositTotalOwner + account.getCurrentBalance();
                continue;
            } else if (accountKey == 'CNS') {
                loanTotalOwner = loanTotalOwner + account.getCurrentBalance();
                continue;
            } else if (accountKey == 'MTG') {
                loanTotalOwner = loanTotalOwner + account.getCurrentBalance();
                continue;
            }
        }

        response  = new AccountSummary(loanTotalOwner, depositTotalOwner);

        return response;
    }

    /**
     * Gets the accounts based on the entity type code and the entity number
     * @param entityTypeCode Code for the request.  Valid values: PERS, ORG
     * @param entityNumber The unique number for the entity being requested
     */
    private List<IAccount> getAccounts(String entityTypeCode, String entityNumber) {
        Map<String, Object> accountRequest = new Map<String, Object>();
        accountRequest.put('EntityTypeCode', entityTypeCode);
        accountRequest.put('EntityNumber', entityNumber);
        accountRequest.put('__type', 'AccountListRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(accountRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> accountsMap = responses[0];
        List<Object> errors = (List<Object>)accountsMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new DataServiceException(message);
        }
        List<Map<String, Object>> rawAccounts = APIUtils.convertObjectList((List<Object>)accountsMap.get('Accounts'));

        List<IAccount> accounts = this.parseAccounts(rawAccounts);

        return accounts;
    }

    /*
     * Fetches the IAccount instances of an IPerson and groups them by their product type
     * @param The person for which we should fetch their DNA accounts.
     * @return A list of AccountGroup objects that belong to the person.
     */
    public List<AccountGroup> getAccountsGrouped(IPerson person) {
        List<IAccount> accounts = this.getAccounts(person);
        List<AccountGroup> groups = this.mapAccountsToGroups(accounts);

        return groups;
    }

    /*
     * Fetches the IAccount instances of an IOrganization and groups them by their product type
     * @param The orc for which we should fetch their DNA accounts.
     * @return A list of AccountGroup objects that belong to the orc.
     */
    public List<AccountGroup> getAccountsGrouped(IOrganization organization) {
        List<IAccount> accounts = this.getAccounts(organization);
        List<AccountGroup> groups = this.mapAccountsToGroups(accounts);

        return groups;
    }

    /**
     * Method for mapping a list of accounts to a group.
     * @param accounts The list of accounts to map.
     * @param A list of AccountGroup objects.
     */
    private List<AccountGroup> mapAccountsToGroups(List<IAccount> accounts) {
        if (accounts == null) {
            return new List<AccountGroup>();
        }

        Map<String, AccountGroup> groups = new Map<String, AccountGroup>();
        Map<String, DNAAccountTypeCode> codes = this.getMajorAccountTypes();

        for (IAccount account : accounts) {
            String accountKey = account.getMajorType();

            AccountGroup accountGroup = groups.get(accountKey);
            if (accountGroup == null) {
                String displayName = accountKey;
                DNAAccountTypeCode code = codes.get(accountKey);

                if (code != null) {
                    displayName = code.getDisplayName();
                }

                accountGroup = new AccountGroup(displayName);
            }

            accountGroup.getAccounts().add(account);

            groups.put(accountKey, accountGroup);
        }

        return groups.values();
    }

    /**
     * Retrieves all collateral for the indicated account.
     */
    public List<ICollateral> getCollateral(String accountNumber) {
        if (accountNumber == null) {
            throw new IllegalArgumentException('The `accountNumber` may NOT be null.');
        }

        Map<String, String> propertyCollateral = new Map<String, String> {
            'AccountNumber' => accountNumber
        };

        Map<String, Object> collateralRequest = new Map<String, Object>();
        collateralRequest.put('PropertyCollateral', propertyCollateral);
        collateralRequest.put('__type', 'CollateralSearchRequest:http://www.opensolutions.com/CoreApi');

        List<Map<String, Object>> requests = new List<Map<String, Object>>();
        requests.add(collateralRequest);

        Map<String, Object> request = this.createGenericRequest(requests);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        for (Map<String, Object> response : responses) {
            List<Object> errors = (List<Object>)response.get('Errors');
            if (errors != null) {
                String message = this.parseErrors(errors);
                throw new DataServiceException(message);
            }
        }

        Map<String, Object> responseMap = responses[0];
        List<Map<String, Object>> rawCollateral = APIUtils.convertObjectList((List<Object>)responseMap.get('PropertyCollateralList'));
        List<ICollateral> collateral = this.parseCollateral(rawCollateral);

        return collateral;
    }

    //Overloaded Function
    public List<IAccountTransaction> getTransactions(String accountNumber, DateTime startDate, DateTime endDate) {
        return this.getTransactions(accountNumber, startDate, endDate, Metadata.SortOrder.ASC_X);
    }

    /**
     * Fetches the IAccountTransaction instances of an IAccount
     * @param accountNumber The account for which transactions should be obtained.
     * @return List of IAccountTransaction objects belonging to the account;
     */
    public List<IAccountTransaction> getTransactions(String accountNumber, DateTime startDate, DateTime endDate, Metadata.SortOrder sortOrder) {
        if (accountNumber == null) {
            throw new IllegalArgumentException('The `accountNumber` may NOT be null.');
        } else if (startDate == null) {
            throw new IllegalArgumentException('The `startDate` may NOT be null.');
        } else if (endDate == null) {
            throw new IllegalArgumentException('The `endDate` may NOT be null.');
        } else if (startDate > endDate) {
            throw new IllegalArgumentException('The start date cannot be after the end date.');
        }

        if (sortOrder == null) {
            sortOrder = Metadata.SortOrder.ASC_X;
        }

        String dnaStartDate = super.createDNADate(startDate);
        String dnaEndDate = super.createDNADate(endDate);

        // Request processed transactions
        Map<String, Object> transactionRequest = new Map<String, Object>();
        transactionRequest.put('AccountNumber', accountNumber);
        transactionRequest.put('FromDate', dnaStartDate);
        transactionRequest.put('ThroughDate', dnaEndDate);
        transactionRequest.put('IsCustomerView', false);
        transactionRequest.put('__type', 'AccountTransactionHistoryRequest:http://www.opensolutions.com/CoreApi');

        // Get pending ACH transactions
        Map<String, Object> pendingTransactionRequest = new Map<String, Object>();
        pendingTransactionRequest.put('AccountNumber', accountNumber);
        pendingTransactionRequest.put('FromDate', dnaStartDate);
        pendingTransactionRequest.put('ThroughDate', dnaEndDate);
        pendingTransactionRequest.put('__type', 'PendingAccountTransactionInquiryRequest:http://www.opensolutions.com/CoreApi');

        // Get pending card/otc transactions
        Map<String, Object> holdTransactionRequest = new Map<String, Object>();
        holdTransactionRequest.put('AccountNumber', accountNumber);
        holdTransactionRequest.put('FromDate', dnaStartDate);
        holdTransactionRequest.put('ThroughDate', dnaEndDate);
        holdTransactionRequest.put('__type', 'AccountHoldsInquiryRequest:http://www.opensolutions.com/CoreApi');

        List<Map<String, Object>> requests = new List<Map<String, Object>>();
        requests.add(transactionRequest);
        requests.add(pendingTransactionRequest);
        requests.add(holdTransactionRequest);

        Map<String, Object> request = this.createGenericRequest(requests);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        for (Map<String, Object> response : responses) {
            List<Object> errors = (List<Object>)response.get('Errors');
            if (errors != null) {
                String message = this.parseErrors(errors);
                throw new DataServiceException(message);
            }
        }

        Map<String, Object> transactionsMap = responses[0];
        Map<String, Object> pendingTransactionsMap = responses[1];
        Map<String, Object> holdTransactionsMap = responses[2];

        List<Map<String, Object>> rawTransactions = APIUtils.convertObjectList((List<Object>)transactionsMap.get('Transactions'));
        List<Map<String, Object>> rawPendingTransactions = APIUtils.convertObjectList((List<Object>)pendingTransactionsMap.get('PendingTransactions'));
        List<Map<String, Object>> rawHoldTransactions = APIUtils.convertObjectList((List<Object>)holdTransactionsMap.get('AccountHolds'));

        List<IAccountTransaction> transactions = this.parseTransactions(rawTransactions);
        List<IAccountTransaction> pendingTransactions = this.parsePendingTransactions(rawPendingTransactions);
        List<IAccountTransaction> holdTransactions = this.parseHoldTransactions(rawHoldTransactions);

        transactions.addAll(pendingTransactions);
        transactions.addAll(holdTransactions);

        transactions.sort();

        if (sortOrder == Metadata.SortOrder.ASC_X) {
            return transactions;
        } else {
            // Sort descending
            List<IAccountTransaction> descTransactions = new List<IAccountTransaction>();
            for(Integer i = transactions.size()-1; i>=0; i--)
                {
                    descTransactions.add(transactions.get(i));
                }
            return descTransactions;
        }
    }

    //Overloaded Function
    public Map<String, List<IAccountTransaction>> getTransactions(List<String> accountNumbers, DateTime startDate, DateTime endDate) {
        return this.getTransactions(accountNumbers, startDate, endDate, Metadata.SortOrder.ASC_X);
    }

    /**
     * Fetches the IAccountTransaction instances of a list of IAccount
     * @param accountNumbers The accounts for which transactions should be obtained.
     * @return Map of List IAccountTransaction objects belonging to the accounts;
     */
    public Map<String, List<IAccountTransaction>> getTransactions(List<String> accountNumbers, DateTime startDate, DateTime endDate, Metadata.SortOrder sortOrder) {
        if (accountNumbers == null) {
            throw new IllegalArgumentException('The `accountNumber` may NOT be null.');
        } else if (accountNumbers.size() == 0) { // No need to proceed
            return new Map<String, List<IAccountTransaction>>();
        } else if (startDate == null) {
            throw new IllegalArgumentException('The `startDate` may NOT be null.');
        } else if (endDate == null) {
            throw new IllegalArgumentException('The `endDate` may NOT be null.');
        }

        if (sortOrder == null) {
            sortOrder = Metadata.SortOrder.ASC_X;
        }

        String dnaStartDate = super.createDNADate(startDate);
        String dnaEndDate = super.createDNADate(endDate);

        List<Map<String, Object>> transactionRequests = new List<Map<String, Object>>();

        for (String accountNumber : accountNumbers) {
            Map<String, Object> transactionRequest = new Map<String, Object>();
            transactionRequest.put('AccountNumber', accountNumber);
            transactionRequest.put('FromDate', dnaStartDate);
            transactionRequest.put('ThroughDate', dnaEndDate);
            transactionRequest.put('__type', 'AccountTransactionHistoryRequest:http://www.opensolutions.com/CoreApi');

            transactionRequests.add(transactionRequest);
        }

        Map<String, Object> request = this.createGenericRequest(transactionRequests);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, List<IAccountTransaction>> transResponse = new Map<String, List<IAccountTransaction>>();

        for (Map<String, Object> transactionsMap : responses) {
            List<Object> errors = (List<Object>)transactionsMap.get('Errors');
            if (errors != null) {
                String message = this.parseErrors(errors);
                throw new DataServiceException(message);
            }

            List<Map<String, Object>> rawTransactions = APIUtils.convertObjectList((List<Object>)transactionsMap.get('Transactions'));
            Long accountNumber = (Long)transactionsMap.get('AccountNumber');

            List<IAccountTransaction> transactions = this.parseTransactions(rawTransactions);
            transactions.sort();
            if (sortOrder == Metadata.SortOrder.DESC_X) {

                // Sort descending
                List<IAccountTransaction> descTransactions = new List<IAccountTransaction>();
                for(Integer i = transactions.size()-1; i>=0;i--) {
                    descTransactions.add(transactions.get(i));
                }
                transactions = descTransactions;
            }

            transResponse.put(String.valueOf(accountNumber), transactions);
        }

        return transResponse;
    }

    //Overloaded Function
    public Map<String, List<IAccountTransaction>> getTransactions(List<IAccount> accounts, DateTime startDate, DateTime endDate) {
        return this.getTransactions(accounts, startDate, endDate, Metadata.SortOrder.ASC_X);
    }

    /**
     * Fetches the IAccountTransaction instances of a list of IAccount
     * @param accounts The accounts for which transactions should be obtained.
     * @return Map of List IAccountTransaction objects belonging to the accounts;
     */
    public Map<String, List<IAccountTransaction>> getTransactions(List<IAccount> accounts, DateTime startDate, DateTime endDate,  Metadata.SortOrder sortOrder) {
        if (accounts == null) {
            throw new IllegalArgumentException('The `accounts` cannot be null.');
        }

        List<String> accountNumbers = new List<String>();

        for (IAccount account : accounts) {
            String accountNumber = account.getAccountNumber();

            if (accountNumber != null) { // Sanity check
                accountNumbers.add(accountNumber);
            }
        }

        return this.getTransactions(accountNumbers, startDate, endDate, sortOrder);
    }

    /**
     * Parses the joint account holders returned by DNA.
     * @param rawJointOwners The List of raw objects to parse
     * @return The list of joint owners parsed.
     */
    @TestVisible
    private List<DNAJointAccountOwner> parseJointOwners(List<Map<String, Object>> rawJointOwners) {
        List<DNAJointAccountOwner> owners = new List<DNAJointAccountOwner>();

        for (Map<String, Object> rawOwner : rawJointOwners) {
            Boolean canTransact = (Boolean)rawOwner.get('CanTransact');
            String entityNumber = String.valueOf((Integer)rawOwner.get('EntityNumber'));
            String entityType = (String)rawOwner.get('EntityTypeCode');
            String fullName = (String)rawOwner.get('EntityName');
            String roleCode = (String)rawOwner.get('RoleCode');
            String roleDescription = (String)rawOwner.get('RoleDescription');

            DNAJointAccountOwner owner = new DNAJointAccountOwner(canTransact, entityNumber, entityType, fullName, roleCode, roleDescription);

            owners.add(owner);
        }

        return owners;
    }

    /**
     * Returns a map of DNA major type codes and a user friendly name
     */
    @TestVisible
    private Map<String, DNAAccountTypeCode> getMajorAccountTypes() {

        Map<String, DNAAccountTypeCode> codes = new Map<String, DNAAccountTypeCode>();
        codes.put('RR',    new DNAAccountTypeCode('RR', 'Regulatory Reporting'));
        codes.put('TD',    new DNAAccountTypeCode('TD', 'Certificates'));
        codes.put('CK',    new DNAAccountTypeCode('CK', 'Checking'));
        codes.put('CNS', new DNAAccountTypeCode('CNS', 'Consumer Loan'));
        codes.put('MTG', new DNAAccountTypeCode('MTG', 'Mortgage Loan'));
        codes.put('BKCK', new DNAAccountTypeCode('BKCK', 'Official Check Accounts'));
        codes.put('RTMT', new DNAAccountTypeCode('RTMT', 'Retirement Account'));
        codes.put('SAV', new DNAAccountTypeCode('SAV', 'Savings'));
        codes.put('CML', new DNAAccountTypeCode('CML', 'Commercial Loan'));
        codes.put('GL',    new DNAAccountTypeCode('GL', 'General Ledger'));
        codes.put('LEAS', new DNAAccountTypeCode('LEAS', 'Leased Assets'));
        codes.put('MLN', new DNAAccountTypeCode('MLN', 'Master Line'));
        codes.put('EXT', new DNAAccountTypeCode('EXT', 'Externally Serviced'));

        return codes;
    }

    private List<ICollateral> parseCollateral(List<Map<String, Object>> rawCollateral) {
        List<ICollateral> collateral = new List<ICollateral>();
        for (Map<String, Object> c : rawCollateral) {
            // Extract the account/role information that is returned as part of the response.
            List<DNAAccount> accounts = new List<DNAAccount>();
            List<Map<String, Object>> collateralAccounts = APIUtils.convertObjectList((List<Object>)c.get('AccountProperties'));
            for (Map<String, Object> a : collateralAccounts) {
                DNAAccount acct = new DNAAccount();
                acct.setAccountNumber(String.valueOf(a.get('AccountNumber')));

                // Set the owner on the account.
                List<DNAJointAccountOwner> jointOwners = new List<DNAJointAccountOwner>();
                Map<String, Object> taxOwner = (Map<String, Object>)a.get('TaxOwner');
                String personNumber = String.valueOf((Integer)taxOwner.get('OwnerPersonNumber'));
                String orgNumber = String.valueOf((Integer)taxOwner.get('OwnerPersonNumber'));
                String entityType = String.isBlank(personNumber) ? DNAConstants.ENTITY_TYPE_ORGANIZATION : DNAConstants.ENTITY_TYPE_PERSON;
                String entityNumber = entityType == DNAConstants.ENTITY_TYPE_PERSON ? personNumber : orgNumber;
                String fullName = (String)taxOwner.get('OwnerName');
                String roleCode = 'TAX';
                String roleDescription = 'Tax Owner';
                DNAJointAccountOwner owner = new DNAJointAccountOwner(null, entityNumber, entityType, fullName, roleCode, roleDescription);
                jointOwners.add(owner);
                acct.setJointOwners(jointOwners);

                accounts.add(acct);
            }

            String description = (String)c.get('PropertyDescription');
            String id = (String)c.get('PropertyId');
            String make = (String)c.get('PropertyMake');
            String model = (String)c.get('PropertyModel');
            String propertyNumber = String.valueOf((Integer)c.get('PropertyNumber'));
            Double purchasePrice = (Double)c.get('PurchasePrice');
            String typeCode = (String)c.get('PropertyTypeCode');
            Integer year = (Integer)c.get('PropertyYearNumber');
            Double value = (Double)c.get('PropertyValue');

            DNACollateral coll = new DNACollateral(accounts, description, id, make, model, propertyNumber, purchasePrice, typeCode, year, value);
            collateral.add(coll);
        }

        return collateral;
    }

    /**
     * Parses a list of raw hold transactions and creates IAccountTransaction instances
     * @param rawTransactions The list of raw transactions needed to be parsed.
     * @return List of IAccountTransaction instances
     */
    private List<IAccountTransaction> parseHoldTransactions(List<Map<String, Object>> rawTransactions) {
        List<IAccountTransaction> transactions = new List<IAccountTransaction>();
        for (Map<String, Object> rawTransaction : rawTransactions) {
            Double amount = (Double)rawTransaction.get('TransactionAmount');
            Double balance = null;
            String cardTransactionNumber = String.valueOf((Integer)rawTransaction.get('CardTransactionNumber'));
            String checkNumber = null;
            String description = (String)rawTransaction.get('HoldDescription');
            DateTime effectiveDate = this.parseDNADate((String)rawTransaction.get('EffectiveDate'));
            String externalDescription = (String)rawTransaction.get('ExternalRtxnDescription');
            String internalDescription = null;
            String internalDescriptionNumber = String.valueOf((Integer)rawTransaction.get('InternalRtxnDescriptionNumber'));
            Boolean isCredit = false; // Holds are only for debit cards in DNA
            Boolean isPending = true;
            String origPersonName = null;
            String origPersonNumber = null;
            DateTime postDate = null;
            String standardIndustryClassCode = null;
            String status = (String)rawTransaction.get('ResponseDescription');
            String transactionNumber = null;
            String typeCode = null;

            DNAAccountTransaction trans = new DNAAccountTransaction(
                amount,
                balance,
                cardTransactionNumber,
                checkNumber,
                description,
                effectiveDate,
                externalDescription,
                internalDescription,
                internalDescriptionNumber,
                isCredit,
                isPending,
                origPersonName,
                origPersonNumber,
                postDate,
                standardIndustryClassCode,
                status,
                transactionNumber,
                typeCode
            );
            transactions.add(trans);
        }

        return transactions;
    }

    /**
     * Parses a list of raw hold transactions and creates IAccountTransaction instances
     * @param rawTransactions The list of raw transactions needed to be parsed.
     * @return List of IAccountTransaction instances
     */
    private List<IAccountTransaction> parsePendingTransactions(List<Map<String, Object>> rawTransactions) {
        List<IAccountTransaction> transactions = new List<IAccountTransaction>();
        for (Map<String, Object> rawTransaction : rawTransactions) {
            Double amount = (Double)rawTransaction.get('TransactionAmount');
            Double balance = null;
            String cardTransactionNumber = null;
            String checkNumber = String.valueOf((Integer)rawTransaction.get('CheckNumber'));
            String description = (String)rawTransaction.get('RtxnTypeDescription');
            DateTime effectiveDate = null;
            String externalDescription = (String)rawTransaction.get('ExternalRtxnDescription');
            String internalDescription = null;
            String internalDescriptionNumber = String.valueOf((Integer)rawTransaction.get('InternalRtxnDescriptionNumber'));
            Boolean isCredit = 'C'.equals((String)rawTransaction.get('DebitCredit'));
            Boolean isPending = true;
            String origPersonName = null;
            String origPersonNumber = null;
            DateTime postDate = this.parseDNADate((String)rawTransaction.get('PostDate'));
            String standardIndustryClassCode = null;
            String status = (String)rawTransaction.get('FileRecordStatusCode');
            String transactionNumber = null;
            String typeCode = (String)rawTransaction.get('RtxnTypeCode');

            DNAAccountTransaction trans = new DNAAccountTransaction(
                amount,
                balance,
                cardTransactionNumber,
                checkNumber,
                description,
                effectiveDate,
                externalDescription,
                internalDescription,
                internalDescriptionNumber,
                isCredit,
                isPending,
                origPersonName,
                origPersonNumber,
                postDate,
                standardIndustryClassCode,
                status,
                transactionNumber,
                typeCode
            );
            transactions.add(trans);
        }

        return transactions;
    }

    /**
     * Parses a list of raw transactions and creates IAccountTransaction instances
     * @param rawTransactions The list of raw transactions needed to be parsed.
     * @return List of IAccountTransaction instances
     */
    private List<IAccountTransaction> parseTransactions(List<Map<String, Object>> rawTransactions) {

        List<IAccountTransaction> transactions = new List<IAccountTransaction>();

        for (Map<String, Object> rawTransaction : rawTransactions) {
            Double amount = (Double)rawTransaction.get('TransactionAmount');
            Double balance = (Double)rawTransaction.get('RunningBalance');
            String cardTransactionNumber = null;
            String checkNumber = String.valueOf((Integer)rawTransaction.get('CheckNumber'));
            String description = (String)rawTransaction.get('RtxnTypeDescription');
            DateTime effectiveDate = this.parseDNADate((String)rawTransaction.get('EffectiveDate'));
            String externalDescription = (String)rawTransaction.get('ExternalRtxnDescription');
            String internalDescription = (String)rawTransaction.get('InternalRtxnDescription');
            String internalDescriptionNumber = String.valueOf((Integer)rawTransaction.get('InternalRtxnDescriptionNumber'));
            Boolean isCredit = 'C'.equals((String)rawTransaction.get('DebitCredit'));
            Boolean isPending = false;
            String origPersonName = (String)rawTransaction.get('OriginatingPersonName');
            String origPersonNumber = String.valueOf((Integer)rawTransaction.get('OriginatingPersonNumber'));
            DateTime postDate = this.parseDNADate((String)rawTransaction.get('PostDate'));
            String standardIndustryClassCode = (String)rawTransaction.get('StandardIndustryClassCode');
            String status = (String)rawTransaction.get('CurrentRtxnStatisticsDescription');
            String transactionNumber = String.valueOf((Integer)rawTransaction.get('RtxnNumber'));
            String typeCode = (String)rawTransaction.get('RtxnTypeCode');

            DNAAccountTransaction trans = new DNAAccountTransaction(
                amount,
                balance,
                cardTransactionNumber,
                checkNumber,
                description,
                effectiveDate,
                externalDescription,
                internalDescription,
                internalDescriptionNumber,
                isCredit,
                isPending,
                origPersonName,
                origPersonNumber,
                postDate,
                standardIndustryClassCode,
                status,
                transactionNumber,
                typeCode
            );
            transactions.add(trans);
        }

        return transactions;
    }

    private DNAAccount parseAccount(Map<String, Object> rawAccount) {
        DNAAccount account = new DNAAccount();

        List<Map<String, Object>> jointOwnerInfo = APIUtils.convertObjectList((List<Object>)rawAccount.get('Roles'));
        List<DNAJointAccountOwner> jointOwners = this.parseJointOwners(jointOwnerInfo);

        account.setAccountNumber(String.valueOf(rawAccount.get('AccountNumber')));
        account.setAvailableBalance((Double)rawAccount.get('AvailableBalance'));
        account.setBranchName((String)rawAccount.get('BranchOrganizationName'));
        account.setCurrentBalance((Double)rawAccount.get('CurrentBalance'));
        account.setInterestRate((Double)rawAccount.get('InterestRate'));
        account.setJointOwners(jointOwners);
        account.setMajorType((String)rawAccount.get('MajorAccountTypeCode'));
        account.setMinorType((String)rawAccount.get('MinorAccountTypeCode'));
        account.setName((String)rawAccount.get('ProductFullName'));
        account.setNickName((String)rawAccount.get('AccountNickName'));
        account.setStatus((String)rawAccount.get('CurrentAccountStatusDescription'));

        String nextPaymentDueString = (String)rawAccount.get('NextPaymentDueDate');
        if (!String.isBlank(nextPaymentDueString)) {
            DateTime nextPaymentDate = super.parseDNADate(nextPaymentDueString);
            account.setNextPaymentDate(nextPaymentDate);
        }

        String majorType = account.getMajorType();
        List<Object> paymentPeriods = (List<Object>)rawAccount.get('PmtCalPeriods');
        Double nextPaymentAmount = parseAccountLoanNextPayment(paymentPeriods, majorType);
        account.setNextPaymentAmount(nextPaymentAmount);

        // Skip a pay eligibility
        List<Object> personOrganizationUserFields = (List<Object>)rawAccount.get('PersonOrganizationUserFields');
        Boolean canSkipPayment = parseAccountLoanSkipPayment(personOrganizationUserFields, majorType);
        account.setCanSkipPayment(canSkipPayment);

        // Get Visa Next Payment Amount
        Decimal visaNextPaymentAmount = parseVisaNextPaymentAmount(personOrganizationUserFields);
        account.setVisaNextPaymentAmount(visaNextPaymentAmount);


        return account;
    }

    private Double parseAccountLoanNextPayment(List<Object> paymentPeriodObjs, String accountMajorType) {
        if (paymentPeriodObjs == null) {
            return null;
        }

        List<Map<String, Object>> paymentPeriods = APIUtils.convertObjectList(paymentPeriodObjs);
        if (paymentPeriods.size() > 0) {
            Double paymentAmount = 0;
            Double escrowAmount = 0;
            if (accountMajorType == DNAConstants.MAJOR_ACCOUNT_TYPE_MORTGAGE) {
                for (Map<String, Object> paymentPeriod : paymentPeriods) {
                    String paymentTypeCode = (String)paymentPeriod.get('PaymentTypeCode');
                    if (paymentTypeCode == DNAConstants.PMT_TYPE_FIXED_PRINCIPAL_AND_INTEREST) {
                        paymentAmount = (Double)paymentPeriod.get('PaymentAmount');
                    }
                    if (paymentTypeCode == DNAConstants.PMT_TYPE_FIXED_BALANCE) {
                        escrowAmount = (Double)paymentPeriod.get('PaymentAmount');
                    }
                }
                Double finalPayment = paymentAmount + escrowAmount;
                return finalPayment;
            } else {
                Map<String, Object> period = paymentPeriods.get(0);
                paymentAmount = (Double)period.get('PaymentAmount');
                return paymentAmount;
            }
        }

        return null;
    }

    private Boolean parseAccountLoanSkipPayment(List<Object> personOrganizationUserFields, String accountMajorType) {
        if (personOrganizationUserFields == null) {
            return false;
        }

        List<Map<String, Object>> personUserFields = APIUtils.convertObjectList(personOrganizationUserFields);
        if (personUserFields.size() >= 0) {
            Boolean canSkip = false;
            for (Map<String, Object> personUserField : personUserFields) {
                String userFieldCode = (String)personUserField.get('UserFieldCode');
                if (userFieldCode == DNAConstants.USER_FIELD_SKIP_PAY && accountMajorType != DNAConstants.ACCOUNT_MAJOR_CREDIT_CARD) {
                    canSkip = true;
                }
                if (userFieldCode == DNAConstants.USER_FIELD_SKIP_PAY_VISA && accountMajorType == DNAConstants.ACCOUNT_MAJOR_CREDIT_CARD) {
                    canSkip = true;
                }
            }
            return canSkip;
        }
        return false;
    }

    private Decimal parseVisaNextPaymentAmount(List<Object> personOrganizationUserFields) {
        if (personOrganizationUserFields == null) {
            return 0;
        }

        List<Map<String, Object>> personUserFields = APIUtils.convertObjectList(personOrganizationUserFields);
        if (personUserFields.size() >= 0) {
            Decimal visaAmount = null;
            for (Map<String, Object> personUserField : personUserFields) {
                String userFieldCode = (String)personUserField.get('UserFieldCode');
                String value = (String)personUserField.get('Value');
                if (userFieldCode == DNAConstants.USER_FIELD_VISA_NEXT_PAYMENT) {
                    visaAmount = Decimal.valueOf(value);
                }
            }
            return visaAmount;
        }
        return 0;
    }

    /**
     * Parses a list of raw accounts and creates IAccount instances
     * @param rawAccounts The list of raw accounts needed to be parsed.
     * @return List of IAccount instances
     */
    private List<IAccount> parseAccounts(List<Map<String, Object>> rawAccounts) {
        List<IAccount> accounts = new List<IAccount>();

        for (Map<String, Object> rawAccount : rawAccounts) {
            Map<String, Object> accountInfo = (Map<String, Object>)rawAccount.get('AccountInfo');
            Map<String, Object> productInfo = (Map<String, Object>)rawAccount.get('Product');
            Map<String, Object> loanInfo = (Map<String, Object>)rawAccount.get('LoanAccountInfo');

            List<Map<String, Object>> jointOwnerInfo = APIUtils.convertObjectList((List<Object>)rawAccount.get('Roles'));

            if (accountInfo == null || productInfo == null || productInfo == null) {
                continue;
            }

            List<DNAJointAccountOwner> jointOwners = this.parseJointOwners(jointOwnerInfo);

            DNAAccount account = new DNAAccount();
            account.setAccountNumber(String.valueOf(rawAccount.get('AccountNumber')));
            account.setAvailableBalance((Double)accountInfo.get('AvailableBalance'));
            account.setBranchName((String)accountInfo.get('BranchOrgName'));
            account.setCurrentBalance((Double)accountInfo.get('CurrentBalance'));
            account.setInterestRate((Double)accountInfo.get('InterestRate'));
            account.setJointOwners(jointOwners);
            account.setMajorType((String)productInfo.get('MajorAccountType'));
            account.setMinorType((String)productInfo.get('MinorAccountType'));
            account.setName((String)productInfo.get('DisplayName'));
            account.setNickName((String)accountInfo.get('Nickname'));
            account.setStatus((String)accountInfo.get('AccountStatusDescription'));

            if (loanInfo != null) {
                String nextPaymentDueString = (String)loanInfo.get('NextPaymentDueDate');
                if (nextPaymentDueString != null) {
                    DateTime nextPaymentDate = super.parseDNADate(nextPaymentDueString);
                    account.setNextPaymentDate(nextPaymentDate);
                }

                String majorType = account.getMajorType();
                List<Object> paymentPeriods = (List<Object>)loanInfo.get('PmtCalPeriods');
                Double nextPaymentAmount = parseAccountLoanNextPayment(paymentPeriods, majorType);
                account.setNextPaymentAmount(nextPaymentAmount);
            }
            accounts.add(account);
        }

        return accounts;
    }

    /**
     * Parses a list of raw flags and creates DNAWarningFlag instances
     * @param rawFlags The list of raw flags needed to be parsed.
     * @return List of DNAWarningFlag instances
     */
    private List<IWarningFlag> parseWarningFlags(List<Map<String, Object>> rawFlags) {
        if (rawFlags == null) {
            return null;
        }

        List<DNAWarningFlag> flags = new List<DNAWarningFlag>();

        for (Map<String, Object> rawFlag : rawFlags) {
            String flagCode = (String)rawFlag.get('WarningFlagCode');
            DateTime effectiveDate = super.parseDNADate((String)rawFlag.get('EffectiveDate'));
            String flagCodeDescription = (String)rawFlag.get('WarningFlagDescription');
            DateTime inactiveDate = super.parseDNADate((String)rawFlag.get('InactiveDate'));
            String noteClassCode = (String)rawFlag.get('NoteClassCode');
            String noteClassCodeDescription = (String)rawFlag.get('NoteClassCodeDescription');
            String noteSubClassCode = (String)rawFlag.get('NoteSubClassCode');
            String noteSubClassCodeDescription = (String)rawFlag.get('NoteSubClassCodeDescription');
            String noteText = (String)rawFlag.get('NoteNumberText');

            DNAWarningFlag flag = new DNAWarningFlag(effectiveDate, flagCode, flagCodeDescription, inactiveDate, noteClassCode, noteClassCodeDescription, noteSubClassCode, noteSubClassCodeDescription, noteText);
            flags.add(flag);
        }

        return flags;
    }

    /**
     * Parses a list of raw flags and creates DNAWarningFlag instances
     * @param rawFlags The list of raw flags needed to be parsed.
     * @return List of DNAWarningFlag instances
     */
    private List<IWarningFlag> parseLockoutFlags(List<Map<String, Object>> rawFlags) {
        if (rawFlags == null) {
            return null;
        }

        List<DNAWarningFlag> flags = new List<DNAWarningFlag>();

        for (Map<String, Object> rawFlag : rawFlags) {
            String flagCode = (String)rawFlag.get('LockOutFlagCode');
            DateTime effectiveDate = super.parseDNADate((String)rawFlag.get('EffectiveDate'));
            String flagCodeDescription = (String)rawFlag.get('LockOutFlagDescription');
            DateTime inactiveDate = super.parseDNADate((String)rawFlag.get('InactiveDate'));
            String noteClassCode = (String)rawFlag.get('NoteClassCode');
            String noteClassCodeDescription = (String)rawFlag.get('NoteClassCodeDescription');
            String noteSubClassCode = (String)rawFlag.get('NoteSubClassCode');
            String noteSubClassCodeDescription = (String)rawFlag.get('NoteSubClassCodeDescription');
            String noteText = (String)rawFlag.get('NoteNumberText');

            DNAWarningFlag flag = new DNAWarningFlag(effectiveDate, flagCode, flagCodeDescription, inactiveDate, noteClassCode, noteClassCodeDescription, noteSubClassCode, noteSubClassCodeDescription, noteText);
            flags.add(flag);
        }

        return flags;
    }

    /**
     * Fetches a filtered list of accounts that have GAP
     * @param accounts The list of accounts that should be checked for active GAP.
     * @return List of IAccountTransactions that have GAP.;
     */
    public Map<String, List<IAccountTransaction>> getFilteredAccountTransactions(List<IAccount> accounts, List<String> typeCodes) {
        if (accounts.size() == 0) { // No need to proceed
            return new Map<String, List<IAccountTransaction>>();
        } else if (typeCodes.size() == 0) { // No need to proceed
            return new Map<String, List<IAccountTransaction>>();
        }

        String formattedTypeCodes = string.join(typeCodes,',');

        List<Map<String, Object>> requests = new List<Map<String, Object>>();

        for (IAccount account : accounts) {
            Map<String, Object> transactionRequest = new Map<String, Object>();
            transactionRequest.put('AccountNumber', account.getAccountNumber());
            transactionRequest.put('RtxnTypeCodes', formattedTypeCodes);
            transactionRequest.put('__type', 'AccountTransactionHistoryRequest:http://www.opensolutions.com/CoreApi');

            requests.add(transactionRequest);
        }

        Map<String, Object> request = this.createGenericRequest(requests);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, List<IAccountTransaction>> transactionResponse = new Map<String, List<IAccountTransaction>>();

        for (Map<String, Object> transactionsMap : responses) {
            List<Object> errors = (List<Object>)transactionsMap.get('Errors');
            if (errors != null) {
                String message = this.parseErrors(errors);
                throw new DataServiceException(message);
            }

            List<Map<String, Object>> rawTransactions = APIUtils.convertObjectList((List<Object>)transactionsMap.get('Transactions'));
            Long accountNumber = (Long)transactionsMap.get('AccountNumber');

            List<IAccountTransaction> transactions = this.parseTransactions(rawTransactions);

            transactionResponse.put(String.valueOf(accountNumber), transactions);
        }

        return transactionResponse;
    }
}