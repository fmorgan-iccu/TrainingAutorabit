/**
 * Parser for finding and populating the promo code of an application
 */
public class AOPromoCodeParser implements IAOPayloadParser {

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
        Dom.XmlNode promoCodeNode = (Dom.XmlNode)payload.get(AOConstants.XML_NODE_KEY);

        if (promoCodeNode == null) {
            throw new XmlException('PromoCode node not found in payload.');
        }

		String code = promoCodeNode.getText();
        
        if (code != null) {
            appInfo.promoCode = code;
        }
    }

}