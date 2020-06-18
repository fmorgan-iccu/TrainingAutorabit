@IsTest
private class DNACoreCardDataProviderTest {

    @IsTest
    private static void testHappyPathGetCardInfo() {
        String personNumber = '123432a';

        Contact testContact = new Contact (
            Birthdate = Date.today(),
            MemberNumber__c = '23423987',
            Email = 'something@example.com',
            FirstName = 'Jack',
            MiddleName = 'Joe',
            LastName = 'Johnson',
            MailingStreet = '123 Penny Lane',
            MailingCity = 'Chubbuck',
            MailingState = 'ID',
            MailingPostalCode = '83202',
            MobilePhone = '(555) 555-5555',
            TaxID__c = '000-00-0000',
            PersonNumber__c = personNumber,
            Phone = '(555) 555-5555'
        );

        insert testContact;

        Test.startTest();

        DNACoreCardDataProvider codeCoverage = new DNACoreCardDataProvider();

        String responseData = '{"Output":{"ExtensionResponses":null,"Responses":[{"__type":"PersonAgreementInquiryResponse:http://www.opensolutions.com/CoreApi","Errors":null,"RequestNumber":"","RequestTypeCode":"7710","WasSuccessful":true,"Agreements":[{"Accounts":[{"AccessTypeCode":"DBT","AccountCurrencyCode":"USD","AccountNumber":716359391,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":9999999,"CycleWithdrawalLimitAmount":9999999,"DepositAllowed":true,"MajorAccountTypeCode":"SAV","MinorAccountTypeCode":"SREG","ProductDescription":"Share","WithdrawalAllowed":true},{"AccessTypeCode":"DBT","AccountCurrencyCode":"USD","AccountNumber":716359487,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":9999999,"CycleWithdrawalLimitAmount":9999999,"DepositAllowed":true,"MajorAccountTypeCode":"CK","MinorAccountTypeCode":"CKBA","ProductDescription":"Free","WithdrawalAllowed":true}],"AgreementNumber":2042807,"ChangePasswordOnNextLogin":null,"ChangePinOnNextLogin":null,"CurrentStatusCode":"ACT","IsCardAgreement":true,"PasswordEffectiveDateTime":null,"TypeCode":"DBT","TypeDescription":"Visa Check Card","UserIdValue":""},{"Accounts":[{"AccessTypeCode":"VRU","AccountCurrencyCode":"USD","AccountNumber":716359391,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":0.01,"CycleWithdrawalLimitAmount":0.01,"DepositAllowed":true,"MajorAccountTypeCode":"SAV","MinorAccountTypeCode":"SREG","ProductDescription":"Share","WithdrawalAllowed":true},{"AccessTypeCode":"VRU","AccountCurrencyCode":"USD","AccountNumber":716359487,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":0.01,"CycleWithdrawalLimitAmount":0.01,"DepositAllowed":true,"MajorAccountTypeCode":"CK","MinorAccountTypeCode":"CKBA","ProductDescription":"Free","WithdrawalAllowed":true},{"AccessTypeCode":"VRU","AccountCurrencyCode":"USD","AccountNumber":716478567,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":0,"CycleWithdrawalLimitAmount":0,"DepositAllowed":false,"MajorAccountTypeCode":"MTG","MinorAccountTypeCode":"MTG","ProductDescription":"Fixed Rate","WithdrawalAllowed":false}],"AgreementNumber":2043384,"ChangePasswordOnNextLogin":null,"ChangePinOnNextLogin":null,"CurrentStatusCode":"ISS","IsCardAgreement":true,"PasswordEffectiveDateTime":null,"TypeCode":"VRU","TypeDescription":"Voice Response Unit","UserIdValue":""}],"EntityNumber":636423,"EntityTypeCode":"PERS","StatementAccounts":null}],"UserAuthentication":{"Errors":null,"WasSuccessful":true}}}';
        String contentType = 'application/json';
        Integer statusCode = 200;

        Test.setMock(HttpCalloutMock.class, new MockDNAResponse(responseData, contentType, statusCode));

        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        DNACoreCardDataProvider coreProvider = new DNACoreCardDataProvider(coreAuthManager);

        List<AccountCardInfo> cards = coreProvider.getAccountCardInfo(testContact.Id);

        Test.stopTest();

        System.assert(cards != null, 'Cards was null!');
        System.assertEquals(1, cards.size());

        // Test the internal parsing
        AccountCardInfo card = cards[0];
        System.assertEquals(true, card.canChangeStatus);
        System.assertEquals(null, card.cardNumber);
        System.assertEquals('Visa Check Card', card.displayName);
        System.assertEquals(null, card.nameOnCard);
        System.assertEquals(null, card.expirationDate);
        System.assertEquals('DNA', card.providerName);
        System.assertEquals('ACT', card.status);
        System.assertEquals(null, card.uniqueId); // Since the core provider doesn't get a card number, this will be null
    }

