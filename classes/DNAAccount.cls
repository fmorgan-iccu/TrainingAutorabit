/*
 * Class representing a financial account in the DNA system.
 */
public with sharing class DNAAccount implements IAccount {

    // These constants are used for creating verification questions.
    public static final String MJR_ACCT_CODE_CHECKING       = 'CK';
    public static final String MJR_ACCT_CODE_SAVINGS        = 'SAV';
    public static final String MJR_ACCT_CODE_CD             = 'TD';
    public static final String MJR_ACCT_CODE_MORTGAGE       = 'MTG';
    public static final String MJR_ACCT_CODE_CREDIT_CARD    = 'EXT';
    public static final String MJR_ACCT_CODE_USED_AUTO_LOAN = 'LBUA';

    // These constants are used for placing accounts into a specific category based on the
    // major/minor type.
    public static final String ACCOUNT_TYPE_AUTO = 'auto';
    public static final String ACCOUNT_TYPE_CREDIT_CARD = 'creditcard';
    public static final String ACCOUNT_TYPE_DEPOSIT = 'deposit';
    public static final String ACCOUNT_TYPE_MORTGAGE = 'mortgage';
    public static final String ACCOUNT_TYPE_SIGNATURE = 'signature';

    // These constants are used for checking transaction codes for GAP purchases and refunds.
    public static final String TRANSACTION_TYPE_GAP_PURCHASE = 'FFDS';
    public static final String TRANSACTION_TYPE_GAP_REFUND = 'PRCT';

    // Constant for checking Rtxn code for subsequent action form.
    public static final String TRANSACTION_TYPE_FIRST_PAYMENT = 'SPMT';
    public static final String TRANSACTION_TYPE_INSURANCES = 'LCAP';

    // Constant for checking Rtxn code for ACH type.
    public static final String TRANSACTION_TYPE_ACH = 'XWTH';

    // Constants for major and minor codes in DNA
    public static final String MAJOR_TYPE_CONSUMER = 'CNS';
    public static final String MINOR_TYPE_SIGNATURE = 'LSIG';

    private String accountNumber;
    private String accountType;
    private Double availableBalance;
    private String branchName;
    private Double currentBalance;
    private Double interestRate;
    private List<DNAJointAccountOwner> jointOwners;
    private String majorType;
    private String minorType;
    private String name;
    private Double nextPaymentAmount;
    private DateTime nextPaymentDate;
    private Double payoffAmount;
    private Double perDiem;
    private String nickName;
    private String status;
    private List<IAccountTransaction> transactions;
    private Boolean activeGapPolicy;
    private Boolean cancelledGapPolicy;
    private DateTime gapPurchaseDate;
    private Boolean canSkipPayment;
    private Decimal visaNextPaymentAmount;
    private Boolean firstPaymentMade;
    private Boolean hasLifeInsurance;
    private Boolean hasDisabilityInsurance;

    public DNAAccount() {
    }

    public DNAAccount(String accountNumber, Double availableBalance, String branchName, Double currentBalance, Double interestRate, List<DNAJointAccountOwner> jointOwners, String majorType, String minorType, String name, String nickName, String status) {
        this.accountNumber = accountNumber;
        this.availableBalance = availableBalance;
        this.branchName = branchName;
        this.currentBalance = currentBalance;
        this.interestRate = interestRate;
        this.jointOwners = jointOwners;
        this.majorType = majorType;
        this.minorType = minorType;
        this.name = name;
        this.nextPaymentDate = nextPaymentDate;
        this.nickName = nickName;
        this.status = status;

        // The major/minor codes must be set for this to work.
        determineAccountType();
    }

    private void determineAccountType() {
        if ((this.majorType == 'CNS' &&
                (this.minorType == 'LILM' ||
                    this.minorType == 'LBMC' ||
                    this.minorType == 'LILN' ||
                    this.minorType == 'LILU' ||
                    this.minorType == 'LIRV' ||
                    this.minorType == 'LBNA' ||
                    this.minorType == 'LBUA' ||
                    this.minorType == 'LBRV')) ||
            (this.majorType == 'CML' &&
                (this.minorType == 'BAL' ||
                    this.minorType == 'BINA' ||
                    this.minorType == 'SBAL' ||
                    this.minorType == 'BIUA'))
            )
        {
            this.accountType = ACCOUNT_TYPE_AUTO;
        }

        if (this.majorType == 'EXT' &&
            (this.minorType == 'VCLS' ||
                this.minorType == 'VCNG' ||
                this.minorType == 'VGLD' ||
                this.minorType == 'VPLT' ||
                this.minorType == 'VBUS' ||
                this.minorType == 'VCRW' ||
                this.minorType == 'VCPR' ||
                this.minorType == 'VBRW' ||
                this.minorType == 'VBPR' ||
                this.minorType == 'VPCR'))
        {
            this.accountType = ACCOUNT_TYPE_CREDIT_CARD;
        }

        if (this.majorType == 'CK' || this.majorType == 'SAV') {
            this.accountType = ACCOUNT_TYPE_DEPOSIT;
        }

        if (this.majorType == 'MTG') {
            this.accountType = ACCOUNT_TYPE_MORTGAGE;
        }

        if (this.majorType == MAJOR_TYPE_CONSUMER && this.minorType == MINOR_TYPE_SIGNATURE) {
            this.accountType = ACCOUNT_TYPE_SIGNATURE;
        }
    }

    public String getAccountNumber() {
        return this.accountNumber;
    }

    public String getAccountType() {
        return this.accountType;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public Double getAvailableBalance() {
        return this.availableBalance;
    }

    public void setAvailableBalance(Double balance) {
        this.availableBalance = balance;
    }

    public String getBranchName() {
        return this.branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public Double getCurrentBalance(){
        return this.currentBalance;
    }

    public void setCurrentBalance(Double balance) {
        this.currentBalance = balance;
    }

    public Double getInterestRate(){
        return this.interestRate;
    }

    public void setInterestRate(Double interestRate) {
        this.interestRate = interestRate;
    }

    public String getMajorType() {
        return this.majorType;
    }

    public void setMajorType(String majorType) {
        this.majorType = majorType;
        determineAccountType();
    }

    public String getMinorType() {
        return this.minorType;
    }

    public void setMinorType(String minorType) {
        this.minorType = minorType;
        determineAccountType();
    }

    public void setName(String name) {
        this.name =  name;
    }

    public String getName() {
        return this.name;
    }

    public String getNickName() {
        return this.nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public List<IJointAccountOwner> getJointOwners() {
        return this.jointOwners;
    }

    public void setJointOwners(List<DNAJointAccountOwner> jointOwners) {
        this.jointOwners = jointOwners;
    }

    public Double getNextPaymentAmount() {
        return this.nextPaymentAmount;
    }

    public void setNextPaymentAmount(Double nextPaymentAmount) {
        this.nextPaymentAmount = nextPaymentAmount;
    }

    public DateTime getNextPaymentDate() {
        return this.nextPaymentDate;
    }

    public void setNextPaymentDate(DateTime nextPaymentDate) {
        this.nextPaymentDate = nextPaymentDate;
    }

    public Double getPayoffAmount() {
        return this.payoffAmount;
    }

    public void setPayoffAmount(Double amount) {
        this.payoffAmount = amount;
    }

     public Double getPerDiem() {
        return this.perDiem;
    }

    public void setPerDiem(Double perDiem) {
        this.perDiem = perDiem;
    }

    public String getPreferredName() {
        String name = this.getName();

        if (this.getNickName() != null) {
            name = this.getNickName();
        }

        return name;
    }

    public String getStatus() {
        return this.status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<IAccountTransaction> getTransactions() {
        return this.transactions;
    }

    public void setTransactions(List<IAccountTransaction> transactions) {
        this.transactions = transactions;
    }

    public Boolean getActiveGapPolicy() {
        return this.activeGapPolicy;
    }

    public void setActiveGapPolicy(Boolean activeGapPolicy) {
        this.activeGapPolicy = activeGapPolicy;
    }

    public Boolean getCancelledGapPolicy() {
        return this.cancelledGapPolicy;
    }

    public void setCancelledGapPolicy(Boolean cancelledGapPolicy) {
        this.cancelledGapPolicy = cancelledGapPolicy;
    }

    public DateTime getGapPurchaseDate() {
        return this.gapPurchaseDate;
    }

    public void setGapPurchaseDate(DateTime gapPurchaseDate) {
        this.gapPurchaseDate = gapPurchaseDate;
    }

    public Boolean getCanSkipPayment() {
        return this.canSkipPayment;
    }

    public void setCanSkipPayment(Boolean canSkipPayment) {
        this.canSkipPayment = canSkipPayment;
    }

    public Decimal getVisaNextPaymentAmount() {
        return this.visaNextPaymentAmount;
    }

    public void setVisaNextPaymentAmount(Decimal visaNextPaymentAmount) {
        this.visaNextPaymentAmount = visaNextPaymentAmount;
    }

    public Boolean getFirstPaymentMade() {
        return this.firstPaymentMade;
    }

    public void setFirstPaymentMade(Boolean firstPaymentMade) {
        this.firstPaymentMade = firstPaymentMade;
    }

    public Boolean getHasLifeInsurance() {
        return this.hasLifeInsurance;
    }

    public void setHasLifeInsurance(Boolean hasLifeInsurance) {
        this.hasLifeInsurance = hasLifeInsurance;
    }

    public Boolean getHasDisabilityInsurance() {
        return this.hasDisabilityInsurance;
    }

    public void setHasDisabilityInsurance(Boolean hasDisabilityInsurance) {
        this.hasDisabilityInsurance = hasDisabilityInsurance;
    }
}