public with sharing class DNABusinessServicesCardDataProvider extends DNABusinessServicesDataProvider implements ICardDataProvider {

	public DNABusinessServicesCardDataProvider() {
        super();
	}

    public DNABusinessServicesCardDataProvider(IAuthenticationManager authManager) {
       super(authManager);
	}

    public List<AccountCardInfo> getAccountCardInfo(String personNumber) {
        if (personNumber == null) {
            throw new IllegalArgumentException('personNumber may NOT be null.');
        }

        // Get the debit card information
        List<Map<String, Object>> debitCards = this.getDebitCards(personNumber);
        List<AccountCardInfo> cards = new List<AccountCardInfo>();

        for (Map<String, Object> debitCard : debitCards) {
            String typeCode = (String)debitCard.get('AgreementTypeCode');

            // For performance reasons, this request doesn't query the account details.  See the
            // DNACardDataProvider for how this is merged with the information from the
            // DNACoreCardDataProvider.
            DNAAccount account = new DNAAccount();
            account.setAccountNumber(String.valueOf(debitCard.get('ServiceChargeAccountNumber')));

            // Much of this information is not available.  Again, see the merge in DNACardDataProvider.
            String agreementNumber = String.valueOf(debitCard.get('AgreementNumber'));
            List<AccountCardInfo.SelectionOption> applicableChangeReasons = null;
            List<AccountCardInfo.SelectionOption> applicableStatuses = null;
            String cardNumber = (String)debitCard.get('ExternalCardNumber');
            String displayName = null;
            String displayType = null;
            String nameOnCard = String.isEmpty((String)debitCard.get('FullName')) ? (String)debitCard.get('OrganizationName') : (String)debitCard.get('FullName');
            DateTime expirationDate = null;
            String providerName = this.getProviderName();
            String status = null;
            String userFriendlyStatus = null;
            Boolean canChangeStatus = false;

            AccountCardInfo cardInfo = new AccountCardInfo(account, agreementNumber, applicableChangeReasons, applicableStatuses, canChangeStatus, cardNumber, displayName, displayType, expirationDate, nameOnCard, providerName, status, userFriendlyStatus, typeCode);
            cards.add(cardInfo);
        }

        return cards;
    }

    public String getProviderName() {
        return 'DNA';
    }

    private List<Map<String, Object>> getDebitCards(String personNumber) {
        Map<String, String> debitCardsRequest = new Map<String, String> {
            'PersonNumber' => personNumber,
            'ActiveOnlyYN' => 'N',
            'CardsOnlyYN' => 'Y'
        };
        Map<String, Object> debitCardMessage = callApi('/AtmDebitCards/Query/ByPerson', debitCardsRequest);
        if (debitCardMessage != null && debitCardMessage.containsKey('Message')) {
            throw new DataServiceException((String)debitCardMessage.get('Message'));
        }
        if (debitCardMessage == null || !debitCardMessage.containsKey('MessageBody')) {
            throw new DataServiceException('Debit card request missing message body.');
        }

        return APIUtils.convertObjectList((List<Object>) debitCardMessage.get('MessageBody'));
    }

    public void updateAccountCardStatuses(String personNumber, List<UpdateAccountCardInfoRequest> requests) {
        throw new DataServiceException('The business services card data provide does not current support update; see DNACoreCardDataProvider.');
    }

}