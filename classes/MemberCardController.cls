/**
 * Aura-enabled controller for interacting with Credit and Debit Cards
 */
public class MemberCardController {
    @TestVisible // This is test visible so that we can inject the network factory for testing purposes.
    private static INetworkFactory networkFactory;

    // TODO:  Retire this once the LWC hot card component replaces the CRMMemberAccountCards component.
    @AuraEnabled
    public static Map<String, Object> authenticateWithCreditCardProvider(String username, String password) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('error', 'This method is no longer supported.');
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> fetchCardData(String contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', 'Contact ID may NOT be null.');
            return response;
        }

        Contact contact = ContactController.getContact(contactId);
        String personNumber = contact.PersonNumber__c;
        response.put('contact', contact);

        if (MemberCardController.networkFactory == null) {
            MemberCardController.networkFactory = new ConcreteNetworkProvider();
        }

        INetworkFactory networkFactory = MemberCardController.networkFactory;
        ICardDataProvider creditCardProvider = networkFactory.getCreditCardDataProvider();
        ICardDataProvider debitCardProvider = networkFactory.getDebitCardDataProvider();

        List<ICardDataProvider> cardProviders = new List<ICardDataProvider> {
            creditCardProvider,
            debitCardProvider
        };

        // Validation of being signed in.
        Boolean authenticationRequired = false;
        for (ICardDataProvider cardProvider : cardProviders) {
            IAuthenticationManager authManager = cardProvider.getAuthenticationManager();

            if (authManager.isUserAuthenticated() == false) {
                authenticationRequired = true;
                response.put('authRequired', cardProvider.getProviderName());
                response.put('error', 'Please log in to ' + cardProvider.getProviderName());
            }
        }
        if (authenticationRequired) {
            return response;
        }

        // TODO:  Consider how this permission check can instead be done by the data provider!
        // Store whether the user has the permissions to see full card numbers.
        Boolean canViewFullPanDebit = true;
        Boolean canViewFullPanCredit = true;
        Pattern validPanPattern = Pattern.compile('^[0-9]+$');

        try {
            List<AccountCardInfo> debitCards = debitCardProvider.getAccountCardInfo(personNumber);
            for (AccountCardInfo debitCard : debitCards) {
                if (!String.isBlank(debitCard.cardNumber)) {
                    Matcher validPanMatcher = validPanPattern.matcher(debitCard.cardNumber);
                    canViewFullPanDebit = canViewFullPanDebit && validPanMatcher.matches();
                }
                debitCard.redactCardNumber();
            }
            List<Map<String, Object>> mappedDebit = MemberCardController.mapCardAccountInfo(debitCards);
            response.put('debit', mappedDebit);
        } catch (UnauthenticatedException e) {
            response.put('authRequired', creditCardprovider.getProviderName());
            response.put('error', 'Please log in to ' + debitCardProvider.getProviderName() + '.');
            return response;
        } catch (Exception e) {
            String message = 'There was a problem getting card data from ' + debitCardProvider.getProviderName() + ': ' + e.getMessage();
            response.put('error', message);
            return response;
        }

        try {
            List<AccountCardInfo> creditCards = creditCardProvider.getAccountCardInfo(personNumber);
            for (AccountCardInfo creditCard : creditCards) {
                if (!String.isBlank(creditCard.cardNumber)) {
                    Matcher validPanMatcher = validPanPattern.matcher(creditCard.cardNumber);
                    canViewFullPanCredit = canViewFullPanCredit && validPanMatcher.matches();
                }
                creditCard.redactCardNumber();
            }
            List<Map<String, Object>> mappedCredit = MemberCardController.mapCardAccountInfo(creditCards);
            response.put('credit', mappedCredit);
        } catch (UnauthenticatedException e) {
            response.put('authRequired', creditCardprovider.getProviderName());
            response.put('error', 'Please log in to ' + creditCardProvider.getProviderName() + '.');
            return response;
        } catch (Exception e) {
            String message = 'There was a problem getting card data from ' + creditCardProvider.getProviderName() + ': ' + e.getMessage();
            response.put('error', message);
            return response;
        }

