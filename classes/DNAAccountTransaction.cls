public with sharing class DNAAccountTransaction implements IAccountTransaction, Comparable {
    public static String DIRECT_DEPOSIT_TYPE_CODE = 'XDEP';
    
    private double amount;
    private double balance;
    private String checkNumber;
    private String description;
    private DateTime effectiveDate;
    private String externalDescription;
    private String internalDescription;
    private boolean isCredit;
    private String originatingPerson;
    private DateTime postDate;
    private String status;
    private String transactionNumber;
    private String typeCode;

    public DNAAccountTransaction(double amount, double balance, String checkNumber, String description, DateTime effectiveDate, String externalDescription, String internalDescription, boolean isCredit, String originatingPerson, DateTime postDate, String status, String transactionNumber, String typeCode) {
        this.amount = amount;
        this.balance = balance;
        this.checkNumber = checkNumber;
        this.description = description;
        this.effectiveDate = effectiveDate;
        this.externalDescription = externalDescription;
        this.internalDescription = internalDescription;
        this.isCredit = isCredit;
        this.originatingPerson = originatingPerson;
        this.postDate = postDate;
        this.status = status;
        this.transactionNumber = transactionNumber;
        this.typeCode = typeCode;
    }
    
    public Integer compareTo(Object compareTo) {
        DNAAccountTransaction compareTrans = (DNAAccountTransaction)compareTo;
        if (this.postDate == compareTrans.postDate) {
            if (this.transactionNumber == compareTrans.transactionNumber) {
                return 0;
            }
            
            if (this.transactionNumber < compareTrans.transactionNumber) {
                return 1;
            }
            
            return -1;
        }

        if (this.postDate < compareTrans.postDate) {
            return 1;
        }

        return -1;       
    }

    public double getAmount() {
        return this.amount;
    }
    
    public double getBalance() {
        return this.balance;
    }
    
    public String getCheckNumber() {
        return this.checkNumber;
    }
    
    public DateTime getEffectiveDate() {
        return this.effectiveDate;
    }
    
    public String getExternalDescription() {
        return this.externalDescription;
    }
    
    public String getDescription() {
        return this.description;
    }
    
    public String getInternalDescription() {
        return this.internalDescription;
    }
    
    public boolean getIsCredit() {
        return this.isCredit;
    }
    
    public String getOriginatingPerson() {
        return this.originatingPerson;
    }

    public DateTime getPostDate() {
        return this.postDate;
    }
    
    public String getStatus() {
        return this.status;
    }
    
    public String getTransactionNumber() {
        return this.transactionNumber;
    }
    
    public String getTypeCode() {
        return this.typeCode;
    }
}