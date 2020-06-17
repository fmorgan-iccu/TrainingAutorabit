public class AOCustomInfoParser implements IAOPayloadParser {
    
    public void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        AOConstants.FormXmlVersion xmlVersion = (AOConstants.FormXmlVersion)payload.get(AOConstants.XML_VERSION);
        switch on xmlVersion {
            when V1 {
                parsePayloadV1(payload, appInfo);
            }
            when V2 {
                parsePayloadV2(payload, appInfo);
            }
            when else {
                parsePayloadDefault(payload, appInfo);
            }
        }
    }

    public void parsePayloadV1(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadV2(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadDefault(Map<String, Object> payload, AOApplicationInfo appInfo) {
		try {
            Dom.XmlNode parentNode = (Dom.XmlNode)payload.get(AOConstants.XML_NODE_KEY);
            if (parentNode == null) {
                throw new XmlException('Did not receive custom info parent node: ' + parentNode); 
            }
            
            String namespace = parentNode.getNamespace();

            Dom.XmlNode customInfoNode = parentNode.getChildElement('ICCUCustom', namespace);

            if (customInfoNode == null) {
                //throw new XmlException('No ICCUCustom node present: ' + parentNode);

                /* Throwing the exception is adding a lot of noise to the parser errors.  
                 * Until such time as we have a actual custom info returning, we will just return.
                 */
                return;
            }
            
            Dom.XmlNode productNameNode = customInfoNode.getChildElement('productName', namespace);
            
            if (productNameNode != null) {
                String productName = productNameNode.getText();
                appInfo.productName = productName;
            }

        } catch (Exception e) {
            appInfo.addExceptionError('Custom Info parser', e);
        }
    }
    
}