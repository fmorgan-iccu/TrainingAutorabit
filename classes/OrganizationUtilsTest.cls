@isTest
private with sharing class OrganizationUtilsTest {
    
	@isTest
    static void testGetOrganization() {
		Organization org = OrganizationUtils.getOrganizationInfo();

		// Not all fields are validated here because these are subject to change.
		System.assertEquals('Idaho Central Credit Union', org.name);
    }

}