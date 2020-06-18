@isTest
private class IdUtilsTest {

    @isTest
    static void idTests() {
        System.assertEquals((Id)'00N1Y00000Ia0LS', IdUtils.getLeadRecordFieldIdByName('ReferralType__c'));
        System.assertEquals(true, IdUtils.isServiceUser(IdUtils.AVOKA_USER_ID));
        System.assertEquals(true, IdUtils.isServiceUser(IdUtils.BATCH_USER_ID));
        System.assertEquals(false, IdUtils.isServiceUser(UserInfo.getUserId()));
        System.assertEquals('00N1Y00000Ia0LS', IdUtils.getLeadRecordFieldIdByName('ReferralType__c'));
        System.assertEquals(true, IdUtils.isServiceUser('0051Y000009QYFxQAO'));
        System.assertEquals(true, IdUtils.isQueue('00G1Y00880123ZxQAO'));
    }

}