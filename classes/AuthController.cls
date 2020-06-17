public with sharing class AuthController {

// =====================================
// STATIC HELPER METHODS FOR LIGHTNING
// =====================================
    @TestVisible
    private static INetworkFactory networkFactory;

    // Session cache manager
    @TestVisible
    private UserSessionCache userSessionCache;

    public AuthController() {
        this.userSessionCache = new UserSessionCache();
    }

    /**
     * Authenticates the user into the Core and Business Services API connections.
     */
    @Auraenabled
    public static Map<String, Object> authenticateDna(
        String username,
        String password,
        String cashBox,
        String postingDate,
        String effectiveDate,
        String networkNodeName)
    {
        if (AuthController.networkFactory == null) {
            AuthController.networkFactory = new ConcreteNetworkProvider();
        }

        Map<String, Object> response = new Map<String, Object>();
        if (String.isBlank(username) || String.isBlank(password)) {
            return AuthController.authenticateDnaErrorResponse('Missing required credentials.');
        }

        IPersonDataProvider personDataProvider = AuthController.networkFactory.getPersonDataProvider();
        IAuthenticationManager coreApiAuthManager = personDataProvider.getAuthenticationManager();

        ICardDataProvider cardDataProvider = AuthController.networkFactory.getDebitCardDataProvider();
        IAuthenticationManager businessServicesApiAuthManager = cardDataProvider.getAuthenticationManager();

        try {
            IAuthenticationCredential coreCredential = new AuthenticationCredential(username, password);
            Boolean isAuthedCore = coreApiAuthManager.authenticateUser(coreCredential);

            // Only attempt to log the user into the business servics API if they have provided
            // a cash box or network node name.  This is done to simplify the login for those team
            // members who don't need to use the business services API.
            Boolean isAuthedBusinessServices = false;
            if (!String.isBlank(cashBox) || !String.isBlank(networkNodeName)) {
                Date pDate = Date.valueOf(postingDate);
                Date eDate = Date.valueOf(effectiveDate);

                IAuthenticationCredential businessServicesCredential = new DNABusinessServicesAuthCredential(username, password, cashBox, pDate, eDate, networkNodeName);
                isAuthedBusinessServices = businessServicesApiAuthManager.authenticateUser(businessServicesCredential);

                // Persist the cashBox and networkNodeName for future logins!
                Id userId = UserInfo.getUserId();
                User u = new User(
                    id = userId,
                    cashBox__c = cashBox,
                    networkNodeName__c = networkNodeName
                );
                update u;
            }

            String errorMessage = !isAuthedCore ? 'Invalid username or password' : '';

            response.put('isAuthedCore', isAuthedCore);
            response.put('isAuthedBusinessServices', isAuthedBusinessServices);
            response.put('error', errorMessage);
            return response;
        } catch (DataServiceException e) {
            return AuthController.authenticateDnaErrorResponse(e.getMessage());
        } catch (Exception e) {
            return AuthController.authenticateDnaErrorResponse('There was a system error! (' + e.getMessage() + ')');
        }
    }

    private static Map<String, Object> authenticateDnaErrorResponse(String message) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('isAuthedCore', false);
        response.put('isAuthedBusinessServices', false);
        response.put('error', message);
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> authenticateCcm(String username, String password) {
        if (AuthController.networkFactory == null) {
            AuthController.networkFactory = new ConcreteNetworkProvider();
        }

        Map<String, Object> response = new Map<String, Object>();
        if (String.isBlank(username) || String.isBlank(password)) {
            return AuthController.authenticateCcmErrorResponse('Missing required credentials.');
        }

        ICardDataProvider creditCardDataProvider = AuthController.networkFactory.getCreditCardDataProvider();
        IAuthenticationManager authManager = creditCardDataProvider.getAuthenticationManager();

        try {
            IAuthenticationCredential ccmCredential = new AuthenticationCredential(username, password);
            Boolean isAuthedCcm = authManager.authenticateUser(ccmCredential);

            String errorMessage = !isAuthedCcm ? 'Invalid username or password' : '';

            response.put('isAuthedCcm', isAuthedCcm);
            response.put('error', errorMessage);
            return response;
        } catch (DataServiceException e) {
            return AuthController.authenticateDnaErrorResponse(e.getMessage());
        } catch(Exception e) {
            return AuthController.authenticateCcmErrorResponse('There was a system error! (' + e.getMessage() + ')');
        }
    }

    private static Map<String, Object> authenticateCcmErrorResponse(String message) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('isAuthedCcm', false);
        response.put('error', message);
        return response;
    }

    @Auraenabled
    public static Map<String, Object> getAuthenticationInfo() {
        if (AuthController.networkFactory == null) {
            AuthController.networkFactory = new ConcreteNetworkProvider();
        }

        Map<String, Object> response = new Map<String, Object>();

        // Get the user's cached information to simplify the login process.
        Id userId = UserInfo.getUserId();
        User u = [
            SELECT id,
                cashBox__c,
                email,
                networkNodeName__c,
                username
            FROM User
            WHERE id = :userId];
        String username = u.username;
        if (u.username.contains('@')) {
            username = u.username.left(u.username.indexOf('@'));
        }
        response.put('username', username);
        response.put('email', u.email);
        response.put('cashBox', u.cashBox__c);
        response.put('networkNodeName', u.networkNodeName__c);

        // Determine the user permissions.
        Boolean enableForms = AccessUtils.checkPermission('MemberForms');
        response.put('allowDnaFullLogin', enableForms);
        response.put('allowCcmLogin', enableForms);
        Boolean allowLogout = AccessUtils.checkPermission('SystemLogout');  // NOTE:  This permission doesn't exist, but this will return true for admins.
        response.put('allowLogout', allowLogout);

        try {
            IPersonDataProvider personDataProvider = AuthController.networkFactory.getPersonDataProvider();
            IAuthenticationManager coreAuthManager = personDataProvider.getAuthenticationManager();
            Boolean isAuthedCore = coreAuthManager.isUserAuthenticated();

            ICardDataProvider cardDataProvider = AuthController.networkFactory.getDebitCardDataProvider();
            IAuthenticationManager businessServicesAuthManager = cardDataProvider.getAuthenticationManager();
            Boolean isAuthedBusinessServices = businessServicesAuthManager.isUserAuthenticated();

            ICardDataProvider creditCardDataProvider = AuthController.networkFactory.getCreditCardDataProvider();
            IAuthenticationManager ccmAuthManager = creditCardDataProvider.getAuthenticationManager();
            Boolean isAuthedCcm = ccmAuthManager.isUserAuthenticated();

            response.put('isAuthedCore', isAuthedCore);
            response.put('isAuthedBusinessServices', isAuthedBusinessServices);
            response.put('isAuthedCcm', isAuthedCcm);
            return response;
        } catch (Exception e) {
            response.put('isAuthedCore', false);
            response.put('isAuthedBusinessServices', false);
            response.put('isAuthedCcm', false);
            response.put('error', 'There was a system error! (' + e.getMessage() + ')');
            return response;
        }
    }

    @Auraenabled
    public static void logout() {
        if (AuthController.networkFactory == null) {
            AuthController.networkFactory = new ConcreteNetworkProvider();
        }

        IPersonDataProvider personDataProvider = AuthController.networkFactory.getPersonDataProvider();
        IAuthenticationManager coreApiAuthManager = personDataProvider.getAuthenticationManager();
        coreApiAuthManager.logout();

        ICardDataProvider debitCardDataProvider = AuthController.networkFactory.getDebitCardDataProvider();
        IAuthenticationManager businessServicesApiAuthManager = debitCardDataProvider.getAuthenticationManager();
        businessServicesApiAuthManager.logout();

        ICardDataProvider creditCardDataProvider = AuthController.networkFactory.getCreditCardDataProvider();
        IAuthenticationManager ccmAuthManager = creditCardDataProvider.getAuthenticationManager();
        ccmAuthManager.logout();
    }

}