public class DNAConstants {
    public static final String AGREEMENT_TYPE_CODE_DEBIT                    = 'DBT';
    public static final String AGREEMENT_TYPE_CODE_SECONDARY_DEBIT          = 'DBT2';
    public static final String AGREEMENT_TYPE_CODE_EXTERNAL_CREDIT          = 'XCRD';
    public static final String AGREEMENT_TYPE_CODE_HELOC                    = 'MDB1';
    public static final String AGREEMENT_TYPE_CODE_HEALTH_SAVING            = 'MDBH';
    public static final String AGREEMENT_TYPE_BUSINESS_CHECK_CARD           = 'BDBT';
    public static final String AGREEMENT_TYPE_BUSINESS_CHECK_CARD_SECONDARY = 'BDB2';

    public static final Set<String> SUPPORTED_AGREEMENT_TYPES = new Set<String> {
        AGREEMENT_TYPE_CODE_DEBIT,
        AGREEMENT_TYPE_CODE_SECONDARY_DEBIT,
        AGREEMENT_TYPE_CODE_HELOC,
        AGREEMENT_TYPE_CODE_HEALTH_SAVING,
        AGREEMENT_TYPE_BUSINESS_CHECK_CARD,
        AGREEMENT_TYPE_BUSINESS_CHECK_CARD_SECONDARY
    };

    public static final String ACCOUNT_MAJOR_CHECKING       = 'CK';
    public static final String ACCOUNT_MAJOR_CONSUMER_LOAN  = 'CNS';
    public static final String ACCOUNT_MAJOR_SAVINGS        = 'SAV';
    public static final String ACCOUNT_MAJOR_CREDIT_CARD    = 'EXT';

    public static final String CARD_STATUS_ACTIVE      = 'ACT';    // Active   ON
    public static final String CARD_STATUS_CLOSED      = 'CLOS';   // Closed   OFF
    public static final String CARD_STATUS_EXPIRED     = 'EXP';    // Expired  OFF
    public static final String CARD_STATUS_HOT         = 'HOT';    // Hot Card OFF  <---- UI
    public static final String CARD_STATUS_ISSUED      = 'ISS';    // Issued   Waiting For Activation
    public static final String CARD_STATUS_LOCK_OUT    = 'LOCK';   // Lock Out OFF
    public static final String CARD_STATUS_LOST        = 'LOST';   // Lost     OFF
    public static final String CARD_STATUS_RESTRICTED  = 'REST';   // Restricted   OFF
    public static final String CARD_STATUS_INQUIRY     = 'INQ';    // Inquiry Only OFF
    public static final String CARD_STATUS_WARM        = 'WARM';   // WarmCard     OFF

    public static final Set<String> SUPPORTS_HOT_CARDING = new Set<String> { CARD_STATUS_ACTIVE, CARD_STATUS_ISSUED };

    public static final String CHANGE_REASON_CODE_AUTOMATIC_COPY   = 'ACPY';  // Automatic Agreement Copy
    public static final String CHANGE_REASON_CODE_CLOSED           = 'CCLS';  // Closed by Customer
    public static final String CHANGE_REASON_CODE_DAMAGED          = 'DMGD';  // Damaged
    public static final String CHANGE_REASON_CODE_LOST             = 'LOST';  // Lost
    public static final String CHANGE_REASON_CODE_STOLEN           = 'STLN';  // Stolen

    public static final String MAJOR_ACCOUNT_TYPE_MORTGAGE           = 'MTG';   // MORTGAGE MAJOR ACCOUNT TYPE CODE
    public static final String PMT_TYPE_FIXED_PRINCIPAL_AND_INTEREST = 'FBI';  // Principal and Interest Payment
    public static final String PMT_TYPE_FIXED_BALANCE                = 'FB';  // Escrow Payment

    public static final String ENTITY_TYPE_PERSON       = 'PERS';
    public static final String ENTITY_TYPE_ORGANIZATION = 'ORG';

    // Constants for Form Related Transactions in DNA
    public static final Integer DAYS_SINCE_INSURANCE                = 31;
    public static final String SINGLELIFE_INSURANCE_INTERNAL_NBR    = '34257';
    public static final String JOINTLIFE_INSURANCE_INTERNAL_NBR     = '34259';
    public static final String DISABILITY_INSURANCE_INTERNAL_NBR    = '34258';
    public static final String GAP_PURCHASE_INTERNAL_NBR            = '4174';
    public static final String GAP_REFUND_INTERNAL_NBR              = '3823';
    public static final String USER_FIELD_SKIP_PAY                  = '8SKP'; // Usercode for skip a pay on accounts.
    public static final String USER_FIELD_SKIP_PAY_VISA             = 'VSKP'; // Usercode for skip a pay for Visa's.
    public static final String USER_FIELD_VISA_NEXT_PAYMENT         = 'CNPA'; // Const for the userfield that contains the next payment amount for Visa's in DNA.
}