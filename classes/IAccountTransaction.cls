public interface IAccountTransaction {
    Double getAmount();
    Double getBalance();
    String getCardTransactionNumber();
    String getCheckNumber();
    String getDescription();
    DateTime getEffectiveDate();
    String getExternalDescription();
    String getInternalDescription();
    String getInternalDescriptionNumber();
    Boolean getIsCredit();
    Boolean getIsPending();
    DateTime getPostDate();
    String getOriginatingPersonName();
    String getOriginatingPersonNumber();
    String getStandardIndustryClassCode();
    String getStatus();
    String getTransactionNumber();
    String getTypeCode();
}