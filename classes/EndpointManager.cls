/*
 *	Abstraction layer for getting the various networking endpoints, based on the currenty environment.
 */ 
public class EndpointManager {
    public static final String HTTP_METHOD_GET      = 'GET';
    public static final String HTTP_METHOD_POST     = 'POST';
    public static final String HTTP_METHOD_PUT      = 'PUT';
    public static final String HTTP_METHOD_DELETE   = 'DELETE';

// DNA endpoints

    public String getDNAServiceEndpoint() {
        return this.getEndpointByName('DNAServices');
    }

    public String getDNASignOnEndpoint() {
        return this.getEndpointByName('DNASignOn');
    }

    public String getDNABusinessServicesEndpoint() {
        return this.getEndpointByName('DNABusinessServices');
    }

    public String getDNABusinessServicesSignOnEndpoint() {
        return this.getEndpointByName('DNABusinessServicesSignOn');
    }
    
// Encompass Endpoints

    public String getEncompassOAuthEndpoint() {
        return this.getEndpointByName('EncompassOAuth');
    }
    
    public String getEncompassSSNSearchEndpoint() {
        return this.getEndpointByName('EncompassCreateCursor');
    }
    
    public String getEncompassLoanEndpoint() {
        return this.getEndpointByName('EncompassGetLoan');
    }
    
    public String getEncompassLoanMilestonesEndpoint() {
        return this.getEndpointByName('EncompassGetLoanMilestones');
    }

// COOP Endpoint

    public String getCoopConciergeEndpoint() {
        return this.getEndpointByName('COOPConcierge');
    }

// CRIF Action Endpoints

    public String getCRIFActionApplicationSearchEndpoint() {
        return this.getEndpointByName('CRIFActionApplicationSearch');
    }
  
// Avoka Endpoints

    public String getAvokaTransactionEndpoint() {
        return this.getEndpointByName('AvokaTransactions');
    }

    public String getAvokaPrefillEndpoint() {
        return this.getEndpointByName('AvokaPrefillService');
    }

// Product API Endpoint
    
    public String getProductsAPIEndpoint() {
        return this.getEndpointByName('ICCUActiveProducts');
    }
    
// CCM API Endpoint

    public String getCCMAPIEndpoint() {
        return this.getEndpointByName('CCM');
    }

// Private methods

    @TestVisible
    private String getEndpointByName(String name) {
        if (name == null || name.length() == 0) {
            return null;
        }

        ServiceEndpoint__mdt serviceEndpoint = [
            SELECT 
            	EndpointURL__c
            FROM ServiceEndpoint__mdt
            WHERE DeveloperName = :name
            LIMIT 1
        ];

        return serviceEndpoint.EndpointURL__c;
    }
}