    @IsTest
    private static void testHappyPathUpdateCardStatus() {
        try {
            String responseData = '{"Output":{"ExtensionResponses":null,"Responses":[{"__type":"PersonAgreementInquiryResponse:http://www.opensolutions.com/CoreApi","Errors":null,"RequestNumber":"","RequestTypeCode":"7710","WasSuccessful":true,"Agreements":[{"Accounts":[{"AccessTypeCode":"DBT","AccountCurrencyCode":"USD","AccountNumber":716359391,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":9999999,"CycleWithdrawalLimitAmount":9999999,"DepositAllowed":true,"MajorAccountTypeCode":"SAV","MinorAccountTypeCode":"SREG","ProductDescription":"Share","WithdrawalAllowed":true},{"AccessTypeCode":"DBT","AccountCurrencyCode":"USD","AccountNumber":716359487,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":9999999,"CycleWithdrawalLimitAmount":9999999,"DepositAllowed":true,"MajorAccountTypeCode":"CK","MinorAccountTypeCode":"CKBA","ProductDescription":"Free","WithdrawalAllowed":true}],"AgreementNumber":2042807,"ChangePasswordOnNextLogin":null,"ChangePinOnNextLogin":null,"CurrentStatusCode":"ACT","IsCardAgreement":true,"PasswordEffectiveDateTime":null,"TypeCode":"DBT","TypeDescription":"Visa Check Card","UserIdValue":""},{"Accounts":[{"AccessTypeCode":"VRU","AccountCurrencyCode":"USD","AccountNumber":716359391,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":0.01,"CycleWithdrawalLimitAmount":0.01,"DepositAllowed":true,"MajorAccountTypeCode":"SAV","MinorAccountTypeCode":"SREG","ProductDescription":"Share","WithdrawalAllowed":true},{"AccessTypeCode":"VRU","AccountCurrencyCode":"USD","AccountNumber":716359487,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":0.01,"CycleWithdrawalLimitAmount":0.01,"DepositAllowed":true,"MajorAccountTypeCode":"CK","MinorAccountTypeCode":"CKBA","ProductDescription":"Free","WithdrawalAllowed":true},{"AccessTypeCode":"VRU","AccountCurrencyCode":"USD","AccountNumber":716478567,"AllowCrossAccountTransfer":false,"CrossAccountDescription":null,"CycleDepositLimitAmount":0,"CycleWithdrawalLimitAmount":0,"DepositAllowed":false,"MajorAccountTypeCode":"MTG","MinorAccountTypeCode":"MTG","ProductDescription":"Fixed Rate","WithdrawalAllowed":false}],"AgreementNumber":2043384,"ChangePasswordOnNextLogin":null,"ChangePinOnNextLogin":null,"CurrentStatusCode":"ISS","IsCardAgreement":true,"PasswordEffectiveDateTime":null,"TypeCode":"VRU","TypeDescription":"Voice Response Unit","UserIdValue":""}],"EntityNumber":636423,"EntityTypeCode":"PERS","StatementAccounts":null}],"UserAuthentication":{"Errors":null,"WasSuccessful":true}}}';
            String contentType = 'application/json';
            Integer statusCode = 200;

            Test.setMock(HttpCalloutMock.class, new MockDNAResponse(responseData, contentType, statusCode));

            IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
            DNACoreCardDataProvider provider = new DNACoreCardDataProvider(coreAuthManager);

            String personNumber = '123432';

            AccountCardInfo cardInfo = new AccountCardInfo(null, '1234567', null, null, true, 'test card number', null, 'Debit', null, 'test name', 'DNA', null, null, 'DBT');

            provider.updateAccountCardStatuses(personNumber, new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(cardInfo, 'Some reason', 'LOST', 'HOT')
            });
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
    }

    @IsTest
    private static void testUnhappyPathGetCardInfoPersonNumber() {
        try {
            DNACoreCardDataProvider provider = new DNACoreCardDataProvider();
            List<AccountCardInfo> cards = provider.getAccountCardInfo(null);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of a null person number');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
    }

    @IsTest
    private static void testUnhappyPathUpdateStatusBadRequests() {
        IAuthenticationManager coreAuthManager = new DNAAuthenticationManagerMock();
        DNACoreCardDataProvider provider = new DNACoreCardDataProvider(coreAuthManager);

        // Null person number
        try {
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>();
            provider.updateAccountCardStatuses(null, null);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of a null person number');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        // Null requests
        try {
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>();
            provider.updateAccountCardStatuses('12344565464', null);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of a null request');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }

        // Bad change reason
        try {
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, null, null, null)
            };
            provider.updateAccountCardStatuses('12334534', requests);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of bad request change reason');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        // Null change reason code
        try {
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, 'Some change reason', null, null)
            };
            provider.updateAccountCardStatuses('12334534', requests);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of a null request reason code');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        // Invalid reason code
        try {
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, 'Some change reason', 'BAD_CODE', null)
            };
            provider.updateAccountCardStatuses('12334534', requests);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of bad request reason code');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        // Null status
        try {
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, 'Some change reason', 'LOST', null)
            };
            provider.updateAccountCardStatuses('12334534', requests);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of null request status');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        // Null account info
        try {
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(null, 'Some change reason', 'LOST', 'ACT')
            };
            provider.updateAccountCardStatuses('12334534', requests);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of null request account info.');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        // Null type code
        try {
            AccountCardInfo info = new AccountCardInfo(null, null, null, null, true, null, null, null, null, null, 'DNA', null, null, null);
            
            List<UpdateAccountCardInfoRequest> requests = new List<UpdateAccountCardInfoRequest>{
                new UpdateAccountCardInfoRequest(info, 'Some change reason', 'LOST', 'ACT')
            };
            provider.updateAccountCardStatuses('12334534', requests);
            System.assert(false, 'Expected to throw an IllegalArgumentException because of null account info type code.');
        } catch (IllegalArgumentException e) {
            // This is expected to throw this exception.
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
    }
}