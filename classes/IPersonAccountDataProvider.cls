/*
 *	Interface for describing a class that accesses financial account data.  
 */
public interface IPersonAccountDataProvider {
    List<IAccount> getAccounts(IPerson person);
    List<IAccount> getAccounts(IOrganization organization);
    List<AccountGroup> getAccountsGrouped(IPerson person);
    List<AccountGroup> getAccountsGrouped(IOrganization organization);
    List<IAccountTransaction> getTransactions(String accountNumber, DateTime startDate, DateTime endDate);
    IAuthenticationManager getAuthenticationManager();
    List<IPersonWarningFlag> getAllWarningFlags(IPerson person);
    List<IPersonWarningFlag> getAllWarningFlags(List<IAccount> accounts);
}