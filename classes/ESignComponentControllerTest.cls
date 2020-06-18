@IsTest(SeeAllData=true)
private class ESignComponentControllerTest {
    public class MockNetworkFactory implements INetworkFactory {
        public IPersonDataProvider getPersonDataProvider() {
            return null;
        }
        public IPersonAccountDataProvider getPersonAccountDataProvider() {
            return null;
        }
        public IProductApplicationDataProvider getProductApplicationDataProvider() {
            return null;
        }
        public IProductOfferingDataProvider getProductOfferingDataProvider() {
            return null;
        }

        public IOrganizationDataProvider getOrganizationDataProvider() {
            return null;
        }
        public IOrganizationDataProvider getOrgWarningDataProvider() {
            return null;
        }

        public IAccountOpeningTransactionProvider getAccountOpeningTransactionProvider() {
            return null;
        }
        public IAccountOpeningApplicationPrefiller getAccountOpeningApplicationPrefillProvider() {
            return null;
        }

        public IAccountOpeningProductDataProvider getAccountOpeningProductDataProvider() {
            return null;
        }

        public ICardDataProvider getCreditCardDataProvider() {
            return new MockCardDataProvider();
        }

        public ICardDataProvider getDebitCardDataProvider() {
            return new MockCardDataProvider();
        }

        public ICardTravelNotificationDataProvider getCardTravelNotificationDataProvider() {
            return null;
        }
    }

    public class MockCardDataProvider implements ICardDataProvider {
        public List<AccountCardInfo> getAccountCardInfo(String personNumber){
            return new List<AccountCardInfo> {
                new AccountCardInfo(
                    new DNAAccount(),
                    '1234567789',
                    new List<AccountCardInfo.SelectionOption>(),
                    new List<AccountCardInfo.SelectionOption>(),
                    true,
                    '123456789098765',
                    'Debit Card',
                    'Debit',
                    System.now(),
                    'Name on Card',
                    'CCM',
                    'Active',
                    'ON',
                    'LSIN',
                    '987654'
                )
            };
        }
        public void updateAccountCardStatuses(String personNumber, List<UpdateAccountCardInfoRequest> requests) {}
        public IAuthenticationManager getAuthenticationManager(){
            return null;
        }
        public String getProviderName(){
            return 'DNA';
        }
    }


    private static INetworkFactory getNetworkFactory() {
        return new MockNetworkFactory();
    }


