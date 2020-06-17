@IsTest
private class AOJobParserTest {
	@IsTest
    private static void testHappyPath() {
        String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><SFMData><SystemProfile><Job><ReferenceNumber>J9SFRMD</ReferenceNumber><StepName>Product Form</StepName><Assignee>lbaxter@avoka.com</Assignee><AvailableRoutes>Default</AvailableRoutes><StepTasks><Task><StepName>Product Form</StepName><MenuLabel>Complete Deposit Products Application</MenuLabel><MenuCategory>Product Form</MenuCategory><TaskSubject>Complete Deposit Products Application</TaskSubject><TaskMessage>Please Complete Deposit Products Application</TaskMessage><FormCompleted>false</FormCompleted><FormEditable>true</FormEditable><FormName>Deposit Products</FormName><FormURL>https://test.iccu.avoka-transact.com/apps/secure/form.htm?submitKey=55f3926dc76f1b1df9f5533ea43da1c3</FormURL><CurrentForm>true</CurrentForm></Task><Task><StepName>Product Form</StepName><MenuLabel>Complete Disclosures and Signatures form.</MenuLabel><MenuCategory>Product Form</MenuCategory><TaskSubject>Complete Disclosures and Signatures form.</TaskSubject><TaskMessage>Please complete the Disclosures and Signatures form.</TaskMessage><FormCompleted>false</FormCompleted><FormEditable>true</FormEditable><FormName>Disclosures and Signatures</FormName><FormURL>https://test.iccu.avoka-transact.com/apps/secure/form.htm?submitKey=13fb7e32f382527257a289a05fd53d74</FormURL><CurrentForm>false</CurrentForm></Task><Task><StepName>Product Form</StepName><MenuLabel>Complete Funding Application</MenuLabel><MenuCategory>Product Form</MenuCategory><TaskSubject>Complete Funding Application</TaskSubject><TaskMessage>Please complete the Funding form.</TaskMessage><FormCompleted>false</FormCompleted><FormEditable>true</FormEditable><FormName>Accounts and Funding</FormName><FormURL>https://test.iccu.avoka-transact.com/apps/secure/form.htm?submitKey=6d2cd6031ef12bea9b2080a599a03d36</FormURL><CurrentForm>false</CurrentForm></Task></StepTasks></Job></SystemProfile></SFMData></AvokaSmartForm></Root>';

        try {
            XPath xpath = new XPath(testData);
            Dom.XmlNode jobNode = xpath.findFirst('/Root/AvokaSmartForm/SFMData/SystemProfile/Job');

            List<Map<String,Object>> jobPayloads = new List<Map<String,Object>>();
            Map<String, Object> v0JobPayload = new Map<String, Object>();
            v0JobPayload.put(AOConstants.XML_NODE_KEY, jobNode);
            jobPayloads.add(v0JobPayload);
            Map<String, Object> v1JobPayload = new Map<String, Object>();
            v1JobPayload.put(AOConstants.XML_NODE_KEY, jobNode);
            v1JobPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
            jobPayloads.add(v1JobPayload);
            Map<String, Object> v2JobPayload = new Map<String, Object>();
            v2JobPayload.put(AOConstants.XML_NODE_KEY, jobNode);
            v2JobPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
            jobPayloads.add(v2JobPayload);

            for (Map<String, Object> jobPayload : jobPayloads) {
                AOApplicationInfo appInfo = new AOApplicationInfo();
                AOJobParser jobParser = new AOJobParser();
                jobParser.parsePayload(jobPayload, appInfo);

                String expectedFormURL = 'https://test.iccu.avoka-transact.com/apps/secure/form.htm?submitKey=55f3926dc76f1b1df9f5533ea43da1c3';
                String expectedFormName = 'Deposit Products';

                System.assert(appInfo.formUrl != null, 'Form URL was unexpectedly null.');
                System.assert(appInfo.formUrl.equals(expectedFormURL), 'Form URLs did not match.  Got: ' + appInfo.formUrl + ' Expected: ' + expectedFormURL);

                System.assert(appInfo.formName != null, 'Form name was unexpectedly null.');
                System.assert(appInfo.formName.equals(expectedFormName), 'Form name did not match. Got: ' + appInfo.formName + ' Expected: ' + expectedFormName);
            }
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }
    }
    
    @IsTest
    private static void testMissingXmlNode() {
        AOApplicationInfo appInfo = new AOApplicationInfo();
        AOJobParser jobParser = new AOJobParser();
        Map<String, Object> jobPayload = new Map<String, Object>();
        jobParser.parsePayload(jobPayload, appInfo);
        
        System.assert(appInfo.formUrl == null, 'Form URL was unexpectedly not null.');
        System.assert(appInfo.formName == null, 'Form name was unexpectedly not null.');
    }
}