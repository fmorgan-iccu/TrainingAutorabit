public with sharing class AOFatalErrorParser implements IAOPayloadParser {
    
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
		Dom.XmlNode fatalErrorNode = (Dom.XmlNode)payload.get(AOConstants.XML_NODE_KEY);
		if (fatalErrorNode != null && fatalErrorNode.getText() == 'true') {
			appInfo.isFatalError = true;
		}
    }
    
}