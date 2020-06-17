@isTest
private class ObjectUtilsTest {

	@isTest(SeeAllData=true)
    static void testDescribeMethods() {
    	// Test the getRecordTypeId function.
    	Id dnaRecordTypeId = ObjectUtils.getRecordTypeId('Contact', 'DNA');
    	System.assertEquals(dnaRecordTypeId, [SELECT id FROM RecordType WHERE name = 'DNA' AND sObjectType = 'Contact'].id);
    	
		// Test the describe object instance functions.
		Account a = new Account(Name = 'Acme Inc.');
		insert a;
		String objectName = ObjectUtils.getObjectTypeName(a);
		System.assertEquals('Account', objectName);
    }

	@isTest
	static void testGetQualifiedPopulatedFieldsAsMap() {
		Account a = new Account(Name = 'Contact');
		insert a;
		Map<String, Object> qualifiedFields = ObjectUtils.getQualifiedPopulatedFieldsAsMap(a);
		System.assert(qualifiedFields.containsKey('Account.Name'));
		System.assertEquals(2, qualifiedFields.keySet().size());
	}

}