        // If the full PAN is not available for a given system, remove all cards of that type and
        // display a message.
        String panMessage = '';
        if (!canViewFullPanDebit) {
            response.put('debit', new List<Map<String, Object>>());
            panMessage = panMessage + 'You are unable to submit changes to debit cards because you don\'t have the necessary permissions to view full card numbers in ' + debitCardProvider.getProviderName() + '. ';
        }
        if (!canViewFullPanCredit) {
            response.put('credit', new List<Map<String, Object>>());
            panMessage = panMessage + 'You are unable to submit changes to credit cards because you don\'t have the necessary permissions to view full card numbers in ' + creditCardProvider.getProviderName() + '. ';
        }
        if (!String.isBlank(panMessage)) {
            response.put('warning', panMessage);
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateCardStatuses(String contactId, String requestJSON) {
        if (MemberCardController.networkFactory == null) {
            MemberCardController.networkFactory = new ConcreteNetworkProvider();
        }

        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', 'Contact ID may NOT be null.');
            return response;
        }

        Contact contact = ContactController.getContact(contactId);
        String personNumber = contact.PersonNumber__c;

        if (requestJSON == null) {
            response.put('error', 'Request JSON cannot be null.');
            return response;
        }

        List<Map<String, Object>> requests = null;
        try {
            requests = APIUtils.convertObjectList((List<Object>)JSON.deserializeUntyped(requestJSON));
        } catch (Exception e) {
            response.put('error', 'Unable to parse requestJSON: ' + e.getMessage());
            return response;
        }

        // Because the card numbers aren't passed to the front-end for security reasons, retrieve
        // the accounts with the unique Id and associated card number.  Create a rapid access Map
        // to be used later to get the card number.
        Map<String, AccountCardInfo> cardUniqueIdLookup = new Map<String, AccountCardInfo>();
        ICardDataProvider creditProvider = MemberCardController.networkFactory.getCreditCardDataProvider();
        List<AccountCardInfo> creditCards = null;
        try {
            creditCards = creditProvider.getAccountCardInfo(personNumber);
        } catch(UnauthenticatedException e) {
            response.put('authRequired', creditProvider.getProviderName());
            response.put('error', 'Please log in to ' + creditProvider.getProviderName() + '.');
            return response;
        }
        for (AccountCardInfo creditCard : creditCards) {
            cardUniqueIdLookup.put(creditCard.uniqueId, creditCard);
        }

        ICardDataProvider debitProvider = MemberCardController.networkFactory.getDebitCardDataProvider();
        List<AccountCardInfo> debitCards = null;
        try {
            debitCards = debitProvider.getAccountCardInfo(personNumber);
        } catch(UnauthenticatedException e) {
            response.put('authRequired', debitProvider.getProviderName());
            response.put('error', 'Please log in to ' + creditProvider.getProviderName() + '.');
            return response;
        }
        for (AccountCardInfo debitCard : debitCards) {
            cardUniqueIdLookup.put(debitCard.uniqueId, debitCard);
        }

        // Easily group requests according to the provider to be used
        Map<ICardDataProvider, List<UpdateAccountCardInfoRequest>> providerRequestMap = new Map<ICardDataProvider, List<UpdateAccountCardInfoRequest>> {
            creditProvider => new List<UpdateAccountCardInfoRequest>(),
            debitProvider => new List<UpdateAccountCardInfoRequest>()
        };

        // Easily determine which provider should be used for the card provided
        Map<String, ICardDataProvider> cardProviderMap = new Map<String, ICardDataProvider> {
            creditProvider.getProviderName() => creditProvider,
            debitProvider.getProviderName() => debitProvider
        };

        for (Map<String, Object> request : requests) {
            // Determine the card number on file and put it in the request.
            String uniqueId = request.containsKey('uniqueId') ? (String)request.get('uniqueId') : null;
            AccountCardInfo cardInfo = cardUniqueIdLookup.get(uniqueId);
            if (cardInfo == null) {
                response.put('error', 'Invalid uniqueId.');
                return response;
            }
            request.put('cardNumber', cardInfo.cardNumber);

            UpdateAccountCardInfoRequest r = MemberCardController.parseCardStatusRequest(request);

            String providerName = r.cardInfo.providerName;
            if (providerName == null) {
                response.put('error', 'Unable to update card because it is missing its provider name.');
                return response;
            }

            ICardDataProvider provider = cardProviderMap.get(providerName);
            if (provider == null) {
                response.put('error', 'Unable to process card provider of type (' + providerName + ').');
                return response;
            }

            List<UpdateAccountCardInfoRequest> providerRequests = providerRequestMap.get(provider);
            providerRequests.add(r);
        }

        // Iterate on each provider and update the pending requests.
        // We aren't doing any in-depth validation of data, since the providers will do this for us.
        for (ICardDataProvider provider : providerRequestMap.keySet()) {
            List<UpdateAccountCardInfoRequest> providerRequests = providerRequestMap.get(provider);

            if (providerRequests.size() == 0) { // No need to process
                continue;
            }

            try {
                provider.updateAccountCardStatuses(personNumber, providerRequests);
            } catch (UnauthenticatedException e) {
                response.put('authRequired', creditProvider.getProviderName());
                response.put('error', 'Please log into ' + provider.getProviderName() + '.');
                return response;
            } catch (Exception e) {
                response.put('error', 'An error occured while updating: ' + e.getMessage());
                return response;
            }
        }

        // We made it! Return the response.
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateTravelNotifications(String contactId, String requestJSON) {
        if (MemberCardController.networkFactory == null) {
            MemberCardController.networkFactory = new ConcreteNetworkProvider();
        }

        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', 'Contact ID may NOT be null.');
            return response;
        }

        Contact contact = ContactController.getContact(contactId);
        String personNumber = contact.PersonNumber__c;

        if (requestJSON == null) {
            response.put('error', 'Request JSON cannot be null.');
            return response;
        }

        List<Map<String, Object>> requests = null;
        try {
            requests = APIUtils.convertObjectList((List<Object>)JSON.deserializeUntyped(requestJSON));
        } catch (Exception e) {
            response.put('error', 'Unable to parse requestJSON: ' + e.getMessage());
            return response;
        }

        // For security, the name and phone number of the contact will always be used on travel
        // notification.  This was setup this way so that if these need to be allowed from the
        // front-end, this code can simply be removed.
        for (Map<String, Object> request : requests) {
            request.put('firstName', contact.firstName);
            request.put('lastName', contact.lastName);
            request.put('phone', contact.phone);
        }

        // The CO-OP API will happily accept quotes in the notes field, but when retrieving the
        // travel notifications it doesn't properly escape these characters and consequently the
        // JSON can't be parsed.  So, prevent quotes from being sent in the notes.
        for (Map<String, Object> request : requests) {
            String note = (String)request.get('note');
            if (note != null) {
                note = note.replace('"', '');
                request.put('note', note);
            }
        }

        // Because the card numbers aren't passed to the front-end for security reasons, retrieve
        // the accounts with the unique Id and associated card number.  Create a rapid access Map
        // to be used later to get the card number.
        Map<String, AccountCardInfo> cardUniqueIdLookup = new Map<String, AccountCardInfo>();
        ICardDataProvider creditProvider = MemberCardController.networkFactory.getCreditCardDataProvider();
        List<AccountCardInfo> creditCards = null;
        try {
            creditCards = creditProvider.getAccountCardInfo(personNumber);
        } catch(UnauthenticatedException e) {
            response.put('authRequired', creditProvider.getProviderName());
            response.put('error', 'Please log in to ' + creditProvider.getProviderName() + '.');
            return response;
        }
        for (AccountCardInfo creditCard : creditCards) {
            cardUniqueIdLookup.put(creditCard.uniqueId, creditCard);
        }

        ICardDataProvider debitProvider = MemberCardController.networkFactory.getDebitCardDataProvider();
        List<AccountCardInfo> debitCards = null;
        try {
            debitCards = debitProvider.getAccountCardInfo(personNumber);
        } catch(UnauthenticatedException e) {
            response.put('authRequired', debitProvider.getProviderName());
            response.put('error', 'Please log in to ' + creditProvider.getProviderName() + '.');
            return response;
        }
        for (AccountCardInfo debitCard : debitCards) {
            cardUniqueIdLookup.put(debitCard.uniqueId, debitCard);
        }

        List<CardTravelNotificationInfo> updateRequests = new List<CardTravelNotificationInfo>();
        for (Map<String, Object> request : requests) {
            // Determine the card number on file and put it in the request.
            String uniqueId = request.containsKey('uniqueId') ? (String)request.get('uniqueId') : null;
            AccountCardInfo cardInfo = cardUniqueIdLookup.get(uniqueId);
            request.put('cardNumber', cardInfo.cardNumber);

            CardTravelNotificationInfo r = MemberCardController.parseTraveNotificationRequest(request);
            updateRequests.add(r);
        }

        if (updateRequests.size() == 0) {
            response.put('error', 'No properly formatted request were received.');
            return response;
        }

        ICardTravelNotificationDataProvider provider = MemberCardController.networkFactory.getCardTravelNotificationDataProvider();
        try {
            // NOTE:  This is written to allow for multiple updates to occur.  However, this may
            // not be the best way to track successes since the front-end would need to know which
            // cards were not updated.  No time will be spent on this because the crmTravelForm
            // only sends one request at this time.
            Boolean success = true;
            for (CardTravelNotificationInfo request : updateRequests) {
                success = success && provider.updateTravelNotification(request);
            }
            response.put('success', success);
        } catch (UnauthenticatedException e) {
            response.put('authRequired', creditProvider.getProviderName());
            response.put('error', 'Please log into ' + provider.getProviderName() + '.');
            return response;
        } catch (Exception e) {
            response.put('error', 'An error occured while updating: ' + e.getMessage());
            return response;
        }

        return response;
    }

