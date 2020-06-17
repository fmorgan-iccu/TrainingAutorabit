@IsTest
private class UpdateAccountCardInfoRequestTest {

    @IsTest
    private static void testConstructor() {

        AccountCardInfo cardInfo = new AccountCardInfo(null, null, null, null, true, 'String cardNumber', 'String displayName', 'Credit', System.now(), 'Name on card', 'CCM', 'String status', 'User friendly status', 'typeCode');
        String changeReason = 'Reason';
        String changeReasonCode = 'LOST';
        String status = 'Inactive';
        UpdateAccountCardInfoRequest request = new UpdateAccountCardInfoRequest(cardInfo, changeReason, changeReasonCode, status);

        System.assertEquals(cardInfo, request.cardInfo);
        System.assertEquals(changeReason, request.changeReason);
        System.assertEquals(changeReasonCode, request.changeReasonCode);
        System.assertEquals(status, request.status);
    }

}