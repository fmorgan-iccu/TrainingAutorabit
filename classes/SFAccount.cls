public with sharing class SFAccount implements IAccount {
    private double availableBalance;
    private String branchName;
    private double currentBalance;
    private String name;	
    private String majorType;
    private String minorType;
    private String nickName;
    private String accountNumber;
    private double interestRate;
    private List<IAccountTransaction> transactions;
    private List<IJointAccountOwner> jointOwners;
    private DateTime nextPaymentDate;
    private String status;
    private double nextPaymentAmount;
    
    public SFAccount(double availableBalance, double currentBalance, String name, String majorType, String minorType, String nickName, String accountNumber) {
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
    
    public double getAvailableBalance() {
        return this.availableBalance;
    }
    
    public double getCurrentBalance() {
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
    
    public double getInterestRate() {
        return this.interestRate;
    }
    
    public void setInterestRate(double interestRate) {
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
    
    public double getNextPaymentAmount() {
        return this.nextPaymentAmount;
    }
    
    public void setNextPaymentAmount(double nextPaymentAmount) {
        this.nextPaymentAmount = nextPaymentAmount;
    }
}