    @IsTest
    private static void testHappyPathACHDispute() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));

        Test.startTest();
        String jsonPayload = '{"name":"Wayne Hartman","taxId":"666-66-6666","email":"whartman@iccu.com","memberNumber":"9999999999999","accountNumber":"88888888888888","companies":[{"name":"Idaho Power","reason":"NOT_AUTHORIZED","transactions":[{"date":"4/23/2020","amount":"$123.23"}]},{"name":"CITY OF POCATELLO","reason":"DIFFERENT_AMOUNT","transactions":[{"date":"4/20/2020","amount":"$12,123.23"}]}]}';
		Map<String, Object> response = ESignComponentController.sendACHDisputeForSignature(jsonPayload);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathACHDispute() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));

        Test.startTest();
        String jsonPayload = '{"name":"Wayne Hartman","taxId":"666-66-6666","email":"whartman@iccu.com","memberNumber":"9999999999999","accountNumber":"88888888888888","companies":[{"name":"Idaho Power","reason":"NOT_AUTHORIZED","transactions":[{"date":"4/23/2020","amount":"$123.23"}]},{"name":"CITY OF POCATELLO","reason":"DIFFERENT_AMOUNT","transactions":[{"date":"4/20/2020","amount":"$12,123.23"}]}]}';
		Map<String, Object> response = ESignComponentController.sendACHDisputeForSignature(jsonPayload);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathSkipAPay() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));

        Test.startTest();
        String jsonPayload = '{"name":"John Smith","email":"noreply@iccu.com","memberNumber":"9999999999999","accountNumber":"88888888888888","accountDescription":"VISA Credit Card","addressLine1":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","unpaidBalance":"5,456","paymentAmount":"144","skipDate":"5/1/2020","letterDate":"4/23/2020","skipMonth":"05","loanType":"visa"}';
		Map<String, Object> response = ESignComponentController.sendSkipAPayForSignature(jsonPayload);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathSkipAPay() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));

        Test.startTest();
        String jsonPayload = '{"name":"John Smith","email":"noreply@iccu.com","memberNumber":"9999999999999","accountNumber":"88888888888888","accountDescription":"VISA Credit Card","addressLine1":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","unpaidBalance":"5,456","paymentAmount":"144","skipDate":"5/1/2020","letterDate":"4/23/2020","skipMonth":"05","loanType":"visa"}';
		Map<String, Object> response = ESignComponentController.sendSkipAPayForSignature(jsonPayload);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathSubsequentAction() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));

        Test.startTest();
        String jsonPayload = '{"iccu":{"accountNumber":"99999999999","requestDate":"4/24/2020","collateralDescription":"2020 CHEVY CAMERO","vin":"IDSPISPOPD","releaseBorrower":true,"releaseDate":"5/1/2020","releaseName":"John Smith","borrowerNumber":"8888888888888","loanModification":true,"unpaidBalance":"5,567.34","interestRate":"16.78","interestStartDate":"5/1/2020","modMonthlyPayment":true,"modRate":false,"modNone":false,"monthlyPayment1":"786.36","dueDate1":"5/1/2020","monthlyPayment2":"400.00","modReason1":"xxxxxxxx","modReason2":"","creditProtection":true,"makeMorePayments":true,"increasePayments":false,"monthlyPayment3":"895.69","cancelationOfInsurance":true,"lifeInsurance":true,"lifeName1":"Billy Smith","lifeName2":"Jane Smith","creditDisability":true,"creditName1":"Billy Smith"},"borrowers":[{"name":"John Smith","email":"jsmith@example.com"},{"name":"Jane Smith","email":"jsmith1@example.com"},{"name":"Billy Smith","email":"bsmith@example.com"}]}';
		Map<String, Object> response = ESignComponentController.sendSubsequentActionForSignature(jsonPayload);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathSubsequentAction() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));

        Test.startTest();
        String jsonPayload = '{"iccu":{"accountNumber":"99999999999","requestDate":"4/24/2020","collateralDescription":"2020 CHEVY CAMERO","vin":"IDSPISPOPD","releaseBorrower":true,"releaseDate":"5/1/2020","releaseName":"John Smith","borrowerNumber":"8888888888888","loanModification":true,"unpaidBalance":"5,567.34","interestRate":"16.78","interestStartDate":"5/1/2020","modMonthlyPayment":true,"modRate":false,"modNone":false,"monthlyPayment1":"786.36","dueDate1":"5/1/2020","monthlyPayment2":"400.00","modReason1":"xxxxxxxx","modReason2":"","creditProtection":true,"makeMorePayments":true,"increasePayments":false,"monthlyPayment3":"895.69","cancelationOfInsurance":true,"lifeInsurance":true,"lifeName1":"Billy Smith","lifeName2":"Jane Smith","creditDisability":true,"creditName1":"Billy Smith"},"borrowers":[{"name":"John Smith","email":"jsmith@example.com"},{"name":"Jane Smith","email":"jsmith1@example.com"},{"name":"Billy Smith","email":"bsmith@example.com"}]}';
		Map<String, Object> response = ESignComponentController.sendSubsequentActionForSignature(jsonPayload);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaDuplicateProcessing() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","usedSameAccount":true,"contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaDuplicateProcessingForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaDuplicateProcessing() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","usedSameAccount":true,"contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaDuplicateProcessingForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaFundsNotReceived() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","notes":"This is just freeform text.  Be reasonable.","amountRequested":"$400.00","amountReceived":"$380.00","atmLocation":"456 Nickel Ct, Pocatello, ID 83201"}';
		Map<String, Object> response = ESignComponentController.sendVisaFundsNotReceivedForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaFundsNotReceived() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","notes":"This is just freeform text.  Be reasonable.","amountRequested":"$400.00","amountReceived":"$380.00","atmLocation":"456 Nickel Ct, Pocatello, ID 83201"}';
		Map<String, Object> response = ESignComponentController.sendVisaFundsNotReceivedForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaMembershipCancelled() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","isRecurring":true,"cancelledDate":"4/30/2020","cancellationNumber":"IDKFJ","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaMembershipCancelledForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaMembershipCancelled() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","isRecurring":true,"cancelledDate":"4/30/2020","cancellationNumber":"IDKFJ","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaMembershipCancelledForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaMerchNotAsDescribed() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","disputeReason":"Counterfeit Merchandise","reasonDesc":"It was pure chafa!","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","wasReturned":true,"returnedVia":"DHL","merchResponse":"A complete fabrication!","previousNegotiation":true,"nogitiationDescription":"Some description"}';
		Map<String, Object> response = ESignComponentController.sendVisaMerchNotAsDescribedForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaMerchNotAsDescribed() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","disputeReason":"Counterfeit Merchandise","reasonDesc":"It was pure chafa!","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","wasReturned":true,"returnedVia":"DHL","merchResponse":"A complete fabrication!","previousNegotiation":true,"nogitiationDescription":"Some description"}';
		Map<String, Object> response = ESignComponentController.sendVisaMerchNotAsDescribedForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaMerchNotReceived() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","deliveryDate":"5/1/2020","productDesc":"Lego 75275 A-wing Starfighter","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!","hasBondingAuthority":false,"shippedWrong":false,"returnedMerchandise":true}';
		Map<String, Object> response = ESignComponentController.sendVisaMerchNotReceivedForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaMerchNotReceived() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","deliveryDate":"5/1/2020","productDesc":"Lego 75275 A-wing Starfighter","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!","hasBondingAuthority":false,"shippedWrong":false,"returnedMerchandise":true}';
		Map<String, Object> response = ESignComponentController.sendVisaMerchNotReceivedForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaOvercharge() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","amountCharged":"$1000.34","correctCharge":"$100.34","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaOverchargeForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaOvercharge() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","amountCharged":"$1000.34","correctCharge":"$100.34","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaOverchargeForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaPaidByOtherMeans() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","usedSameAccount":true,"checkNumber":"123456789","achAccountNumber":"4889998348853","cardNumber":"983498734","proof":"Check","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaPaidByOtherMeansForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaPaidByOtherMeans() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","usedSameAccount":true,"checkNumber":"123456789","achAccountNumber":"4889998348853","cardNumber":"983498734","proof":"Check","contactMerchDate":"4/10/2020","merchRepName":"Jane Smith","contactMethod":"Phone","merchResponse":"A complete fabrication!"}';
		Map<String, Object> response = ESignComponentController.sendVisaPaidByOtherMeansForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaRefund() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","refundAcknowledged":false,"merchantDate":"4/30/2020","merchantRepresentative":"Billy","merchantContactMethod":"Phone","returnDate":"4/30/2020","returnedVia":"In Person","merchantResponse":"This is more freeform text.  Be reasonable."}';
		Map<String, Object> response = ESignComponentController.sendVisaRefundForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaRefund() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","refundAcknowledged":false,"merchantDate":"4/30/2020","merchantRepresentative":"Billy","merchantContactMethod":"Phone","returnDate":"4/30/2020","returnedVia":"In Person","merchantResponse":"This is more freeform text.  Be reasonable."}';
		Map<String, Object> response = ESignComponentController.sendVisaRefundForSignature(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }

    @IsTest
    private static void testHappyPathVisaUnauthorizedTransaction() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(true));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","wasAtmTransaction":false,"wasWithinIdaho":false,"cardStatus":"Lost","isCardBlocked":true,"wasReportedToPolice":false,"dateLossDiscovered":"4/30/2020","dateLossReported":"4/30/2020","dateOfFirstFraud":"4/30/2020","authorityName":"Sgt. Pepper","authorityPhone":"555-555-5555","authorityReportNumber":"THX1138","unauthorizedUser":"Johnny Smith","unauthorizedUserAddress":"123 Penny Lane"}';
		Map<String, Object> response = ESignComponentController.sendVisaUnauthorizedTransaction(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') == null, response.get('error'));
    }

    @IsTest
    private static void testUnhappyPathVisaUnauthorizedTransaction() {
        Test.setMock(HttpCalloutMock.class, new MockMuleSoftESignResponse(false));
        ESignComponentController.networkFactory = ESignComponentControllerTest.getNetworkFactory();
        String personNumber = '123456';
        String uniqueId = '987654';
        Test.startTest();
        String jsonPayload = '{"memberName":"John Smith","memberNumber":"987654321","phoneNumber":"555-555-5555","email":"noreply@iccu.com","accountNumber":"9999999999999999","street":"123 Penny Lane","city":"Pocatello","state":"ID","postalCode":"83201","transactions":[{"merchant":"Bobs Crab Shack","date":"4/30/2020","amount":"$45.66"}],"notes":"This is just freeform text.  Be reasonable.","wasAtmTransaction":false,"wasWithinIdaho":false,"cardStatus":"Lost","isCardBlocked":true,"wasReportedToPolice":false,"dateLossDiscovered":"4/30/2020","dateLossReported":"4/30/2020","dateOfFirstFraud":"4/30/2020","authorityName":"Sgt. Pepper","authorityPhone":"555-555-5555","authorityReportNumber":"THX1138","unauthorizedUser":"Johnny Smith","unauthorizedUserAddress":"123 Penny Lane"}';
		Map<String, Object> response = ESignComponentController.sendVisaUnauthorizedTransaction(jsonPayload, personNumber, uniqueId);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.get('error') != null);
    }
}