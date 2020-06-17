/*
*	Class representing a financial account in the DNA system. 
*/
public with sharing class DNAAccount implements IAccount {
    
    // These constants are used for creating verification questions.
    public static final String MJR_ACCT_CODE_CHECKING		= 'CK';
    public static final String MJR_ACCT_CODE_SAVINGS		= 'SAV';
    public static final String MJR_ACCT_CODE_CD				= 'TD';
    public static final String MJR_ACCT_CODE_MORTGAGE		= 'MTG';
    public static final String MJR_ACCT_CODE_CREDIT_CARD	= 'EXT';
    public static final String MJR_ACCT_CODE_USED_AUTO_LOAN	= 'LBUA';

    private String accountNumber;
    private Double availableBalance;
    private String branchName;
    private Double currentBalance;
    private Double interestRate;
    private List<DNAJointAccountOwner> jointOwners;
    private String majorType;
    private String minorType;
    private String name;
    private double nextPaymentAmount;
    private DateTime nextPaymentDate;
    private String nickName;
    private String status;
    private List<IAccountTransaction> transactions;
    
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
    }
    
    public String getAccountNumber() {
        return this.accountNumber;
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
    }
    
    public String getMinorType() {
        return this.minorType;
    }
    
    public void setMinorType(String minorType) {
        this.minorType = minorType;
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
    
    public double getNextPaymentAmount() {
        return this.nextPaymentAmount;
    }
    
    public void setNextPaymentAmount(double nextPaymentAmount) {
        this.nextPaymentAmount = nextPaymentAmount;
    }
    
    public DateTime getNextPaymentDate() {
        return this.nextPaymentDate;
    }
    
    public void setNextPaymentDate(DateTime nextPaymentDate) {
        this.nextPaymentDate = nextPaymentDate;
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
}