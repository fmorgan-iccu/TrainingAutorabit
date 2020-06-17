public interface IAccountOpeningTransactionProvider {
	List<IAccountOpeningTransaction> getTransactionsByFormStatus(String formStatus);
    List<AccountOpeningTransactionGroup> getGroupedTransactions();
    IAccountOpeningTransaction getTransaction(String transactionId);
    IAccountOpeningTransaction updateTransactionStatus(String status, String transactionId);
    List<String> getUpdateTransactionFormStatuses();
}