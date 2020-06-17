@IsTest
private class AOProductParserTest {
	@IsTest
    private static void testProductParsingHappyPath() {

        try {
            String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><TriageFlow><ProductSelection><MinorProductId>CKBA</MinorProductId><MajorProductId>CK</MajorProductId><SelectedProductInterestRate>0</SelectedProductInterestRate><JointEligible/><YouthEligible>false</YouthEligible></ProductSelection></TriageFlow></AvokaSmartForm></Root>';
        
            XPath xpath = new XPath(testData);
            Dom.XmlNode productNode = xpath.findFirst('/Root/AvokaSmartForm/TriageFlow/ProductSelection');

            List<Map<String,Object>> productPayloads = new List<Map<String,Object>>();
            Map<String, Object> v0ProductPayload = new Map<String, Object>();
            v0ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
            productPayloads.add(v0ProductPayload);
            Map<String, Object> v1ProductPayload = new Map<String, Object>();
            v1ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
            v1ProductPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
            productPayloads.add(v1ProductPayload);
            Map<String, Object> v2ProductPayload = new Map<String, Object>();
            v2ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
            v2ProductPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
            productPayloads.add(v2ProductPayload);

            for (Map<String, Object> productPayload : productPayloads) {
                AOProductParser productParser = new AOProductParser();
                AOApplicationInfo appInfo = new AOApplicationInfo();
                productParser.parsePayload(productPayload, appInfo);

                System.assert(appInfo.productMajorCode != null, 'Product major code was null!');
                System.assert(appInfo.productMinorCode != null, 'Product minor code was null!');
                
                String expectedMajor = 'CK';
                String expectedMinor = 'CKBA';
                
                System.assert(appInfo.productMajorCode.equals(expectedMajor), 'Product did not match: ' + expectedMajor);
                System.assert(appInfo.productMinorCode.equals(expectedMinor), 'Product did not match: ' + expectedMinor);
            }
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e);
        }
        
