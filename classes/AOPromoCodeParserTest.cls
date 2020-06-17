@IsTest
private class AOPromoCodeParserTest {
	@IsTest
    private static void testHappyPath() {
        String testdata = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><PromoCode>promoWayneRocks</PromoCode></AvokaSmartForm></Root>';
		
        try {
            XPath xpath = new XPath(testData);
            Dom.XmlNode promoCodeNode = xpath.findFirst('/Root/AvokaSmartForm/PromoCode');

            List<Map<String,Object>> promoCodePayloads = new List<Map<String,Object>>();
            Map<String, Object> v0PromoCodePayload = new Map<String, Object>();
            v0PromoCodePayload.put(AOConstants.XML_NODE_KEY, promoCodeNode);
            promoCodePayloads.add(v0PromoCodePayload);
            Map<String, Object> v1PromoCodePayload = new Map<String, Object>();
            v1PromoCodePayload.put(AOConstants.XML_NODE_KEY, promoCodeNode);
            v1PromoCodePayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
            promoCodePayloads.add(v1PromoCodePayload);
            Map<String, Object> v2PromoCodePayload = new Map<String, Object>();
            v2PromoCodePayload.put(AOConstants.XML_NODE_KEY, promoCodeNode);
            v2PromoCodePayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
            promoCodePayloads.add(v2PromoCodePayload);

            for (Map<String, Object> promoCodePayload : promoCodePayloads) {
                AOPromoCodeParser parser = new AOPromoCodeParser();
                AOApplicationInfo appInfo = new AOApplicationInfo();
                parser.parsePayload(promoCodePayload, appInfo);
                
                System.assert(appInfo.promoCode != null, 'Promo code was unexpectedly null!');
                
                String expectedPromoCode = 'promoWayneRocks'; // I didn't write that, Torrey did. ;)
                System.assert(expectedPromoCode.equals(appInfo.promoCode), 'Expected promo code not found.  Expected (' + expectedPromoCode + ') found (' + appInfo.promoCode + ').');
                
                Integer expectedErrorCount = 0;
                Integer actualErrorCount = appInfo.errors.size();
                System.assertEquals(expectedErrorCount, actualErrorCount, 'Error: ' + appInfo.errors);
            }
        } catch(Exception e) {
            System.assert(false, 'unexpected threw exception: ' + e.getMessage());
        }
    }
    
    @IsTest
    private static void testUnhappyPath() {
        try {
            Map<String, Object> payload = new Map<String, Object>();

			AOPromoCodeParser parser = new AOPromoCodeParser();
            AOApplicationInfo appInfo = new AOApplicationInfo();
			parser.parsePayload(payload, appInfo);

            System.assert(false, 'expected an exception to be thrown');
        } catch(Exception e) {
            
        }
    }
}