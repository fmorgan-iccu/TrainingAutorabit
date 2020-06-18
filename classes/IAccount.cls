/*
 *	Interface for describing a financial account
 */
public interface IAccount {
    String getAccountNumber();
    String getAccountType();
    Double getAvailableBalance();
    String getBranchName();
    Double getCurrentBalance();
    Double getInterestRate();
    List<IJointAccountOwner> getJointOwners();
    String getMajorType();
    String getMinorType();
    String getName();
    String getNickName();
    Double getPerDiem();
    Double getPayoffAmount();
    String getPreferredName();
    double getNextPaymentAmount(); // Only applicable for loans
    DateTime getNextPaymentDate(); // Only applicable for loans
    String getStatus();
    List<IAccountTransaction> getTransactions(); // Not typically present on accounts
    void setTransactions(List<IAccountTransaction> transactions);
    Boolean getActiveGapPolicy();
    Boolean getCancelledGapPolicy();
    DateTime getGapPurchaseDate();
    Boolean getFirstPaymentMade();
    Boolean getHasLifeInsurance();
    Boolean getHasDisabilityInsurance();
    void setActiveGapPolicy(Boolean activeGapPolicy);
    void setCancelledGapPolicy(Boolean cancelledGapPolicy);
    void setGapPurchaseDate(DateTime gapPurchaseDate);
    Boolean getCanSkipPayment();
    void setCanSkipPayment(Boolean canSkipPayment);
    Decimal getVisaNextPaymentAmount();
    void setVisaNextPaymentAmount(Decimal visaNextPaymentAmount);
    void setFirstPaymentMade(Boolean firstPaymentMade);
    void setHasLifeInsurance(Boolean hasLifeInsurance);
    void setHasDisabilityInsurance(Boolean hasDisabilityInsurance);
}