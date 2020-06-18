public interface ICollateral {

    List<IAccount> getAccounts();
    String getDescription();
    String getId();
    String getMake();
    String getModel();
    String getPropertyNumber();
    Double getPurchasePrice();
    String getTypeCode();
    Integer getYear();
    Double getValue();

}