@IsTest
private class ObjectUtilsTest {

    @IsTest(SeeAllData=true)
    static void testDescribeMethods() {
        // Test the getRecordTypeId function.
        Id dnaRecordTypeId = ObjectUtils.getRecordTypeId('Contact', 'DNA');
        System.assertEquals(dnaRecordTypeId, [SELECT id FROM RecordType WHERE name = 'DNA' AND sObjectType = 'Contact'].id);

        // Test the describe object instance functions.
        Account a = new Account(Name = 'Acme Inc.');
        insert a;
        String objectName = ObjectUtils.getSObjectTypeName(a);
        System.assertEquals('Account', objectName);
    }

    @IsTest
    static void testGetObjectTypeName() {
        Integer x = 1;
        System.assertEquals('Integer', ObjectUtils.getObjectTypeName((Object)x));

        Set<String> a = new Set<String> {'a','b'};
        System.assertEquals('Set', ObjectUtils.getObjectTypeName((Object)a));

        Set<Id> b = new Set<Id>();
        System.assertEquals('Set', ObjectUtils.getObjectTypeName((Object)b));

        List<String> c = new List<String> {'a','b'};
        System.assertEquals('List', ObjectUtils.getObjectTypeName((Object)c));

        Account d = new Account();
        System.assertEquals('Account', ObjectUtils.getObjectTypeName((Object)d));

        Map<String,String> e = new Map<String,String> { 'test' => 'this' };
        System.assertEquals('Object', ObjectUtils.getObjectTypeName((Object)e));

        DNAAccount aoi = new DNAAccount();
        System.assertEquals('Object', ObjectUtils.getObjectTypeName(aoi));
    }

    @IsTest
    static void testGetQualifiedPopulatedFieldsAsMap() {
        Account a = new Account(Name = 'Contact');
        insert a;
        Map<String, Object> qualifiedFields = ObjectUtils.getQualifiedPopulatedFieldsAsMap(a);
        System.assert(qualifiedFields.containsKey('Account.Name'));
        System.assertEquals(2, qualifiedFields.keySet().size());
    }

}