@isTest
private class AOFatalErrorParserTest {

    static testMethod void fatalError() {
        String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><SFMData><NarrativeMeta><FatalError>true</FatalError></NarrativeMeta></SFMData></AvokaSmartForm></Root>';
        
		try {
            XPath xpath = new XPath(testData);
			Dom.XmlNode fatalErrorNode = xpath.findFirst('/Root/AvokaSmartForm/SFMData/NarrativeMeta/FatalError');

            List<Map<String,Object>> fatalErrorPayloads = new List<Map<String,Object>>();
            Map<String, Object> v0FatalErrorPayload = new Map<String, Object>();
            v0FatalErrorPayload.put(AOConstants.XML_NODE_KEY, fatalErrorNode);
            fatalErrorPayloads.add(v0FatalErrorPayload);
            Map<String, Object> v1FatalErrorPayload = new Map<String, Object>();
            v1FatalErrorPayload.put(AOConstants.XML_NODE_KEY, fatalErrorNode);
            v1FatalErrorPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
            fatalErrorPayloads.add(v1FatalErrorPayload);
            Map<String, Object> v2FatalErrorPayload = new Map<String, Object>();
            v2FatalErrorPayload.put(AOConstants.XML_NODE_KEY, fatalErrorNode);
            v2FatalErrorPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
            fatalErrorPayloads.add(v2FatalErrorPayload);

            for (Map<String, Object> fatalErrorPayload : fatalErrorPayloads) {
                AOFatalErrorParser fatalErrorParser = new AOFatalErrorParser();
                AOApplicationInfo appInfo = new AOApplicationInfo();
                fatalErrorParser.parsePayload(fatalErrorPayload, appInfo);

                System.assertEquals(true, appInfo.isFatalError, 'The fatal error flag is not set.');
            }
            
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }
    }

	static testMethod void notFatalError() {
        String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><SFMData><NarrativeMeta><FatalError>false</FatalError></NarrativeMeta></SFMData></AvokaSmartForm></Root>';
        
		try {
            XPath xpath = new XPath(testData);
           	
			Dom.XmlNode fatalErrorNode = xpath.findFirst('/Root/AvokaSmartForm/SFMData/NarrativeMeta/FatalError');
			Map<String, Object> fatalErrorPayload = new Map<String, Object>();
            fatalErrorPayload.put(AOConstants.XML_NODE_KEY, fatalErrorNode);
            AOFatalErrorParser fatalErrorParser = new AOFatalErrorParser();
            
            AOApplicationInfo appInfo = new AOApplicationInfo();
			fatalErrorParser.parsePayload(fatalErrorPayload, appInfo);

			System.assertEquals(false, appInfo.isFatalError, 'The fatal error flag should not be set.');
            
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }
    }

}