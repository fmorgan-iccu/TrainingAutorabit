@isTest
private class TMTransactionDataProviderTest {
    @isTest
    private static void testHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockAvokaTMResponse());

        ResourceOwnerCredential creds = new ResourceOwnerCredential(null, null, null, 'username', 'password');
        ICCUAccountOpeningProductDataProvider productProvider = new ICCUAccountOpeningProductDataProvider();
        TMTransactionDataProvider provider = new TMTransactionDataProvider(creds, productProvider);

        try {
            List<TMTransaction> transactions = provider.getTransactionsByFormStatus('Opened');
            System.assert(transactions != null, 'Transactions list was null!');
            System.assert(transactions.size() > 0);
        } catch (Exception e) {
            System.assert(false, 'Thrown exception getting transactions: ' + e);
        }

        try {
            TMTransaction trans = provider.getTransaction('123456');
            System.assert(trans != null, 'Transaction was null!');
        } catch (Exception e) {
            System.assert(false, 'Thrown exception getting transaction: ' + e);
        }

        try {
            List<AccountOpeningTransactionGroup> groups = provider.getGroupedTransactions();
            System.assert(groups != null);
            System.assert(groups.size() > 0);
        } catch (Exception e) {
            System.assert(false, 'thrown exception getting grouped transactions: ' + e);
        }

        try {
            TMTransaction trans = provider.updateTransactionStatus('Saved', '123456');
            System.assert(trans != null, 'Transaction was null!');
        } catch (Exception e) {
            System.assert(false, 'Thrown exception updating transaction: ' + e);
        }

        List<String> statuses = provider.getUpdateTransactionFormStatuses();
        System.assert(statuses != null);
        System.assert(statuses.size() > 0);
    }

    @isTest
    private static void testUnhappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockAvokaTMResponse());

        ICCUAccountOpeningProductDataProvider productProvider = new ICCUAccountOpeningProductDataProvider();
        ResourceOwnerCredential creds = new ResourceOwnerCredential(null, null, null, 'username', 'password');
        TMTransactionDataProvider provider = new TMTransactionDataProvider(creds, productProvider);

        try {
            List<TMTransaction> transactions = provider.getTransactionsByFormStatus(null);
            System.assert(false, 'expected an exception to be thrown');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Threw an expected exception.');
        }

        try {
            TMTransaction trans = provider.getTransaction(null);
            System.assert(false, 'expected an exception to be thrown');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Threw an expected exception.');
        }

        try {
            TMTransaction trans = provider.updateTransactionStatus(null, '09283423');
            System.assert(false, 'expected an exception to be thrown');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Threw an expected exception.');
        }

        try {
            TMTransaction trans = provider.updateTransactionStatus('123432', null);
            System.assert(false, 'expected an exception to be thrown');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Threw an expected exception.');
        }
    }
}