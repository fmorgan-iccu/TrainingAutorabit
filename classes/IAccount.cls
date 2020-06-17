/*
 *	Interface for describing a financial account 
 */
public interface IAccount {
	String getAccountNumber();
    Double getAvailableBalance();
    String getBranchName();
    Double getCurrentBalance();
    Double getInterestRate();
    List<IJointAccountOwner> getJointOwners();
    String getMajorType();
    String getMinorType();
    String getName();
    String getNickName();
    String getPreferredName();
    double getNextPaymentAmount(); // Only applicable for loans
    DateTime getNextPaymentDate(); // Only applicable for loans
    String getStatus();
    List<IAccountTransaction> getTransactions(); // Not typically present on accounts
    void setTransactions(List<IAccountTransaction> transactions);
}