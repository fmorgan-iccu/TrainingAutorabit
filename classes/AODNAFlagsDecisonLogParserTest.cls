@IsTest
private class AODNAFlagsDecisonLogParserTest {
	
    @IsTest
    private static void testHappyPath() {
        Map<String, Object> testData = new Map<String, Object> {
            'WarningFlagsCheck' => new Map<String, Object> {
            	'everything' => '{\r\n    \"PersonFlags\": [{ \"FlagCode\": \"CHOF\" }],\r\n    \"AccountFlags\": [\r\n        { \"AccountNumber\": \"706614501\", \"FlagCode\": [\"BRST\"] },\r\n        { \"AccountNumber\": \"706638389\", \"FlagCode\": [\"FRDA\"] }\r\n    ]\r\n}',
            	'callStatus' => 'Success',
	            'decision' => 'APPROVE',
            	'transactionKey' => 'c1b5dd1649b94762976328a4ccca8f93',
            	'trackingNumber' => 'RZHZMXR',
	            'svcDisplayName' => 'Warning Flags Check',
            	'userAction' => null
            }
        };
        
        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        AOApplicationInfo appInfo = new AOApplicationInfo();
        parser.parsePayload(testData, appInfo);
        
        System.assert(appInfo.systemInteractionResults != null);
		
        Map<String, AOInteractionResult> results = appInfo.systemInteractionResults;
        System.assert(results.keySet().size() == 1);
        
        AOInteractionResult result = results.get('WarningFlagsCheck');
        System.assert(result != null);
        
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        System.assertEquals('Approve', result.systemDecision);
        System.assertEquals('Person Flags:  CHOF\n\nAccount Flags: | [706614501 Codes: [BRST ]] | [706638389 Codes: [FRDA ]] ', result.message);
        System.assertEquals('Warning Flags Check', parser.getFriendlyName());
    }
    
    @IsTest
    private static void testNullEverything() {
        Map<String, Object> testData = new Map<String, Object> {
            'WarningFlagsCheck' => new Map<String, Object> {
            	'everything' => null,
            	'callStatus' => 'Success',
	            'decision' => 'APPROVE',
            	'transactionKey' => 'c1b5dd1649b94762976328a4ccca8f93',
            	'trackingNumber' => 'RZHZMXR',
	            'svcDisplayName' => 'Warning Flags Check',
            	'userAction' => null
            }
        };
        
        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        AOApplicationInfo appInfo = new AOApplicationInfo();
        parser.parsePayload(testData, appInfo);
        
        System.assert(appInfo.systemInteractionResults != null);
        
        Map<String, AOInteractionResult> results = appInfo.systemInteractionResults;
        System.assert(results.keySet().size() == 1);
        
        AOInteractionResult result = results.get('WarningFlagsCheck');
        System.assert(result != null);
        
        System.assertEquals(AOInteractionResult.State.ERROR, result.state);
    }
    
    @IsTest
    private static void testEmptyStringEverything() {
        Map<String, Object> testData = new Map<String, Object> {
            'WarningFlagsCheck' => new Map<String, Object> {
            	'everything' => '',
            	'callStatus' => 'Success',
	            'decision' => 'APPROVE',
            	'transactionKey' => 'c1b5dd1649b94762976328a4ccca8f93',
            	'trackingNumber' => 'RZHZMXR',
	            'svcDisplayName' => 'Warning Flags Check',
            	'userAction' => null
            }
        };
        
        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        AOApplicationInfo appInfo = new AOApplicationInfo();
        parser.parsePayload(testData, appInfo);
        
        System.assert(appInfo.systemInteractionResults != null);
        
        Map<String, AOInteractionResult> results = appInfo.systemInteractionResults;
        System.assert(results.keySet().size() == 1);
        
        AOInteractionResult result = results.get('WarningFlagsCheck');
        System.assert(result != null);
        
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        System.assertEquals('Approve', result.systemDecision);
        System.assertEquals('', result.message);
        System.assertEquals('Warning Flags Check', parser.getFriendlyName());    }    
    
    @IsTest
    private static void testBadEverythingJSON() {
        Map<String, Object> testData = new Map<String, Object> {
            'WarningFlagsCheck' => new Map<String, Object> {
            	'everything' => '{\r\n    \"PersonFlag$$\": [{ \"FlagCode\": \"CHOF\" }],\r\n    \"AccountFlag$$\": [\r\n        { \"AccountNumber\": \"706614501\", \"FlagCode\": [\"BRST\"] },\r\n        { \"AccountNumber\": \"706638389\", \"FlagCode\": [\"FRDA\"] }\r\n    ]\r\n}',
            	'callStatus' => 'Success',
	            'decision' => 'APPROVE',
            	'transactionKey' => 'c1b5dd1649b94762976328a4ccca8f93',
            	'trackingNumber' => 'RZHZMXR',
	            'svcDisplayName' => 'Warning Flags Check',
            	'userAction' => null
            }
        };
        
        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        AOApplicationInfo appInfo = new AOApplicationInfo();
        parser.parsePayload(testData, appInfo);
        
        System.assert(appInfo.systemInteractionResults != null);
        
        Map<String, AOInteractionResult> results = appInfo.systemInteractionResults;
        System.assert(results.keySet().size() == 1);
        
        AOInteractionResult result = results.get('WarningFlagsCheck');
        System.assert(result != null);
        
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
    }
    
    @IsTest
    private static void testNullJSONValues() {
        Map<String, Object> testData = new Map<String, Object> {
            'WarningFlagsCheck' => new Map<String, Object> {
            	'everything' => '{\"PersonFlag\":null,\"AccountFlag\":null}',
            	'callStatus' => 'Success',
	            'decision' => 'APPROVE',
            	'transactionKey' => 'c1b5dd1649b94762976328a4ccca8f93',
            	'trackingNumber' => 'RZHZMXR',
	            'svcDisplayName' => 'Warning Flags Check',
            	'userAction' => null
            }
        };
        
        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        AOApplicationInfo appInfo = new AOApplicationInfo();
        parser.parsePayload(testData, appInfo);
        
        System.assert(appInfo.systemInteractionResults != null);
        
        Map<String, AOInteractionResult> results = appInfo.systemInteractionResults;
        System.assert(results.keySet().size() == 1);
        
        AOInteractionResult result = results.get('WarningFlagsCheck');
        System.assert(result != null);
        
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        System.assertEquals('Person Flags: \n\nAccount Flags: ', result.message);
    }
}