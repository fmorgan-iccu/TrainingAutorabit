@IsTest
public with sharing class TestCoreConfigAutoBook {
	@TestSetup
	private static void setup() {
		LLC_BI__Booking_Config__c bc = new LLC_BI__Booking_Config__c();
		bc.LLC_BI__Category__c = 'Test';
		bc.Name = 'Test';
		bc.LLC_BI__Product_Context_Id__c = 'that one';
		nFORCE.DmlUtility.insertObj(bc);
	}

	@IsTest
	private static void assertActivatePlugin() {
		CoreConfigAutoBook.Activator mockActivator = new CoreConfigAutoBook.Activator();
		mockActivator.coreConfigInstance = new MockCoreConfigAutoBook();
		mockActivator.onActivate();

		Integer numConfigs = new nFUSE.PluginConfigurationManager('CoreConfig_AutoBook', '1.0').getConfigurations().size();
		System.assertEquals(8, numConfigs);

		nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest('CoreConfig_AutoBook', '1.0', null);
		Object locatedService = new nFUSE.ServiceLocator().locate(request, nFUSE.SendService.class);
		System.assertEquals(true, locatedService instanceof CoreConfigAutoBook.CoreConfigSendService);

		nForce.SystemProperties.instance.clearCache();
		System.assertEquals('CoreConfig_AutoBook', nForce.SystemProperties.instance.getProperty('atbk.generic', 'pluginName'));
		System.assertEquals('1.0', nForce.SystemProperties.instance.getProperty('atbk.generic', 'pluginVersion'));
	}

	@IsTest
	private static void onActivate_twice() {
		assertActivatePlugin();
		assertActivatePlugin();
	}

	@IsTest
	private static void onActivate_onDeactivate() {
		assertActivatePlugin();

		CoreConfigAutoBook.Activator mockActivator = new CoreConfigAutoBook.Activator();
		mockActivator.coreConfigInstance = new MockCoreConfigAutoBook();
		mockActivator.onActivate();

		Integer numConfigsAfter = new nFUSE.PluginConfigurationManager('CoreConfig_AutoBook', '1.0').getConfigurations().size();
		System.assertEquals(8, numConfigsAfter);

		mockActivator.onDeactivate();
		nFUSE.PackageServiceRequest request2 = new nFUSE.PackageServiceRequest('CoreConfig_AutoBook', '1.0', null);
		try {
			Object locatedServiceAfter = new nFUSE.ServiceLocator().locate(request2, nFUSE.SendService.class);
			System.assert(false, 'expected exception was not thrown');
		} catch (Exception ex) {
			System.assertEquals(true, ex.getMessage().startsWith('Unable to locate service'));

		}
		nForce.SystemProperties.instance.clearCache();
		System.assertEquals(null, nForce.SystemProperties.instance.getProperty('atbk.generic', 'pluginName'));
		System.assertEquals(null, nForce.SystemProperties.instance.getProperty('atbk.generic', 'pluginVersion'));
	}

	@IsTest
	private static void preSendSeam() {
		CoreConfigAutoBook.Activator mockActivator = new CoreConfigAutoBook.Activator();
		mockActivator.coreConfigInstance = new MockCoreConfigAutoBook();
		mockActivator.onActivate();

		Test.startTest();
		nFUSE.AMiddlewareMessage m = new nFUSE.MiddlewareMessage();
		m.messageHeader.action = 'RESERVE';
		m.properties.put('category', 'generic');
		m = new CoreConfigAutoBook.CoreConfigSendService().preSendSeam(m);
		Test.stopTest();

		Map<String, Object> pluginProps = (Map<String, Object>) m.properties.get('CoreConfig_AutoBook');
		System.assertNotEquals(null, pluginProps);
		System.assertEquals(1, pluginProps.size());
	}

	@IsTest
	private static void preSendRequest() {
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginProp
				= createConfig('RESERVE generic Core_Endpoint_URL', 'testUrl');
		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs
				= new List<nFUSE.PluginConfigurationManager.PluginConfiguration>{
						pluginProp
				};
		new nFUSE.PluginConfigurationManager('CoreConfig_AutoBook', '1.0').softInsertConfigurations(configs);

		Test.startTest();
		HttpRequest httpReq = new HttpRequest();
		nFUSE.AMiddlewareMessage m = new nFUSE.MiddlewareMessage();
		m.messageHeader = new nFUSE.MessageHeader();
		m.messageHeader.action = 'RESERVE';
		m.properties.put('category', 'generic');

		new CoreConfigAutoBook.CoreConfigSendService().preSendRequest(httpReq, m);
		Test.stopTest();

		System.assertEquals('testUrl', httpReq.getEndpoint());
	}

	@IsTest
	private static void preSendRequest_BookingConfigsDoNotExist() {
		Test.startTest();
		HttpRequest httpReq = new HttpRequest();
		nFUSE.AMiddlewareMessage m = new nFUSE.MiddlewareMessage();
		m.messageHeader = new nFUSE.MessageHeader();
		m.messageHeader.action = 'RESERVE';
		m.properties.put('category', 'does.not.exist');

		try {
			new CoreConfigAutoBook.CoreConfigSendService().preSendRequest(httpReq, m);
			System.assert(false);
		} catch (Exception e) {
			System.assertEquals(e.getMessage(), CoreConfigAutoBook.X_BOOKING_CONFIGS_NOT_CONFIGURED);
		}
		Test.stopTest();
	}

	@IsTest
	private static void preSendRequest_testMultipleEndPoints() {
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropGeneric
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_GENERIC), GENERIC_URL);
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropLoan
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_LOAN), LOAN_URL);
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropLoanRetail
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_LOAN_RETAIL), LOAN_RETAIL_URL);

		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs
			= new List<nFUSE.PluginConfigurationManager.PluginConfiguration>{
				pluginPropGeneric,
				pluginPropLoan,
				pluginPropLoanRetail
			};
		new nFUSE.PluginConfigurationManager('CoreConfig_AutoBook', '1.0').softInsertConfigurations(configs);

		Test.startTest();
		HttpRequest httpReqGeneric = new HttpRequest();
		nFUSE.AMiddlewareMessage mGeneric = new nFUSE.MiddlewareMessage();
		mGeneric.messageHeader = new nFUSE.MessageHeader();
		mGeneric.messageHeader.action = BOOK_ACTION_RESERVE;
		mGeneric.properties.put(KEY_CATEGORY, CATEGORY_GENERIC);

		new CoreConfigAutoBook.CoreConfigSendService().preSendRequest(httpReqGeneric, mGeneric);

		HttpRequest httpReqLoan = new HttpRequest();
		nFUSE.AMiddlewareMessage mLoan = new nFUSE.MiddlewareMessage();
		mLoan.messageHeader = new nFUSE.MessageHeader();
		mLoan.messageHeader.action = BOOK_ACTION_RESERVE;
		mLoan.properties.put(KEY_CATEGORY, CATEGORY_LOAN);

		new CoreConfigAutoBook.CoreConfigSendService().preSendRequest(httpReqLoan, mLoan);

		HttpRequest httpReqLoanRetail = new HttpRequest();
		nFUSE.AMiddlewareMessage mLoanRetail = new nFUSE.MiddlewareMessage();
		mLoanRetail.messageHeader = new nFUSE.MessageHeader();
		mLoanRetail.messageHeader.action = BOOK_ACTION_RESERVE;
		mLoanRetail.properties.put(KEY_CATEGORY, CATEGORY_LOAN_RETAIL);

		new CoreConfigAutoBook.CoreConfigSendService().preSendRequest(httpReqLoanRetail, mLoanRetail);
		Test.stopTest();

		System.assertEquals(GENERIC_URL, httpReqGeneric.getEndpoint());
		System.assertEquals(LOAN_URL, httpReqLoan.getEndpoint());
		System.assertEquals(LOAN_RETAIL_URL, httpReqLoanRetail.getEndpoint());
	}

	@IsTest
	private static void preSendRequest_testHierarchyEndPoints_DefaultsToGeneric() {
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropGeneric
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_GENERIC), GENERIC_URL);
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropLoan
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_LOAN), '');
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropLoanRetail
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_LOAN_RETAIL), '');

		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs
			= new List<nFUSE.PluginConfigurationManager.PluginConfiguration>{
					pluginPropGeneric,
					pluginPropLoan,
					pluginPropLoanRetail
			};
		new nFUSE.PluginConfigurationManager('CoreConfig_AutoBook', '1.0').softInsertConfigurations(configs);

		Test.startTest();
		HttpRequest httpReqLoanRetail = new HttpRequest();
		nFUSE.AMiddlewareMessage mLoanRetail = new nFUSE.MiddlewareMessage();
		mLoanRetail.messageHeader = new nFUSE.MessageHeader();
		mLoanRetail.messageHeader.action = BOOK_ACTION_RESERVE;
		mLoanRetail.properties.put(KEY_CATEGORY, CATEGORY_LOAN_RETAIL);

		new CoreConfigAutoBook.CoreConfigSendService().preSendRequest(httpReqLoanRetail, mLoanRetail);
		Test.stopTest();

		System.assertEquals(GENERIC_URL, httpReqLoanRetail.getEndpoint());
	}

	@IsTest
	private static void preSendRequest_testHierarchyEndPoints_DefaultsToNextLevel() {
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropGeneric
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_GENERIC), GENERIC_URL);
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropLoan
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_LOAN), LOAN_URL);
		nFUSE.PluginConfigurationManager.PluginConfiguration pluginPropLoanRetail
			= createConfig(buildConfigKey(BOOK_ACTION_RESERVE, CATEGORY_LOAN_RETAIL), '');

		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs
			= new List<nFUSE.PluginConfigurationManager.PluginConfiguration>{
					pluginPropGeneric,
					pluginPropLoan,
					pluginPropLoanRetail
			};
		new nFUSE.PluginConfigurationManager('CoreConfig_AutoBook', '1.0').softInsertConfigurations(configs);

		Test.startTest();
		HttpRequest httpReqLoanRetail = new HttpRequest();
		nFUSE.AMiddlewareMessage mLoanRetail = new nFUSE.MiddlewareMessage();
		mLoanRetail.messageHeader = new nFUSE.MessageHeader();
		mLoanRetail.messageHeader.action = BOOK_ACTION_RESERVE;
		mLoanRetail.properties.put(KEY_CATEGORY, CATEGORY_LOAN_RETAIL);

		new CoreConfigAutoBook.CoreConfigSendService().preSendRequest(httpReqLoanRetail, mLoanRetail);
		Test.stopTest();

		System.assertEquals(LOAN_URL, httpReqLoanRetail.getEndpoint());
	}

	private static string buildConfigKey(String action, String category){
		return action + ' ' + category + ' ' + CORE_ENDPOINT_URL;
	}

	public static nFUSE.PluginConfigurationManager.PluginConfiguration createConfig(String key, String value) {
		nFUSE.PluginConfigurationManager.PluginConfiguration prop = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		prop.key = key;
		prop.description = key;
		prop.isEncrypted = false;
		prop.value = value;
		return prop;
	}

	public class MockBookingConfigsFetchXPkg extends nFORCE.ACrossPackageService {
		public MockBookingConfigsFetchXPkg() {
		}

		public virtual override void execute() {
			List<LLC_BI__Booking_Config__c> configs = [
				SELECT
					Id,
					LLC_BI__Product_Context_Id__c,
					LLC_BI__Category__c,
					Name
				FROM
					LLC_BI__Booking_Config__c
			];

			setOutputParameter('results', configs);
		}
	}

	public class MockCoreConfigAutoBook extends CoreConfigAutoBook {
		private override nFORCE.ACrossPackageService getBean(String beanName) {
			return new MockBookingConfigsFetchXPkg();
		}
	}

	private static String
		BOOK_ACTION_RESERVE = 'RESERVE',
		CORE_ENDPOINT_URL = 'Core_Endpoint_URL',
		CATEGORY_GENERIC = 'generic',
		CATEGORY_LOAN = 'loan',
		CATEGORY_LOAN_RETAIL = 'loan.retail',
		GENERIC_URL = 'testGenericUrl',
		KEY_CATEGORY = 'category',
		LOAN_URL = 'testLoanUrl',
		LOAN_RETAIL_URL = 'testLoanRetailUrl';
}