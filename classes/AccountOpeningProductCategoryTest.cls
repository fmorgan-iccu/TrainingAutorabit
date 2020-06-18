@isTest
private class AccountOpeningProductCategoryTest {
	@isTest
    private static void testHappyPath() {
        String displayName = 'asldkjs';
        String id = 'ouo3i45o3';
        integer order = 8;
        String parentCategoryID = '23';
        
        AccountOpeningProductCategory category = new AccountOpeningProductCategory(displayName, id, order, parentCategoryID);

        System.assert(category.getChildCategories() != null);
        System.assert(displayName.equals(category.getDisplayName()));
        System.assert(id.equals(category.getId()));
        System.assert(order == category.getOrder());
        System.assert(parentCategoryID.equals(category.getParentCategoryId()));
    }
}