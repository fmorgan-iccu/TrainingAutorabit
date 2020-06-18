public with sharing class SFAccount implements IAccount {

    private String accountNumber;
    private String accountType;
    private Double availableBalance;
    private String branchName;
    private Double currentBalance;
    private String name;
    private String majorType;
    private String minorType;
    private String nickName;
    private Double interestRate;
    private List<IAccountTransaction> transactions;
    private List<IJointAccountOwner> jointOwners;
    private DateTime nextPaymentDate;
    private String status;
    private Double nextPaymentAmount;
    private Double payoffAmount;
    private Double perDiem;
    private Boolean activeGapPolicy;
    private Boolean cancelledGapPolicy;
    private DateTime gapPurchaseDate;
    private Boolean canSkipPayment;
    private Decimal visaNextPaymentAmount;
    private Boolean firstPaymentMade;
    private Boolean hasLifeInsurance;
    private Boolean hasDisabilityInsurance;

    public SFAccount(Double availableBalance, Double currentBalance, String name, String majorType, String minorType, String nickName, String accountNumber) {
        this.availableBalance = availableBalance;
        this.currentBalance = currentBalance;
        this.name = name;
        this.majorType = majorType;
        this.minorType = minorType;
        this.nickName = nickName;
        this.accountNumber = accountNumber;
        this.jointOwners = new List<IJointAccountOwner>();
    }

    public String getAccountNumber() {
        return this.accountNumber;
    }

    public String getAccountType() {
        return this.accountType;
    }

    public Double getAvailableBalance() {
        return this.availableBalance;
    }

    public Double getCurrentBalance() {
        return this.currentBalance;
    }

    public String getMajorType() {
        return this.majorType;
    }

    public String getMinorType() {
        return this.minorType;
    }

    public String getName() {
        return this.name;
    }

    public String getNickName() {
        return this.nickName;
    }

    public List<IJointAccountOwner> getJointOwners() {
        return this.jointOwners;
    }

    public void setNextPaymentDate(DateTime nextPaymentDate) {
        this.nextPaymentDate = nextPaymentDate;
    }

    public DateTime getNextPaymentDate() {
        return this.nextPaymentDate;
    }

    public Double getPayoffAmount() {
        return null;
    }

    public Double getPerDiem() {
        return null;
    }

    public String getStatus() {
        return this.status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPreferredName() {
        String name = this.getName();

        if (this.getNickName() != null) {
            name = this.getNickName();
        }

        return name;
    }

    public Double getInterestRate() {
        return this.interestRate;
    }

    public void setInterestRate(Double interestRate) {
        this.interestRate = interestRate;
    }

    public String getBranchName() {
        return this.branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public List<IAccountTransaction> getTransactions() {
        return this.transactions;
    }

    public void setTransactions(List<IAccountTransaction> transactions) {
        this.transactions = transactions;
    }

    public Double getNextPaymentAmount() {
        return this.nextPaymentAmount;
    }

    public void setNextPaymentAmount(Double nextPaymentAmount) {
        this.nextPaymentAmount = nextPaymentAmount;
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

    public void setGapPurchaseDate(DateTime GapPurchaseDate) {
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