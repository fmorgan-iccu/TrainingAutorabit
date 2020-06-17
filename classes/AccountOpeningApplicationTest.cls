@isTest
private class AccountOpeningApplicationTest {
	@isTest
    private static void testHappyPath() {
        IPerson person = new DNAPerson();
        AccountOpeningProduct product = new AccountOpeningProduct('categoryId', 'description', 'displayName', 'majorTypeCode', 'minorTypeCode');
        
        AccountOpeningApplication application = new AccountOpeningApplication(person, product);
        
        System.assert(person == application.getPerson());
        System.assert(product == application.getProduct());
    }
}