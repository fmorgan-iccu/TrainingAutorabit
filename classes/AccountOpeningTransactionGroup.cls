/**
 * Model object for grouping transactions
 */
public class AccountOpeningTransactionGroup {
	private String title;
    private List<IAccountOpeningTransaction> transactions;
    
    public AccountOpeningTransactionGroup(String title, List<IAccountOpeningTransaction> transactions) {
        this.title = title;
		this.transactions = transactions;
    }
    
    public String getTitle() {
        return this.title;
    }
    
    public List<IAccountOpeningTransaction> getTransactions() {
        return this.transactions;
    }
}