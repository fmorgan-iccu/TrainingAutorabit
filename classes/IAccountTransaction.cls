public interface IAccountTransaction {
    double getAmount();
    double getBalance();
    String getCheckNumber();
    String getDescription();
    DateTime getEffectiveDate();
    String getExternalDescription();
    String getInternalDescription();
    boolean getIsCredit();
    DateTime getPostDate();
    String getOriginatingPerson();
    String getStatus();
    String getTransactionNumber();
    String getTypeCode();
}