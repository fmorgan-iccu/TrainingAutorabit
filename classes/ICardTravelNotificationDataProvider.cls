public interface ICardTravelNotificationDataProvider {
    Boolean cancelTravelNotification(String cardNumber, String id);
    List<CardTravelNotificationInfo> getTravelNotification(String cardNumber);
    Boolean updateTravelNotification(CardTravelNotificationInfo info);
    String getProviderName();
}