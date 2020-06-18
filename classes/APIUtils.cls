public class APIUtils {
	/**
     *  This method exists to convert List<Object> objects to List<Map<String, Object>> objects.
     *  For reasons that aren't clear, APEX's JSON parser interprets arrays of objects
     *  as List<Object> and a cast to List<Map<String, Object>> fails.  This function exists
     *  to clean up the object structure and make it cleaner and easier to work with.
     *  @param objectList The list of Object to convert
     *  @return A new List<Map<String, Object>>.
     */
    public static List<Map<String, Object>> convertObjectList(List<Object> objectList) {
        if (objectList == null) {
             return new List<Map<String, Object>>();
        }

        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        for (Object obj : objectList) {
            mapList.add((Map<String, Object>)obj);
        }

        return mapList;
    }

    /**
     * For a similar reason as convertObjectList.
     */
    public static List<String> convertStringList(List<Object> objectList) {
        if (objectList == null) {
            return new List<String>();
        }

        List<String> listOfStrings = new List<String>();
        for (Object obj : objectList) {
            listOfStrings.add((String)obj);
        }

        return listOfStrings;
    }
    
    /**
     * Recursive method for walking down a Map to get another Map.  Doesn't support going down arrays.
     * @param tree The Map to recursively walk
     * @param paths Array of key paths to walk
     * @return the map the matches the key path, or null if it wasn't found.
     */
    public static Map<String, Object> walkTreeToValue(Map<String, Object> tree, String[] paths) {
        if (tree == null || paths == null) {
            return null;
        }
        
        if (paths.size() == 0) { // Found what we needed, return the tree that was passed in
            return tree;
        }

        String pathKey = paths[0];

        Object obj = tree.get(pathKey);
        
        if (obj instanceof Map<String, Object>) {
            Map<String, Object> subTree = (Map<String, Object>)tree.get(pathKey);
            String[] subPaths = APIUtils.subArray(paths, 1); // get a new array that is a subarray of the first element.
            
            return APIUtils.walkTreeToValue(subTree, subPaths);
        } else {
            System.debug('walkTreeToValue was NOT a map! Path key: ' + pathKey + ' Object: ' + obj);
            return null;
        }
        
    }
    
    /**
     * Converts all the attributes of an XML node to a Map
     * @param node The XML node from which to get the attributes
     * 
     * Note: The key of the map is the name of the attribute (the namespace is discarded)
     */
    public static Map<String, String> parseXMLNodeAttributes(Dom.XmlNode node) {
        Map<String, String> attributes = new Map<String, String>();
        
        if (node == null) {
            return attributes;
        }
        
        Integer attribCount = node.getAttributeCount();
        for (integer index = 0; index < attribCount; index++) {
            String attribKey = node.getAttributeKeyAt(index);
            String attribKeyNs = node.getAttributeKeyNsAt(index);
            String attribValue = node.getAttributeValue(attribKey, attribKeyNs);
            
            attributes.put(attribKey, attribValue);
        }

        return attributes;
    }
    
    /**
     * Debug utility for recursively printing the children of an XML node
     * @param node The XML node to recursively print to the debug console
     */
    public static void printNode(Dom.XMLNode node, Integer indentLevel) {
        if (node == null) {
            System.debug('>>>>>> node was null!');
        }
        
        String indent = '';
        
        for (Integer i = 0; i < indentLevel; i++) {
            indent += '____';
        }

        System.debug(indent + node.getNamespace() + ':' + node.getName());
        
        integer attributeCount = node.getAttributeCount();
            
        for (integer i = 0; i < attributeCount; i++) {
            String key = node.getAttributeKeyAt(i);
            String ns = node.getAttributeKeyNsAt(i);
            String value = node.getAttributeValue(key, ns);

            String attributeIndent = indent + '@';
            
            System.debug(attributeIndent + ns + ':' + key + '=' + value);
        }
        
        for (Dom.XMLNode child : node.getChildElements()) {
            printNode(child, indentLevel + 1);
        }
    }
    
    /**
     * Utility method for subarraying
     */
    private static List<String> subArray(List<String> dataList, Integer startIndex) {
        List<String> subArray = new List<String>();
        for (Integer i = startIndex; i < dataList.size(); i++) {
            subArray.add(dataList[i]);
        }
        
        return subArray;
    }
}