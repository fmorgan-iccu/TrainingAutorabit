public with sharing class ObjectUtils {

	
	/* Retrieves the record type Id for the object and type name.
	 */
	public static Id getRecordTypeId(String objectName, String recordTypeName) {
		Schema.DescribeSObjectResult describedObj = Schema.getGlobalDescribe().get(objectname).getDescribe();
		return (Id)describedObj.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
	}

	/**
	 * Given an instance of an sObject, determines the type name of the object.
	 * NOTE:  Use the "instanceof" operator when doing type checking.  Only use this when the
	 * actual name is needed.
	 * @param  obj The sObject that will be described.
	 * @return     The type name of the object (e.g. Account, Contact, etc.)
	 */
	public static String getObjectTypeName(sObject obj) {
		Schema.SObjectType sObjType = obj.getSObjectType();
		Schema.DescribeSObjectResult describedObj = sObjType.getDescribe();
		String objectName = describedObj.getName();

		return objectName;
	}

	/**
	 * Given an sObject, returns all of the populated fields with an object qualification.
	 * For example, an Account instance will yield:
	 * { 'account.name': 'Acme Inc.', ... }
	 * @param  obj The object to return the qualified fields for.
	 * @return     The map from the qualified name to the value.
	 */
	public static Map<String, Object> getQualifiedPopulatedFieldsAsMap(sObject obj) {
		String objectName = getObjectTypeName(obj);
		Map<String, Object> fieldMap = obj.getPopulatedFieldsAsMap();

		Map<String, Object> qualifiedFieldMap = new Map<String, Object>();
		Set<String> fieldNames = fieldMap.keySet();
		for (String fieldName : fieldNames) {
			qualifiedFieldMap.put(objectName + '.' + fieldName, fieldMap.get(fieldName));
		}

		return qualifiedFieldMap;
	}

}