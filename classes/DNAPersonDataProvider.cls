/*
 * Class that implements the IPersonDataProvider interface
 */
public with sharing class DNAPersonDataProvider extends DNACoreDataProvider implements IPersonDataProvider, IOrganizationDataProvider {
    private static String DATE_FORMAT = 'M/d/YYYY';

    /**
     * Default constructor
     */
    public DNAPersonDataProvider() {
        super();
    }

    /**
     * Constructor for specifying the IAuthenticationManager.  Primarily to facilitate unit testing.
     * @authManager The IAuthenticationManager to use
     */
    public DNAPersonDataProvider(IAuthenticationManager dnaCoreAuthenticationManager) {
        super(dnaCoreAuthenticationManager);
    }

    /**
     * Gets a person's details
     * @param personNumber The person number of the person
     * @return a DNAPerson instance that conforms to the IPerson interface
     */
    public DNAPerson getPersonDetails(String personNumber) {
        if (personNumber == null) {
            throw new IllegalArgumentException('The person number may not be null.');
        }

        Map<String, Object> personRequest = new Map<String, Object>();
        personRequest.put('PersonNumber', personNumber);
        personRequest.put('__type', 'PersonDetailInquiryRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(personRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> personMap = responses[0];
        List<Object> errors = (List<Object>)personMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new InvalidPersonException(message);
        }

        DNAPerson person = this.parsePerson(personMap);
        return person;
    }

    /*
     * Gets an orc's details
     * @param organizationNumber The orc number of the orc
     * @return a DNAOrganization instance that conforms to the IOrganization interface
     */
    public DNAOrganization getOrganizationDetails(String organizationNumber) {
       if (organizationNumber == null) {
            throw new IllegalArgumentException('The organization number may not be null.');
        }

        Map<String, Object> orcRequest = new Map<String, Object>();
        orcRequest.put('OrgNumber', organizationNumber);
        orcRequest.put('__type', 'OrgDetailInquiryRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(orcRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> orcMap = responses[0];
        List<Object> errors = (List<Object>)orcMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new InvalidPersonException(message);
        }

        DNAOrganization orc = this.parseOrganization(orcMap);

        return orc;
    }

    /*
     * Gets a person's details
     * @param personNumbers The list of person numbers of the people to getch
     * @return a List of DNAPerson instances that conforms to the IPerson interface
     */
    public List<IPerson> getPersonDetails(List<String> personNumbers) {
        if (personNumbers == null) {
            throw new IllegalArgumentException('The person numbers may not be null.');
        }

        if (personNumbers.size() == 0) {
            return new List<DNAPerson>();
        }

        List<Map<String, Object>> requests = new List<Map<String, Object>>();

        for (String personNumber : personNumbers) {
            Map<String, Object> personRequest = new Map<String, Object>();
            personRequest.put('PersonNumber', personNumber);
            personRequest.put('__type', 'PersonDetailInquiryRequest:http://www.opensolutions.com/CoreApi');

            requests.add(personRequest);
        }

        Map<String, Object> request = this.createGenericRequest(requests);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return new List<DNAPerson>();
        }

        List<DNAPerson> persons = new List<DNAPerson>();

        for (Map<String, Object> personMap : responses) {
            List<Object> errors = (List<Object>)personMap.get('Errors');
            if (errors != null) {
                String message = this.parseErrors(errors);
                throw new InvalidPersonException(message);
            }

            DNAPerson person = this.parsePerson(personMap);
            persons.add(person);
        }

        return persons;
    }

    /*
     * Get the verification questions of a person
     * @param person The IPerson for whom we should get their verification questions
     * @return PersonVerificationQuestionGroup to present to a user
     */
    public PersonVerificationQuestionGroup getVerificationQuestions(IPerson person, PersonVerificationConfiguration verificationConfiguration) {
        if (person == null || person.getPersonNumber() == null) {
            throw new IllegalArgumentException('The person nor its person number may not be null.');
        }

        if (verificationConfiguration == null) {
            throw new IllegalArgumentException('The verification configuration may not be null.');
        }

        DNAPersonAccountDataProvider accountProvider = new DNAPersonAccountDataProvider(super.getAuthenticationManager());
        DNAPerson dnaPerson = this.getPersonDetails(person.getPersonNumber());
        List<IAccount> accounts = accountProvider.getAccounts(person);

        List<PersonVerificationQuestion> identifyingQuestions = this.getIdentifyingQuestions(dnaPerson, accounts, verificationConfiguration);
        List<PersonVerificationQuestion> outOfWalletQuestions = this.getOutOfWalletQuestions(dnaPerson, accounts, verificationConfiguration);
        List<PersonVerificationQuestion> phonePasswordQuestions = this.getPhonePasswordQuestions(dnaPerson);

        PersonVerificationQuestionGroup questionGroup = new PersonVerificationQuestionGroup(identifyingQuestions, outOfWalletQuestions, phonePasswordQuestions);

        return questionGroup;
    }

    public String getProviderName() {
        return 'DNA';
    }

    /*
     * Get the warning flags, if any, associated with a person.
     * @param personNumber The person number for whom we should get their warning flags
     * @return A list of warning flags associated the person.  If there are none, it will return an empty list.
     */
    public List<IPersonWarningFlag> getPersonWarningFlags(String personNumber) {
        if (personNumber == null) {
            throw new IllegalArgumentException('The person number may not be null.');
        }

        Map<String, Object> warningFlagsRequest = new Map<String, Object>();
        warningFlagsRequest.put('PersonNumber', personNumber);
        warningFlagsRequest.put('__type', 'PersonWarningListRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(warningFlagsRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> warningsMap = responses[0];
        List<Object> errors = (List<Object>)warningsMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new InvalidPersonException(message);
        }

        List<Map<String, Object>> warningsList = APIUtils.convertObjectList((List<Object>)warningsMap.get('PersonWarnings'));

        List<DNAPersonWarningFlag> flags = new List<DNAPersonWarningFlag>();

        for (Map<String, Object> warning : warningsList) {
            String flagCode = (String)warning.get('FlagCode');
            DateTime effectiveDate = super.parseDNADate((String)warning.get('EffectiveDate'));
            String flagCodeDescription = (String)warning.get('FlagCodeDescription');
            DateTime inactiveDate = super.parseDNADate((String)warning.get('InactiveDate'));
            String noteClassCode = (String)warning.get('NoteClassCode');
            String noteClassCodeDescription = (String)warning.get('NoteClassCodeDescription');
            String noteSubClassCode = (String)warning.get('NoteSubClassCode');
            String noteSubClassCodeDescription = (String)warning.get('NoteSubClassCodeDescription');
            String noteText = (String)warning.get('NoteNumberText');

            DNAPersonWarningFlag flag = new DNAPersonWarningFlag(effectiveDate, flagCode, flagCodeDescription, inactiveDate, noteClassCode, noteClassCodeDescription, noteSubClassCode, noteSubClassCodeDescription, noteText);
            flags.add(flag);
        }

        return flags;
    }

    /**
     * Updates a person's phone password and hint
     * @param person The person being udpated
     * @param password The password to update
     * @param passwordHint The password hint to update
     */
    public void updatePersonPhonePassword(IPerson person, String password, String passwordHint) {
        boolean hasNullValues = password == null || passwordHint == null;

        if (hasNullValues) {
            throw new IllegalArgumentException('You MUST enter a password and hint');
        }

        boolean hasEmptyValues = password.length() == 0 || passwordHint.length() == 0;

        if (hasEmptyValues) {
            throw new IllegalArgumentException('You MUST enter a password and hint');
        }

        if (person == null) {
            throw new IllegalArgumentException('Person may NOT be null.');
        }

        String personNumber = person.getPersonNumber();
        String firstName = person.getFirstName();
        String lastName = person.getLastName();

        if (personNumber == null || firstName == null || lastName == null) {
            throw new IllegalArgumentException('Person number, first name, & last name may NOT be null.');
        }

        List<Map<String, String>> userFields = new List<Map<String, String>>();
        userFields.add(this.createUserField('PSWD', password));
        userFields.add(this.createUserField('PSHT', passwordHint));

        Map<String, String> name = new Map<String, String>();
        name.put('FirstName', firstName);
        name.put('LastName', lastName);

        Map<String, Object> updatePasswordRequest = new Map<String, Object>();
        updatePasswordRequest.put('PersonNumber', personNumber);
        updatePasswordRequest.put('Name', name);
        updatePasswordRequest.put('UserFields', userFields);
        updatePasswordRequest.put('__type', 'PersonMaintenanceRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = super.createGenericRequest(updatePasswordRequest);
        List<Map<String, Object>> responses = super.callApi(request);

        if (responses == null || responses.size() == 0) {
            return;
        }

        Map<String, Object> personMap = responses[0];
        List<Object> errors = (List<Object>)personMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new DataServiceException(message);
        }

        return; // If there were no errors, everything went great!
    }

    /**
     * Updates a person's contact information
     * @param person The person being udpated
     * @param addresses The addresses to update
     * @param phoneNumbers The phone numbers to update
     * @param emailAddresses The email addresses to update
     * @return DNAPerson that was updated.
     */
    public DNAPerson updatePersonContactInfo(IPerson person, List<IAddress> addresses, List<PhoneNumber> phoneNumbers, List<EmailAddress> emailAddresses) {
        if (person == null) {
            throw new IllegalArgumentException('Person may NOT be null.');
        }

        if (addresses == null) {
            throw new IllegalArgumentException('Address may NOT be null.');
        }

        if (phoneNumbers == null) {
            throw new IllegalArgumentException('Phone number may NOT be null.');
        }

        String personNumber = person.getPersonNumber();
        String firstName = person.getFirstName();
        String lastName = person.getLastName();

        if (personNumber == null || firstName == null || lastName == null) {
            throw new IllegalArgumentException('Person number, first name, & last name may NOT be null.');
        }

        List<Map<String, Object>> mappedAddresses = new List<Map<String, Object>>();
        for (IAddress address : addresses) {
            List<Map<String, Object>> addressLines = new List<Map<String, Object>>();

            if (address.getAddressType() == null) {
                throw new IllegalArgumentException('Address type may not be null.');
            }

            String addrCode = this.addressCodeForAddressType(address.getAddressType());
            if (addrCode == null) {
                throw new IllegalArgumentException('Address type not handled and is null.');
            }

            // The street address can contain numerous lines separated by carriage return and/or new line.
            // The type of the code will be detected from the contents of the address.
            String street = address.getStreet();
            for (String line : street.split('\\r?\\n')) {
                Map<String, Object> addressLine = new Map<String, Object>();
                addressLine.put('Value', line);
                addressLine.put('AddrLineTypCd', getAddressLineTypeCode(line));
                addressLines.add(addressLine);
            }

            Map<String, Object> mappedAddress = new Map<String, Object>();
            mappedAddress.put('AddressLines', addressLines);
            mappedAddress.put('CityName', address.getCity());
            mappedAddress.put('CountryCode', address.getCountryCode());
            mappedAddress.put('IsElectronic', false);
            mappedAddress.put('UseCode', addrCode);
            mappedAddress.put('ShouldUpdate', true); // Always hardcode to `true`
            mappedAddress.put('State', address.getStateCode());
            mappedAddress.put('ZipCode', address.getPostalCode());

            mappedAddresses.add(mappedAddress);
        }

        List<Map<String, Object>> mappedPhones = new List<Map<String, Object>>();
        for (PhoneNumber phone : phoneNumbers) {
            PhoneNumberType phoneType = phone.getPhoneType();
            if (phone.getPhoneType() == null) {
                throw new IllegalArgumentException('Phone type may not be null.');
            }

            // Verify that the phone number has the correct number of digits; yes, it must be a
            // ten digit phone number!  Only the home phone is required.
            Integer phoneLength = phone.getValue().length();
            if ((phoneType == PhoneNumberType.HOME && phoneLength != 10) ||
                (phoneType != PhoneNumberType.HOME && phoneLength != 10 && phoneLength != 0))
            {
                throw new IllegalArgumentException('Phone numbers must be 10-digits.');
            }

            String phoneCode = this.phoneCodeForPhoneNumberType(phoneType);
            if (phoneCode == null) {
                throw new IllegalArgumentException('Phone type not handled and is null.');
            }

            Map<String, Object> mappedPhone = new Map<String, Object>();
            mappedPhone.put('CountryCode', 'USA');
            mappedPhone.put('AreaCode', phone.getAreaCode());
            mappedPhone.put('Exchange', phone.getPrefix());
            mappedPhone.put('Number', phone.getLineNumber());
            mappedPhone.put('ShouldUpdate', true);
            mappedPhone.put('UsageCode', phoneCode);

            mappedPhones.add(mappedPhone);
        }

        List<Map<String, Object>> mappedEmails = new List<Map<String, Object>>();
        for (EmailAddress email : emailAddresses) {
            if (email.getEmailType() == null) {
                throw new IllegalArgumentException('Email type may not be null.');
            }

            String emailCode = this.emailCodeForEmailType(email.getEmailType());
            if (emailCode == null) {
                throw new IllegalArgumentException('Email type not handled and is null.');
            }

            Boolean isDelete = false;
            String emailAddress = email.getAddress();
            if (String.isBlank(emailAddress)) {
                emailAddress = 'delete@iccu.com';
                isDelete = true;
            }

            List<Map<String, Object>> addressLines = new List<Map<String, Object>>();
            Map<String, Object> addressLine = new Map<String, Object>();
            addressLine.put('AddrLine', emailAddress);
            addressLines.add(addressLine);

            // The order of these nodes is important to ensure the request doesn't fail.
            Map<String, Object> mappedEmail = new Map<String, Object>();
            mappedEmail.put('ElectronicAddressLines', addressLines);
            mappedEmail.put('addrUseCode', emailCode);
            mappedEmail.put('IsDelete', isDelete);

            mappedEmails.add(mappedEmail);
        }

        Map<String, String> name = new Map<String, String>();
        name.put('FirstName', firstName);
        name.put('LastName', lastName);

        Map<String, Object> updateContactInfoRequest = new Map<String, Object>();
        updateContactInfoRequest.put('PersonNumber', personNumber);
        updateContactInfoRequest.put('Name', name);
        updateContactInfoRequest.put('Addresses', mappedAddresses);
        updateContactInfoRequest.put('Phones', mappedPhones);
        updateContactInfoRequest.put('EmailAddresses', mappedEmails);
        updateContactInfoRequest.put('__type', 'PersonMaintenanceRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(updateContactInfoRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> responseMap = responses[0];
        List<Object> errors = (List<Object>)responseMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new DataServiceException(message);
        }

        return this.getPersonDetails(person.getPersonNumber());
    }

    /**
     * Maps an address type to its corresponding String code
     * @param addressType The type of address
     * @return The corresponding DNA String code.  If a case is missing, will return null
     */
    @TestVisible
    private String addressCodeForAddressType(AddressType addressType) {
        switch on addressType {
            when ALTERNATE {
                return 'ALT';
            }
            when BIRTHPLACE {
                return 'POB';
            }
            when INTEREST {
                return 'INT';
            }
            when NOTICE {
                return 'NOTC';
            }
            when PRIMARY {
                return 'PRI';
            }
            when SEASONAL {
                return 'SEA';
            }
            when STATEMENTOVERRIDE {
                return 'STMT';
            }
            when TAX {
                return 'IRS';
            }
            when else {
                return null;
            }
        }
    }

    @TestVisible String addressLineCodeForAddressLineType(AddressLineType addressLineType) {
        switch on addressLineType {
            when POST_OFFICE_BOX_NUMBER {
                return 'POBN';
            }
            when INTERNAL_MAIL_STOP {
                return 'INTL';
            }
            when APARTMENT_NUMBER {
                return 'APTN';
            }
            when STREET {
                return 'ST';
            }
            when ATTENTION {
                return 'ATTN';
            }
            when BUILDING_NUMBER {
                return 'BLDG';
            }
            when ROOM_NUMBER {
                return 'ROOM';
            }
            when SUITE_NUMBER {
                return 'STE';
            }
            when RURAL_ROUTE_NUMBER {
                return 'RR';
            }
            when HIGHWAY_ROUTE_NUMBER {
                return 'HC';
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Maps a phone number type to its corresponding String code
     * @param phoneType The type of phone number
     * @return The corresponding DNA String code.  If a case is missing, will return null
     */
    @TestVisible
    private String phoneCodeForPhoneNumberType(PhoneNumberType phoneType) {
        switch on phoneType {
            when BUSINESS {
               return 'BUS';
            }
            when CELL {
                return 'CELL';
            }
            when DONOTCALL {
                return 'DNC';
            }
            when FAX {
                return 'FAX';
            }
            when HOME {
                return 'PER';
            }
            when OTHER {
                return 'OTH';
            }
            when PAGER {
                return 'PAGE';
            }
            when RELATIVE {
                return 'REL';
            }
            when SEASONAL {
                return 'SEA';
            }
            when VACATION {
                return 'VAC';
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Maps an email type to its corresponding String code
     * @param emailType The type of Email
     * @return The corresponding DNA String code.  If a case is missing, will return null
     */
    @TestVisible
    private String emailCodeForEmailType(EmailAddressType emailType) {
        switch on emailType {
            when BUSINESS {
                return 'EBUS';
            }
            when NPS {
                return 'ENPS';
            }
            when PRIMARY {
                return 'EHOM';
            }
            when RECEIPT {
                return 'RCPT';
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Retrieves just the person's DNA phone password/hint.
     * @param personNumber The DNA person number for which the password is requested
     * @return List of PersonVerificationQuestion objects containing the password and hint, if applicable.
     */
    public List<PersonVerificationQuestion> getPhonePassword(String personNumber) {
        if (personNumber == null) {
            throw new IllegalArgumentException('Person number may NOT be null.');
        }

        DNAPerson dnaPerson = this.getPersonDetails(personNumber);

        return this.getPhonePasswordQuestions(dnaPerson);
    }

    /**
     * Convenience method for creating a DNA user field.
     * @param code The code of the user field
     * @param value The value of the user field
     * @return A Map containing the DNA code and value
     */
    private Map<String, String> createUserField(String code, String value) {
        Map<String, String> userField = new Map<String, String>();
        userField.put('Code', code);
        userField.put('Value', value);

        return userField;
    }

    /**
     * Inspects the contents of an address line to infer the DNA address line type to use.  This process
     * is somewhat subjective, but all of the checks have been developed from the user entered data.
     * @param  addressLine The address line to inspect and determine the type of.
     * @param  isFirstLine Indicates if the line is the first address line.
     * @return             The inferred address line type.
     */
    private String getAddressLineTypeCode(String addressLine) {
        String addrLineType = null;
        if (AddressUtils.isPostOfficeBox(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.POST_OFFICE_BOX_NUMBER);
        } else if (AddressUtils.isApartment(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.APARTMENT_NUMBER);
        } else if (AddressUtils.isApartment(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.BUILDING_NUMBER);
        } else if (AddressUtils.isApartment(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.SUITE_NUMBER);
        } else if (AddressUtils.isApartment(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.ATTENTION);
        } else {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.STREET);
        }
        return addrLineType;
    }

    /*
     * Get a list form the Identifying Questions list.  Can be found:
     * https://isearchwp.iccu.com/policy/non-member-member-identification/#confirming-identity-over-the-phone
     * @param person The DNAPerson for whom we should get their verification questions
     * @return List of identifying questions
     */
    @TestVisible
    private List<PersonVerificationQuestion> getIdentifyingQuestions(DNAPerson dnaPerson, List<IAccount> accounts, PersonVerificationConfiguration verificationConfiguration) {
        // Sanity check
        if (accounts == null) {
            accounts = new List<IAccount>();
        }

        List<PersonVerificationQuestion> questions = new List<PersonVerificationQuestion>();

        String maidenName = dnaPerson.getMotherMaidenName();
        if (maidenName != null) {
            questions.add(new PersonVerificationQuestion('What is your mother\'s maiden name?', maidenName));
        }

        IAddress address = dnaPerson.getPrimaryAddress();
        if (address != null) {
            questions.add(new PersonVerificationQuestion('What is your address?', address.toString()));
        }

        String taxId = dnaPerson.getTaxId();
        if (taxId != null) {
            Integer ssnLength = taxId.length();
            Integer startIndex = ssnLength - 4;
            String last4 = taxId.substring(startIndex);
            questions.add(new PersonVerificationQuestion('What are the last four digits of your social security number?', last4));
        }

        DateTime dob = dnaPerson.getDateOfBirth();
        if (dob != null) {
            questions.add(new PersonVerificationQuestion('What is your date of birth?', dob.formatGmt(DateUtils.DATE_FORMAT)));
        }

        String email = dnaPerson.getEmailAddress();
        if (email != null) {
            questions.add(new PersonVerificationQuestion('What is your email address?', email));
        }

        String memberNumber = dnaPerson.getMemberNumber();
        if (memberNumber != null) {
            questions.add(new PersonVerificationQuestion('What is your member number?', memberNumber));
        }

        if (accounts.size() > 0) {
            List<String> answers = new List<String>();

            for (IAccount account : accounts) {
                    String nickname = '';

                    if (account.getNickName() != null) {
                        nickname = ' (' + account.getNickName() + ') ';
                    }

                    answers.add('' + account.getName() + nickName + ' Number: ' + account.getAccountNumber());
            }

            questions.add(new PersonVerificationQuestion('What is your account number?', answers));

            IVerificationQuestionProvider jointVerificationProvider = new JointVerificationQuestionProvider(accounts, verificationConfiguration, this);
            List<PersonVerificationQuestion> jointQuestions = jointVerificationProvider.createVerificationQuestions();
            questions.addAll(jointQuestions);
        }

        String dlNumber = dnaPerson.getDriversLicenseNumber();
        if (dlNumber != null) {
            questions.add(new PersonVerificationQuestion('What is your drivers license number?', dlNumber));
        }

        return questions;
    }

    /*
     * Get a list from the Out of Wallet Questions list.  Can be found:
     * https://isearchwp.iccu.com/policy/non-member-member-identification/#confirming-identity-over-the-phone
     * @param person The IPerson for whom we should get their verification questions
     * @return List of Out of Wallet questions
     */
    @TestVisible
    private List<PersonVerificationQuestion> getOutOfWalletQuestions(IPerson person, List<IAccount> accounts, PersonVerificationConfiguration verificationConfiguration) {
        DateTime startDate = verificationConfiguration.getTransactionStartDate();
        DateTime endDate = verificationConfiguration.getTransactionEndDate();

        if (startDate == null) {
            startDate = System.now().addDays(-30);
        }

        if (endDate == null) {
            endDate = System.now();
        }

        DNAPersonAccountDataProvider accountProvider = new DNAPersonAccountDataProvider(super.getAuthenticationManager());
        // Map of accounts where the account number is the key
        Map<String, List<IAccountTransaction>> mappedTransactions = accountProvider.getTransactions(accounts, startDate, endDate);

        // Need to attach the transactions to the accounts
        for (IAccount account : accounts) {
            List<IAccountTransaction> transactions = mappedTransactions.get(account.getAccountNumber());
            List<IAccountTransaction> filteredTransactions = new List<IAccountTransaction>();

            if (transactions != null) {
                for (IAccountTransaction trans :  transactions) {
                    if (trans.getTypeCode() != null && trans.getTypeCode().equals(DNAAccountTransaction.DIRECT_DEPOSIT_TYPE_CODE)) { // Remove ALL direct deposits to eliminate ICCU payroll from coming through.
                        continue;
                    }

                    filteredTransactions.add(trans);
                }
            }

            account.setTransactions(filteredTransactions);
        }

        List<IVerificationQuestionProvider> questionProviders = new List<IVerificationQuestionProvider>();
        questionProviders.add(new LoanVerificationQuestionProvider(accounts));
        questionProviders.add(new CDVerificationQuestionProvider(person.getPersonNumber(), accounts));
        questionProviders.add(new TransactionVerificationQuestionProvider(accounts, verificationConfiguration));
        // Removed questions related to joint dates of birth, per request from MCC.

        List<PersonVerificationQuestion> questions = new List<PersonVerificationQuestion>();

        for (IVerificationQuestionProvider provider : questionProviders) {
            List<PersonVerificationQuestion> providedQuestions = provider.createVerificationQuestions();
            if (providedQuestions != null) {
                questions.addAll(providedQuestions);
            }
        }

        return questions;
    }

    /*
     * Get the phone password questions to be displayed.
     * @param person The person from whom we will contstruct the phone password questions.
     * @return List containing the phone password and hint, if present on the person.
     */
    private List<PersonVerificationQuestion> getPhonePasswordQuestions(DNAPerson person) {
        List<PersonVerificationQuestion> questions = new List<PersonVerificationQuestion>();

        String password = person.getPhonePassword();
        String passwordHint = person.getPhonePasswordHint();

        if (password != null) { // There may be situations where there is a password, but not a hint, so only checking for password. Bad data FTW.
            PersonVerificationQuestion passwordQuestion = new PersonVerificationQuestion('What is your phone password?', password);
            PersonVerificationQuestion hintQuestion = new PersonVerificationQuestion('Hint:', passwordHint);

            questions.add(passwordQuestion);
            questions.add(hintQuestion);
        }

        return questions;
    }

    /**
     * Parses IDs returned by DNA
     * @param desiredType The type of ID desired.
     * @param rawIDs The List of raw objects to parse
     * @return The value of the ID, if it exists in the list.
     */
    private String parseIDs(String desiredType, List<Map<String, Object>> rawIDs) {
        if (desiredType == null) {
            return null;
        }

        for (Map<String, Object> rawID : rawIDs) {
            String idType = (String)rawID.get('PersIdTypeCode');

            if (!idType.equals(desiredType)) {
                continue;
            }

            String value = (String)rawID.get('IdValue');
            return value;
        }

        return null;
    }

    /**
     * Parses address data returned by DNA
     * @param desiredType The type of address desired.
     * @param rawAddresses The List of raw objects to parse
     * @return The address desired, if it exists in the list.
     */
    @TestVisible
    private DNAAddress parseAddress(AddressType desiredType, List<Map<String, Object>> rawAddresses) {
        if (desiredType == null || rawAddresses == null) {
            return null;
        }

        String desiredTypeCode = addressCodeForAddressType(desiredType);
        for (Map<String, Object> rawAddress : rawAddresses) {
            String useCode = (String)rawAddress.get('AddressUseCode');
            if (!useCode.equals(desiredTypeCode)) {
                continue;
            }

            // Determine which address lines represent lines 1 and 2.  DNA defines the lowest line
            // number to be the first address line, the next lowest to be line 2, etc.  See
            // view_get_pers_address for details of the query.
            String line1 = null;
            String line2 = null;
            Integer line1Number = null;
            Integer line2Number = null;
            List<Map<String, Object>> addressLines = APIUtils.convertObjectList((List<Object>)rawAddress.get('AddressLines'));
            for (Map<String, Object> addressLine : addressLines) {
                Integer lineNumber = (Integer)addressLine.get('AddressLineNumber');
                if (line1Number == null || lineNumber < line1Number) {
                    line1 = (String)addressLine.get('AddressLineText');
                    line1Number = lineNumber;
                }
            }
            for (Map<String, Object> addressLine : addressLines) {
                Integer lineNumber = (Integer)addressLine.get('AddressLineNumber');
                if (lineNumber > line1Number && (line2Number == null || lineNumber < line2Number)) {
                    line2 = (String)addressLine.get('AddressLineText');
                    line2Number = lineNumber;
                }
            }

            String addressLine = line1 + (line2 != null ? '\n' + line2 : '');
            String city = (String)rawAddress.get('CityName');
            String stateCode = (String)rawAddress.get('StateCode');
            String countryCode = (String)rawAddress.get('CountryCode');
            String postalCode = (String)rawAddress.get('ZipCode');

            return new DNAAddress(city, countryCode, postalCode, stateCode, addressLine);
        }

        return null;
    }

    /**
     * Parses email addresses returned by DNA
     * @param desiredType The type of email address desired.
     * @param rawEmailAddresses The List of raw objects to parse
     * @return The email address, if it exists in the list.
     */
    private String parseEmail(String desiredType, List<Map<String, Object>> rawEmailAddresses) {
        if (desiredType == null) {
            return null;
        }

        for (Map<String, Object> rawEmailAddress : rawEmailAddresses) {
            String emailType = (String)rawEmailAddress.get('AddressUseCode');

            if (!emailType.equals(desiredType)) {
                continue;
            }

            List<Map<String, Object>> addressList = APIUtils.convertObjectList((List<Object>)rawEmailAddress.get('ElectronicAddressLines'));

            // There's not reason this should be a single object list.  Instead of adding tons of code
            // to 'safely' pull this out, we're forcing it.
            Map<String, Object> addressLines = addressList[0];

            String emailAddress = (String)addressLines.get('AddressLineText');
            return emailAddress;
        }

        return null;
    }

    /**
     * Parses Phone Numbers returned by DNA
     * @param desiredType The type of phone number desired.
     * @param rawPhoneNumbers The List of raw objects to parse
     * @return The phone number indicated, if it exists in the list.
     */
    private String parsePhoneNumber(String desiredType,  List<Map<String, Object>> rawPhoneNumbers) {
        if (desiredType == null) {
            return null;
        }

        for (Map<String, Object> rawNumber : rawPhoneNumbers) {
            String phoneType = (String)rawNumber.get('PhoneUseCode');

            if (!phoneType.equals(desiredType)) {
                continue;
            }

            String areaCode = (String)rawNumber.get('AreaCode');
            String exchange = (String)rawNumber.get('Exchange');
            String suffix = (String)rawNumber.get('PhoneNumber');
            String extension = (String)rawNumber.get('PhoneExtension');

            String fullNumber = '(' + areaCode + ') ' + exchange + '-' + suffix + (extension != null ? ' Ext: ' + extension : '');
            return fullNumber;
        }

        return null;
    }

    /**
     * Parses user fields returned by DNA
     * @param userFieldCode The user field code we should be searching.
     * @param rawUserFields The List of raw objects to parse
     * @return The value of the user field indicated, if it exists in the list.
     */
    private String parseUserFields(String userFieldCode, List<Map<String, Object>> rawUserFields) {
        if (userFieldCode == null) {
            return null;
        }

        for (Map<String, Object> rawUserField : rawUserFields) {
            String code = (String)rawUserField.get('UserFieldCode');

            if (code != null && userFieldCode.equals(code)) {
                String value = (String)rawUserField.get('Value');
                return value;
            }
        }

        return null;
    }

    /**
     * Parses Tax IDs returned by DNA
     * @param desiredType The type of Tax ID desired.
     * @param rawTaxIds The List of raw objects to parse
     * @return The Tax ID indicated, if it exists in the list.
     */
    private String parseTaxIDs(String taxIdCode, List<Map<String, Object>> rawTaxIds) {
        if (taxIdCode == null) {
            return null;
        }

        for (Map<String, Object> rawTaxId : rawTaxIds) {
            String code = (String)rawTaxId.get('TaxIdTypeCode');

            if (code != null && taxIdCode.equals(code)) {
                String taxId = (String)rawTaxId.get('TaxIdDisplay');
                return taxId;
            }
        }

        return null;
    }

    /**
     * Parses a person from DNA
     * @param personMap The map containing person data.
     * @return Fully mapped DNAPerson
     */
    private DNAPerson parsePerson(Map<String, Object> personMap) {
        Map<String, Object> nameMap = (Map<String, Object>)personMap.get('Name');
        Map<String, Object> demoMap = (Map<String, Object>)personMap.get('Demographics');

        //System.debug('raw person data: ' + personMap);

        List<Map<String, Object>> rawAddresses = APIUtils.convertObjectList((List<Object>)personMap.get('Addresses'));
        List<Map<String, Object>> rawPhoneNumbers = APIUtils.convertObjectList((List<Object>)personMap.get('Phones'));
        List<Map<String, Object>> rawEmailAddresses = APIUtils.convertObjectList((List<Object>)personMap.get('ElectronicAddresses'));
        List<Map<String, Object>> rawIDs = APIUtils.convertObjectList((List<Object>)personMap.get('PersIds'));
        List<Map<String, Object>> rawUserFields = APIUtils.convertObjectList((List<Object>)personMap.get('UserFields'));

        String firstName = (String)nameMap.get('FirstName');
        String middleName = (String)nameMap.get('MiddleName');
        String lastName = (String)nameMap.get('LastName');
        String preferredName = (String)nameMap.get('NickName');
        String fetchedPersonNumber = String.valueOf(personMap.get('PersonNumber'));
        String memberNumber = String.valueOf(personMap.get('MemberNumber'));
        String taxId = (String)demoMap.get('TaxId');
        Date dob = Date.valueOf(this.parseDNADate((String)demoMap.get('DateOfBirth')));
        Date membershipDate = Date.valueOf(this.parseDNADate((String)demoMap.get('AddDate'))); // TODO: This is likely not it, but whatevs.
        DNAAddress primaryAddress = this.parseAddress(AddressType.PRIMARY, rawAddresses);
        String homePhone = this.parsePhoneNumber('PER', rawPhoneNumbers);
        String mobilePhone = this.parsePhoneNumber('CELL', rawPhoneNumbers);
        String email = this.parseEmail('EHOM', rawEmailAddresses);
        String driversLicense = this.parseIDs('1', rawIDs);
        String motherMaidenName = (String)demoMap.get('CustomerKeyword');
        String phonePassword = this.parseUserFields('PSWD', rawUserFields);
        String phonePasswordHint = this.parseUserFields('PSHT', rawUserFields);

        if (preferredName == null) {
            preferredName = firstName;
        }

        DNAPerson person = new DNAPerson(fetchedPersonNumber, memberNumber, preferredName, primaryAddress, firstName, middleName, lastName, taxId, dob, homePhone, mobilePhone, email, membershipDate, driversLicense);
        person.setDriversLicenseNumber(driversLicense);
        person.setMotherMaidenName(motherMaidenName);
        person.setPhonePassword(phonePassword);
        person.setPhonePasswordHint(phonePasswordHint);

        return person;
    }

    /**
     * Parses an orc from DNA
     * @param orcMap The map containing orc data.
     * @return Fully mapped DNAOrganization
     */
    private DNAOrganization parseOrganization(Map<String, Object> orcMap) {
        List<Map<String, Object>> rawAddresses = APIUtils.convertObjectList((List<Object>)orcMap.get('Addresses'));
        List<Map<String, Object>> rawEmailAddresses = APIUtils.convertObjectList((List<Object>)orcMap.get('ElectronicAddresses'));
        List<Map<String, Object>> rawPhoneNumbers = APIUtils.convertObjectList((List<Object>)orcMap.get('Phones'));
        List<Map<String, Object>> rawTaxIds = APIUtils.convertObjectList((List<Object>)orcMap.get('OrgTaxIds'));

        DNAAddress address = this.parseAddress(AddressType.PRIMARY, rawAddresses);
        String emailAddress = this.parseEmail('EBUS', rawEmailAddresses);
        String name = (String)orcMap.get('OrgName');
        String orgNumber = String.valueOf((decimal)orcMap.get('OrgNumber'));
        String orgType = (String)orcMap.get('OrgTypeCode');
        String phoneNumber = this.parsePhoneNumber('BUS', rawPhoneNumbers);
        String taxId = this.parseTaxIDs('FEIN', rawTaxIds);

        DNAOrganization orc = new DNAOrganization(address, emailAddress, name, orgNumber, orgType, phoneNumber, taxId);

        return orc;
    }
}