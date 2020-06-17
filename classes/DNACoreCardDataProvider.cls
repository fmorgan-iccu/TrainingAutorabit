/**
 * Class for interacting with card-related data
 */
public class DNACoreCardDataProvider extends DNACoreDataProvider implements ICardDataProvider {
    public static final String AGREEMENT_TYPE_CODE_DEBIT = 'DBT';
    public static final String AGREEMENT_TYPE_CODE_SECONDARY_DEBIT = 'DBT2';
    public static final String AGREEMENT_TYPE_CODE_EXTERNAL_CREDIT = 'XCRD';
    public static final String AGREEMENT_TYPE_CODE_HELOC = 'MDB1';
    public static final String AGREEMENT_TYPE_CODE_HEALTH_SAVING = 'MDBH';
    public static final String AGREEMENT_TYPE_BUSINESS_CHECK_CARD = 'BDBT';
    public static final String AGREEMENT_TYPE_BUSINESS_CHECK_CARD_SECONDARY = 'BDB2';

    public static final Set<String> SUPPORTED_AGREEMENT_TYPES = new Set<String> {
        AGREEMENT_TYPE_CODE_DEBIT,
        AGREEMENT_TYPE_CODE_SECONDARY_DEBIT,
        AGREEMENT_TYPE_CODE_HELOC,
        AGREEMENT_TYPE_CODE_HEALTH_SAVING,
        AGREEMENT_TYPE_BUSINESS_CHECK_CARD,
        AGREEMENT_TYPE_BUSINESS_CHECK_CARD_SECONDARY
    };

    public static final String ACCOUNT_MAJOR_CHECKING = 'CK';
    public static final String ACCOUNT_MAJOR_CONSUMER_LOAN = 'CNS';
    public static final String ACCOUNT_MAJOR_SAVINGS = 'SAV';

    private static final String CARD_STATUS_ACTIVE      = 'ACT';    // Active   ON
    private static final String CARD_STATUS_CLOSED      = 'CLOS';   // Closed   OFF
    private static final String CARD_STATUS_EXPIRED     = 'EXP';    // Expired  OFF
    private static final String CARD_STATUS_HOT         = 'HOT';    // Hot Card OFF  <---- UI
    private static final String CARD_STATUS_ISSUED      = 'ISS';    // Issued   Waiting For Activation
    private static final String CARD_STATUS_LOCK_OUT    = 'LOCK';   // Lock Out OFF
    private static final String CARD_STATUS_LOST        = 'LOST';   // Lost     OFF
    private static final String CARD_STATUS_RESTRICTED  = 'REST';   // Restricted   OFF
    private static final String CARD_STATUS_INQUIRY     = 'INQ';    // Inquiry Only OFF
    private static final String CARD_STATUS_WARM        = 'WARM';   // WarmCard     OFF

    private static final String CHANGE_REASON_CODE_AUTOMATIC_COPY   = 'ACPY';  // Automatic Agreement Copy
    private static final String CHANGE_REASON_CODE_CLOSED           = 'CCLS';  // Closed by Customer
    private static final String CHANGE_REASON_CODE_DAMAGED          = 'DMGD';  // Damaged
    private static final String CHANGE_REASON_CODE_LOST             = 'LOST';  // Lost
    private static final String CHANGE_REASON_CODE_STOLEN           = 'STLN';  // Stolen

    /*
     * Default constructor
     */
    public DNACoreCardDataProvider() {
        super();
    }

    /**
     * Constructor for specifying the IAuthenticationManager.  Primarily to facilitate unit testing.
     */
    public DNACoreCardDataProvider(IAuthenticationManager authManager) {
        super(authManager);
    }

