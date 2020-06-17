public interface ICardDataProvider {
	List<AccountCardInfo> getAccountCardInfo(String personNumber);
    void updateAccountCardStatuses(String personNumber, List<UpdateAccountCardInfoRequest> requests);
    IAuthenticationManager getAuthenticationManager();
    String getProviderName();
}