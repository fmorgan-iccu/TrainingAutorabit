public interface IAccountOpeningTransaction {
    String getId();
    String getCaseId();
    String getClientName();
    String getContactEmail();
    String getDeliveryStatus();
    String getExternalProfileId();
    String getFormName();
    String getFormStatus();
    String getFormURL();
    AccountOpeningProduct getProduct();
    DateTime getTimeLastUserActivity();
    DateTime getTimeRequested();
    DateTime getTimeSubmitted();
    String getTrackingCode();
}