    public List<AccountCardInfo> getAccountCardInfo(String personNumber) {
        if (personNumber == null) {
            throw new IllegalArgumentException('personNumber may NOT be null.');
        }

        IPersonAccountDataProvider accountProvider = new DNAPersonAccountDataProvider(this.getAuthenticationManager());
        IPerson person = new DNAPerson(personNumber);

        List<IAccount> accounts = accountProvider.getAccounts(person);
        Map<String, IAccount> accountsMap = new Map<String, IAccount>();

        for (IAccount account : accounts) {
            accountsMap.put(account.getAccountNumber(), account);
        }

        // Only want debit card agreements
        List<Map<String, Object>> agreements = this.getAgreements(personNumber);

        List<AccountCardInfo> cards = new List<AccountCardInfo>();

        List<AccountCardInfo.SelectionOption> applicableChangeReasons = this.getApplicableChangeReasons();

        for (Map<String, Object> agreement : agreements) {
            IAccount account = null;
            String currentStatusCode = (String)agreement.get('CurrentStatusCode');
            String typeCode = (String)agreement.get('TypeCode');
            List<AccountCardInfo.SelectionOption> applicableStatuses = this.getApplicableStatuses(currentStatusCode);

            // Look through the account objects associated with the agreement and attempt to match it with an actual IAccount
            List<Map<String, Object>> agreementAccounts = APIUtils.convertObjectList((List<Object>)agreement.get('Accounts'));
            if (agreementAccounts != null) {
                for (Map<String, Object> accountMap : agreementAccounts) {
                    String accountNumber = String.valueOf((Long)accountMap.get('AccountNumber'));
                    IAccount agreementAccount = accountsMap.get(accountNumber);

                    //Since a debit card can be a part of multiple agreements, it is necessary to be
                    //specific when selecting a card and filter by agreement type code and major type code.
                    //ie. one card can be part of an agreement for a saving and checking account.
                    Boolean isDebitAccount = agreementAccount != null && (
                        typeCode == AGREEMENT_TYPE_CODE_DEBIT ||
                        typeCode == AGREEMENT_TYPE_CODE_SECONDARY_DEBIT ||
                        typeCode == AGREEMENT_TYPE_BUSINESS_CHECK_CARD ||
                        typeCode == AGREEMENT_TYPE_BUSINESS_CHECK_CARD_SECONDARY) &&
                        agreementAccount.getMajorType() == ACCOUNT_MAJOR_CHECKING;
                    Boolean isHelocAccount = agreementAccount != null &&
                        typeCode == AGREEMENT_TYPE_CODE_HELOC &&
                        agreementAccount.getMajorType() == ACCOUNT_MAJOR_CONSUMER_LOAN;
                    Boolean isHsaAccount = agreementAccount != null &&
                        typeCode == AGREEMENT_TYPE_CODE_HEALTH_SAVING && agreementAccount.getMajorType() == ACCOUNT_MAJOR_SAVINGS;

                    If (agreement != null && (isDebitAccount || isHelocAccount || isHsaAccount)) {
                        account = agreementAccount;
                        break;
                    }
                }
            }

            // Only looking for card agreements; external credit cards are NOT included because
            // they are provided by CCM.
            if (!SUPPORTED_AGREEMENT_TYPES.contains(typeCode)) {
                continue;
            }

            String agreementNumber = String.valueOf(agreement.get('AgreementNumber'));
            Boolean canChangeStatus = this.canChangeCardStatus(currentStatusCode);
            String cardNumber = null;
            String displayName = account != null ? account.getPreferredName() : (String)agreement.get('TypeDescription');
            String displayType = typeCode == AGREEMENT_TYPE_CODE_EXTERNAL_CREDIT ? 'Credit' : 'Debit';
            String nameOnCard = null;
            DateTime expirationDate = null;
            String providerName = this.getProviderName();
            String status = currentStatusCode;
            String userFriendlyStatus = this.userFriendlyStatusForStatus(status);

            AccountCardInfo cardInfo = new AccountCardInfo(account, agreementNumber, applicableChangeReasons, applicableStatuses, canChangeStatus, cardNumber, displayName, displayType, expirationDate, nameOnCard, providerName, status, userFriendlyStatus, typeCode);

            cards.add(cardInfo);
        }

        return cards;
    }

    public void updateAccountCardStatuses(String personNumber, List<UpdateAccountCardInfoRequest> requests) {
        if (personNumber == null) {
            throw new IllegalArgumentException('Person number may NOT be null.');
        }

        if (requests == null) {
            throw new IllegalArgumentException('Update requests may NOT be null.');
        }

        if (requests.size() == 0) {
            return;
        }

        // Validate the requests first
        for (UpdateAccountCardInfoRequest request : requests) {
            if (request.changeReason == null) {
                throw new IllegalArgumentException('Request change reason cannot be null.');
            }

            if (request.changeReasonCode == null) {
                throw new IllegalArgumentException('Request change reason code cannot be null.');
            }

            // Validate that the requested change reason is in the acceptable domain values
            Set<String> changeReasonCodes = new Set<String>();
            List<AccountCardInfo.SelectionOption> changeReasons = this.getApplicableChangeReasons();

            for (AccountCardInfo.SelectionOption reason : changeReasons) {
                changeReasonCodes.add(reason.code);
            }

            if (!changeReasonCodes.contains(request.changeReasonCode)) {
                throw new IllegalArgumentException('Change reason code (' + request.changeReasonCode + ') is NOT a valid value.');
            }

            if (request.status == null) {
                throw new IllegalArgumentException('Request status cannot be null.');
            }

            AccountCardInfo info = request.cardInfo;

            if (info == null) {
                throw new IllegalArgumentException('Request card info cannot be null.');
            }

            if (info.typeCode == null) {
                throw new IllegalArgumentException('Request card info type code cannot be null.');
            }

            if (info.agreementNumber == null) {
                throw new IllegalArgumentException('Request card info agreement number cannot be null.');
            }

            if (info.uniqueId == null) {
                throw new IllegalArgumentException('Request card info unique ID cannot be null.');
            }
        }

        List<Map<String, Object>> mappedAgreements = new List<Map<String, Object>>();

        for (UpdateAccountCardInfoRequest request : requests) {
            List<Map<String, Object>> mappedDetails = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'DetailTypeCode' => 'NEWSTATCD',
                    'Value' => request.status
                },
                new Map<String, Object> {
                    'DetailTypeCode' => 'NEWSTATREAS',
                    'Value' => request.changeReason
                },
                new Map<String, Object> {
                    'DetailTypeCode' => 'NEWSTATREASCD',
                    'Value' => request.changeReasonCode
                }
            };

