@IsTest
private class AOJointApplicationParserTest {
	@IsTest
    private static void testTrueHappyPath() {
        String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><isJointFlow>true</isJointFlow></AvokaSmartForm></Root>';
 
        try {
            XPath xpath = new XPath(testData);
            Dom.XmlNode isJointNode = xpath.findFirst('/Root/AvokaSmartForm/isJointFlow');

            List<Map<String,Object>> isJointPayloads = new List<Map<String,Object>>();
            Map<String, Object> v0IsJointPayload = new Map<String, Object>();
            v0IsJointPayload.put(AOConstants.XML_NODE_KEY, isJointNode);
            isJointPayloads.add(v0IsJointPayload);
            Map<String, Object> v1IsJointPayload = new Map<String, Object>();
            v1IsJointPayload.put(AOConstants.XML_NODE_KEY, isJointNode);
            v1IsJointPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
            isJointPayloads.add(v1IsJointPayload);
            Map<String, Object> v2IsJointPayload = new Map<String, Object>();
            v2IsJointPayload.put(AOConstants.XML_NODE_KEY, isJointNode);
            v2IsJointPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
            isJointPayloads.add(v2IsJointPayload);

            for (Map<String, Object> isJointPayload : isJointPayloads) {
                AOJointApplicationParser parser = new AOJointApplicationParser();
                AOApplicationInfo appInfo = new AOApplicationInfo();
                parser.parsePayload(isJointPayload, appInfo);

                System.assertEquals(true, appInfo.isJointApplication, 'Expected this to be a joint application, but it was not.');
                
                Integer expectedErrors = 0;
                Integer actualErrors = appInfo.errors.size();
                System.assertEquals(expectedErrors, actualErrors, 'Unexpected errors: ' + appInfo.errors);
            }
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }
    }
    
    @IsTest
    private static void testFalseHappyPath() {
        String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><isJointFlow>false</isJointFlow></AvokaSmartForm></Root>';
 
        try {
            XPath xpath = new XPath(testData);
            Dom.XmlNode isJointNode = xpath.findFirst('/Root/AvokaSmartForm/isJointFlow');

            List<Map<String,Object>> isJointPayloads = new List<Map<String,Object>>();
            Map<String, Object> v0IsJointPayload = new Map<String, Object>();
            v0IsJointPayload.put(AOConstants.XML_NODE_KEY, isJointNode);
            isJointPayloads.add(v0IsJointPayload);
            Map<String, Object> v1IsJointPayload = new Map<String, Object>();
            v1IsJointPayload.put(AOConstants.XML_NODE_KEY, isJointNode);
            v1IsJointPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
            isJointPayloads.add(v1IsJointPayload);
            Map<String, Object> v2IsJointPayload = new Map<String, Object>();
            v2IsJointPayload.put(AOConstants.XML_NODE_KEY, isJointNode);
            v2IsJointPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
            isJointPayloads.add(v2IsJointPayload);

            for (Map<String, Object> isJointPayload : isJointPayloads) {
                AOJointApplicationParser parser = new AOJointApplicationParser();
                AOApplicationInfo appInfo = new AOApplicationInfo();
                parser.parsePayload(isJointPayload, appInfo);

                System.assertEquals(false, appInfo.isJointApplication, 'Expected this to be a joint application, but it was not.');
                
                Integer expectedErrors = 0;
                Integer actualErrors = appInfo.errors.size();
                System.assertEquals(expectedErrors, actualErrors, 'Unexpected errors: ' + appInfo.errors);
            }
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }
    }
    
    @IsTest
    private static void testUnhappyPath() {
		AOJointApplicationParser parser = new AOJointApplicationParser();
        AOApplicationInfo appInfo = new AOApplicationInfo();
        
        try {
            parser.parsePayload(null, appInfo);
            System.assert(appInfo.isJointApplication == false);
            
            parser.parsePayload(new Map<String, Object>(), null);
            System.assert(appInfo.isJointApplication == false);
            
            parser.parsePayload(new Map<String, Object>(), appInfo);
            System.assert(appInfo.isJointApplication == false);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }
    }
}