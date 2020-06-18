public with sharing class DNAAccountTransaction implements IAccountTransaction, Comparable {
    public static String DIRECT_DEPOSIT_TYPE_CODE = 'XDEP';

    private Double amount;
    private Double balance;
    private String cardTransactionNumber;
    private String checkNumber;
    private String description;
    private DateTime effectiveDate;
    private String externalDescription;
    private String internalDescription;
    private String internalDescriptionNumber;
    private Boolean isCredit;
    private Boolean isPending;
    private String originatingPersonName;
    private String originatingPersonNumber;
    private DateTime postDate;
    private String status;
    private String standardIndustryClassCode;
    private String transactionNumber;
    private String typeCode;

    public DNAAccountTransaction(
        Double amount,
        Double balance,
        String cardTransactionNumber,
        String checkNumber,
        String description,
        DateTime effectiveDate,
        String externalDescription,
        String internalDescription,
        String internalDescriptionNumber,
        Boolean isCredit,
        Boolean isPending,
        String originatingPersonName,
        String originatingPersonNumber,
        DateTime postDate,
        String standardIndustryClassCode,
        String status,
        String transactionNumber,
        String typeCode)
    {
        this.amount = amount;
        this.balance = balance;
        this.cardTransactionNumber = cardTransactionNumber;
        this.checkNumber = checkNumber;
        this.description = description;
        this.effectiveDate = effectiveDate;
        this.externalDescription = externalDescription;
        this.internalDescription = internalDescription;
        this.internalDescriptionNumber = internalDescriptionNumber;
        this.isCredit = isCredit;
        this.isPending = isPending;
        this.originatingPersonName = originatingPersonName;
        this.originatingPersonNumber = originatingPersonNumber;
        this.postDate = postDate;
        this.standardIndustryClassCode = standardIndustryClassCode;
        this.status = status;
        this.transactionNumber = transactionNumber;
        this.typeCode = typeCode;
    }

    public Integer compareTo(Object compareTo) {
        DNAAccountTransaction compareTrans = (DNAAccountTransaction)compareTo;
        DateTime transactionDate = this.postDate != null ? this.postDate : this.effectiveDate;
        DateTime compareTransDate = compareTrans.postDate != null ? compareTrans.postDate : compareTrans.effectiveDate;
        String transNumber = this.transactionNumber != this.transactionNumber ? this.transactionNumber : this.cardTransactionNumber;
        String compareTransNumber = compareTrans.transactionNumber != null ? compareTrans.transactionNumber : compareTrans.cardTransactionNumber;

        if (transactionDate == compareTransDate) {
            if (transNumber == compareTransNumber) {
                return 0;
            } else if (transNumber < compareTransNumber) {
                return 1;
            }
            return -1;
        }

        if (transactionDate < compareTransDate) {
            return 1;
        }

        return -1;
    }

    public Double getAmount() {
        return this.amount;
    }

    public Double getBalance() {
        return this.balance;
    }

    public String getCardTransactionNumber() {
        return this.cardTransactionNumber;
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

    public String getInternalDescriptionNumber() {
        return this.internalDescriptionNumber;
    }

    public Boolean getIsCredit() {
        return this.isCredit;
    }

    public Boolean getIsPending() {
        return this.isPending;
    }

    public String getOriginatingPersonName() {
        return this.originatingPersonName;
    }

    public String getOriginatingPersonNumber() {
        return this.originatingPersonNumber;
    }

    public DateTime getPostDate() {
        return this.postDate;
    }

    public String getStandardIndustryClassCode() {
        return this.standardIndustryClassCode;
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