public class ESignComponentController {
    @TestVisible
    private static INetworkFactory networkFactory;

	@AuraEnabled
    public static Map<String, Object> sendACHDisputeForSignature(String jsonPayload) {
        ESignAbstractMapper mapper = new ESignACHDisputeMapper(jsonPayload);
        Map<String, Object> response = ESignComponentController.sendForSignature(jsonPayload, mapper);

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> sendSkipAPayForSignature(String jsonPayload) {
        ESignAbstractMapper mapper = new ESignSkipAPayMapper(jsonPayload);
        Map<String, Object> response = ESignComponentController.sendForSignature(jsonPayload, mapper);

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> sendSubsequentActionForSignature(String jsonPayload) {
        ESignAbstractMapper mapper = new ESignSubsequentActionMapper(jsonPayload);
        Map<String, Object> response = ESignComponentController.sendForSignature(jsonPayload, mapper);

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaDuplicateProcessingForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaDuplicateProcessingMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaFundsNotReceivedForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaFundsNotReceivedMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaMembershipCancelledForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaMembershipCancelledMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaMerchNotAsDescribedForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaMerchNotAsDescMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaMerchNotReceivedForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaMerchNotReceivedMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaOverchargeForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaOverchargeMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaPaidByOtherMeansForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaPaidByOtherMeansMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaRefundForSignature(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaRefundMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendVisaUnauthorizedTransaction(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            String finalJsonPayload = ESignComponentController.addCardNumber(jsonPayload, personNumber, cardUniqueId);
            ESignAbstractMapper mapper = new ESignVisaUnauthorizedTxnMapper(finalJsonPayload);
            response = ESignComponentController.sendForSignature(finalJsonPayload, mapper);
            return response;
        } catch (UnauthenticatedException ue) {
            response.put('error', 'Unauthorized, please login to DNA and CCM.');
            return response;
        } catch (IllegalArgumentException ae) {
            response.put('error', 'There was a problem getting the card number used. ' + ae.getMessage());
            return response;
        } catch (Exception e) {
            response.put('error', 'An unknown error occured: ' + e.getMessage());
            return response;
        }
    }

    private static Map<String, Object> sendForSignature(String jsonPayload, ESignAbstractMapper mapper) {
        Map<String, Object> response = new Map<String, Object>();

        ESignSendCeremonyRequest request = mapper.mapRequest();

        try {
            IESignProvider provider = ESignProviderFactory.getESignProvider();
	        provider.sendCeremonyForESignature(request);
        } catch (Exception e) {
            response.put('error', 'There was an issue sending the form for signature: ' + e.getMessage());
        }

        return response;
    }

    private static String addCardNumber(String jsonPayload, String personNumber, String cardUniqueId) {
        Map<String, Object> response = new Map<String, Object>();
        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(jsonPayload);

        // Get the card number
        try {
            String cardNumber = ESignComponentController.getCardNumber(personNumber, cardUniqueId);
            // Add the card number into the JSON and serialize it.
            jsonData.put('pan', cardNumber);
            String finalJsonPayload = JSON.serialize(jsonData);
            return finalJsonPayload;
        } catch (UnauthenticatedException ue) {
            throw ue;
        } catch (IllegalArgumentException ae) {
            throw ae;
        } catch (Exception e) {
            throw e;
        }
    }

    private static String getCardNumber(String personNumber, String cardUniqueId) {
        if (ESignComponentController.networkFactory == null) {
            ESignComponentController.networkFactory = new ConcreteNetworkProvider();
        }

        if (personNumber == null) {
            throw new IllegalArgumentException('personNumber may NOT be null.');
        }

        if (cardUniqueId == null) {
            throw new IllegalArgumentException('cardUniqueID may NOT be null.');
        }

        // Because the card numbers aren't passed to the front-end for security reasons, retrieve
        // the accounts with the unique Id and associated card number.  Create a rapid access Map
        // to be used later to get the card number.
        Map<String, AccountCardInfo> cardUniqueIdLookup = new Map<String, AccountCardInfo>();
        ICardDataProvider creditProvider = ESignComponentController.networkFactory.getCreditCardDataProvider();
        List<AccountCardInfo> creditCards = null;
        try {
            creditCards = creditProvider.getAccountCardInfo(personNumber);
        } catch(UnauthenticatedException e) {
            throw e;
        }
        for (AccountCardInfo creditCard : creditCards) {
            cardUniqueIdLookup.put(creditCard.uniqueId, creditCard);
        }

        ICardDataProvider debitProvider = ESignComponentController.networkFactory.getDebitCardDataProvider();
        List<AccountCardInfo> debitCards = null;
        try {
            debitCards = debitProvider.getAccountCardInfo(personNumber);
        } catch(UnauthenticatedException e) {
            throw e;
        }
        for (AccountCardInfo debitCard : debitCards) {
            cardUniqueIdLookup.put(debitCard.uniqueId, debitCard);
        }

        // Determine the card number on file and put it in the request.
        String uniqueId = cardUniqueId;
        AccountCardInfo cardInfo = cardUniqueIdLookup.get(uniqueId);
        if (cardInfo == null) {
            throw new IllegalArgumentException('There was a problem with the card unique ID.');
        }

        return cardInfo.cardNumber;
    }
}