@isTest
private class DNAPersonAccountDataProviderTest {
    @isTest
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
        
        List<IAccountTransaction> transactions = provider.getTransactions(account.getAccountNumber(), startDate, endDate);
        System.assert(transactions != null);
        System.assert(transactions.size() > 0);
        
        List<String> accountNumbers = new List<String>();
        accountNumbers.add('12345');
        accountNumbers.add('45644');

        Map<String, List<IAccountTransaction>> groupedTransactions = provider.getTransactions(accountNumbers, startDate, endDate);
		System.assert(groupedTransactions != null);
        System.assert(groupedTransactions.keySet().size() > 0);
        
        for (String accountNumber : groupedTransactions.keySet()) {
            List<IAccountTransaction> transactionList = groupedTransactions.get(accountNumber);
            System.assert(transactionList != null);
            System.assert(transactionList.size() > 0);
        }
    }
    
    @isTest
    private static void testTransactionObjects() {
        double amount = (double)1.21;
        double balance = (double)345.43;
        String checkNumber = '3928475';
        String description = 'Bubble gum';
        String originatingPerson = 'originatingPerson';
        DateTime postDate = System.now();
        DateTime effectiveDate = postDate.addMinutes(5);
        String externalDescription = 'aasdfasdfasdfasd';
        String internalDescription = 'oiuwet,ndfg';
        boolean isCredit = true;
        String status = 'status';
        String transactionNumber = '98974';
        String typeCode = 'INT';

        DNAAccountTransaction dnaTransaction = new DNAAccountTransaction(amount, balance, checkNumber, description, effectiveDate, externalDescription, internalDescription, isCredit, originatingPerson, postDate, status, transactionNumber, typeCode);

        System.assert(dnaTransaction.getAmount() == amount);
        System.assert(dnaTransaction.getBalance() == balance);
        System.assert(dnaTransaction.getCheckNumber().equals(checkNumber));
        System.assert(dnaTransaction.getDescription().equals(description));
        System.assert(dnaTransaction.getOriginatingPerson().equals(originatingPerson));
        System.assert(dnaTransaction.getPostDate() == postDate);
        System.assert(dnaTransaction.getEffectiveDate() == effectiveDate);
        System.assert(dnaTransaction.getExternalDescription().equals(externalDescription));
        System.assert(dnaTransaction.getInternalDescription().equals(internalDescription));
        System.assert(dnaTransaction.getIsCredit() == isCredit);
        System.assert(dnaTransaction.getStatus().equals(status));
        System.assert(dnaTransaction.getTransactionNumber().equals(transactionNumber));
        System.assert(dnaTransaction.getTypeCode().equals(typeCode));
    }
    
    @isTest
    private static void testDNADateMethods() {
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);
        
        DateTime now = System.now();
        String dnaDate = provider.createDNADate(now);
        DateTime convertedTime = provider.parseDNADate(dnaDate);
        
        System.assert(now == convertedTime, 'Dates did not match. Expected ' + now + ', received ' + convertedTime + '. DNADate = ' + dnaDate);
    }
    
    @isTest
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
    
    @isTest
    private static void testWarningFlags() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonAccountDataProvider provider = new DNAPersonAccountDataProvider(authManager);
        
        DNAPerson person = new DNAPerson('90809');
        List<IPersonWarningFlag> flags = provider.getAllWarningFlags(person);

        System.assert(flags != null);
        System.assert(flags.size() > 0);
    }
    
    @isTest
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