@isTest
private class DNAPersonDataProviderTest {
	@isTest
    private static void testGetPerson() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();
        System.assert(gottenAuthManager != null);

        IPerson person = provider.getPersonDetails('355061');
        System.assert('Wayne'.equals(person.getFirstName()));
        System.assert('Hartman'.equals(person.getLastName()));
        System.assert(person.getPreferredName().equals('Jake'));
        System.assert(person.getMobilePhone() == null);
        System.assert(person.getHomePhone() != null);
        System.assert(person.getMembershipDate() != null);
        
        List<String> personNumbers = new List<String>();
        personNumbers.add('345345');
        personNumbers.add('123433');
        
        List<IPerson> people = provider.getPersonDetails(personNumbers);
        System.assert(people.size() > 0);
        
        List<IPerson> noPeople = provider.getPersonDetails(new List<String>());
        System.assert(noPeople.size() == 0);
    }
    
    @isTest
    private static void testPersonContactInfoModels() {
        String email = 'test@example.com';
        EmailAddressType emailType = EmailAddressType.PRIMARY;

        EmailAddress addr = new EmailAddress(email, emailType);
        
        System.assert(addr.getAddress().equals(email));
        System.assert(addr.getEmailType() == emailType);
        
        String phone = '1234567890';
        PhoneNumberType phoneType = PhoneNumberType.HOME;
        PhoneNumber phoneNumber = new PhoneNumber(phone, phoneType);
        
        System.assert(phoneNumber.getValue().equals(phone));
        System.assert(phoneNumber.getPhoneType() == phoneType);
        System.assert('123'.equals(phoneNumber.getAreaCode()), 'Area code: ' + phoneNumber.getAreaCode());
        System.assert('456'.equals(phoneNumber.getPrefix()), 'Prefix: ' + phoneNumber.getPrefix());
        System.assert('7890'.equals(phoneNumber.getLineNumber()), 'Line number: ' + phoneNumber.getLineNumber());

        PhoneNumber badPhone = new PhoneNumber('', phoneType);

        System.assert(badPhone.getAreaCode() == null);
        System.assert(badPhone.getPrefix() == null);
        System.assert(badPhone.getLineNumber() == null);
    }
    
    @isTest
    private static void testUpdateContactInfoHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();
        System.assert(gottenAuthManager != null);
        
        List<IAddress> addresses = new List<IAddress>();
        DNAAddress address = new DNAAddress('city', 'countryCode', 'postalCode', 'stateCode', 'street');
        address.setAddressType(AddressType.PRIMARY);
        addresses.add(address);
        
        List<PhoneNumber> phoneNumbers = new List<PhoneNumber>();
        phoneNumbers.add(new PhoneNumber('1234567890', PhoneNumberType.HOME));
        
        List<EmailAddress> emailAddresses = new List<EmailAddress>();
        emailAddresses.add(new EmailAddress('test@example.com', EmailAddressType.PRIMARY));

        IPerson person = new DNAPerson('personNumber', 'firstName', 'lastName');
        
        IPerson updatedPerson = provider.updatePersonContactInfo(person, addresses, phoneNumbers, emailAddresses);
    }
		
	@isTest
    private static void testUpdateContactInfoUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();

        DNAAddress address = new DNAAddress('city', 'countryCode', 'postalCode', 'stateCode', 'street');
        address.setAddressType(AddressType.PRIMARY);

        List<IAddress> addresses = new List<IAddress>();
        addresses.add(address);
        
        List<PhoneNumber> phoneNumbers = new List<PhoneNumber>();
        phoneNumbers.add(new PhoneNumber('1234567890', PhoneNumberType.HOME));
        
        List<EmailAddress> emailAddresses = new List<EmailAddress>();
        emailAddresses.add(new EmailAddress('test@example.com', EmailAddressType.PRIMARY));

        IPerson person = new DNAPerson('personNumber', 'firstName', 'lastName');
        
        try {
            IPerson updatedPerson = provider.updatePersonContactInfo(null, addresses, phoneNumbers, emailAddresses);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
        try {
            IPerson updatedPerson = provider.updatePersonContactInfo(person, null, phoneNumbers, emailAddresses);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
        try {
            IPerson updatedPerson = provider.updatePersonContactInfo(person, addresses, null, emailAddresses);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
        try {
            IPerson updatedPerson = provider.updatePersonContactInfo(person, addresses, phoneNumbers, null);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
        try {
            IPerson badPerson = new DNAPerson(null, null, null);
            IPerson updatedPerson = provider.updatePersonContactInfo(badPerson, addresses, phoneNumbers, emailAddresses);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }

        try {
            List<PhoneNumber> badPhones = new List<PhoneNumber>();
            PhoneNumber badPhone = new PhoneNumber('(208) 555-5555', PhoneNumberType.HOME);
            badPhones.add(badPhone);
            
            IPerson updatedPerson = provider.updatePersonContactInfo(person, addresses, badPhones, emailAddresses);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
        try {
            List<IAddress> badAddresses = new List<IAddress>();
            badAddresses.add(new DNAAddress('city', 'countryCode', 'postalCode', 'stateCode', 'street')); // Missing its type

            IPerson updatedPerson = provider.updatePersonContactInfo(person, badAddresses, phoneNumbers, emailAddresses);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
        try {
            List<PhoneNumber> badPhones = new List<PhoneNumber>();
            badPhones.add(new PhoneNumber('2085555555', null));

            IPerson updatedPerson = provider.updatePersonContactInfo(person, addresses, badPhones, emailAddresses);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
        try {
            List<EmailAddress> badEmails = new List<EmailAddress>();
            badEmails.add(new EmailAddress('test@example.com', null));

            IPerson updatedPerson = provider.updatePersonContactInfo(person, addresses, phoneNumbers, badEmails);
            System.assert(false, 'Expected to throw an exception');
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest
    private static void testContactInfoModelCodes() {
        AddressType[] addressTypes = new AddressType[]{AddressType.ALTERNATE, AddressType.BIRTHPLACE, AddressType.INTEREST, AddressType.NOTICE, AddressType.PRIMARY, AddressType.SEASONAL, AddressType.STATEMENTOVERRIDE, AddressType.TAX};
		DNAPersonDataProvider provider = new DNAPersonDataProvider();
            
        for (AddressType addType : addressTypes) {
            String value = provider.addressCodeForAddressType(addType);
            System.assert(value != null);
        }
        
        String nullAddrValue = provider.addressCodeForAddressType(null);
        System.assert(nullAddrValue == null);
        
        PhoneNumberType[] phoneTypes = new PhoneNumberType[]{PhoneNumberType.BUSINESS, PhoneNumberType.CELL, PhoneNumberType.DONOTCALL, PhoneNumberType.FAX, PhoneNumberType.HOME, PhoneNumberType.OTHER, PhoneNumberType.PAGER, PhoneNumberType.RELATIVE, PhoneNumberType.SEASONAL, PhoneNumberType.VACATION};
		
		for (PhoneNumberType phoneType : phoneTypes) {
            String value = provider.phoneCodeForPhoneNumberType(phoneType);
            System.assert(value != null);
        }
        
        String nullPhoneValue = provider.phoneCodeForPhoneNumberType(null);
        System.assert(nullPhoneValue == null);
        
        EmailAddressType[] emailTypes = new EmailAddressType[]{EmailAddressType.BUSINESS, EmailAddressType.NPS, EmailAddressType.PRIMARY, EmailAddressType.RECEIPT};
        
        for (EmailAddressType emailType : emailTypes) {
			String value = provider.emailCodeForEmailType(emailType);
            System.assert(value != null);
        }
        
        String nullEmailValue = provider.emailCodeForEmailType(null);
        System.assert(nullEmailValue == null);
	}

    @isTest
    private static void testGetOrc() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();

		System.assert(gottenAuthManager != null);

        try {
            IOrganization orc = provider.getOrganizationDetails('355061');
            System.assert(orc.getAddress() != null, 'Orc address was null!');
            System.assert(orc.getEmailAddress() != null, 'Orc email was null!');
            System.assert(orc.getOrgNumber() != null, 'Orc number was null!');
            System.assert(orc.getEmailAddress() != null, 'Orc email was null!');
            System.assert(orc.getOrgType() != null, 'Orc type was null!');
            System.assert(orc.getPhoneNumber() != null, 'Orc phone # was null!');
            System.assert(orc.getTaxId() != null, 'Orc tax ID was null!');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        try {
            IOrganization orc = provider.getOrganizationDetails(null);
            System.assert(false, 'Expected an exception to be thrown.');
        } catch (IllegalArgumentException e) {
            // Expected to throw
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    @isTest
    private static void testAddressParsing() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        
        String streetAddress = '123 Penny Lane';
        String houseNumber = '#2';
        
        List<Map<String, Object>> rawAddresses = new List<Map<String, Object>>();
        
        List<Map<String, Object>> addressLines = new List<Map<String, Object>>();
        Map<String, Object> line1 = new Map<String, Object>();
        line1.put('AddressLineNumber', 1);
        line1.put('AddressLineText', streetAddress);

        Map<String, Object> line2 = new Map<String, Object>();
        line2.put('AddressLineNumber', 2);
        line2.put('AddressLineText', houseNumber);
        
        Map<String, Object> line3 = new Map<String, Object>();
        line3.put('AddressLineNumber', 3);
        line3.put('AddressLineText', 'line3');

        addressLines.add(line1);
        addressLines.add(line2);
        addressLines.add(line3);

        Map<String, Object> primaryAddress = new Map<String, Object>();
        primaryAddress.put('AddressUseCode', 'PRI');
        primaryAddress.put('AddressLines', addressLines);

        rawAddresses.add(primaryAddress);

        // Perform the actual test:
        DNAAddress address = provider.parseAddress(AddressType.PRIMARY, rawAddresses);
        System.assert(address.getStreet().equals(streetAddress + '\n' + houseNumber), address.getStreet());
        
        // Test null rawAddresses
        DNAAddress nullAddress = provider.parseAddress(AddressType.PRIMARY, null);
        System.assert(nullAddress == null);
        
        // Test null desired address
        DNAAddress nullDesiredAddress = provider.parseAddress(null, rawAddresses);
        System.assert(nullDesiredAddress == null);
        
        // Test non-existant desired address
        DNAAddress nonexistentDesiredAddress = provider.parseAddress(AddressType.NOTICE, rawAddresses);
        System.assert(nonexistentDesiredAddress == null);
    }
    
    @isTest
    private static void testWarningFlags() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        IPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();
        System.assert(gottenAuthManager != null);
        
        String personNumber = '983475';
        List<IPersonWarningFlag> flags = provider.getPersonWarningFlags(personNumber);
        System.assert(flags != null);
        System.assert(flags.size() > 0);

        DateTime effectiveDate = System.now().addMinutes(5);
        String flagCode = 'FlagCode';
        String flagCodeDescription = 'FlagCodeDescription';
        DateTime inactiveDate = System.now();
        String noteClassCode = 'NoteClassCode';
        String noteClassCodeDescription = 'NoteClassCodeDescription';
        String noteSubClassCode = 'NoteSubClassCode';
        String noteSubClassCodeDescription = 'NoteSubClassCodeDescription';
        String noteText = 'NoteNumberText';
        
        DNAPersonWarningFlag flag = new DNAPersonWarningFlag(effectiveDate, flagCode, flagCodeDescription, inactiveDate, noteClassCode, noteClassCodeDescription, noteSubClassCode, noteSubClassCodeDescription, noteText);
        System.assert(effectiveDate == flag.getEffectiveDate());
        System.assert(flagCode.equals(flag.getFlagCode()));
        System.assert(flagCodeDescription.equals(flag.getFlagCodeDescription()));
        System.assert(inactiveDate == flag.getInactiveDate());
        System.assert(noteClassCode.equals(flag.getNoteClassCode()));
        System.assert(noteSubClassCode.equals(flag.getNoteSubClassCode()));
        System.assert(noteSubClassCodeDescription.equals(flag.getNoteSubClassCodeDescription()));
        System.assert(noteText.equals(flag.getNoteText()));
        
        try {
            provider.getPersonWarningFlags(null);
            System.assert(false, 'Warning flags should have thrown an exception.');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'properly threw an exception.');
        }
    }
    
    @isTest
    private static void testUpdatePassword() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        IPersonDataProvider provider = new DNAPersonDataProvider(authManager);

        DNAPerson person = new DNAPerson('90809', 'Leroy', 'Jenkins');
        String password = 'password';
        String passwordHint = 'passwordHint';
        provider.updatePersonPhonePassword(person, password, passwordHint);
    }
    
    @isTest
    private static void testDateParsing() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);

        DateTime positiveDate = provider.parseDNADate('/Date(1351490400000-0600)');
        DateTime negativeDate = provider.parseDNADate('/Date(-1131001966000-0600)');
        DateTime badDate = provider.parseDNADate('asdfasdf');
        DateTime nullDate = provider.parseDNADate(null);
        
        System.assert(positiveDate != null);
        System.assert(negativeDate != null);
        System.assert(badDate == null);
        System.assert(nullDate == null);
    }

    @isTest
    private static void testGetVerificationQuestions() {
		Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        List<String> acceptableJointRoleCodes = new List<String>();
        acceptableJointRoleCodes.add('OWN');
        acceptableJointRoleCodes.add('TAX');
        integer merchantFrequencyThresholdCount = 4;
        integer numberOfRecentTransactions = 5;
        DateTime transactionEndDate = System.now();
        DateTime transactionStartDate = transactionEndDate.addDays(-300);
        
        PersonVerificationConfiguration config = new PersonVerificationConfiguration(acceptableJointRoleCodes, merchantFrequencyThresholdCount, numberOfRecentTransactions, transactionEndDate, transactionStartDate);
        System.assert(config.getAcceptableJointRoleCodes() == acceptableJointRoleCodes);
        System.assert(config.getMerchantFrequencyThresholdCount() == merchantFrequencyThresholdCount);
        System.assert(config.getNumberOfRecentTransactionsToFetch() == numberOfRecentTransactions);
        System.assert(config.getTransactionEndDate() == transactionEndDate);
        System.assert(config.getTransactionStartDate() == transactionStartDate);

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();
        System.assert(gottenAuthManager != null);

        String phonePassword = 'password';
        String phonePasswordHint = 'hint';
        
        DNAPerson person = new DNAPerson('personNumber', 'memberNumber', 'String preferredName', null, 'firstName', 'middleName', 'lastName', 'taxId', null, '2085555555', '2085555556', 'example@example.com', null, '123456');
        person.setPhonePassword(phonePassword);
        person.setPhonePasswordHint(phonePasswordHint);

        PersonVerificationQuestionGroup questionGroup = provider.getVerificationQuestions(person, config);
        System.assert(questionGroup != null);

        PersonVerificationQuestion testQuestion = new PersonVerificationQuestion('question', 'answer');
        System.assert(testQuestion.getQuestion().equals('question'));
        System.assert(testQuestion.getAnswer().equals('answer'));
        System.assert(testQuestion.getAnswers() != null);
        System.assert(testQuestion.getAnswers().size() > 0);

        String accountNumber = '1234567890';
        double availableBalance = (double)23.45;
        String branchName = 'branch name';
        double currentBalance = (double)11.98;
        double interestRate = (double)0.05456;
        List<DNAJointAccountOwner> jointOwners = new List<DNAJointAccountOwner>();
        String majorType = 'SAV';
        String minorType = 'SHR';
        String name = 'Share Savings';
        String nickName = 'My Savings!';
        DateTime nextPaymentDate = System.now();
        String status = 'status';

        IAccount savings = new DNAAccount(accountNumber, availableBalance, branchName, currentBalance, interestRate, jointOwners, majorType, minorType, name, nickName, status);

        List<IAccount> accounts = new List<IAccount>();
        accounts.add(savings);

		List<PersonVerificationQuestion> accountsQuestions = provider.getIdentifyingQuestions(person, accounts, config);
        System.assert(accountsQuestions != null);
        
        for (PersonVerificationQuestion q : accountsQuestions) {
            System.assert(q.getAnswers() != null);
            System.assert(q.getAnswer() != null);
        }

        // Test coverage 
        List<PersonVerificationQuestion> nullAccountsQuestions = provider.getIdentifyingQuestions(person, null, config);
    }

    @isTest
    private static void testGetPhonePassword() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());
        
        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        DNAPersonDataProvider provider = new DNAPersonDataProvider(authManager);
        IAuthenticationManager gottenAuthManager = provider.getAuthenticationManager();
        System.assert(gottenAuthManager != null);
        
        try {
            List<PersonVerificationQuestion> questions = provider.getPhonePassword(null);
            System.assert(false, 'Should have thrown an IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            // Expected Exception
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        try {
            List<PersonVerificationQuestion> questions = provider.getPhonePassword('123456');
			System.assert(questions != null, 'Questions were null!');

            Integer expectedSize = 2;
            Integer actualSize = questions.size();
            System.assertEquals(expectedSize, actualSize);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
	@isTest
    private static void testFindLastCheckNumber() {
        String accountNumber = '123456';
        double availableBalance = (double)10.10;
        String branchName = 'Chubbuck';
        double currentBalance = (double)9.01;
        double interestRate = (double)0.00457;
        String majorType = 'DEP';
        String minorType = 'SAV';
        String nickName = 'nickName';
        String name = 'name';
        DateTime nextPaymentDate = System.now();
        String status = 'status';
        
        DNAAccount account = new DNAAccount();
        account.setAccountNumber(accountNumber);
        account.setAvailableBalance(availableBalance);
        account.setBranchName(branchName);
        account.setCurrentBalance(currentBalance);
        account.setInterestRate(interestRate);
        account.setMajorType(majorType);
        account.setMinorType(minorType);
        account.setName(name);
        account.setNickName(nickName);
        account.setNextPaymentDate(nextPaymentDate);
        account.setStatus(status);

        DNAAccountTransaction nonCheck = new DNAAccountTransaction((double)1.21, (double)345.43, '3928475', 'Bubble gum', System.now(), 'aasdfasdfasdfasd', 'oiuwet,ndfg', false, 'originatingPerson', System.now(), 'status', null, 'INT');
        DNAAccountTransaction oldCheck = new DNAAccountTransaction((double)1.21, (double)345.43, '3928475', 'Bubble gum', System.now(), 'aasdfasdfasdfasd', 'oiuwet,ndfg', false, 'originatingPerson', System.now(), 'status', '12345', 'INT');
		DNAAccountTransaction recentCheck = new DNAAccountTransaction((double)1.21, (double)345.43, '3928475', 'Bubble gum', System.now().addMinutes(5), 'aasdfasdfasdfasd', 'oiuwet,ndfg', false, 'originatingPerson', System.now(), 'status', '78901', 'INT');

        List<IAccountTransaction> transactions = new List<IAccountTransaction>();
        transactions.add(oldCheck);
        transactions.add(recentCheck);
    }
    
    @isTest
    private static void testUnhappyGetPerson() {
        try {
            String personNumber = null;
            DNAPersonDataProvider provider = new DNAPersonDataProvider();
            provider.getPersonDetails(personNumber);
            System.assert(false, 'This should have thrown an Unauthenticated exception!');
        } catch(IllegalArgumentException e) {
            System.assert(true, 'Properly threw an exception');
        }
        
        try {
            List<String> personNumbers = null;
            DNAPersonDataProvider provider = new DNAPersonDataProvider();
            provider.getPersonDetails(personNumbers);
            System.assert(false, 'This should have thrown an Unauthenticated exception!');
        } catch(IllegalArgumentException e) {
            System.assert(true, 'Properly threw an exception');
        }
        
        try {
            DNAPersonDataProvider provider = new DNAPersonDataProvider();
            provider.getPersonDetails('355061');
            System.assert(false, 'This should have thrown an Unauthenticated exception!');
        } catch(UnauthenticatedException e) {
            System.assert(true, 'Properly threw an exception');
        }   
    }

    @isTest
    private static void testUnhappyGetVerificationQuestions() {
        try {
            DNAPersonDataProvider provider = new DNAPersonDataProvider();
            provider.getVerificationQuestions(null, null);
            System.assert(false, 'This should have thrown an Unauthenticated exception!');
        } catch(IllegalArgumentException e) {
            System.assert(true, 'Properly threw an exception');
        }
        
        try {
            List<String> acceptableJointRoleCodes = new List<String>();
            acceptableJointRoleCodes.add('OWN');
            acceptableJointRoleCodes.add('TAX');
            integer merchantFrequencyThresholdCount = 4;
            integer numberOfRecentTransactions = 5;
            DateTime transactionEndDate = System.now();
            DateTime transactionStartDate = transactionEndDate.addDays(-300);
            
            PersonVerificationConfiguration config = new PersonVerificationConfiguration(acceptableJointRoleCodes, merchantFrequencyThresholdCount, numberOfRecentTransactions, transactionEndDate, transactionStartDate);
            
			DNAPersonDataProvider provider = new DNAPersonDataProvider();
            IPerson person = new DNAPerson('1234');
            provider.getVerificationQuestions(person, config);

            System.assert(false, 'This should have thrown an Unauthenticated exception!');
        } catch(UnauthenticatedException e) {
            System.assert(true, 'Properly threw an exception');
        }
    }
    
    @isTest
    private static void testUnhappyUpdatePassword() {
        Test.setMock(HttpCalloutMock.class, new MockDNAResponse());

        IAuthenticationManager authManager = new DNAAuthenticationManagerMock();
        IPersonDataProvider provider = new DNAPersonDataProvider(authManager);

        DNAPerson person = new DNAPerson('90809', 'Leroy', 'Jenkins');
        String password = 'password';
        String passwordHint = 'passwordHint';
        
        try {
            provider.updatePersonPhonePassword(null, password, passwordHint);
            System.assert(false, 'should have thrown an exception.');
        } catch (Exception e) {
            System.assert(true);
        }
        
        try {
            provider.updatePersonPhonePassword(person, null, passwordHint);
            System.assert(false, 'should have thrown an exception.');
        } catch (Exception e) {
            System.assert(true);
        }
        
        try {
            provider.updatePersonPhonePassword(person, password, null);
            System.assert(false, 'should have thrown an exception.');
        } catch (Exception e) {
            System.assert(true);
        }
        
        try {
            provider.updatePersonPhonePassword(person, '', passwordHint);
            System.assert(false, 'should have thrown an exception.');
        } catch (Exception e) {
            System.assert(true);
        }
        
        try {
            provider.updatePersonPhonePassword(person, password, '');
            System.assert(false, 'should have thrown an exception.');
        } catch (Exception e) {
            System.assert(true);
        }
        
        DNAPerson nullPersonNumber = new DNAPerson(null, 'Leroy', 'Jenkins');
        try {
            provider.updatePersonPhonePassword(nullPersonNumber, password, passwordHint);
            System.assert(false, 'Should have thrown an exception');
        } catch (Exception e) {
            System.assert(true);
        }
        
        DNAPerson nullFirstName = new DNAPerson('234234', null, 'Jenkins');
        try {
            provider.updatePersonPhonePassword(nullFirstName, password, passwordHint);
            System.assert(false, 'Should have thrown an exception');
        } catch (Exception e) {
            System.assert(true);
        }
        
        DNAPerson nullLastName = new DNAPerson('234234', 'Leroy', null);
        try {
            provider.updatePersonPhonePassword(nullLastName, password, passwordHint);
            System.assert(false, 'Should have thrown an exception');
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    @isTest
    private static void testUnhappyWarningFlags() {
        
    }
    
    @isTest
    private static void testErrorParsing() {
        List<Map<String, Object>> errors = new List<Map<String, Object>>();
        Map<String, Object> mockError = new Map<String, Object>();
        mockError.put('ErrorMessage', 'error');
        errors.add(mockError);
        
        DNAPersonDataProvider provider = new DNAPersonDataProvider();
        String message = provider.parseErrors(errors);
        System.assert(message.equals('error '));
    }
}