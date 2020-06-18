/*
 *	Interface for describing a class that accesses financial account data.
 */
public interface IPersonAccountDataProvider {
    IAccount getAccount(String accountNumber);
    IAccount getAccount(String accountNumber, Date payoffDate);
    List<IAccount> getAccounts(IPerson person);
    List<IAccount> getAccounts(IOrganization organization);
    List<AccountGroup> getAccountsGrouped(IPerson person);
    List<AccountGroup> getAccountsGrouped(IOrganization organization);
    List<ICollateral> getCollateral(String accountNumber);
    List<IAccountTransaction> getTransactions(String accountNumber, DateTime startDate, DateTime endDate);
    IAuthenticationManager getAuthenticationManager();
    List<IWarningFlag> getAllWarningFlags(IOrganization org);
    List<IWarningFlag> getAllWarningFlags(IPerson person);
    List<IWarningFlag> getAllWarningFlags(List<IAccount> accounts);
    AccountSummary getAccountOwnerTotals(IOrganization organization);
    Map<String, List<IAccountTransaction>> getFilteredAccountTransactions(List<IAccount> accounts, List<String> typeCodes);
}