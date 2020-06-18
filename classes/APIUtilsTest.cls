@IsTest
private class APIUtilsTest {
    @isTest
    private static void testObjecListMapping() {       
        List<Object> objectList = new List<Object>();
        Map<String,Object> mapObj = new Map<String,Object>();
        objectList.add(mapObj);

        List<Map<String, Object>> mapList = APIUtils.convertObjectList(objectList);
        System.assert(mapList != null);
        System.assert(mapList.size() == 1);
        
        List<Map<String, Object>> nullList = APIUtils.convertObjectList(null);
        System.assert(nullList != null);
        System.assert(nullList.size() == 0);
    }
    
    @IsTest
    private static void testWalkTreeToValueHappyPath() {
        Map<String, Object> root = new Map<String, Object> {
            'first' => new Map<String, Object> {
            	'second' => new Map<String, Object> {
                    'third' => new Map<String, Object> {}
        		}
        	}
        };
            
        List<String> paths = new List<String> {
            'first',
            'second',
            'third'
        };
            
        Map<String, Object> result = APIUtils.walkTreeToValue(root, paths);
        System.assert(result != null, 'Value was expected to be NOT null.');
    }
    
    @IsTest
    private static void testWalkTreeToValueUnhappyPath() {
        Map<String, Object> root = new Map<String, Object> {
            'first' => new Map<String, Object> {
            	'second' => new Map<String, Object> {
                    'third' => new Map<String, Object> {}
        		}
        	}
        };
            
        List<String> paths = new List<String> {
            'first',
            'fourth', // non-present value
            'third'
        };
            
        Map<String, Object> result = APIUtils.walkTreeToValue(root, paths);
        System.assert(result == null, 'Value was expected to be NULL, but was not.');
        
        result = APIUtils.walkTreeToValue(null, paths);
        System.assert(result == null, 'Result was expected to be NULL, but was not.');

        result = APIUtils.walkTreeToValue(root, null);
        System.assert(result == null, 'Result was expected to be NULL, but was not.');
    }
    
    @IsTest
    private static void testParseXMLNodeAttributes() {
        Dom.Document doc = new Dom.Document();
        
        Dom.XmlNode root = doc.createRootElement('name', 'namespace', null);
        Dom.XmlNode child = root.addChildElement ('name', 'namespace', null);
        child.setAttribute('key', 'keyNamespace');
        
        try {
            Map<String, String> attributes = APIUtils.parseXMLNodeAttributes(child);
            System.assert(attributes != null, 'Attributes were NULL!');
            
            String expected = 'keyNamespace';
            String actual = attributes.get('key');
            System.assertEquals(expected, actual);
            
            attributes = APIUtils.parseXMLNodeAttributes(null);
            
            System.assert(attributes != null, 'Attributes were unexpectedly null!');
        } catch (Exception e) {
            System.assert(false, 'Threw an exception while printing: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        
    }
    
    @IsTest
    private static void testPrintXMLNodes() {
        Dom.Document doc = new Dom.Document();
        
        Dom.XmlNode root = doc.createRootElement('name', 'namespace', null);
        Dom.XmlNode child = root.addChildElement ('name', 'namespace', null);
        child.setAttribute('key', 'keyNamespace');
        
        try {
            APIUtils.printNode(root, 0);
        } catch (Exception e) {
            System.assert(false, 'Threw an exception while printing: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
}