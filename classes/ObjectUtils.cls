public with sharing class ObjectUtils {

    public static final Integer MAX_TEXT_FIELD_LENGTH = 131072;

    /**
     * Retrieves the record type Id for the object and type name.
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
    public static String getSObjectTypeName(sObject obj) {
        String objectName = obj.getSObjectType().getDescribe().getName();
        return objectName;
    }

    /**
     * Used to dynamically determine the type of an object
     */
    public static string getObjectTypeName(Object o) {
        if (o == null) return null;

        // Check for basic types
        if (o instanceof Id) return 'Id';
        if (o instanceof String) return 'String';
        if (o instanceof Boolean) return 'Boolean';
        if (o instanceof Integer) return 'Integer';
        if (o instanceof Double) return 'Double'; // Salesforce can't differentiate between Double/Decimal; use Double!
        if (o instanceof Date) return 'Date';
        if (o instanceof Datetime) return 'Datetime';
        if (o instanceof Time) return 'Time';
        if (o instanceof Blob) return 'Blob';
        if (o instanceof Long) return 'Long';
        if (o instanceof List<Object>) return 'List';

        // For Set objects, instanceof Set<Object> doesn't work.  So, detect some of the common cases.
        if (o instanceof Set<String> ||
            o instanceof Set<Id> ||
            o instanceof Set<Integer> ||
            o instanceof Set<Date> ||
            o instanceof Set<Datetime>)
        {
            return 'Set';
        }

        // Try to cast the value to an SObject and retrieve the type name.
        try {
            if (o instanceof SObject) {
                return ObjectUtils.getSObjectTypeName((SObject)o);
            }
        } catch (Exception e) {
            // Ignore this
        }

        return 'Object';
    }

    /**
     * Given an sObject, returns all of the populated fields with an object qualification.
     * For example, an Account instance will yield:
     * { 'account.name': 'Acme Inc.', ... }
     * @param  obj The object to return the qualified fields for.
     * @return     The map from the qualified name to the value.
     */
    public static Map<String, Object> getQualifiedPopulatedFieldsAsMap(sObject obj) {
        String objectName = getSObjectTypeName(obj);
        Map<String, Object> fieldMap = obj.getPopulatedFieldsAsMap();

        Map<String, Object> qualifiedFieldMap = new Map<String, Object>();
        Set<String> fieldNames = fieldMap.keySet();
        for (String fieldName : fieldNames) {
            qualifiedFieldMap.put(objectName + '.' + fieldName, fieldMap.get(fieldName));
        }

        return qualifiedFieldMap;
    }

}