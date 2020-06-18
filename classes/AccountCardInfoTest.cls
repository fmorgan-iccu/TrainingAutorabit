@IsTest
private class AccountCardInfoTest {

    @IsTest
    private static void testConstructor() {
        IAccount account = new DNAAccount();
        String agreementNumber = '983459873';
        List<AccountCardInfo.SelectionOption> applicableChangeReasons = new List<AccountCardInfo.SelectionOption>();
        List<AccountCardInfo.SelectionOption> applicableStatuses = new List<AccountCardInfo.SelectionOption>();
        Boolean canChangeStatus = true;
        String cardNumber = '1234567890';
        String nameOnCard = 'John Doe';
        DateTime expirationDate = System.now();
        String status = 'HOT!';
        String providerName = 'CCM';
        String typeCode = 'DBT';
        String displayName = 'Debt Inducer';
        String displayType = 'Debit';
        String userFriendlyStatus = 'OFF';

        AccountCardInfo info = new AccountCardInfo(account, agreementNumber, applicableChangeReasons, applicableStatuses, canChangeStatus, cardNumber, displayName, displayType, expirationDate, nameOnCard, providerName, status, userFriendlyStatus, typeCode);

        System.assertEquals(account, info.account);
        System.assertEquals(applicableChangeReasons, info.applicableChangeReasons);
        System.assertEquals(applicableStatuses, info.applicableStatuses);
        System.assertEquals(canChangeStatus, info.canChangeStatus);
        System.assertEquals(cardNumber, info.cardNumber);
        System.assertEquals(displayName, info.displayName);
        System.assertEquals(expirationDate, info.expirationDate);
        System.assertEquals(providerName, info.providerName);
        System.assertEquals(status, info.status);
        System.assertEquals(userFriendlyStatus, info.userFriendlyStatus);
        System.assertEquals(typeCode, info.typeCode);
        System.assertNotEquals(null, info.uniqueId);
    }

}