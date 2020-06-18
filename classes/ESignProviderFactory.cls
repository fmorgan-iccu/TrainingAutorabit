public class ESignProviderFactory {
    public static IESignProvider getESignProvider() {
        ServiceAccounts__c mulesoftESign = [
            SELECT
                APIClientID__c,
                APIClientSecret__c
            FROM ServiceAccounts__c
            WHERE ServiceName__c = 'MuleSoftESign'
            LIMIT 1
        ];

        EndpointManager mgr = new EndpointManager();

        String endpoint = mgr.getESignEndpoint();
        String clientId = mulesoftESign.APIClientID__c;
        String clientSecret = mulesoftESign.APIClientSecret__c;

        return new MuleSoftESignProvider(endpoint, clientId, clientSecret);
    }
}