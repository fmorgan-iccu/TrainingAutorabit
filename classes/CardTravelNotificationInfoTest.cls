@IsTest
private class CardTravelNotificationInfoTest {

    @IsTest
    private static void testConstructor() {
        Date today = System.today();
        CardTravelNotificationInfo.Detail detail = new CardTravelNotificationInfo.Detail(today, today.addDays(5), 'CA', 'USA', 'test');
        List<CardTravelNotificationInfo.Detail> details = new List<CardTravelNotificationInfo.Detail>();
        details.add(detail);
        CardTravelNotificationInfo info = new CardTravelNotificationInfo('4758691723569136', 'John', 'Doe', '12089991234', details);

        System.assertEquals('4758691723569136', info.cardNumber);
        System.assertEquals('John', info.firstName);
        System.assertEquals('Doe', info.lastName);
        System.assertEquals('12089991234', info.primaryPhone);

        details = info.details;
        System.assertEquals(1, details.size());
        System.assertEquals(today, details[0].fromDate);
        System.assertEquals(today.addDays(5), details[0].toDate);
        System.assertEquals('CA', details[0].stateCode);
        System.assertEquals('USA', details[0].countryCode);
        System.assertEquals('test', details[0].note);
    }
}