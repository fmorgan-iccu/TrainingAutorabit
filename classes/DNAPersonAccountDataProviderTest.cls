@IsTest
private class DNAPersonAccountDataProviderTest {

    @IsTest
    private static void testHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();
        System.assert(gottenAuthManager != null);


        DNAPerson person = new DNAPerson('90809');
        DNAOrganization orc = new DNAOrganization(null, null, null, '18473864', null, null, null);
        List<IAccount> personAccounts = provider.getAccounts(person);

        System.assert(personAccounts != null);
        System.assert(personAccounts.size() > 0);

        List<IAccount> orcAccounts = provider.getAccounts(orc);

        System.assert(orcAccounts != null);
        System.assert(orcAccounts.size() > 0);

        IAccount account = personAccounts[0];

        DateTime endDate = System.now();
        DateTime startDate = endDate.addMonths(-2);

        List<IAccountTransaction> transactions = provider.getTransactions(account.getAccountNumber(), startDate, endDate, Metadata.SortOrder.ASC_X);
        System.assert(transactions != null);
        System.assert(transactions.size() > 0);

        List<String> accountNumbers = new List<String>();
        accountNumbers.add('1469641');
        accountNumbers.add('1752731');

        //Test Ascending
        Map<String, List<IAccountTransaction>> groupedTransactions = provider.getTransactions(accountNumbers, startDate, endDate, Metadata.SortOrder.ASC_X);
        System.assert(groupedTransactions != null);
        System.assert(groupedTransactions.keySet().size() > 0);

        List<IAccountTransaction> transactionList = null;
        for (String accountNumber : groupedTransactions.keySet()) {
            transactionList = groupedTransactions.get(accountNumber);
            System.assert(transactionList != null);
            System.assert(transactionList.size() > 0);
        }

        transactionList = groupedTransactions.get('1469641');
        System.assertEquals(2, transactionList.size());
        System.assertEquals('338', transactionList[0].getTransactionNumber());
        System.assertEquals('337', transactionList[1].getTransactionNumber());

        //Test Descending
        Map<String, List<IAccountTransaction>> groupedTransactionsDesc = provider.getTransactions(accountNumbers, startDate, endDate, Metadata.SortOrder.DESC_X);
        System.assert(groupedTransactionsDesc != null);
        System.assert(groupedTransactionsDesc.keySet().size() > 0);

        List<IAccountTransaction> transactionListDesc = null;
        for (String accountNumber : groupedTransactionsDesc.keySet()) {
            transactionListDesc = groupedTransactionsDesc.get(accountNumber);
            System.assert(transactionListDesc != null);
            System.assert(transactionListDesc.size() > 0);
        }

