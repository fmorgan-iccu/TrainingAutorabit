public class AOProductParser implements IAOPayloadParser {
	
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
        // Access the major/minor produduct codes to get the values.
		Dom.XmlNode parentNode = (Dom.XmlNode)payload.get(AOConstants.XML_NODE_KEY);
        if (parentNode == null) {
            throw new XmlException('Did not receive product parent node: ' + parentNode);
        }

		String parentNamespace = parentNode.getNamespace();

		Dom.XmlNode majorProductNode = parentNode.getChildElement('MajorProductId', parentNamespace);
		Dom.XmlNode minorProductNode = parentNode.getChildElement('MinorProductId', parentNamespace);

		// NOTE:  There is a difference in our sample data packages where the node names were different.  For now,
		// the system will look for these alternate nodes if both of the nodes above weren't found.  The data needs
		// to be reviewed to determine if this is actually needed.
        Dom.XmlNode selectedProductObjectNode = parentNode.getChildElement('SelectedProductObject', parentNamespace);
        
        if (selectedProductObjectNode != null) {
            //this.printNode(selectedProductObjectNode, 0);

            if (majorProductNode == null && minorProductNode == null) {
                majorProductNode = selectedProductObjectNode.getChildElement('mjaccttypcd', parentNamespace);
                minorProductNode = selectedProductObjectNode.getChildElement('miaccttypcd', parentNamespace);
            }
            
            Dom.XmlNode productInfoNode = selectedProductObjectNode.getChildElement('product_info', parentNamespace);

            // Dig down and see if we can find the product name
            if (productInfoNode != null) {
                Dom.XmlNode displayNameNode = productInfoNode.getChildElement('display_name', parentNamespace);
                
                if (displayNameNode != null) {
                    Dom.XmlNode enNode = displayNameNode.getChildElement('en', parentNamespace);
                    
                    if (enNode != null) {
                        appInfo.productName = enNode.getText();
                    }
                }
            }
        }

        if (majorProductNode == null || minorProductNode == null) {
            throw new XmlException('Major or minor product node not found in ProductSelection: ' + parentNode.getName() + ' - ' + parentNode);
        }

		// Store the major/minor product codes in the appliction info object; avoid storing unknown.
        String unknownProduct = 'unknown';

		appInfo.productMajorCode = majorProductNode.getText();
        if (unknownProduct.equals(appInfo.productMajorCode)) {
            appInfo.productMajorCode = null;
        }

		appInfo.productMinorCode = minorProductNode.getText();
        if (unknownProduct.equals(appInfo.productMinorCode)) {
            appInfo.productMinorCode = null;
        }
    }
    
    /*
    private void printNode(Dom.XMLNode node, Integer indentLevel) {
        String indent = '';
        
        for (Integer i = 0; i < indentLevel; i++) {
            indent = indent + '____	';
        }
        
        System.debug('>>>>>' + indent + '['+node.getName() + ']:[' + node.getNamespace() + ']:[' + node.getText() + ']');
        
        integer attributeCount = node.getAttributeCount();  
        for (integer i = 0; i < attributeCount; i++) {
            String key = node.getAttributeKeyAt(i);
            String value = node.getAttributeValue(key, null);
            System.debug('>>>>> ' + indent + ' attribute:    ' + key + '=' + value);
        }

        for (Dom.XMLNode child : node.getChildElements()) {
            this.printNode(child, indentLevel + 1);
        }
    }
*/
}