@isTest
private class AccountOpeningProductTest {
	@isTest
    private static void testHappyPath() {
        String description = 'xkwyrijkhdfg';
        String displayName = 'asdfasdf';
        String majorTypeCode = 'dfgh';
        String minorTypeCode = 'xcxc';
        String categoryId = '2342';

        AccountOpeningProduct product = new AccountOpeningProduct(categoryId, description, displayName, majorTypeCode, minorTypeCode);

        System.assert(categoryId.equals(product.categoryId));
        System.assert(description.equals(product.description));
        System.assert(displayName.equals(product.displayName));
        System.assert(majorTypeCode.equals(product.majorTypeCode));
        System.assert(minorTypeCode.equals(product.minorTypeCode));
    }
}