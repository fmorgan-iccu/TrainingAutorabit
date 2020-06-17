@isTest
private class IdUtilsTest {

	@isTest
    static void idTests() {
		System.assert(IdUtils.getLeadRecordFieldIdByName('ReferralType__c') == (Id)'00N1Y00000Ia0LS', 'The field Id was not correct.');
		System.assert(IdUtils.isServiceUser(IdUtils.AVOKA_USER_ID) == true, 'The Avoka user should be considered a service user.');
		System.assert(IdUtils.isServiceUser(IdUtils.BATCH_USER_ID) == true, 'The Batch user should be considered a service user.');
		System.assert(IdUtils.isServiceUser(UserInfo.getUserId()) == false, 'The administrator should not be considered a service user.');
    }

}