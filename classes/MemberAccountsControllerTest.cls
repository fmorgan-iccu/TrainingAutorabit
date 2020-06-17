@isTest
private class MemberAccountsControllerTest {
    @isTest
    private static void testHappyPath() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),  	
            MemberNumber__c = '23423987', 	
            Email = 'something@example.com',	
            FirstName = 'Jack', 
            LastName = 'Johnson',
            IsEmployee__c = false,
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555', 	
            TaxID__c = '000-00-0000', 
            PersonNumber__c = '123456',             	 
            Phone = '(555) 555-5555'
        );

        insert testContact;
        
        Contact testEmployeeContact = new Contact (
            Birthdate = Date.today(),  	
            MemberNumber__c = '0987864564', 	
            Email = 'something@example.com',	
            FirstName = 'Jack',
            IsEmployee__c = true,
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555', 	
            TaxID__c = '000-00-0001', 
            PersonNumber__c = '98765453',             	 
            Phone = '(555) 555-5555'
        );
        
        insert testEmployeeContact;
        
        Account testAccount = new Account (
            Email__c = 'email@example.com',
            Name = 'Test',
            OrganizationNumber__c = 'Test',
            OrganizationTaxID__c = '666-99-9999',
            OrganizationType__c = 'XXXX',
            Phone = '555-555-5555'
        );

        insert testAccount;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();

        MemberAccountsController.networkFactory = new ConcreteNetworkProvider(authManager);

        Map<String, Object> response = MemberAccountsController.getMemberAccountsList(testContact.Id);
        System.assert(response != null);
        System.assert(response.get('error') == null, (String)response.get('error'));

        List<Object> objectList = (List<Object>)response.get('accounts');
        System.assert(objectList != null, (String)response.get('error'));
        System.assert(objectList.size() > 0);

        for (Object obj : objectList) {
            Map<String, Object> rawAccount = (Map<String, Object>)obj;

            System.assert(rawAccount.get('accountNumber') != null);
            System.assert(rawAccount.get('availableBalance') != null);
            System.assert(rawAccount.get('branchName') != null);
            System.assert(rawAccount.get('currentBalance') != null);
            System.assert(rawAccount.get('interestRate') != null);
            System.assert(rawAccount.get('jointOwners') != null);
            System.assert(rawAccount.get('majorType') != null);
            System.assert(rawAccount.get('minorType') != null);
            System.assert(rawAccount.get('name') != null);
            System.assert(rawAccount.get('status') != null);

            List<Object> rawJointOwners = (List<Object>)rawAccount.get('jointOwners');

            for (Object ownerObj : rawJointOwners) {
                Map<String, Object> rawOwner = (Map<String, Object>)ownerObj;

                System.assert(rawOwner.get('canTransact') != null);
                System.assert(rawOwner.get('fullName') != null);
                System.assert(rawOwner.get('entityNumber') != null);
                System.assert(rawOwner.get('entityType') != null);
                System.assert(rawOwner.get('roleCode') != null);
                System.assert(rawOwner.get('roleDescription') != null);
            }
            
            DateTime endDate = System.now();
            DateTime startDate = endDate.addMonths(-5);

            Map<String, Object> transResponse = MemberAccountsController.getAccountTransactions(rawAccount, startDate, endDate);
            System.assert(transResponse != null);

            List<Object> objTransactions = (List<Object>)transResponse.get('transactions');
            System.assert(objTransactions != null);
   
            for (Object objTran : objTransactions) {
                Map<String, Object> rawTrans = (Map<String, Object>)objTran;
                
                System.assert(rawTrans.get('amount') != null, 'Amount was null.');
                System.assert(rawTrans.get('balance') != null, 'Balance was null.');
                System.assert(rawTrans.get('description') != null, 'Description was null.');
                System.assert(rawTrans.get('postDate') != null, 'Post Date was null.');
                System.assert(rawTrans.get('effectiveDate') != null, 'Effective Date was null.');
                System.assert(rawTrans.get('externalDescription') != null, 'externalDescription was null.');
                System.assert(rawTrans.get('internalDescription') != null, 'internalDescription was null.');
                System.assert(rawTrans.get('isCredit') != null, 'isCredit was null.');
                System.assert(rawTrans.get('status') != null, 'status was null.');
                System.assert(rawTrans.get('transactionNumber') != null, 'transactionNumber was null.');
                System.assert(rawTrans.get('typeCode') != null, 'Type code was null.');
            }
        }
        Map<String, Object> contactResponse = MemberAccountsController.getContact(testContact.Id);
        System.assert(contactResponse != null);
        System.assert(contactResponse.get('contact') != null);

        response = MemberAccountsController.getOrganizationAccountsGrouped(testAccount.Id);
        System.assert(response != null);
        System.assert(response.get('error') == null, (String)response.get('error'));

        System.debug('in-test Is Employee: ' + testEmployeeContact.IsEmployee__c);
        Map<String, Object> employeeResponse = MemberAccountsController.getMemberAccountsGrouped(testEmployeeContact.Id);
        System.assert(employeeResponse.get('error') != null, 'Expected this to throw an error! ' + response);
        
        Map<String, Object> employeeListResponse = MemberAccountsController.getMemberAccountsList(testEmployeeContact.Id);
        System.assert(employeeListResponse.get('error') != null, 'Expected this to throw an error!' + response);
        
        // Get the current account's profile to add as an acceptable profile for testing purposes.
        id userProfileID = UserInfo.getProfileId();
		Profile prof = [
            SELECT 
            	Name
            FROM 
            	profile
            WHERE id = :userProfileID
            LIMIT 1
        ];

        Set<String> acceptableProfiles = new Set<String>();
        acceptableProfiles.add(prof.Name);
        
        MemberAccountsController.validAccountProfiles = acceptableProfiles;

        Map<String, Object> supervisorEmployeeListResponse = MemberAccountsController.getMemberAccountsList(testEmployeeContact.Id);
        System.assert(supervisorEmployeeListResponse.get('error') == null, (String)employeeListResponse.get('error'));

        Test.stopTest();
    }
    
    @isTest
    private static void testSFAccount() {
        Double availableBalance = Double.valueOf(10.10);
        Double currentBalance = Double.valueOf(9.01);
        String major = 'DEP';
        String minor = 'SAV';
        String nickName = 'nickName';
        String accountNumber = '123456';
        String name = 'name';
        double nextPaymentAmount = (double)345.34;
        DateTime nextPaymentDate = System.now();
        String status = 'status';
        String branchName = 'Chubbuck';
        double interestRate = (double)234.34;
        List<IAccountTransaction> transactions = new List<IAccountTransaction>();
        
        SFAccount account = new SFAccount(availableBalance, currentBalance, name, major, minor, nickName, accountNumber);
        account.setNextPaymentDate(nextPaymentDate);
        account.setStatus(status);
        account.setNextPaymentAmount(nextPaymentAmount);
        account.setBranchName(branchName);
        account.setInterestRate(interestRate);
        account.setTransactions(transactions);
        
        System.assert(account.getAccountNumber().equals(accountNumber));
        System.assert(account.getAvailableBalance() == availableBalance);
        System.assert(account.getBranchName().equals(branchName));
        System.assert(account.getCurrentBalance() == currentBalance);
        System.assert(account.getInterestRate() == interestRate);
        System.assert(account.getJointOwners() != null);
        System.assert(account.getJointOwners().size() == 0);
        System.assert(account.getMajorType().equals(major));
        System.assert(account.getMinorType().equals(minor));
        System.assert(account.getName().equals(name));
        System.assert(account.getNextPaymentAmount() == nextPaymentAmount);
        System.assert(account.getNextPaymentDate() == nextPaymentDate);
        System.assert(account.getNickName().equals(nickName));
        System.assert(account.getStatus().equals(status));
        System.assert(account.getTransactions() == transactions);
    }
    
    @isTest
    private static void testAccountGroups() {
        Contact testContact = new Contact (
            Birthdate = Date.today(),  	
            MemberNumber__c = '23423987', 	
            Email = 'something@example.com',	
            FirstName = 'Jack', 
            LastName = 'Johnson', 
            MailingStreet = '123 Penny Lane', 
            MailingCity = 'Chubbuck', 
            MailingState = 'ID', 
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555', 	
            TaxID__c = '000-00-0000', 
            PersonNumber__c = '123456',             	 
            Phone = '(555) 555-5555'
        );
        
        insert testContact;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();

        MemberAccountsController.networkFactory = new ConcreteNetworkProvider(authManager);

        Map<String, Object> response = MemberAccountsController.getMemberAccountsGrouped(testContact.Id);
        System.assert(response != null);
        System.assert(response.get('error') == null, (String)response.get('error'));
        
        List<Object> groups = (List<Object>)response.get('accounts');
        System.assert(groups != null);
        
        for (Object accountGroupObject : groups) {
            Map<String, Object> accountGroup = (Map<String, Object>)accountGroupObject;
            String name = (String)accountGroup.get('name');
            List<Map<String, Object>> accountList = (List<Map<String, Object>>)accountGroup.get('accounts');
            
            System.assert(name != null);
            System.assert(accountList != null);
            System.assert(accountList.size() != 0);
        }
    }
    
    @isTest
    private static void testEmptyDateRangesTransactions() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();

        MemberAccountsController.networkFactory = new ConcreteNetworkProvider(authManager);
        
        Map<String, Object> accountRequest = new Map<String, Object>();
        accountRequest.put('accountNumber', '2343454');

        Map<String, Object> response = MemberAccountsController.getAccountTransactions(accountRequest, null, null);
        String error = (String)response.get('error');
        System.assert(error == null, 'Service should have finished without exception while NOT passing a date range: ' + error);
    }
    
    @isTest
    private static void testUnappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();

        MemberAccountsController.networkFactory = new ConcreteNetworkProvider(authManager);

        Map<String, Object> listResponse = MemberAccountsController.getMemberAccountsList(null);
        System.assert(listResponse.get('error') != null);

        Map<String, Object> groupResponse = MemberAccountsController.getMemberAccountsGrouped(null);
        String groupError = (String)groupResponse.get('error');
        System.assert(groupError != null, groupError);

        groupResponse = MemberAccountsController.getOrganizationAccountsGrouped(null);
        groupError = (String)groupResponse.get('error');
        System.assert(groupError != null, groupError);
        
        Map<String, Object> nullRequestResponse = MemberAccountsController.getAccountTransactions(null, null, null);
        System.assert(nullRequestResponse.get('error') != null);
        
        Map<String, Object> nullAccountNumberResponse = MemberAccountsController.getAccountTransactions(new Map<String, Object>(), null, null);
        System.assert(nullAccountNumberResponse.get('error') != null);
    }
}