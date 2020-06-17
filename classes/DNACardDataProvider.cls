public class DNACardDataProvider implements ICardDataProvider {

    private DNACoreCardDataProvider coreCardDataProvider;
    private DNABusinessServicesCardDataProvider businessServiceCardDataProvider;

    public DNACardDataProvider() {
        this.coreCardDataProvider = new DNACoreCardDataProvider();
        this.businessServiceCardDataProvider = new DNABusinessServicesCardDataProvider();
    }

    public DNACardDataProvider(IAuthenticationManager coreAuthManager, IAuthenticationManager businessServicesAuthManager) {
        coreCardDataProvider = new DNACoreCardDataProvider(coreAuthManager);
        businessServiceCardDataProvider = new DNABusinessServicesCardDataProvider(businessServicesAuthManager);
    }

    public List<AccountCardInfo> getAccountCardInfo(String personNumber) {
        List<AccountCardInfo> coreCards = this.coreCardDataProvider.getAccountCardInfo(personNumber);
        List<AccountCardInfo> businessServicesCards = this.businessServiceCardDataProvider.getAccountCardInfo(personNumber);

        // Create a quick way to lookup all PANs that are associated with an account and agreement.
        // It is possible to have multiple of the same PAN.  Get a distinct list of unique PANs.
        Map<String, Set<String>> panLookup = new Map<String, Set<String>>();
        Map<String, AccountCardInfo> panToCardLookup = new Map<String, AccountCardInfo>();
        for (AccountCardInfo cardInfo : businessServicesCards) {
            String panKey = cardInfo.agreementNumber;
            Set<String> existingPans = panLookup.get(panKey);
            if (existingPans == null) {
                existingPans = new Set<String>();
                panLookup.put(pankey, existingPans);
            }

            existingPans.add(cardInfo.cardNumber);
            panToCardLookup.put(panKey, cardInfo);
        }

        // Merge the PAN(s) to the core account/agremeents.
        List<AccountCardInfo> mergedCards = new List<AccountCardInfo>();
        for (AccountCardInfo cardInfo : coreCards) {
            String panKey = cardInfo.agreementNumber;
            Set<String> pans = panLookup.get(panKey);

            // If no PANs are found for the agreement and account...
            if (pans == null) {
                pans = new Set<String>();
                pans.add(null);
            }

            for (String pan : pans) {
                // Find any other information that should be copied from the business services
                // agreement object base on the PAN.
                AccountCardInfo businessServicesCardInfo = panToCardLookup.get(panKey);

                IAccount account = cardInfo.account;
                String agreementNumber = cardInfo.agreementNumber;
                List<AccountCardInfo.SelectionOption> applicableChangeReasons = cardInfo.applicableChangeReasons;
                List<AccountCardInfo.SelectionOption> applicableStatuses = cardInfo.applicableStatuses;
                Boolean canChangeStatus = cardInfo.canChangeStatus;
                String cardNumber = pan;
                String displayName = cardInfo.displayName;
                String displayType = cardInfo.displayType;
                String nameOnCard = businessServicesCardInfo != null ? businessServicesCardInfo.nameOnCard : null;
                DateTime expirationDate = cardInfo.expirationDate;
                String providerName = cardInfo.providerName;
                String status = cardInfo.status;
                String friendlyStatus = cardInfo.userFriendlyStatus;
                String typeCode = cardInfo.typeCode;

                AccountCardInfo mergedCardInfo = new AccountCardInfo(account,
                                                agreementNumber,
                                                applicableChangeReasons,
                                                applicableStatuses,
                                                canChangeStatus,
                                                cardNumber,
                                                displayName,
                                                displayType,
                                                expirationDate,
                                                nameOnCard,
                                                providerName,
                                                status,
                                                friendlyStatus,
                                                typeCode);
                mergedCards.add(mergedCardInfo);
            }
        }

        return mergedCards;
    }

    public void updateAccountCardStatuses(String personNumber, List<UpdateAccountCardInfoRequest> requests) {
        this.coreCardDataProvider.updateAccountCardStatuses(personNumber, requests);
    }

    public IAuthenticationManager getAuthenticationManager() {
        return this.businessServiceCardDataProvider.getAuthenticationManager();
    }

    public String getProviderName() {
        return this.businessServiceCardDataProvider.getProviderName();
    }

}