    /***
     * Private API
     */

    private static List<Map<String, Object>> mapCardAccountInfo(List<AccountCardInfo> cardInfos) {
        List<Map<String, Object>> mappedInfo = new List<Map<String, Object>>();

        for (AccountCardInfo cardInfo : cardInfos) {
            String accountNumber = cardInfo.account != null ? cardInfo.account.getAccountNumber() : null;
            Map<String, Object> infoMap = new Map<String, Object> {
                'accountNumber' => accountNumber,
                'agreementNumber' => cardInfo.agreementNumber,
                'applicableChangeReasons' => MemberCardController.mapSelectionOptions(cardInfo.applicableChangeReasons),
                'applicableStatuses' => MemberCardController.mapSelectionOptions(cardInfo.applicableStatuses),
                'canChangeStatus' => cardInfo.canChangeStatus,
                'cardNumber' => cardInfo.cardNumber,
                'displayName' => cardInfo.displayName,
                'displayType' => cardInfo.displayType,
                'nameOnCard' => cardInfo.nameOnCard,
                'expirationDate' => cardInfo.expirationDate,
                'providerName' => cardInfo.providerName,
                'status' => cardInfo.status,
                'userFriendlyStatus' => cardInfo.userFriendlyStatus,
                'typeCode' => cardInfo.typeCode,
                'uniqueId' => cardInfo.uniqueId
            };

            mappedInfo.add(infoMap);
        }

        return mappedInfo;
    }