            Map<String, Object> mappedRequest = new Map<String, Object> {
                'AgreeNumber' => request.cardInfo.agreementNumber,
                'TypeCode' => request.cardInfo.typeCode,
                'Details' => mappedDetails
            };

            mappedAgreements.add(mappedRequest);
        }

        Map<String, Object> requestPayload = new Map<String, Object> {
            'EntityTypeCode' => 'PERS',
            'EntityNumber' => personNumber,
            'Agreements' => mappedAgreements,
            '__type' => 'PersonAgreementMaintenanceRequest:http://www.opensolutions.com/CoreApi'
        };

        Map<String, Object> request = super.createGenericRequest(requestPayload);

        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return;
        }

        for (Map<String, Object> response : responses) {
            List<Object> errors = (List<Object>)response.get('Errors');
            if (errors != null) {
                String message = this.parseErrors(errors);
                throw new DataServiceException(message);
            }
        }

        // If we got this far, then it succeeded
    }

    public String getProviderName() {
        return 'DNA';
    }

    /**
     * Gets a list of agreements from DNA
     */
    private List<Map<String, Object>> getAgreements(String personNumber) {
        Map<String, Object> agreementRequest = new Map<String, Object> {
            'ShouldFetchAllAgreementStatuses' => true,
            'EntityTypeCode' => 'PERS',
            'EntityNumber' => personNumber,
            '__type' => 'PersonAgreementInquiryRequest:http://www.opensolutions.com/CoreApi'
        };

        Map<String, Object> request = this.createGenericRequest(agreementRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> agreementsMap = responses[0];
        List<Object> errors = (List<Object>)agreementsMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new DataServiceException(message);
        }

        List<Map<String, Object>> agreements = APIUtils.convertObjectList((List<Object>)agreementsMap.get('Agreements'));

        return agreements;
    }

    /**
     * Determines if a card status can be changed.
     * @param currentStatus The current status of the card in question
     * @return true or false that the status can be changed.
     */
    private Boolean canChangeCardStatus(String currentStatus) {
        List<AccountCardInfo.SelectionOption> applicableStatuses = this.getApplicableStatuses(currentStatus);

        Boolean canChange = applicableStatuses.size() > 0;

        return canChange;
    }

    /**
     * Returns a list of applicable reasons for changing the state of a card.
     * Note: Testing would indicate that any reason is valid for any other state change.
     */
    private List<AccountCardInfo.SelectionOption> getApplicableChangeReasons() {
        List<AccountCardInfo.SelectionOption> reasons = new List<AccountCardInfo.SelectionOption> {
            new AccountCardInfo.SelectionOption(CHANGE_REASON_CODE_AUTOMATIC_COPY, 'Automatic Agreement Copy'),
            new AccountCardInfo.SelectionOption(CHANGE_REASON_CODE_CLOSED, 'Closed by Customer'),
            new AccountCardInfo.SelectionOption(CHANGE_REASON_CODE_DAMAGED, 'Damaged'),
            new AccountCardInfo.SelectionOption(CHANGE_REASON_CODE_LOST, 'Lost'),
            new AccountCardInfo.SelectionOption(CHANGE_REASON_CODE_STOLEN, 'Stolen')
        };

        return reasons;
    }

    /**
     * Returns a list of potential statuses that a card can have.
     * @param currentStatus The current status of the given card.
     * @return a list of objects representing all of the applicable statuses of a card.
     */
    private List<AccountCardInfo.SelectionOption> getApplicableStatuses(String currentStatus) {
        /**
         *  That's right! We only support changing cards that are active.  Otherwise, they can't change it.
         */
        if (currentStatus != DNACoreCardDataProvider.CARD_STATUS_ACTIVE) {
            return new List<AccountCardInfo.SelectionOption>();
        }

        List<AccountCardInfo.SelectionOption> applicableStatuses = new List<AccountCardInfo.SelectionOption> {
            new AccountCardInfo.SelectionOption(CARD_STATUS_HOT, AccountCardInfo.USER_FRIENDLY_STATUS_OFF)
        };

        return applicableStatuses;
    }

    /**
     * Converts the system status to a more user friendly version.
     * @param currentStatus The current system status of the card
     */
    private String userFriendlyStatusForStatus(String currentStatus) {
        if (currentStatus == DNACoreCardDataProvider.CARD_STATUS_ACTIVE) {
            return AccountCardInfo.USER_FRIENDLY_STATUS_ON;
        } else if (currentStatus == DNACoreCardDataProvider.CARD_STATUS_ISSUED) {
            return AccountCardInfo.USER_FRIENDLY_STATUS_WAITING_ACTIVATION;
        } else {
            return AccountCardInfo.USER_FRIENDLY_STATUS_OFF;
        }
    }
}