        try {
            String xmlPayload = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><TriageFlow><ChkBypassKBA/><Bypass2FVCheckbox/><ProductSelection><MajorProductId>SAV</MajorProductId><MinorProductId>SECH</MinorProductId><SelectedProductObject><mjaccttypcd>SAV</mjaccttypcd><miaccttypcd>SECH</miaccttypcd><active_start>2018-06-11T12:39:32.000Z</active_start><active_end>2038-01-01T00:00:00.000Z</active_end><product_info><display_name><en>Choice Savings</en></display_name><product_description><en>Perfect for saving on specific purposes while earning a higher interest rate! Save for summer vacations, taxes, Christmas, or maybe even a down payment for a new home. Set up an automatic transfer to make saving even easier.</en></product_description><eligibility><primary><min_age>18</min_age><min_dep>25</min_dep></primary><joint/></eligibility><marketing_features><en>Tiered interest levels that increase as your balance increases</en><es/></marketing_features><marketing_features><en>Unlimited deposits</en><es/></marketing_features><marketing_features><en>Two free withdrawals per calendar year</en><es/></marketing_features><rate_tiers><APYYield>0.001</APYYield><EffectiveDate>/Date(1533621600000-0600)/</EffectiveDate><MaximumTierBalance>1499.99</MaximumTierBalance><MinimumTierBalance>0</MinimumTierBalance><Rate>0.0009995</Rate><RateTierNumber>1</RateTierNumber><dfRateAndApy><rateTo3>0.099</rateTo3><ApyTo3>0.100</ApyTo3></dfRateAndApy><dfBalancesToShow>0-1,499</dfBalancesToShow></rate_tiers><rate_tiers><APYYield>0.002</APYYield><EffectiveDate>/Date(1533621600000-0600)/</EffectiveDate><MaximumTierBalance>999999999.99</MaximumTierBalance><MinimumTierBalance>1500</MinimumTierBalance><Rate>0.0019982</Rate><RateTierNumber>2</RateTierNumber><dfRateAndApy><rateTo3>0.199</rateTo3><ApyTo3>0.200</ApyTo3></dfRateAndApy><dfBalancesToShow>1,500 +</dfBalancesToShow></rate_tiers></product_info><category>8</category><dfDisplayName>Choice Savings</dfDisplayName><dfDescription>Perfect for saving on specific purposes while earning a higher interest rate! Save for summer vacations, taxes, Christmas, or maybe even a down payment for a new home. Set up an automatic transfer to make saving even easier.</dfDescription><dfExpanded>false</dfExpanded><dfRates><APYYield>0.001</APYYield><EffectiveDate>/Date(1533621600000-0600)/</EffectiveDate><MaximumTierBalance>1499.99</MaximumTierBalance><MinimumTierBalance>0</MinimumTierBalance><Rate>0.0009995</Rate><RateTierNumber>1</RateTierNumber><dfRateAndApy><rateTo3>0.099</rateTo3><ApyTo3>0.100</ApyTo3></dfRateAndApy><dfBalancesToShow>0-1,499</dfBalancesToShow></dfRates><dfRates><APYYield>0.002</APYYield><EffectiveDate>/Date(1533621600000-0600)/</EffectiveDate><MaximumTierBalance>999999999.99</MaximumTierBalance><MinimumTierBalance>1500</MinimumTierBalance><Rate>0.0019982</Rate><RateTierNumber>2</RateTierNumber><dfRateAndApy><rateTo3>0.199</rateTo3><ApyTo3>0.200</ApyTo3></dfRateAndApy><dfBalancesToShow>1,500 +</dfBalancesToShow></dfRates><dfFeatures><en>Tiered interest levels that increase as your balance increases</en><es/></dfFeatures><dfFeatures><en>Unlimited deposits</en><es/></dfFeatures><dfFeatures><en>Two free withdrawals per calendar year</en><es/></dfFeatures><dfEligibilities><en>Minimum Age: 18</en></dfEligibilities><dfEligibilities><en>Minimum Deposit: $25</en></dfEligibilities><repeatMarketingFeatures><en>Tiered interest levels that increase as your balance increases</en><es/></repeatMarketingFeatures><repeatMarketingFeatures><en>Unlimited deposits</en><es/></repeatMarketingFeatures><repeatMarketingFeatures><en>Two free withdrawals per calendar year</en><es/></repeatMarketingFeatures><repeatRateTiers><APYYield>0.001</APYYield><EffectiveDate>/Date(1533621600000-0600)/</EffectiveDate><MaximumTierBalance>1499.99</MaximumTierBalance><MinimumTierBalance>0</MinimumTierBalance><Rate>0.0009995</Rate><RateTierNumber>1</RateTierNumber><dfRateAndApy><rateTo3>0.099</rateTo3><ApyTo3>0.100</ApyTo3></dfRateAndApy><dfBalancesToShow>0-1,499</dfBalancesToShow></repeatRateTiers><repeatRateTiers><APYYield>0.002</APYYield><EffectiveDate>/Date(1533621600000-0600)/</EffectiveDate><MaximumTierBalance>999999999.99</MaximumTierBalance><MinimumTierBalance>1500</MinimumTierBalance><Rate>0.0019982</Rate><RateTierNumber>2</RateTierNumber><dfRateAndApy><rateTo3>0.199</rateTo3><ApyTo3>0.200</ApyTo3></dfRateAndApy><dfBalancesToShow>1,500 +</dfBalancesToShow></repeatRateTiers><rptEligibilities><en>Minimum Age: 18</en></rptEligibilities><rptEligibilities><en>Minimum Deposit: $25</en></rptEligibilities><dfSelected>true</dfSelected><dfSelectedDisplayName>Choice Savings</dfSelectedDisplayName></SelectedProductObject><SelectedProductInterestRate>0.0009995</SelectedProductInterestRate><JointEligible/><YouthEligible>false</YouthEligible></ProductSelection></TriageFlow></AvokaSmartForm></Root>';
        
            XPath xpath = new XPath(xmlPayload);
            Dom.XmlNode productNode = xpath.findFirst('/Root/AvokaSmartForm/TriageFlow/ProductSelection');
            System.debug('About to try and get the selected product...');

            List<Map<String,Object>> productPayloads = new List<Map<String,Object>>();
            Map<String, Object> v0ProductPayload = new Map<String, Object>();
            v0ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
            productPayloads.add(v0ProductPayload);
            Map<String, Object> v1ProductPayload = new Map<String, Object>();
            v1ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
            v1ProductPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
            productPayloads.add(v1ProductPayload);
            Map<String, Object> v2ProductPayload = new Map<String, Object>();
            v2ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
            v2ProductPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
            productPayloads.add(v2ProductPayload);

            for (Map<String, Object> productPayload : productPayloads) {
                AOProductParser productParser = new AOProductParser();
                AOApplicationInfo appInfo = new AOApplicationInfo();
                productParser.parsePayload(productPayload, appInfo);

                String expectedProductName = 'Choice Savings';

                System.assert(appInfo.productName != null, 'Product name was null!');
                System.assert(appInfo.productName.equals(expectedProductName), 'Expected product name (' + expectedProductName +') got this name instead: (' + appInfo.productName + ').');
            }
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e);
            System.debug('threw an exception: ' + e.getMessage());
        }
    }
    
    @IsTest
    private static void testUnknownProducts() {
        String xmlPayload = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><TriageFlow><ProductSelection><MajorProductId>unknown</MajorProductId><MinorProductId>unknown</MinorProductId><SelectedProductObject/><SelectedProductInterestRate/><JointEligible/><YouthEligible/></ProductSelection></TriageFlow></AvokaSmartForm></Root>';
        
        XPath xpath = new XPath(xmlPayload);
        Dom.XmlNode productNode = xpath.findFirst('/Root/AvokaSmartForm/TriageFlow/ProductSelection');

        List<Map<String,Object>> productPayloads = new List<Map<String,Object>>();
        Map<String, Object> v0ProductPayload = new Map<String, Object>();
        v0ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
        productPayloads.add(v0ProductPayload);
        Map<String, Object> v1ProductPayload = new Map<String, Object>();
        v1ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
        v1ProductPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
        productPayloads.add(v1ProductPayload);
        Map<String, Object> v2ProductPayload = new Map<String, Object>();
        v2ProductPayload.put(AOConstants.XML_NODE_KEY, productNode);
        v2ProductPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
        productPayloads.add(v2ProductPayload);

        for (Map<String, Object> productPayload : productPayloads) {
            try {
                AOProductParser productParser = new AOProductParser();
                AOApplicationInfo appInfo = new AOApplicationInfo();
                productParser.parsePayload(productPayload, appInfo);
                
                System.assert(appInfo.productMajorCode == null, 'Product major code was expected to be null!');
                System.assert(appInfo.productMinorCode == null, 'Product minor code was expected to be null!');
            } catch(Exception e) {
                System.assert(false, 'Threw an exception: ' + e);
            }
        }
    }
}