    private static List<Map<String, Object>> mapSelectionOptions(List<AccountCardInfo.SelectionOption> options) {
        List<Map<String, Object>> mappedOptions = new List<Map<String, Object>>();

        for (AccountCardInfo.SelectionOption option : options) {
            Map<String, Object> mappedOption = new Map<String, Object>{
                'code' => option.code,
                'displayValue' => option.displayValue
            };
            mappedOptions.add(mappedOption);
        }

        return mappedOptions;
    }

    private static CardTravelNotificationInfo parseTraveNotificationRequest(Map<String, Object> request) {
        String cardNumber = (String)request.get('cardNumber');
        String firstName = (String)request.get('firstName');
        String lastName = (String)request.get('lastName');
        Date fromDate = Date.valueOf((String)request.get('fromDate'));
        Date toDate = Date.valueOf((String)request.get('toDate'));
        List<Object> stateCodeList = (List<Object>)request.get('stateCodes');
        List<String> stateCodes = APIUtils.convertStringList(stateCodeList);
        List<Object> countryCodeList = (List<Object>)request.get('countryCodes');
        List<String> countryCodes = APIUtils.convertStringList(countryCodeList);
        String phone = (String)request.get('phone');
        String note = (String)request.get('note');

        List<CardTravelNotificationInfo.Detail> details = new List<CardTravelNotificationInfo.Detail>();
        for (String stateCode : stateCodes) {
            CardTravelNotificationInfo.Detail detail = new CardTravelNotificationInfo.Detail(fromDate, toDate, stateCode, 'USA', note);
            details.add(detail);
        }
        for (String countryCode : countryCodes) {
            CardTravelNotificationInfo.Detail detail = new CardTravelNotificationInfo.Detail(fromDate, toDate, null, countryCode, note);
            details.add(detail);
        }

        CardTravelNotificationInfo info = new CardTravelNotificationInfo(cardNumber, firstName, lastName, phone, details);
        return info;
    }

    private static UpdateAccountCardInfoRequest parseCardStatusRequest(Map<String, Object> request) {
        String changeReason = (String)request.get('changeReason');
        String changeReasonCode = (String)request.get('changeReasonCode');
        String newStatus = (String)request.get('status');

        IAccount account = null;
        String agreementNumber = (String)request.get('agreementNumber');
        List<AccountCardInfo.SelectionOption> applicableChangeReasons = null;
        List<AccountCardInfo.SelectionOption> applicableStatuses = null;
        Boolean canChangeStatus = false;
        String cardNumber = (String)request.get('cardNumber');
        String displayName = null;
        String displayType = null;
        String nameOnCard = null;
        DateTime expirationDate = null;
        String providerName = (String)request.get('providerName');
        String status = (String)request.get('status');
        String userFriendlyStatus = null;
        String typeCode =  (String)request.get('typeCode');
        String uniqueId = (String)request.get('uniqueId');

        AccountCardInfo cardInfo = new AccountCardInfo(account, agreementNumber, applicableChangeReasons, applicableStatuses, canChangeStatus, cardNumber, displayName, displayType, expirationDate, nameOnCard, providerName, status, userFriendlyStatus, typeCode, uniqueId);

        UpdateAccountCardInfoRequest info = new UpdateAccountCardInfoRequest(cardInfo, changeReason, changeReasonCode, newStatus);
        return info;
    }
}