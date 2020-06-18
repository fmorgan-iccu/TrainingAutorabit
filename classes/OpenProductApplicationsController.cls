/**
 * Aura controller for presenting online account opening applications.
 */
public class OpenProductApplicationsController {

	@AuraEnabled
    public static Map<String, Object> fetchApplicationsByStatus(String status) {
        Map<String, Object> response = new Map<String, Object>();
        
        INetworkFactory network = new ConcreteNetworkProvider();
        IAccountOpeningTransactionProvider transProvider = network.getAccountOpeningTransactionProvider();

        try {
            List<Map<String, Object>> groupList = new List<Map<String, Object>>();

            if (status == null || status.length() == 0) { // If no status, then get them all and group them
                List<AccountOpeningTransactionGroup> groups = transProvider.getGroupedTransactions();
                
                for (AccountOpeningTransactionGroup transGroup : groups) {
                    Map<String, Object> mappedGroup = OpenProductApplicationsController.mapTransactionGroupToMap(transGroup);
                    groupList.add(mappedGroup);
                }
            } else { // We need to get transactions by a form status
                String title = StringUtils.toProperCase(status);
                List<IAccountOpeningTransaction> transactions = transProvider.getTransactionsByFormStatus(status);
                
                AccountOpeningTransactionGroup transGroup = new AccountOpeningTransactionGroup(title, transactions);
                
                Map<String, Object> mappedGroup = OpenProductApplicationsController.mapTransactionGroupToMap(transGroup);
                groupList.add(mappedGroup);
            }
            
            response.put('groups', groupList);
        } catch (Exception e) {
            response.put('error', 'Unable to get transactions: ' + e);
        }
        
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> createCaseForAppplication(Map<String, Object> application) {
        Map<String, Object> response = new Map<String, Object>();
        
        if (application == null) {
            response.put('error', 'Application was null.');
            return response;
        }
        
        String applicationId = (String)application.get('id');
        
        if (applicationId == null) {
            response.put('error', 'Application ID was null.');
            return response;
        }

        try {
            /*String recordTypeName = 'AccountOpening';
            RecordType recordType = [
                SELECT
                	Id
                FROM
                	RecordType
                WHERE
                	RecordType.Name = :recordTypeName
                LIMIT 1
            ];*/
            
            Case kase = new Case(
                AccountOpeningTransactionId__c = applicationId
                //RecordType = recordType
            );
            
            insert kase;
            
            response.put('caseId', kase.Id);
        } catch (Exception e) {
            response.put('error', 'There was a problem creating a case: ' + e);
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getUpdateTransactionFormStatuses() {
        INetworkFactory network = new ConcreteNetworkProvider();
        IAccountOpeningTransactionProvider transProvider = network.getAccountOpeningTransactionProvider();
        
        List<String> statuses = transProvider.getUpdateTransactionFormStatuses();
        
        Map<String, Object> response = new Map<String, Object>();
        
        response.put('statuses', statuses);
        
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateFormStatusForTransaction(String transactionId, String status) {
        INetworkFactory network = new ConcreteNetworkProvider();
        IAccountOpeningTransactionProvider transProvider = network.getAccountOpeningTransactionProvider();

        Map<String, Object> response = new Map<String, Object>();

        try {
            IAccountOpeningTransaction trans = transProvider.updateTransactionStatus(status, transactionId);
            Map<String, Object> rawTrans = OpenProductApplicationsController.mapTransactionToMap(trans);

            response.put('transaction', rawTrans);
        } catch (Exception e) {
            response.put('error', 'There was a problem updating the transaction: ' + e);
        }

        return response;
    }

    private static Map<String, Object> mapTransactionToMap(IAccountOpeningTransaction trans) {
        if (trans == null) {
            return null;
        }

        Map<String, Object> mappedProduct = null;
        
        if (trans.getProduct() != null) {
            mappedProduct = new Map<String, Object>();
            AccountOpeningProduct product = trans.getProduct();
            
            mappedProduct.put('categoryId', product.categoryId);
            mappedProduct.put('description', product.description);
            mappedProduct.put('displayName', product.displayName);
            mappedProduct.put('majorTypeCode', product.majorTypeCode);
            mappedProduct.put('minorTypeCode', product.minorTypeCode);
        }

        Map<String, Object> mappedTrans = new Map<String, Object>();

		mappedTrans.put('id', trans.getId());
        mappedTrans.put('caseId', trans.getCaseId());
		mappedTrans.put('clientName', trans.getClientName());
        mappedTrans.put('contactEmail', trans.getContactEmail());
        mappedTrans.put('deliveryStatus', trans.getDeliveryStatus());
        mappedTrans.put('externalProfileId', trans.getExternalProfileId());
        mappedTrans.put('formName', trans.getFormName());
        mappedTrans.put('formStatus', trans.getFormStatus());
        mappedTrans.put('formURL', trans.getFormURL());
        mappedTrans.put('product', mappedProduct);
        mappedTrans.put('timeLastUserActivity', trans.getTimeLastUserActivity());
        mappedTrans.put('timeRequested', trans.getTimeRequested());
        mappedTrans.put('trackingCode', trans.getTrackingCode());

        return mappedTrans;
    }

    private static Map<String, Object> mapTransactionGroupToMap(AccountOpeningTransactionGroup transactionGroup) {
        Map<String, Object> mappedGroup = new Map<String, Object>();

        mappedGroup.put('title', transactionGroup.getTitle());
        
        List<Map<String, Object>> mappedTransactions = new List<Map<String, Object>>();
        for (IAccountOpeningTransaction trans : transactionGroup.getTransactions()) {
            mappedTransactions.add(OpenProductApplicationsController.mapTransactionToMap(trans));
        }

        mappedGroup.put('transactions', mappedTransactions);

        return mappedGroup;
    }

}