        transactionListDesc = groupedTransactionsDesc.get('1752731');
        System.assertEquals(14, transactionListDesc.size());
        System.assertEquals('278', transactionListDesc[0].getTransactionNumber());
        System.assertEquals('291', transactionListDesc[13].getTransactionNumber());
    }

    @IsTest
    private static void testGetAccount() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest();

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);
        IAccount account = provider.getAccount('1392541');

        Test.stopTest();

        System.assertEquals('1392541', account.getAccountNumber());
        System.assertEquals(16368.54, account.getAvailableBalance());
        System.assertEquals('Benton', account.getBranchName());
        System.assertEquals(16393.54, account.getCurrentBalance());
        System.assertEquals(0.0009996, account.getInterestRate());
        System.assert(account.getJointOwners().size() > 0);
        System.assertEquals('SAV', account.getMajorType());
        System.assertEquals('SBUS', account.getMinorType());
        System.assertEquals('Business Share Savings', account.getName());
        System.assertEquals('Business Savings', account.getNickName());
        System.assertEquals('Active', account.getStatus());
        System.assertEquals(null, account.getNextPaymentDate());
        System.assertEquals(null, account.getNextPaymentAmount());
    }

    @IsTest
    private static void testGetAccountWithPayoff() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        Test.startTest();

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);
        Date payoffDate = System.today();
        IAccount account = provider.getAccount('722847664', payoffDate);

        Test.stopTest();

        System.assertEquals('722847664', account.getAccountNumber());
        System.assertEquals('CNS', account.getMajorType());
        System.assertEquals('LBUA', account.getMinorType());
        System.assertEquals('Branch Used Auto Consumer Loan', account.getName());
        System.assertEquals(null, account.getNickName());
        System.assertEquals(1793.36, account.getPayoffAmount());
    }

    @IsTest
    private static void testGetCollateral() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);

        Test.startTest();

        List<ICollateral> collateral = provider.getCollateral('708120251');

        Test.stopTest();

        System.assertEquals(1, collateral.size());
        ICollateral c = collateral[0];
        List<IAccount> accounts = c.getAccounts();
        System.assertEquals(1, accounts.size());
        IAccount a = accounts[0];
        List<IJointAccountOwner> owners = a.getJointOwners();
        System.assertEquals(1, owners.size());
        IJointAccountOwner o = owners[0];

        System.assertEquals('2007 DODGE TRUCK Ram 3500 Pickup-V8 Mega Cab SLT 4WD Turbo Diesel - X(3/4)9', c.getDescription());
        System.assertEquals('3D7MX39A97G847928', c.getId());
        System.assertEquals('DODGE TRUCK', c.getMake());
        System.assertEquals('Ram 3500 Pickup-V8', c.getModel());
        System.assertEquals('210117', c.getPropertyNumber());
        System.assertEquals(24300.94, c.getPurchasePrice());
        System.assertEquals('210', c.getTypeCode());
        System.assertEquals(2007, c.getYear());
        System.assertEquals(30225.00, c.getValue());
        System.assertEquals('708120251', a.getAccountNumber());
        System.assertEquals('156308', o.getEntityNumber());
        System.assertEquals('Victoria L. Luft', o.getFullName());
        System.assertEquals(DNAConstants.ENTITY_TYPE_PERSON, o.getEntityType());
        System.assertEquals('TAX', o.getRoleCode());
    }

    @isTest
    private static void testTransactionObjects() {
        Double amount = (Double)1.21;
        Double balance = (Double)345.43;
        String cardTransactionNumber = null;
        String checkNumber = '3928475';
        String description = 'Bubble gum';
        String originatingPersonName = 'originatingPerson';
        String originatingPersonNumber = '99999';
        DateTime postDate = System.now();
        DateTime effectiveDate = postDate.addMinutes(5);
        String externalDescription = 'aasdfasdfasdfasd';
        String internalDescription = 'oiuwet,ndfg';
        String internalDescriptionNumber = '57123';
        Boolean isCredit = true;
        Boolean isPending = false;
        String standardIndustryClassCode = '100';
        String status = 'status';
        String transactionNumber = '98974';
        String typeCode = 'INT';

        DNAAccountTransaction dnaTransaction = new DNAAccountTransaction(
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
            originatingPersonName,
            originatingPersonNumber,
            postDate,
            standardIndustryClassCode,
            status,
            transactionNumber,
            typeCode
        );

        System.assertEquals(amount, dnaTransaction.getAmount());
        System.assertEquals(balance, dnaTransaction.getBalance());
        System.assertEquals(cardTransactionNumber, dnaTransaction.getCardTransactionNumber());
        System.assertEquals(checkNumber, dnaTransaction.getCheckNumber());
        System.assertEquals(description, dnaTransaction.getDescription());
        System.assertEquals(originatingPersonName, dnaTransaction.getOriginatingPersonName());
        System.assertEquals(originatingPersonNumber, dnaTransaction.getOriginatingPersonNumber());
        System.assertEquals(postDate, dnaTransaction.getPostDate());
        System.assertEquals(effectiveDate, dnaTransaction.getEffectiveDate());
        System.assertEquals(externalDescription, dnaTransaction.getExternalDescription());
        System.assertEquals(internalDescription, dnaTransaction.getInternalDescription());
        System.assertEquals(isCredit, dnaTransaction.getIsCredit());
        System.assertEquals(isPending, dnaTransaction.getIsPending());
        System.assertEquals(status, dnaTransaction.getStatus());
        System.assertEquals(standardIndustryClassCode, dnaTransaction.getStandardIndustryClassCode());
        System.assertEquals(transactionNumber, dnaTransaction.getTransactionNumber());
        System.assertEquals(typeCode, dnaTransaction.getTypeCode());
    }

    @IsTest
    private static void testDNADateMethods() {
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);

        DateTime now = System.now();
        String dnaDate = provider.createDNADate(now);
        DateTime convertedTime = provider.parseDNADate(dnaDate);

        System.assert(now == convertedTime, 'Dates did not match. Expected ' + now + ', received ' + convertedTime + '. DNADate = ' + dnaDate);
    }

    @IsTest
    private static void testAccountGroups() {
        String name = 'test name';
        AccountGroup accountGroup = new AccountGroup(name);

        System.assert(accountGroup.getName().equals(name));
        System.assert(accountGroup.getAccounts() != null);
        System.assert(accountGroup.getAccounts().size() == 0);

        List<IAccount> accounts = new List<IAccount>();
        DNAAccount account = new DNAAccount();
        accounts.add(account);

        accountGroup = new AccountGroup(name, accounts);
        System.assert(accountGroup.getName().equals(name));
        System.assert(accountGroup.getAccounts() != null);
        System.assert(accountGroup.getAccounts().size() == 1);

        String code = 'code';
        String displayValue = 'value';
        DNAAccountTypeCode typeCode = new DNAAccountTypeCode(code, displayValue);

        System.assert(code.equals(typeCode.getCode()));
        System.assert(displayValue.equals(typeCode.getDisplayName()));
    }

    @IsTest
    private static void testOrganizationWarningFlags() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);

        DNAAddress addr = new DNAAddress('Pocatello', 'USA', '83202', 'ID', '123 St.', AddressType.PRIMARY);
        DNAOrganization org = new DNAOrganization(addr, 'test@iccu.com', 'Test LLC', '12345', 'LLC', '(800) 123-1234', '12-1234567');
        List<IWarningFlag> flags = provider.getAllWarningFlags(org);

        System.assertEquals(2, flags.size());
    }

    @IsTest
    private static void testPersonWarningFlags() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);

        DNAPerson person = new DNAPerson('90809');
        List<IWarningFlag> flags = provider.getAllWarningFlags(person);

        System.assert(flags != null);
        System.assert(flags.size() > 0);
    }

    @IsTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        IPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);

        try {
            IPerson person = null;
            List<IAccount> accounts = provider.getAccounts(person);
            System.assert(false);
        } catch (IllegalArgumentException e) {
            System.assert(true);
        }

        try {
            IOrganization orc = null;
            List<IAccount> accounts = provider.getAccounts(orc);
            System.assert(false);
        } catch (IllegalArgumentException e) {
            System.assert(true);
        }

        try {
            List<IAccountTransaction> transactions = provider.getTransactions(null, null, null);
            System.assert(false);
        } catch (IllegalArgumentException e) {
            System.assert(true);
        }

        DNAPerson person = new DNAPerson('90809');
        List<IAccount> accounts = provider.getAccounts(person);
        IAccount account = accounts[0];

        try {
            List<IAccountTransaction> transactions = provider.getTransactions(account.getAccountNumber(), null, null);
            System.assert(false);
        } catch (IllegalArgumentException e) {
            System.assert(true);
        }

        DateTime now = System.now();

        try {
            List<IAccountTransaction> transactions = provider.getTransactions(account.getAccountNumber(), now, null);
            System.assert(false);
        } catch (IllegalArgumentException e) {
            System.assert(true);
        }
    }

}