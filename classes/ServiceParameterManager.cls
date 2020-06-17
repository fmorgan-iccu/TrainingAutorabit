/**
 * Class for managing Service Parameters that are stored in SF.
 */
public class ServiceParameterManager {
    public String getCRIFInterfaceID() {
        return this.getParameterByKey('CRIFInterfaceID');
    }

    public String getDNAApplNumber() {
        return this.getParameterByKey('DNAApplNumber');
    }
    
    public String getDNANetworkNodeName() {
        return this.getParameterByKey('DNANetworkNodeName');
    }
    
    public String getDNAAuthorizationType() {
        return this.getParameterByKey('DNAAuthorizationType');
    }

    public String getProxyCertificateName() {
        return this.getParameterByKey('ProxyCertificateName');
    }

    public String getCRIFUser() {
        return this.getParameterByKey('CRIFUser');
    }

// Private Methods

    @TestVisible
    private String getParameterByKey(String key) {
        if (key == null || key.length() == 0) {
            return null;
        }
        
        ServiceParameter__mdt parameter = [
            SELECT 
            	Value__c
            FROM ServiceParameter__mdt
            WHERE Key__c = :key
            LIMIT 1
        ];

        return parameter.Value__c;
    }
}