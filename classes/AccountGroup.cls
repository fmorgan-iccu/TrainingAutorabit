/**
 * Object representing an arbitrary grouping of IAccount
 */
public class AccountGroup {
	private String name;
    private List<IAccount> accounts;
    
    public AccountGroup(String name) {
        this.name = name;
        this.accounts = new List<IAccount>();
    }
    
    public AccountGroup(String name, List<IAccount> accounts) {
        this.name = name;
        this.accounts = accounts;
    }
    
    public String getName() {
        return this.name;
    }
    
    public List<IAccount> getAccounts() {
        return this.accounts;
    }
}