global virtual with sharing class CoreConfigAutoBook {
	private List<LLC_BI__Booking_Config__c> getBookingConfigs() {
		try {
			nFORCE.ACrossPackageService xpkg = getBean(BOOKING_CONFIGS_FETCH);

			if(xpkg != null) {
				xpkg.executeService();

				return (List<LLC_BI__Booking_Config__c>) xpkg.getOutputParameter(BOOKING_CONFIGS_FETCH_RESULTS);
			}

			return null;
		}
		catch(Exception e) {
			throw new XException(X_BOOKING_CONFIGS_FETCH_ERROR, e);
		}
	}

	@TestVisible
	private virtual nFORCE.ACrossPackageService getBean(String beanName) {
		return (nFORCE.ACrossPackageService) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(beanName);
	}

	global with sharing class Activator implements nFUSE.IPluginActivator {
		public CoreConfigAutoBook coreConfigInstance = new CoreConfigAutoBook();
		private List<String> usedCategories = new List<String>();

		public void onActivate() {
			createSystemProperties();
			createPluginProperties();
			registerServices();
		}

		public void onDeactivate() {
			deleteSystemProperties();
			deregisterServices();
		}

		private void registerServices() {
			nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(PLUGIN_NAME, PLUGIN_VERSION, null);
			new nFUSE.ServiceLocator().register(request, nFUSE.SendService.class, CoreConfigAutoBook.CoreConfigSendService.class);
		}

		private void deregisterServices() {
			nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(PLUGIN_NAME, PLUGIN_VERSION, null);
			new nFUSE.ServiceLocator().deregister(request, nFUSE.SendService.class);
		}

		private void createPluginProperties() {
			List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs =
				new List<nFUSE.PluginConfigurationManager.PluginConfiguration>();

			configs.addAll(createUrlAndApiProps('generic'));

			List<LLC_BI__Booking_Config__c> bookingConfigs = coreConfigInstance.getBookingConfigs();
			for(LLC_BI__Booking_Config__c bookingConfig : bookingConfigs) {
				if(!usedCategories.contains(bookingConfig.LLC_BI__Category__c)) {
					configs.addAll(createUrlAndApiProps(bookingConfig.LLC_BI__Category__c));
				}
			}

			new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION).softInsertConfigurations(configs);
		}

		private void createSystemProperties() {
			Map<String, nFORCE__System_Properties__c> propsMap = getSysPropsMap('atbk.generic', new Set<String> {KEY_PLUGIN_NAME, KEY_PLUGIN_VERSION});

			List<nFORCE__System_Properties__c> props = new List<nFORCE__System_Properties__c>();

			if(propsMap.containsKey(KEY_PLUGIN_NAME)) {
				nFORCE__System_Properties__c p = propsMap.get(KEY_PLUGIN_NAME);
				p.nFORCE__Value__c = PLUGIN_NAME;
				props.add(p);
			}
			else {
				props.add(createSysProp('atbk.generic', KEY_PLUGIN_NAME, PLUGIN_NAME));
			}

			if(propsMap.containsKey(KEY_PLUGIN_VERSION)) {
				nFORCE__System_Properties__c p = propsMap.get(KEY_PLUGIN_VERSION);
				p.nFORCE__Value__c = PLUGIN_VERSION;
				props.add(p);
			}
			else {
				props.add(createSysProp('atbk.generic', KEY_PLUGIN_VERSION, PLUGIN_VERSION));
			}

			nFORCE.DmlUtility.upsertObj(props);
		}

		private List<nFUSE.PluginConfigurationManager.PluginConfiguration> createUrlAndApiProps(String category) {
			List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs =
				new List<nFUSE.PluginConfigurationManager.PluginConfiguration>();

			configs.add(createConfig(getConfigKey('RESERVE', category, CONFIG_URL)));
			configs.add(createEncryptedConfig(getConfigKey('RESERVE', category, CONFIG_API_KEY)));
			configs.add(createConfig(getConfigKey('BOOK', category, CONFIG_URL)));
			configs.add(createEncryptedConfig(getConfigKey('BOOK', category, CONFIG_API_KEY)));

			usedCategories.add(category);
			return configs;
		}

		private void deleteSystemProperties() {
			List<nFORCE__System_Properties__c> props = getSysProps('atbk.generic', new Set<String> {KEY_PLUGIN_NAME, KEY_PLUGIN_VERSION});
			if(props != null && props.size() > 0) {
				nFORCE.DmlUtility.deleteObj(props);
			}
		}
	}

	global with sharing class CoreConfigSendService extends nFUSE.SendService {

		private List<nFUSE.PluginConfigurationManager.PluginConfiguration> properties;

		public protected override nFUSE.AMiddlewareMessage preSendSeam(nFUSE.AMiddlewareMessage m) {
			nFUSE.AMiddlewareMessage message = super.preSendSeam(m);
			String category = (String) message.properties.get(MESSAGE_KEY_CATEGORY);

			List<nFUSE.PluginConfigurationManager.PluginConfiguration> properties = getPluginProperties();

			Map<String, Object> configuredProperties = new Map<String, Object>();
			for(nFUSE.PluginConfigurationManager.PluginConfiguration config : properties) {
				if(isConfigKeyForAction(message.messageHeader.action, category, config.key)) {
					if(config.key.contains(CONFIG_API_KEY)) {
						configuredProperties.put(CONFIG_API_KEY, config.value);
					}
				}
			}

			message.properties.put(PLUGIN_NAME, configuredProperties);

			return message;
		}

		public protected override Object preSendRequest(Object request, nFUSE.AMiddlewareMessage message) {
			if(request instanceof HttpRequest) {
				HttpRequest httpReq = (HttpRequest) request;
				String category = (String) message.properties.get(MESSAGE_KEY_CATEGORY);

				String endpoint = getConfiguredEndpointUrl(message.messageHeader.action, category);
				httpReq.setEndpoint(endpoint);

				return httpReq;
			}
			else {
				throw new XException(X_HTTP_ERROR);
			}
		}

		private String getConfiguredEndpointUrl(String action, String category){
			List<String> bookingUrlKeys = getConfigKeys(action, category, CONFIG_URL);
			for(String bookingUrlKey : bookingUrlKeys) {
				nFUSE.PluginConfigurationManager.PluginConfiguration bookingUrl = getPluginProperty(bookingUrlKey);

				if (bookingUrl != null && bookingUrl.value != null) {
					return bookingUrl.value;
				}
			}
			throw new XException(X_BOOKING_CONFIGS_NOT_CONFIGURED);
		}

		private List<nFUSE.PluginConfigurationManager.PluginConfiguration> getPluginProperties() {
			if(properties == null) {
				properties = new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION).getConfigurations();
			}

			return properties;
		}

		private nFUSE.PluginConfigurationManager.PluginConfiguration getPluginProperty(String key) {
			getPluginProperties();

			for(nFUSE.PluginConfigurationManager.PluginConfiguration prop : properties) {
				if(prop.key == key) {
					return prop;
				}
			}

			return null;
		}
	}

	private class XException extends Exception {
	}

	private static nFORCE__System_Properties__c createSysProp(String category, String key, String value) {
		nFORCE__System_Properties__c sysProp = new nFORCE__System_Properties__c();
		sysProp.Name = new nFORCE.GuidGenerator().randomUUID();
		sysProp.nFORCE__Category_Name__c = category;
		sysProp.nFORCE__Key__c = key;
		sysProp.nFORCE__Value__c = value;

		return sysProp;
	}

	private static List<nFORCE__System_Properties__c> getSysProps(String category, Set<String> keys) {
		List<nFORCE__System_Properties__c> props = [
			SELECT Id, nFORCE__Key__c, nFORCE__Value__c
			FROM nFORCE__System_Properties__c
			WHERE nFORCE__Category_Name__c = :category
			AND nFORCE__Key__c in :keys
		];

		return props;
	}

	private static Map<String, nFORCE__System_Properties__c> getSysPropsMap(String category, Set<String> keys) {
		List<nFORCE__System_Properties__c> props = getSysProps(category, keys);

		Map<String, nFORCE__System_Properties__c> propsMap = new Map<String, nFORCE__System_Properties__c>();
		for(nFORCE__System_Properties__c p : props) {
			propsMap.put(p.nFORCE__Key__c, p);
		}

		return propsMap;
	}

	private static nFUSE.PluginConfigurationManager.PluginConfiguration createConfig(String key) {
		nFUSE.PluginConfigurationManager.PluginConfiguration prop = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		prop.key = key;
		prop.description = key;
		prop.isEncrypted = false;
		return prop;
	}

	private static nFUSE.PluginConfigurationManager.PluginConfiguration createEncryptedConfig(String key) {
		nFUSE.PluginConfigurationManager.PluginConfiguration prop = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		prop.key = key;
		prop.description = key;
		prop.isEncrypted = true;
		return prop;
	}

	private static String getConfigKey(String configuredAction, String configuredCategory, String key) {
		return configuredAction + ' ' + configuredCategory + ' ' + key;
	}

	private static List<String> getConfigKeys(String configuredAction, String configuredCategory, String key) {
		List<String> configKeys = new List<String>();
		String[] categories = configuredCategory.split('\\.');
		String categoryLevel = '';
		for(String category : categories){
			categoryLevel = categoryLevel == '' ? category : categoryLevel + '.' + category;
			if(configKeys.size() > 0) {
				configKeys.add(0, configuredAction + ' ' + categoryLevel + ' ' + key);
			} else {
				configKeys.add(configuredAction + ' ' + categoryLevel + ' ' + key);
			}
		}
		configKeys.add(configuredAction + ' ' + GENERIC_CATEGORY + ' ' + key);
		return configKeys;
	}

	private static Boolean isConfigKeyForAction(String configuredAction, String configuredCategory, String configKey) {
		return configKey.startsWith(configuredAction + ' ' + configuredCategory);
	}

	public static final String
		KEY_PLUGIN_NAME = 'pluginName',
		KEY_PLUGIN_VERSION = 'pluginVersion',
		PLUGIN_NAME = 'CoreConfig_AutoBook',
		PLUGIN_VERSION = '1.0',

		BOOKING_CONFIGS_FETCH = 'ATBK.BookingConfigsFetchXPkg',
		BOOKING_CONFIGS_FETCH_RESULTS = 'results',

		CONFIG_URL = 'Core_Endpoint_URL',
		CONFIG_API_KEY = 'Core_Client_API_Key',

		MESSAGE_KEY_CATEGORY = 'category',
		GENERIC_CATEGORY = 'generic',

		X_BOOKING_CONFIGS_FETCH_ERROR = 'Please ensure Automated Booking package is installed.',
		X_HTTP_ERROR = 'CoreConfig AutoBook Plugin expects a valid HttpRequest.',
		X_BOOKING_CONFIGS_NOT_CONFIGURED = 'Please ensure Booking Configs are properly configured. Verify endpoint urls are configured';
}