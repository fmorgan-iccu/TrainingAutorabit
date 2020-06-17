/*
 *	Class implementing IPersonAccountDataProvider
 *	Connects to DNA and fetches all of the accounts of a person.
 */
public with sharing class DNAPersonAccountDataProvider extends DNACoreDataProvider implements IPersonAccountDataProvider {
	/*
	 *	Default constructor
	 */
	public DNAPersonAccountDataProvider() {
		super();
	}
	
	/*
	 *	Constructor for specifying the IAuthenticationManager.  Primarily to facilitate unit testing.
	 *	@authManager The IAuthenticationManager to use
	 */
	public DNAPersonAccountDataProvider(IAuthenticationManager authenticationManager) {
		super(authenticationManager);
	}

    /*
     *	Fetches the IAccount instances of an IPerson
     *	@param The person for which we should fetch their DNA accounts.
     *	@return A list of IAccount objects that belong to the person.
     */
    public List<IAccount> getAccounts(IPerson person) {
        if (person == null || person.getPersonNumber() == null) {
            throw new IllegalArgumentException('The person nor its person number may be null.');
        }
        
        List<IAccount> accounts = this.getAccounts('PERS', person.getPersonNumber());
        return accounts;
    }
    
    /*
     *	Fetches the IAccount instances of an IOrganization
     *	@param The orc for which we should fetch their DNA accounts.
     *	@return A list of IAccount objects that belong to the orc.
     */
    public List<IAccount> getAccounts(IOrganization organization) {
        if (organization == null || organization.getOrgNumber() == null) {
            throw new IllegalArgumentException('The organization nor its organization number may be null.');
        }

        List<IAccount> accounts = this.getAccounts('ORG', organization.getOrgNumber());
        return accounts;
    }

    /*
     *	Fetches the IPersonWarningFlag instances associated with the IAccounts of an IPerson
     *	@param person The person for which we should fetch their DNA account flags.
     *	@return A list of IPersonWarningFlag objects that belong to the IPerson's IAccounts.
     */
    public List<IPersonWarningFlag> getAllWarningFlags(IPerson person) {
        if (person == null || person.getPersonNumber() == null) {
            throw new IllegalArgumentException('The person nor its person number may be null.');
        }

        List<IAccount> accounts = this.getAccounts(person);
        List<IPersonWarningFlag> flags = this.getAllWarningFlags(accounts);

        return flags;
    }
    
    /*
     *	Fetches the IPersonWarningFlag instances associated with a list of IAccounts
     *	@param accounts The accounts for which we should fetch their DNA flags.
     *	@return A list of IPersonWarningFlag objects that belong to the IAccounts.
     */
    public List<IPersonWarningFlag> getAllWarningFlags(List<IAccount> accounts) {
        if (accounts == null) {
            throw new IllegalArgumentException('The accounts may not be null.');
        }
        if (accounts.size() == 0) {
        	return new List<IPersonWarningFlag>();
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

        List<IPersonWarningFlag> flags = new List<DNAPersonWarningFlag>();

        for (Map<String, Object> responseMap : responses) {
            List<IPersonWarningFlag> parsedFlags = null;
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
     *	Fetches the IAccount instances of an IPerson and groups them by their product type
     *	@param The person for which we should fetch their DNA accounts.
     *	@return A list of AccountGroup objects that belong to the person.
     */
    public List<AccountGroup> getAccountsGrouped(IPerson person) {
        List<IAccount> accounts = this.getAccounts(person);
        List<AccountGroup> groups = this.mapAccountsToGroups(accounts);

        return groups;
    }
    
    /*
     *	Fetches the IAccount instances of an IOrganization and groups them by their product type
     *	@param The orc for which we should fetch their DNA accounts.
     *	@return A list of AccountGroup objects that belong to the orc.
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
     *	Fetches the IAccountTransaction instances of an IAccount
     *	@param accountNumber The account for which transactions should be obtained.
     *	@return List of IAccountTransaction objects belonging to the account;
     */
    public List<IAccountTransaction> getTransactions(String accountNumber, DateTime startDate, DateTime endDate) {
        if (accountNumber == null) {
            throw new IllegalArgumentException('The accountNumber may NOT be null.');
        } else if (startDate == null) {
            throw new IllegalArgumentException('The startDate may NOT be null.');
        } else if (endDate == null) {
            throw new IllegalArgumentException('The endDate may NOT be null.');
        } else if (startDate > endDate) {
            throw new IllegalArgumentException('The start date cannot be after the end date.');
        }

        String dnaStartDate = super.createDNADate(startDate);
        String dnaEndDate = super.createDNADate(endDate);

        Map<String, Object> transactionRequest = new Map<String, Object>();
        transactionRequest.put('AccountNumber', accountNumber);
        transactionRequest.put('FromDate', dnaStartDate);
        transactionRequest.put('ThroughDate', dnaEndDate);
        transactionRequest.put('__type', 'AccountTransactionHistoryRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> pendingTransactionRequest = new Map<String, Object>();
        pendingTransactionRequest.put('AccountNumber', accountNumber);
        pendingTransactionRequest.put('FromDate', dnaStartDate);
        pendingTransactionRequest.put('ThroughDate', dnaEndDate);
        pendingTransactionRequest.put('__type', 'AccountTransactionHistoryRequest:http://www.opensolutions.com/CoreApi');

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
        List<IAccountTransaction> pendingTransactions = this.parseTransactions(rawPendingTransactions);
        List<IAccountTransaction> holdTransactions = this.parseTransactions(rawHoldTransactions);
        
        transactions.addAll(pendingTransactions);
        transactions.addAll(holdTransactions);
        
        transactions.sort();
        
        return transactions;
    }
    
    /**
     *	Fetches the IAccountTransaction instances of a list of IAccount
     *	@param accountNumbers The accounts for which transactions should be obtained.
     *	@return Map of List IAccountTransaction objects belonging to the accounts;
     */
    public Map<String, List<IAccountTransaction>> getTransactions(List<String> accountNumbers, DateTime startDate, DateTime endDate) {
        if (accountNumbers == null) {
            throw new IllegalArgumentException('The accountNumber may NOT be null.');
        } else if (accountNumbers.size() == 0) { // No need to proceed
            return new Map<String, List<IAccountTransaction>>();
        } else if (startDate == null) {
            throw new IllegalArgumentException('The startDate may NOT be null.');
        } else if (endDate == null) {
            throw new IllegalArgumentException('The endDate may NOT be null.');
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
            transResponse.put(String.valueOf(accountNumber), transactions);
        }
        
        return transResponse;
    }
    
    /**
     *	Fetches the IAccountTransaction instances of a list of IAccount
     *	@param accounts The accounts for which transactions should be obtained.
     *	@return Map of List IAccountTransaction objects belonging to the accounts;
     */
    public Map<String, List<IAccountTransaction>> getTransactions(List<IAccount> accounts, DateTime startDate, DateTime endDate) {
        if (accounts == null) {
            throw new IllegalArgumentException('Accounts cannot be null.');
        }

        List<String> accountNumbers = new List<String>();

        for (IAccount account : accounts) {
            String accountNumber = account.getAccountNumber();

            if (accountNumber != null) { // Sanity check
                accountNumbers.add(accountNumber);
            }
        }

        return this.getTransactions(accountNumbers, startDate, endDate);
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
            boolean canTransact = (boolean)rawOwner.get('CanTransact');
            String entityNumber = String.valueOf((integer)rawOwner.get('EntityNumber'));
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
        codes.put('RR',	new DNAAccountTypeCode('RR', 'Regulatory Reporting'));
        codes.put('TD',	new DNAAccountTypeCode('TD', 'Certificates'));
        codes.put('CK',	new DNAAccountTypeCode('CK', 'Checking'));
        codes.put('CNS', new DNAAccountTypeCode('CNS', 'Consumer Loan'));
        codes.put('MTG', new DNAAccountTypeCode('MTG', 'Mortgage Loan'));
        codes.put('BKCK', new DNAAccountTypeCode('BKCK', 'Official Check Accounts'));
        codes.put('RTMT', new DNAAccountTypeCode('RTMT', 'Retirement Account'));
        codes.put('SAV', new DNAAccountTypeCode('SAV', 'Savings'));
        codes.put('CML', new DNAAccountTypeCode('CML', 'Commercial Loan'));
        codes.put('GL',	new DNAAccountTypeCode('GL', 'General Ledger'));
        codes.put('LEAS', new DNAAccountTypeCode('LEAS', 'Leased Assets'));
        codes.put('MLN', new DNAAccountTypeCode('MLN', 'Master Line'));
        codes.put('EXT', new DNAAccountTypeCode('EXT', 'Externally Serviced'));

        return codes;
    }
    
    /**
     * Parses a list of raw transactions and creates IAccountTransaction instances
     * @param rawTransactions The list of raw transactions needed to be parsed.
     * @return List of IAccountTransaction instances
     */
    private List<IAccountTransaction> parseTransactions(List<Map<String, Object>> rawTransactions) {

        List<IAccountTransaction> transactions = new List<IAccountTransaction>();
        
        for (Map<String, Object> rawTransaction : rawTransactions) {
            double amount = (double)rawTransaction.get('TransactionAmount');
            double balance = (double)rawTransaction.get('RunningBalance'); // Not applicable for holds
            String description = (String)rawTransaction.get('RtxnTypeDescription'); // Not applicable for holds
            DateTime effectiveDate = this.parseDNADate((String)rawTransaction.get('EffectiveDate'));
            String externalDescription = (String)rawTransaction.get('ExternalRtxnDescription');
            String internalDescription = (String)rawTransaction.get('InternalRtxnDescription'); // Not applicable for holds
            boolean isCredit = 'C'.equals((String)rawTransaction.get('DebitCredit')); // Not applicable for holds
            String originatingPerson = (String)rawTransaction.get('OriginatingPersonName'); // Not applicable for holds
            DateTime postDate = this.parseDNADate((String)rawTransaction.get('PostDate')); // Not applicable for holds
            String status = (String)rawTransaction.get('CurrentRtxnStatisticsDescription'); // Not applicable for holds
            String transactionNumber = String.valueOf((integer)rawTransaction.get('RtxnNumber')); // Not applicable for holds
            String typeCode = (String)rawTransaction.get('RtxnTypeCode'); // Not applicable for holds
            integer checkNumber = (integer)rawTransaction.get('CheckNumber'); // Not applicable for holds
            String strCheckNumber = null;

            if (checkNumber != null) {
                strCheckNumber = String.valueOf(checkNumber);
            }

            DNAAccountTransaction trans = new DNAAccountTransaction(amount, balance, strCheckNumber, description, effectiveDate, externalDescription, internalDescription, isCredit, originatingPerson, postDate, status, transactionNumber, typeCode);

            transactions.add(trans);
        }
        
        transactions.sort();

		return transactions;
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

            // Sanity checking logic for loan info...
            if (loanInfo != null) {
                String nextPaymentString = (String)loanInfo.get('NextPaymentDueDate');

                if (nextPaymentString != null) {
                    DateTime nextPaymentDate = super.parseDNADate(nextPaymentString);
                    account.setNextPaymentDate(nextPaymentDate);
                }
                
                List<Object> paymentPeriodObjs = (List<Object>)loanInfo.get('PmtCalPeriods');
                if (paymentPeriodObjs != null) {
                    List<Map<String, Object>> paymentPeriods = APIUtils.convertObjectList(paymentPeriodObjs);
                    
                    if (paymentPeriods.size() > 0) {
                        Map<String, Object> period = paymentPeriods.get(0);
                        double paymentAmount = (double)period.get('PaymentAmount');
                        
                        account.setNextPaymentAmount(paymentAmount);
                    }
                }
            }

            accounts.add(account);
        }

        return accounts;
    }
    
    /**
     * Parses a list of raw flags and creates DNAPersonWarningFlag instances
     * @param rawFlags The list of raw flags needed to be parsed.
     * @return List of DNAPersonWarningFlag instances
     */
    private List<IPersonWarningFlag> parseWarningFlags(List<Map<String, Object>> rawFlags) {
        if (rawFlags == null) {
            return null;
        }

        List<DNAPersonWarningFlag> flags = new List<DNAPersonWarningFlag>();

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

            DNAPersonWarningFlag flag = new DNAPersonWarningFlag(effectiveDate, flagCode, flagCodeDescription, inactiveDate, noteClassCode, noteClassCodeDescription, noteSubClassCode, noteSubClassCodeDescription, noteText);
            flags.add(flag);
        }
        
        return flags;
    }
    
    /**
     * Parses a list of raw flags and creates DNAPersonWarningFlag instances
     * @param rawFlags The list of raw flags needed to be parsed.
     * @return List of DNAPersonWarningFlag instances
     */
    private List<IPersonWarningFlag> parseLockoutFlags(List<Map<String, Object>> rawFlags) {
        if (rawFlags == null) {
            return null;
        }

        List<DNAPersonWarningFlag> flags = new List<DNAPersonWarningFlag>();

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

            DNAPersonWarningFlag flag = new DNAPersonWarningFlag(effectiveDate, flagCode, flagCodeDescription, inactiveDate, noteClassCode, noteClassCodeDescription, noteSubClassCode, noteSubClassCodeDescription, noteText);
            flags.add(flag);
        }
        
        return flags;
    }
}